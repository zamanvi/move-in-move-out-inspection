import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

class _HomeScreenState extends State<HomeScreen> {
  List<Inspection> _inspections = [];

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() => _inspections = StorageService.getInspections());
  }

  int _failCount(Inspection i) => i.items.where((item) => item.status == ItemStatus.fail).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inspection Reports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.checklist),
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
            icon: const Icon(Icons.settings),
            tooltip: 'Company Branding',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BrandingSettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: _inspections.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No inspections yet.\nTap + to start your first report.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            )
          : ListView.builder(
              itemCount: _inspections.length,
              itemBuilder: (context, index) {
                final i = _inspections[index];
                final label = i.clientName.isEmpty ? i.propertyAddress : i.clientName;
                return Dismissible(
                  key: ValueKey(i.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
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
                  child: ListTile(
                    leading: const Icon(Icons.description_outlined),
                    title: Text(i.templateName),
                    subtitle: Text(
                      label.isEmpty
                          ? DateFormat.yMMMd().format(i.date)
                          : '$label · ${DateFormat.yMMMd().format(i.date)}',
                    ),
                    trailing: _failCount(i) > 0
                        ? Chip(
                            label: Text('${_failCount(i)} failed'),
                            backgroundColor: Colors.red.shade50,
                            labelStyle: TextStyle(color: Colors.red.shade700, fontSize: 12),
                            visualDensity: VisualDensity.compact,
                          )
                        : null,
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => InspectionRunScreen(inspection: i)),
                      );
                      _refresh();
                    },
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
