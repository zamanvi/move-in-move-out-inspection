import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../services/storage_service.dart';
import 'inspection_run_screen.dart';

class NewInspectionScreen extends StatefulWidget {
  const NewInspectionScreen({super.key});

  @override
  State<NewInspectionScreen> createState() => _NewInspectionScreenState();
}

class _NewInspectionScreenState extends State<NewInspectionScreen> {
  final _clientController = TextEditingController();
  final _addressController = TextEditingController();
  ChecklistTemplate? _selected;
  late List<ChecklistTemplate> _templates;

  @override
  void initState() {
    super.initState();
    _templates = StorageService.getTemplates();
    if (_templates.isNotEmpty) _selected = _templates.first;
  }

  void _start() {
    if (_selected == null) return;
    final inspection = Inspection(
      id: const Uuid().v4(),
      templateName: _selected!.name,
      clientName: _clientController.text.trim(),
      propertyAddress: _addressController.text.trim(),
      date: DateTime.now(),
      items: _selected!.items.map((label) => InspectionItem(label: label)).toList(),
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => InspectionRunScreen(inspection: inspection)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Inspection')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<ChecklistTemplate>(
            value: _selected,
            decoration: const InputDecoration(labelText: 'Checklist Type'),
            items: _templates
                .map((t) => DropdownMenuItem(value: t, child: Text(t.name)))
                .toList(),
            onChanged: (v) => setState(() => _selected = v),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _clientController,
            decoration: const InputDecoration(labelText: 'Client Name'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _addressController,
            decoration: const InputDecoration(labelText: 'Property Address'),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _selected == null ? null : _start,
            child: const Padding(
              padding: EdgeInsets.all(12),
              child: Text('Start Inspection'),
            ),
          ),
        ],
      ),
    );
  }
}
