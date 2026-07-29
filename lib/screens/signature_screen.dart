import 'dart:io';
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class SignatureScreen extends StatefulWidget {
  const SignatureScreen({super.key});

  @override
  State<SignatureScreen> createState() => _SignatureScreenState();
}

class _SignatureScreenState extends State<SignatureScreen> {
  final _controller = SignatureController(penStrokeWidth: 3, penColor: Colors.black);
  bool _saving = false;

  Future<void> _save() async {
    if (_controller.isEmpty) return;
    setState(() => _saving = true);
    try {
      final bytes = await _controller.toPngBytes();
      if (bytes == null) return;
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/signature_${const Uuid().v4()}.png');
      await file.writeAsBytes(bytes);
      if (mounted) Navigator.pop(context, file.path);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Signature'),
        actions: [
          IconButton(icon: const Icon(Icons.clear), onPressed: _controller.clear),
          IconButton(
            icon: _saving
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.check),
            onPressed: _saving ? null : _save,
          ),
        ],
      ),
      body: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400)),
        child: Signature(controller: _controller, backgroundColor: Colors.white),
      ),
    );
  }
}
