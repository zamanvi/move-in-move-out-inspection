import 'dart:io';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

class ReportPreviewScreen extends StatelessWidget {
  final File pdfFile;
  const ReportPreviewScreen({super.key, required this.pdfFile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Preview'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => Share.shareXFiles([XFile(pdfFile.path)], text: 'Inspection Report'),
          ),
        ],
      ),
      body: PdfPreview(
        build: (format) => pdfFile.readAsBytes(),
        canChangeOrientation: false,
        canChangePageFormat: false,
        allowSharing: false,
      ),
    );
  }
}
