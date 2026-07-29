import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/storage_service.dart';

class TemplateEditorScreen extends StatefulWidget {
  final ChecklistTemplate template;
  const TemplateEditorScreen({super.key, required this.template});

  @override
  State<TemplateEditorScreen> createState() => _TemplateEditorScreenState();
}

class _TemplateEditorScreenState extends State<TemplateEditorScreen> {
  late TextEditingController _nameController;
  late List<TextEditingController> _itemControllers;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.template.name);
    _itemControllers = widget.template.items.map((e) => TextEditingController(text: e)).toList();
  }

  @override
  void dispose() {
    _nameController.dispose();
    for (final c in _itemControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addItem() => setState(() => _itemControllers.add(TextEditingController()));

  void _removeItem(int index) => setState(() => _itemControllers.removeAt(index));

  Future<void> _save() async {
    widget.template.name = _nameController.text.trim().isEmpty ? 'Untitled Checklist' : _nameController.text.trim();
    widget.template.items = _itemControllers
        .map((c) => c.text.trim())
        .where((t) => t.isNotEmpty)
        .toList();
    await StorageService.saveTemplate(widget.template);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Checklist'),
        actions: [IconButton(icon: const Icon(Icons.check), onPressed: _save)],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Checklist Name'),
          ),
          const SizedBox(height: 16),
          const Text('Items', style: TextStyle(fontWeight: FontWeight.bold)),
          for (int i = 0; i < _itemControllers.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _itemControllers[i],
                      decoration: InputDecoration(hintText: 'Item ${i + 1}'),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: () => _removeItem(i),
                  ),
                ],
              ),
            ),
          TextButton.icon(
            onPressed: _addItem,
            icon: const Icon(Icons.add),
            label: const Text('Add Item'),
          ),
        ],
      ),
    );
  }
}
