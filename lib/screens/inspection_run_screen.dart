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
        return Colors.green;
      case ItemStatus.fail:
        return Colors.red;
      case ItemStatus.na:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final subtitleParts = [_inspection.clientName, _inspection.propertyAddress]
        .where((s) => s.isNotEmpty)
        .join(' · ');
    return Scaffold(
      appBar: AppBar(title: Text(_inspection.templateName)),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          if (subtitleParts.isNotEmpty) ...[
            Text(subtitleParts, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 12),
          ],
          for (int i = 0; i < _inspection.items.length; i++)
            Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_inspection.items[i].label,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      children: ItemStatus.values.map((s) {
                        final selected = _inspection.items[i].status == s;
                        return ChoiceChip(
                          label: Text(s.name.toUpperCase()),
                          selected: selected,
                          selectedColor: _statusColor(s).withOpacity(0.25),
                          onSelected: (_) {
                            setState(() => _inspection.items[i].status = s);
                            _persist();
                          },
                        );
                      }).toList(),
                    ),
                    TextField(
                      decoration: const InputDecoration(hintText: 'Note (optional)'),
                      controller: _noteControllers[i],
                      onChanged: (v) => _inspection.items[i].note = v,
                      onEditingComplete: _persist,
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
                  icon: const Icon(Icons.add_a_photo),
                  label: Text('Photos (${_inspection.photoPaths.length})'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _addSignature,
                  icon: const Icon(Icons.draw),
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
                            borderRadius: BorderRadius.circular(6),
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
                : const Icon(Icons.picture_as_pdf),
            label: const Text('Generate PDF Report'),
          ),
        ],
      ),
    );
  }
}
