import 'dart:io';
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/storage_service.dart';
import '../services/pdf_service.dart';
import 'photo_annotate_screen.dart';
import 'signature_screen.dart';
import 'report_preview_screen.dart';

class InspectionRunScreen extends StatefulWidget {
  final Inspection inspection;
  const InspectionRunScreen({super.key, required this.inspection});

  @override
  State<InspectionRunScreen> createState() => _InspectionRunScreenState();
}

class _InspectionRunScreenState extends State<InspectionRunScreen> {
  late Inspection _inspection;
  late List<TextEditingController> _noteControllers;
  bool _generating = false;

  @override
  void initState() {
    super.initState();
    _inspection = widget.inspection;
    _noteControllers =
        _inspection.items.map((item) => TextEditingController(text: item.note)).toList();
  }

  @override
  void dispose() {
    for (final c in _noteControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _persist() => StorageService.saveInspection(_inspection);

  Future<void> _addPhoto() async {
    final path = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const PhotoAnnotateScreen()),
    );
    if (path != null) {
      setState(() => _inspection.photoPaths = [..._inspection.photoPaths, path]);
      await _persist();
    }
  }

  Future<void> _addSignature() async {
    final path = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const SignatureScreen()),
    );
    if (path != null) {
      setState(() => _inspection.signaturePath = path);
      await _persist();
    }
  }

  Future<void> _generateReport() async {
    setState(() => _generating = true);
    try {
      final branding = StorageService.getBranding();
      final file = await PdfService.generateReport(_inspection, branding);
      await _persist();
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ReportPreviewScreen(pdfFile: file)),
        );
      }
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  Color _statusColor(ItemStatus s) {
    switch (s) {
      case ItemStatus.pass:
        return const Color(0xFF3E7C59);
      case ItemStatus.fail:
        return const Color(0xFFC7402D);
      case ItemStatus.na:
        return Colors.grey.shade400;
    }
  }

  @override
  Widget build(BuildContext context) {
    final subtitleParts = [_inspection.clientName, _inspection.propertyAddress]
        .where((s) => s.isNotEmpty)
        .join(' · ');
    final total = _inspection.items.length;
    final completed = _inspection.items.where((i) => i.status != ItemStatus.na).length;
    final failed = _inspection.items.where((i) => i.status == ItemStatus.fail).length;

    return Scaffold(
      appBar: AppBar(title: Text(_inspection.templateName)),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          if (subtitleParts.isNotEmpty) ...[
            Text(subtitleParts, style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 8),
          ],
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('$completed of $total reviewed',
                          style: Theme.of(context).textTheme.titleMedium),
                      if (failed > 0)
                        Text('$failed failed',
                            style: TextStyle(
                                color: Colors.red.shade600,
                                fontWeight: FontWeight.w600,
                                fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: total == 0 ? 0 : completed / total,
                      minHeight: 8,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation(Theme.of(context).colorScheme.primary),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          for (int i = 0; i < _inspection.items.length; i++)
            Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              clipBehavior: Clip.antiAlias,
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(width: 5, color: _statusColor(_inspection.items[i].status)),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_inspection.items[i].label,
                                style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: ItemStatus.values.map((s) {
                                final selected = _inspection.items[i].status == s;
                                final color = _statusColor(s);
                                return ChoiceChip(
                                  label: Text(
                                    s.name.toUpperCase(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                      color: selected ? color : Colors.grey.shade700,
                                    ),
                                  ),
                                  selected: selected,
                                  showCheckmark: false,
                                  backgroundColor: Colors.grey.shade100,
                                  selectedColor: color.withOpacity(0.14),
                                  side: BorderSide(
                                    color: selected ? color : Colors.grey.shade300,
                                    width: selected ? 1.4 : 1,
                                  ),
                                  onSelected: (_) {
                                    setState(() => _inspection.items[i].status = s);
                                    _persist();
                                  },
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              decoration: const InputDecoration(hintText: 'Add a note (optional)'),
                              controller: _noteControllers[i],
                              onChanged: (v) => _inspection.items[i].note = v,
                              onEditingComplete: _persist,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _addPhoto,
                  icon: const Icon(Icons.add_a_photo_outlined),
                  label: Text('Photos (${_inspection.photoPaths.length})'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _addSignature,
                  icon: const Icon(Icons.draw_outlined),
                  label: Text(_inspection.signaturePath == null ? 'Signature' : 'Signed ✓'),
                ),
              ),
            ],
          ),
          if (_inspection.photoPaths.isNotEmpty) ...[
            const SizedBox(height: 8),
            SizedBox(
              height: 80,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: _inspection.photoPaths
                    .map((p) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(File(p), width: 80, height: 80, fit: BoxFit.cover),
                          ),
                        ))
                    .toList(),
              ),
            ),
          ],
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _generating ? null : _generateReport,
            icon: _generating
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.picture_as_pdf_outlined),
            label: const Text('Generate PDF Report'),
          ),
        ],
      ),
    );
  }
}
