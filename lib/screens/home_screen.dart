import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../main.dart';
import '../models/models.dart';
import '../services/storage_service.dart';
import 'new_inspection_screen.dart';
import 'inspection_run_screen.dart';
import 'templates_screen.dart';
import 'branding_settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RouteAware {
  List<Inspection> _inspections = [];

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  // Called every time this screen becomes visible again after a nested
  // route pops - covers pushReplacement chains (New Inspection -> Run
  // Inspection) where a single awaited Navigator.push in this screen
  // would otherwise resolve too early and miss the freshly saved report.
  @override
  void didPopNext() {
    _refresh();
  }

  void _refresh() {
    setState(() => _inspections = StorageService.getInspections());
  }

  int _failCount(Inspection i) => i.items.where((item) => item.status == ItemStatus.fail).length;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inspection Reports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.checklist_rounded),
            tooltip: 'Checklist Templates',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TemplatesScreen()),
              );
              _refresh();
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Company Branding',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BrandingSettingsScreen()),
              );
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: _inspections.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.fact_check_outlined, size: 44, color: colorScheme.primary),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'No inspections yet',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(color: Colors.grey.shade800),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Tap "New Inspection" below to create\nyour first report.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade500, height: 1.4),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
              itemCount: _inspections.length,
              itemBuilder: (context, index) {
                final i = _inspections[index];
                final label = i.clientName.isEmpty ? i.propertyAddress : i.clientName;
                final fails = _failCount(i);
                return Dismissible(
                  key: ValueKey(i.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.red.shade400,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete_outline, color: Colors.white),
                  ),
                  confirmDismiss: (_) => showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Delete inspection?'),
                      content: const Text('This report will be permanently deleted.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  ),
                  onDismissed: (_) async {
                    await StorageService.deleteInspection(i.id);
                    _refresh();
                  },
                  child: Card(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => InspectionRunScreen(inspection: i)),
                        );
                        _refresh();
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: colorScheme.primary.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(Icons.description_outlined,
                                  color: colorScheme.primary, size: 22),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(i.templateName,
                                      style: Theme.of(context).textTheme.titleMedium),
                                  const SizedBox(height: 2),
                                  Text(
                                    label.isEmpty
                                        ? DateFormat.yMMMd().format(i.date)
                                        : '$label · ${DateFormat.yMMMd().format(i.date)}',
                                    style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            if (fails > 0) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '$fails failed',
                                  style: TextStyle(
                                    color: Colors.red.shade700,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                            ],
                            Icon(Icons.chevron_right, color: Colors.grey.shade400),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('New Inspection'),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NewInspectionScreen()),
          );
          _refresh();
        },
      ),
    );
  }
}
