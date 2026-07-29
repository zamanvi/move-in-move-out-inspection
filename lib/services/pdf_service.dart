import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '../models/models.dart';

class PdfService {
  static Future<File> generateReport(Inspection inspection, BrandingSettings branding) async {
    final doc = pw.Document();

    pw.MemoryImage? logoImage;
    if (branding.logoPath != null && File(branding.logoPath!).existsSync()) {
      logoImage = pw.MemoryImage(File(branding.logoPath!).readAsBytesSync());
    }

    final photoImages = <pw.MemoryImage>[];
    for (final path in inspection.photoPaths) {
      final f = File(path);
      if (f.existsSync()) photoImages.add(pw.MemoryImage(f.readAsBytesSync()));
    }

    pw.MemoryImage? signatureImage;
    if (inspection.signaturePath != null && File(inspection.signaturePath!).existsSync()) {
      signatureImage = pw.MemoryImage(File(inspection.signaturePath!).readAsBytesSync());
    }

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        build: (context) => [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    branding.companyName.isEmpty ? 'Inspection Report' : branding.companyName,
                    style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
                  ),
                  if (branding.contactInfo.isNotEmpty)
                    pw.Text(branding.contactInfo, style: const pw.TextStyle(fontSize: 10)),
                ],
              ),
              if (logoImage != null) pw.Image(logoImage, width: 60, height: 60),
            ],
          ),
          pw.SizedBox(height: 16),
          pw.Text(inspection.templateName,
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Text('Client: ${inspection.clientName}'),
          pw.Text('Property: ${inspection.propertyAddress}'),
          pw.Text('Date: ${inspection.date.toLocal().toString().split(' ').first}'),
          pw.SizedBox(height: 16),
          pw.Table(
            border: pw.TableBorder.all(width: 0.5, color: PdfColors.grey400),
            columnWidths: const {
              0: pw.FlexColumnWidth(3),
              1: pw.FlexColumnWidth(1),
              2: pw.FlexColumnWidth(3),
            },
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  _cell('Item', bold: true),
                  _cell('Status', bold: true),
                  _cell('Notes', bold: true),
                ],
              ),
              ...inspection.items.map(
                (item) => pw.TableRow(children: [
                  _cell(item.label),
                  _cell(item.status.name.toUpperCase()),
                  _cell(item.note),
                ]),
              ),
            ],
          ),
          if (inspection.generalNotes.isNotEmpty) ...[
            pw.SizedBox(height: 12),
            pw.Text('Additional Notes', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text(inspection.generalNotes),
          ],
          if (photoImages.isNotEmpty) ...[
            pw.SizedBox(height: 16),
            pw.Text('Photos', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            pw.Wrap(
              spacing: 8,
              runSpacing: 8,
              children: photoImages
                  .map((img) => pw.Container(
                        width: 150,
                        height: 150,
                        child: pw.Image(img, fit: pw.BoxFit.cover),
                      ))
                  .toList(),
            ),
          ],
          pw.SizedBox(height: 24),
          if (signatureImage != null) ...[
            pw.Text('Inspector Signature', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Container(height: 80, child: pw.Image(signatureImage)),
          ],
          if (branding.terms.isNotEmpty) ...[
            pw.SizedBox(height: 16),
            pw.Divider(),
            pw.Text(branding.terms, style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
          ],
        ],
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/report_${inspection.id}.pdf');
    await file.writeAsBytes(await doc.save());
    return file;
  }

  static pw.Widget _cell(String text, {bool bold = false}) => pw.Padding(
        padding: const pw.EdgeInsets.all(4),
        child: pw.Text(
          text,
          style: pw.TextStyle(fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal),
        ),
      );
}
