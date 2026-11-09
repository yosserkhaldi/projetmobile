import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// « Mes données » (loi n° 2004-63) en PDF lisible, à partir de l'export JSON
/// de l'API. Le document reste en français, langue des textes officiels.
Future<Uint8List> buildDataExportPdf(Map<String, dynamic> export) async {
  final regular = pw.Font.ttf(
    await rootBundle.load('assets/fonts/Manrope-500.ttf'),
  );
  final bold = pw.Font.ttf(
    await rootBundle.load('assets/fonts/Manrope-700.ttf'),
  );
  final account = export['account'] as Map<String, dynamic>;
  final company = account['company'] as Map<String, dynamic>?;
  final identity = account['identity'] as Map<String, dynamic>? ?? {};
  final devices = (export['devices'] as List).cast<Map<String, dynamic>>();
  final signIns = (export['signIns'] as List).cast<Map<String, dynamic>>();

  String date(Object? iso) {
    final parsed = DateTime.tryParse('${iso ?? ''}')?.toLocal();
    if (parsed == null) return '—';
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(parsed.day)}/${two(parsed.month)}/${parsed.year} '
        '${two(parsed.hour)}:${two(parsed.minute)}';
  }

  String value(Object? v) => v == null || '$v'.isEmpty ? '—' : '$v';

  pw.Widget section(String title, List<List<String>> rows) => pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.SizedBox(height: 14),
      pw.Text(
        title.toUpperCase(),
        style: pw.TextStyle(
          font: bold,
          fontSize: 10,
          letterSpacing: 0.6,
          color: PdfColor.fromInt(0xFF4A5568),
        ),
      ),
      pw.SizedBox(height: 6),
      pw.Table(
        border: pw.TableBorder.all(color: PdfColor.fromInt(0xFFE4E8EE)),
        columnWidths: {0: const pw.FlexColumnWidth(2)},
        children: [
          for (final row in rows)
            pw.TableRow(
              children: [
                for (final (index, cell) in row.indexed)
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text(
                      cell,
                      style: pw.TextStyle(
                        font: index == 0 ? bold : regular,
                        fontSize: 9,
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    ],
  );

  final doc = pw.Document(
    title: 'Mes données - Mon Constat Digital',
    theme: pw.ThemeData.withFont(base: regular, bold: bold),
  );
  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      header: (_) => pw.Container(
        padding: const pw.EdgeInsets.all(14),
        decoration: pw.BoxDecoration(
          color: PdfColor.fromInt(0xFF0B1626),
          borderRadius: pw.BorderRadius.circular(10),
        ),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Mon Constat Digital — Mes données',
              style: pw.TextStyle(
                font: bold,
                fontSize: 14,
                color: PdfColors.white,
              ),
            ),
            pw.Text(
              date(export['exportedAt']),
              style: pw.TextStyle(fontSize: 9, color: PdfColors.white),
            ),
          ],
        ),
      ),
      footer: (context) => pw.Text(
        '${value(export['legalBasis'])} · page ${context.pageNumber}/${context.pagesCount}',
        style: pw.TextStyle(fontSize: 8, color: PdfColor.fromInt(0xFF4A5568)),
      ),
      build: (_) => [
        section('Compte', [
          ['Nom', '${account['firstName']} ${account['lastName']}'],
          ['E-mail', value(account['email'])],
          ['Téléphone', value(account['phone'])],
          ['Téléphone vérifié', date(account['phoneVerifiedAt'])],
          ['Rôle', value(account['role'])],
          ['Compagnie', value(company?['name'])],
          ['Langue', value(account['language'])],
          ['Compte créé le', date(account['createdAt'])],
          ['Consentement donné le', date(account['consentAt'])],
        ]),
        section('Permis de conduire', [
          ['Numéro', value(account['licenseNumber'])],
          ['Catégories', value(account['licenseCategory'])],
          ['Date de délivrance', value(account['licenseIssuedAt'])],
          [
            'Photo du permis',
            account['licensePhotoId'] == null ? 'Non' : 'Oui',
          ],
        ]),
        section("Vérification d'identité", [
          ['État', value(identity['status'])],
          ['Pièce', value(identity['documentType'])],
          ['N° de la pièce', value(identity['cinNumber'])],
          [
            "Ressemblance calculée par l'IA",
            identity['faceMatch'] == null
                ? '—'
                : '${((identity['faceMatch'] as num) * 100).round()} %',
          ],
          [
            "Validée par l'IA",
            identity['autoVerified'] == true ? 'Oui' : 'Non',
          ],
          ['Envoyée le', date(identity['submittedAt'])],
        ]),
        section('Appareils', [
          ['Appareil', 'Première connexion', 'Dernière activité', 'Déconnecté'],
          for (final d in devices)
            [
              value(d['deviceName']),
              date(d['createdAt']),
              date(d['lastUsedAt']),
              date(d['signedOutAt']),
            ],
        ]),
        section('Connexions', [
          ['Date', 'Résultat', 'Méthode', 'Appareil'],
          for (final e in signIns)
            [
              date(e['at']),
              e['success'] == true
                  ? 'Réussie'
                  : 'Échec (${value(e['reason'])})',
              value(e['method']),
              value(e['deviceName']),
            ],
        ]),
      ],
    ),
  );
  return doc.save();
}
