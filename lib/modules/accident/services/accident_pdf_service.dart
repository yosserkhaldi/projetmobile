import 'dart:io';

import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'package:mon_constat_digital/modules/accident/models/accident_draft.dart';

class AccidentPdfService {
  Future<Uint8List> build(AccidentDraft draft) async {
    final regular = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Manrope-500.ttf'),
    );
    final bold = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Manrope-700.ttf'),
    );
    final document = pw.Document(
      title: 'Constat amiable - ${draft.place}',
      author: 'Mon Constat Digital',
      creator: 'Mon Constat Digital',
      theme: pw.ThemeData.withFont(base: regular, bold: bold),
    );
    final photos = await _loadPhotos(draft);

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => _header(context),
        footer: (context) => _footer(context),
        build: (_) => [
          pw.SizedBox(height: 12),
          _title('Informations sur l’accident'),
          _table([
            ('Lieu', draft.place),
            ('Coordonnées GPS', _coordinates(draft)),
            ('Date et heure', _dateTime(draft.occurredAt)),
            ('Type / gravité', '${draft.type} • ${draft.severity}'),
            ('Conditions', '${draft.weather} • ${draft.road} • ${draft.light}'),
            (
              'Véhicules / blessés',
              '${draft.vehicleCount} / ${draft.injuredCount}',
            ),
            ('Témoin', _join([draft.witnessName, draft.witnessPhone])),
          ]),
          _title('Conducteur B'),
          _table([
            ('Nom', draft.driverBName),
            ('Permis', draft.driverBPermit),
            ('Validité du permis', draft.driverBPermitExpiry),
            ('Immatriculation', draft.driverBPlate),
            ('Assurance', draft.driverBInsurer),
          ]),
          _title('Circonstances et observations'),
          _table([
            ('Conducteur A', draft.circumstancesA.join(', ')),
            ('Conducteur B', draft.circumstancesB.join(', ')),
            ('Zones de choc', draft.impactZones.join(', ')),
            ('Observations', draft.observations),
          ]),
          if (photos.isNotEmpty) ...[
            _title('Preuves photographiques'),
            pw.Wrap(
              spacing: 10,
              runSpacing: 10,
              children: photos
                  .map(
                    (photo) => pw.Container(
                      width: 245,
                      padding: const pw.EdgeInsets.all(6),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.grey300),
                        borderRadius: pw.BorderRadius.circular(6),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Image(
                            pw.MemoryImage(photo.bytes),
                            height: 130,
                            width: 233,
                            fit: pw.BoxFit.cover,
                          ),
                          pw.SizedBox(height: 5),
                          pw.Text(
                            photo.label,
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
          _title('Croquis de l’accident'),
          _drawing(draft.sketchStrokes, height: 190, empty: 'Aucun croquis'),
          _title('Signatures'),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: _signature('Conducteur A', draft.driverASignature),
              ),
              pw.SizedBox(width: 14),
              pw.Expanded(
                child: _signature('Conducteur B', draft.driverBSignature),
              ),
            ],
          ),
          pw.SizedBox(height: 18),
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            color: PdfColor.fromHex('#E8F0FF'),
            child: pw.Text(
              'Document généré par Mon Constat Digital le ${_dateTime(DateTime.now())}. '
              'Les informations et signatures ci-dessus proviennent de la déclaration validée par les conducteurs.',
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
            ),
          ),
        ],
      ),
    );
    return document.save();
  }

  Future<void> preview(AccidentDraft draft) async {
    final bytes = await build(draft);
    await Printing.layoutPdf(
      name: _fileName(draft),
      onLayout: (_) async => bytes,
    );
  }

  Future<void> share(AccidentDraft draft) async {
    await Printing.sharePdf(
      bytes: await build(draft),
      filename: _fileName(draft),
    );
  }

  pw.Widget _header(pw.Context context) => pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
    children: [
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'MON CONSTAT DIGITAL',
            style: pw.TextStyle(
              color: PdfColor.fromHex('#2140B8'),
              fontSize: 17,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.Text('Constat amiable d’accident automobile'),
        ],
      ),
      pw.Text('Page ${context.pageNumber}/${context.pagesCount}'),
    ],
  );

  pw.Widget _footer(pw.Context context) => pw.Container(
    margin: const pw.EdgeInsets.only(top: 12),
    padding: const pw.EdgeInsets.only(top: 6),
    decoration: const pw.BoxDecoration(
      border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300)),
    ),
    child: pw.Text(
      'Mon Constat Digital • document récapitulatif',
      style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
    ),
  );

  pw.Widget _title(String text) => pw.Container(
    margin: const pw.EdgeInsets.only(top: 16, bottom: 7),
    padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 7),
    color: PdfColor.fromHex('#0B172A'),
    child: pw.Text(
      text,
      style: pw.TextStyle(
        color: PdfColors.white,
        fontWeight: pw.FontWeight.bold,
      ),
    ),
  );

  pw.Widget _table(List<(String, String)> rows) => pw.Table(
    border: pw.TableBorder.all(color: PdfColors.grey300, width: .6),
    columnWidths: const {0: pw.FixedColumnWidth(145), 1: pw.FlexColumnWidth()},
    children: rows
        .map(
          (row) => pw.TableRow(
            children: [
              pw.Container(
                color: PdfColors.grey100,
                padding: const pw.EdgeInsets.all(7),
                child: pw.Text(
                  row.$1,
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(7),
                child: pw.Text(
                  row.$2.trim().isEmpty ? 'Non renseigné' : row.$2,
                ),
              ),
            ],
          ),
        )
        .toList(),
  );

  pw.Widget _signature(String label, List<List<Map<String, double>>> strokes) =>
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 5),
          _drawing(strokes, height: 90, empty: 'Signature absente'),
        ],
      );

  pw.Widget _drawing(
    List<List<Map<String, double>>> strokes, {
    required double height,
    required String empty,
  }) => pw.Container(
    width: double.infinity,
    height: height,
    decoration: pw.BoxDecoration(
      color: PdfColors.white,
      border: pw.Border.all(color: PdfColors.grey400),
      borderRadius: pw.BorderRadius.circular(5),
    ),
    child: strokes.isEmpty
        ? pw.Center(
            child: pw.Text(
              empty,
              style: const pw.TextStyle(color: PdfColors.grey600),
            ),
          )
        : pw.SvgImage(svg: _strokesSvg(strokes)),
  );

  String _strokesSvg(List<List<Map<String, double>>> strokes) {
    final paths = strokes.where((stroke) => stroke.isNotEmpty).map((stroke) {
      final points = stroke
          .map(
            (point) => '${(point['x'] ?? 0) * 1000},${(point['y'] ?? 0) * 500}',
          )
          .join(' ');
      return '<polyline points="$points" fill="none" stroke="#0B172A" stroke-width="5" stroke-linecap="round" stroke-linejoin="round"/>';
    }).join();
    return '<svg viewBox="0 0 1000 500" xmlns="http://www.w3.org/2000/svg">$paths</svg>';
  }

  Future<List<_PdfPhoto>> _loadPhotos(AccidentDraft draft) async {
    final photos = <_PdfPhoto>[];
    for (final entry in draft.evidencePaths.entries) {
      final path = entry.value;
      if (path == null || path.isEmpty) {
        continue;
      }
      final file = File(path);
      if (!await file.exists()) continue;
      try {
        photos.add(_PdfPhoto(entry.key, await file.readAsBytes()));
      } on FileSystemException {
        // Le PDF reste disponible même si une ancienne photo a été supprimée.
      }
    }
    return photos;
  }

  String _coordinates(AccidentDraft draft) {
    if (draft.latitude == null || draft.longitude == null) {
      return 'Non renseignées';
    }
    return '${draft.latitude!.toStringAsFixed(6)}, ${draft.longitude!.toStringAsFixed(6)}'
        '${draft.locationAccuracy == null ? '' : ' (±${draft.locationAccuracy!.round()} m)'}';
  }

  String _join(List<String> values) =>
      values.where((value) => value.trim().isNotEmpty).join(' • ');

  String _fileName(AccidentDraft draft) =>
      'constat_${draft.occurredAt.year}${draft.occurredAt.month.toString().padLeft(2, '0')}${draft.occurredAt.day.toString().padLeft(2, '0')}.pdf';

  String _dateTime(DateTime value) {
    String two(int number) => number.toString().padLeft(2, '0');
    return '${two(value.day)}/${two(value.month)}/${value.year} ${two(value.hour)}:${two(value.minute)}';
  }
}

class _PdfPhoto {
  const _PdfPhoto(this.label, this.bytes);
  final String label;
  final Uint8List bytes;
}
