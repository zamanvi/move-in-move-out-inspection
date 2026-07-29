import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class PhotoAnnotateScreen extends StatefulWidget {
  const PhotoAnnotateScreen({super.key});

  @override
  State<PhotoAnnotateScreen> createState() => _PhotoAnnotateScreenState();
}

class _PhotoAnnotateScreenState extends State<PhotoAnnotateScreen> {
  File? _image;
  final List<List<Offset>> _strokes = [];
  final GlobalKey _boundaryKey = GlobalKey();
  bool _saving = false;

  Future<void> _pickImage(ImageSource source) async {
    final picked = await ImagePicker().pickImage(source: source, imageQuality: 85);
    if (picked != null) {
      setState(() {
        _image = File(picked.path);
        _strokes.clear();
      });
    }
  }

  Future<void> _save() async {
    if (_image == null) return;
    setState(() => _saving = true);
    try {
      final boundary =
          _boundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final img = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/photo_${const Uuid().v4()}.png');
      await file.writeAsBytes(bytes);
      if (mounted) Navigator.pop(context, file.path);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Photo'),
        actions: [
          if (_image != null)
            IconButton(
              icon: _saving
                  ? const SizedBox(
                      width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.check),
              onPressed: _saving ? null : _save,
            ),
        ],
      ),
      body: _image == null
          ? Center(
              child: Wrap(
                spacing: 16,
                children: [
                  FilledButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Camera'),
                  ),
                  FilledButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(8),
                  child: Text('Drag your finger to mark up defects on the photo'),
                ),
                Expanded(
                  child: RepaintBoundary(
                    key: _boundaryKey,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.file(_image!, fit: BoxFit.contain),
                        GestureDetector(
                          onPanStart: (d) => setState(() => _strokes.add([d.localPosition])),
                          onPanUpdate: (d) => setState(() => _strokes.last.add(d.localPosition)),
                          child: CustomPaint(painter: _AnnotationPainter(_strokes)),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: TextButton.icon(
                    onPressed: () => setState(() => _strokes.clear()),
                    icon: const Icon(Icons.undo),
                    label: const Text('Clear Markup'),
                  ),
                ),
              ],
            ),
    );
  }
}

class _AnnotationPainter extends CustomPainter {
  final List<List<Offset>> strokes;
  _AnnotationPainter(this.strokes);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    for (final stroke in strokes) {
      for (int i = 0; i < stroke.length - 1; i++) {
        canvas.drawLine(stroke[i], stroke[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _AnnotationPainter oldDelegate) => true;
}
