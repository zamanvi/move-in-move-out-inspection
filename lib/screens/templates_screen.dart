import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../services/storage_service.dart';
import 'template_editor_screen.dart';

class TemplatesScreen extends StatefulWidget {
  const TemplatesScreen({super.key});

  @override
  State<TemplatesScreen> createState() => _TemplatesScreenState();
}

class _TemplatesScreenState extends State<TemplatesScreen> {
  List<ChecklistTemplate> _templates = [];

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() => setState(() => _templates = StorageService.getTemplates());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checklist Templates')),
      body: ListView.builder(
        itemCount: _templates.length,
        itemBuilder: (context, index) {
          final t = _templates[index];
          return ListTile(
            title: Text(t.name),
            subtitle: Text('${t.items.length} items'),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                await StorageService.deleteTemplate(t.id);
                _refresh();
              },
            ),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => TemplateEditorScreen(template: t)),
              );
              _refresh();
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final newTemplate = ChecklistTemplate(id: const Uuid().v4(), name: 'New Checklist', items: []);
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => TemplateEditorScreen(template: newTemplate)),
          );
          _refresh();
        },
      ),
    );
  }
}
