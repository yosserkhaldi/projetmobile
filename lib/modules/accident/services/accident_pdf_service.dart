import 'dart:io';

import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'package:mon_constat_digital/modules/accident/models/accident_draft.dart';
import 'package:mon_constat_digital/modules/constat/models/constat.dart';
import 'package:mon_constat_digital/modules/users/models/app_user.dart';
import 'package:mon_constat_digital/modules/vehicles/models/vehicle.dart';

/// Données du conducteur A et de son véhicule injectées dans le constat PDF.
///
/// Tous les champs ont des valeurs par défaut sûres pour garantir la
/// rétrocompatibilité avec les aperçus hors-ligne et les tests unitaires.
class ConstatDriverAData {
  const ConstatDriverAData({
    this.fullName = '',
    this.phone = '',
    this.email = '',
    this.cinNumber = '',
    this.licenseNumber = '',
    this.licenseCategory = '',
    this.licenseIssuedAt = '',
    this.vehicleBrand = '',
    this.vehicleModel = '',
    this.vehicleYear = '',
    this.plate = '',
    this.insurerName = '',
    this.policyNumber = '',
    this.insuranceExpiry = '',
  });

  factory ConstatDriverAData.fromUserAndVehicle({
    AppUser? user,
    Vehicle? vehicle,
  }) {
    final resolvedInsurer = _firstNonEmpty([
      vehicle?.companyName,
      vehicle?.insurerName,
      user?.companyName,
    ]);
    return ConstatDriverAData(
      fullName: user?.name.trim() ?? '',
      phone: user?.phone.trim() ?? '',
      email: user?.email.trim() ?? '',
      cinNumber: user?.identity.cinNumber?.trim() ?? '',
      licenseNumber: user?.licenseNumber?.trim() ?? '',
      licenseCategory: user?.licenseCategory?.trim() ?? '',
      licenseIssuedAt: user?.licenseIssuedAt?.trim() ?? '',
      vehicleBrand: vehicle?.brand.trim() ?? '',
      vehicleModel: vehicle?.model.trim() ?? '',
      vehicleYear: vehicle?.year.trim() ?? '',
      plate: vehicle?.plate.trim() ?? '',
      insurerName: resolvedInsurer,
      policyNumber: vehicle?.policy.trim() ?? '',
      insuranceExpiry: vehicle?.insuranceExpiry.trim() ?? '',
    );
  }

  factory ConstatDriverAData.fromConstat(Constat constat) => ConstatDriverAData(
    fullName: constat.driverAName,
    plate: constat.driverAPlate,
    insurerName: constat.driverAInsurer,
    policyNumber: constat.driverAPolicy ?? '',
  );

  final String fullName;
  final String phone;
  final String email;
  final String cinNumber;
  final String licenseNumber;
  final String licenseCategory;
  final String licenseIssuedAt;
  final String vehicleBrand;
  final String vehicleModel;
  final String vehicleYear;
  final String plate;
  final String insurerName;
  final String policyNumber;
  final String insuranceExpiry;

  String get vehicleLabel {
    final parts = <String>[
      if (vehicleBrand.isNotEmpty) vehicleBrand,
      if (vehicleModel.isNotEmpty) vehicleModel,
      if (vehicleYear.isNotEmpty) '($vehicleYear)',
    ];
    return parts.join(' ');
  }

  static String _firstNonEmpty(List<String?> values) {
    for (final v in values) {
      if (v != null && v.trim().isNotEmpty) return v.trim();
    }
    return '';
  }
}

class AccidentPdfService {
  /// Liste officielle numérotée des 17 circonstances du Constat Amiable tunisien (FTUSA).
  static const List<String> officialCircumstances = [
    'En stationnement / À l’arrêt',
    'Quittait un stationnement / ouvrait une portière',
    'Prenait un stationnement',
    'Sortait d’un parking, lieu privé ou chemin',
    'S’engageait dans un parking, lieu privé ou chemin',
    'S’engageait sur une place à sens giratoire',
    'Circulait sur une place à sens giratoire',
    'Heurtait à l’arrière (même sens, même file)',
    'Roulait dans le même sens sur une file différente',
    'Changeait de file',
    'Doublait',
    'Virait à droite',
    'Virait à gauche',
    'Reculait',
    'Empiétait sur la chaussée en sens inverse',
    'Venait de droite (dans un carrefour)',
    'N’avait pas observé un signal de priorité',
  ];

  // Palette officielle Constat Amiable (A Bleu / B Ambre / Encre ardoise)
  static final PdfColor _ink = PdfColor.fromHex('#0B172A');
  static final PdfColor _muted = PdfColor.fromHex('#475569');
  static final PdfColor _borderDark = PdfColor.fromHex('#334155');
  static final PdfColor _borderLight = PdfColor.fromHex('#CBD5E1');
  static final PdfColor _slateRow = PdfColor.fromHex('#F8FAFC');

  static final PdfColor _bluePrimary = PdfColor.fromHex('#1537A8');
  static final PdfColor _blueTint = PdfColor.fromHex('#EEF3FF');
  static final PdfColor _blueSoftBorder = PdfColor.fromHex('#93B4F8');

  static final PdfColor _amberPrimary = PdfColor.fromHex('#9A5300');
  static final PdfColor _amberAccent = PdfColor.fromHex('#D97706');
  static final PdfColor _amberTint = PdfColor.fromHex('#FFF7E6');
  static final PdfColor _amberSoftBorder = PdfColor.fromHex('#F3C57A');

  static final PdfColor _sealRed = PdfColor.fromHex('#B91C1C');

  Future<Uint8List> build(
    AccidentDraft draft, {
    Uint8List? qrCodeBytes,
    String? verifierUrl,
    DateTime? generatedAt,
    ConstatDriverAData? driverA,
    String? constatRef,
    String? sha256Hex,
  }) async {
    final sealedTimestamp = generatedAt ?? DateTime.now();
    final effectiveDriverA = driverA ?? const ConstatDriverAData();
    final hasQr =
        (verifierUrl != null && verifierUrl.trim().isNotEmpty) ||
        qrCodeBytes != null;
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
        margin: const pw.EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        header: (context) => _pageHeader(
          context,
          qrCodeBytes: qrCodeBytes,
          verifierUrl: verifierUrl,
          constatRef: constatRef,
          generatedAt: sealedTimestamp,
        ),
        footer: (context) => _footer(context, constatRef: constatRef),
        build: (_) => [
          _topBoxes1to5(draft),
          pw.SizedBox(height: 3.5),
          _comparisonGridAB(draft, effectiveDriverA),
          pw.SizedBox(height: 3.5),
          _sketchAndObservations(draft),
          pw.SizedBox(height: 3.5),
          _signaturesSection(draft, effectiveDriverA),
          pw.SizedBox(height: 3.5),
          _sealBanner(
            sealedTimestamp,
            constatRef: constatRef,
            sha256Hex: sha256Hex,
            hasQr: hasQr,
          ),
          if (photos.isNotEmpty) ...[
            pw.NewPage(),
            _annexHeader(draft, photos.length),
            pw.SizedBox(height: 10),
            pw.Wrap(
              spacing: 12,
              runSpacing: 12,
              children: photos
                  .map(
                    (photo) => pw.Container(
                      width: 271,
                      padding: const pw.EdgeInsets.all(6),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.white,
                        border: pw.Border.all(color: _borderLight),
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Image(
                            pw.MemoryImage(photo.bytes),
                            height: 165,
                            width: 257,
                            fit: pw.BoxFit.cover,
                          ),
                          pw.SizedBox(height: 5),
                          pw.Text(
                            photo.label,
                            style: pw.TextStyle(
                              fontSize: 8.5,
                              fontWeight: pw.FontWeight.bold,
                              color: _ink,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
    return document.save();
  }

  Future<void> preview(
    AccidentDraft draft, {
    ConstatDriverAData? driverA,
  }) async {
    final bytes = await build(draft, driverA: driverA);
    await Printing.layoutPdf(
      name: _fileName(draft),
      onLayout: (_) async => bytes,
    );
  }

  Future<void> share(
    AccidentDraft draft, {
    ConstatDriverAData? driverA,
  }) async {
    await Printing.sharePdf(
      bytes: await build(draft, driverA: driverA),
      filename: _fileName(draft),
    );
  }

  pw.Widget _pageHeader(
    pw.Context context, {
    Uint8List? qrCodeBytes,
    String? verifierUrl,
    String? constatRef,
    required DateTime generatedAt,
  }) {
    final cleanUrl = verifierUrl?.trim();
    final hasVectorQr = cleanUrl != null && cleanUrl.isNotEmpty;
    final hasQr = hasVectorQr || qrCodeBytes != null;
    if (context.pageNumber > 1) {
      return pw.Container(
        margin: const pw.EdgeInsets.only(bottom: 8),
        padding: const pw.EdgeInsets.only(bottom: 5),
        decoration: pw.BoxDecoration(
          border: pw.Border(bottom: pw.BorderSide(color: _borderLight)),
        ),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'CONSTAT AMIABLE D’ACCIDENT AUTOMOBILE — ANNEXES',
              style: pw.TextStyle(
                fontSize: 8.5,
                fontWeight: pw.FontWeight.bold,
                color: _bluePrimary,
              ),
            ),
            pw.Text(
              '${constatRef != null && constatRef.isNotEmpty ? 'Réf. $constatRef • ' : ''}'
              'Page ${context.pageNumber}/${context.pagesCount}',
              style: pw.TextStyle(fontSize: 8, color: _muted),
            ),
          ],
        ),
      );
    }

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 4),
      padding: const pw.EdgeInsets.all(6),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        border: pw.Border.all(color: _borderDark, width: 1),
        borderRadius: pw.BorderRadius.circular(3),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  children: [
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
                      color: _sealRed,
                      child: pw.Text(
                        'RÉPUBLIQUE TUNISIENNE',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 6.8,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                    pw.SizedBox(width: 6),
                    pw.Text(
                      'MODÈLE CONFORME FTUSA • MON CONSTAT DIGITAL',
                      style: pw.TextStyle(
                        color: _muted,
                        fontSize: 6.8,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'CONSTAT AMIABLE D’ACCIDENT AUTOMOBILE',
                  style: pw.TextStyle(
                    color: _bluePrimary,
                    fontSize: 13.5,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 3),
                pw.Wrap(
                  spacing: 6,
                  runSpacing: 3,
                  children: [
                    _pill(
                      constatRef != null && constatRef.isNotEmpty
                          ? 'Réf. : $constatRef'
                          : 'Exemplaire numérique',
                      bg: _blueTint,
                      fg: _bluePrimary,
                    ),
                    _pill(
                      'Édité le ${_dateTime(generatedAt)}',
                      bg: _slateRow,
                      fg: _ink,
                    ),
                    _pill(
                      hasQr ? 'CERTIFIÉ JWS / ECDSA' : 'DOCUMENT PRÉPARATOIRE',
                      bg: hasQr ? PdfColor.fromHex('#DCFCE7') : _amberTint,
                      fg: hasQr ? PdfColor.fromHex('#166534') : _amberPrimary,
                    ),
                    _pill(
                      'Page ${context.pageNumber}/${context.pagesCount}',
                      bg: _slateRow,
                      fg: _muted,
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (hasQr) ...[
            pw.SizedBox(width: 8),
            pw.Column(
              mainAxisSize: pw.MainAxisSize.min,
              children: [
                pw.Container(
                  width: 84,
                  height: 84,
                  padding: const pw.EdgeInsets.all(4),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.white,
                    border: pw.Border.all(color: _borderDark, width: 0.7),
                    borderRadius: pw.BorderRadius.circular(3),
                  ),
                  child: hasVectorQr
                      ? pw.BarcodeWidget(
                          barcode: pw.Barcode.qrCode(
                            errorCorrectLevel: cleanUrl.length > 650
                                ? pw.BarcodeQRCorrectionLevel.low
                                : pw.BarcodeQRCorrectionLevel.medium,
                          ),
                          data: cleanUrl,
                          drawText: false,
                          color: PdfColors.black,
                          backgroundColor: PdfColors.white,
                        )
                      : pw.Image(
                          pw.MemoryImage(qrCodeBytes!),
                          fit: pw.BoxFit.contain,
                        ),
                ),
                pw.SizedBox(height: 1.5),
                pw.Text(
                  'Scanner pour vérifier',
                  style: pw.TextStyle(
                    fontSize: 6.2,
                    fontWeight: pw.FontWeight.bold,
                    color: _bluePrimary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  pw.Widget _pill(String label, {required PdfColor bg, required PdfColor fg}) =>
      pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        decoration: pw.BoxDecoration(
          color: bg,
          borderRadius: pw.BorderRadius.circular(2),
        ),
        child: pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: 6.8,
            fontWeight: pw.FontWeight.bold,
            color: fg,
          ),
        ),
      );

  /// Cadres 1 à 5 : Date/Heure, Lieu + GPS, Blessés, Dégâts matériels autres & conditions, Témoins.
  pw.Widget _topBoxes1to5(AccidentDraft draft) {
    final injuredYes = draft.injuredCount > 0;
    final otherMaterialYes = draft.vehicleCount > 2;
    return pw.Table(
      border: pw.TableBorder.all(color: _borderDark, width: 0.7),
      columnWidths: const {
        0: pw.FixedColumnWidth(134),
        1: pw.FixedColumnWidth(265),
        2: pw.FixedColumnWidth(160),
      },
      children: [
        pw.TableRow(
          children: [
            // Cases 1 & 3
            pw.Container(
              padding: const pw.EdgeInsets.all(5),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _boxHeading('1. DATE & HEURE DE L’ACCIDENT'),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    'Le ${_dateOnly(draft.occurredAt)} à ${_timeOnly(draft.occurredAt)}',
                    style: pw.TextStyle(
                      fontSize: 8.2,
                      fontWeight: pw.FontWeight.bold,
                      color: _ink,
                    ),
                  ),
                  pw.SizedBox(height: 5),
                  _boxHeading('3. BLESSÉS (MÊME LÉGERS)'),
                  pw.SizedBox(height: 3),
                  pw.Row(
                    children: [
                      _checkBadge(
                        checked: !injuredYes,
                        fill: _bluePrimary,
                      ),
                      pw.SizedBox(width: 3),
                      pw.Text('Non', style: const pw.TextStyle(fontSize: 7.4)),
                      pw.SizedBox(width: 10),
                      _checkBadge(
                        checked: injuredYes,
                        fill: _sealRed,
                      ),
                      pw.SizedBox(width: 3),
                      pw.Text(
                        injuredYes ? 'Oui (${draft.injuredCount})' : 'Oui',
                        style: pw.TextStyle(
                          fontSize: 7.4,
                          fontWeight: injuredYes
                              ? pw.FontWeight.bold
                              : pw.FontWeight.normal,
                          color: injuredYes ? _sealRed : _ink,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Cases 2 & 4
            pw.Container(
              padding: const pw.EdgeInsets.all(5),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _boxHeading('2. LIEU PRÉCIS DE L’ACCIDENT (PAYS : TUNISIE)'),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    _valueOrDash(draft.place),
                    style: pw.TextStyle(
                      fontSize: 7.8,
                      fontWeight: pw.FontWeight.bold,
                      color: _ink,
                    ),
                  ),
                  pw.Text(
                    'GPS : ${_coordinates(draft)}',
                    style: pw.TextStyle(fontSize: 6.7, color: _muted),
                  ),
                  pw.SizedBox(height: 4),
                  _boxHeading('4. DÉGÂTS MATÉRIELS AUTRES QUE VÉHICULES A & B / CONDITIONS'),
                  pw.SizedBox(height: 2),
                  pw.Row(
                    children: [
                      _checkBadge(checked: !otherMaterialYes, fill: _bluePrimary),
                      pw.SizedBox(width: 3),
                      pw.Text('Non', style: const pw.TextStyle(fontSize: 7.2)),
                      pw.SizedBox(width: 8),
                      _checkBadge(checked: otherMaterialYes, fill: _amberAccent),
                      pw.SizedBox(width: 3),
                      pw.Text(
                        'Oui (${draft.vehicleCount} véh.)',
                        style: const pw.TextStyle(fontSize: 7.2),
                      ),
                      pw.SizedBox(width: 8),
                      pw.Expanded(
                        child: pw.Text(
                          '${draft.type} • ${draft.severity}',
                          textAlign: pw.TextAlign.right,
                          style: pw.TextStyle(
                            fontSize: 7,
                            fontWeight: pw.FontWeight.bold,
                            color: _ink,
                          ),
                        ),
                      ),
                    ],
                  ),
                  pw.Text(
                    'Météo : ${draft.weather} • Chaussée : ${draft.road} • Lumière : ${draft.light}',
                    style: pw.TextStyle(fontSize: 6.7, color: _muted),
                  ),
                ],
              ),
            ),
            // Case 5
            pw.Container(
              padding: const pw.EdgeInsets.all(5),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _boxHeading('5. TÉMOINS (NOMS, ADRESSES, TÉL.)'),
                  pw.SizedBox(height: 3),
                  if (draft.witnessName.trim().isEmpty &&
                      draft.witnessPhone.trim().isEmpty)
                    pw.Text(
                      'Aucun témoin signalé',
                      style: pw.TextStyle(fontSize: 7.3, color: _muted),
                    )
                  else ...[
                    pw.Text(
                      _valueOrDash(draft.witnessName),
                      style: pw.TextStyle(
                        fontSize: 7.8,
                        fontWeight: pw.FontWeight.bold,
                        color: _ink,
                      ),
                    ),
                    if (draft.witnessPhone.trim().isNotEmpty) ...[
                      pw.SizedBox(height: 2),
                      pw.Text(
                        'Tél. : ${draft.witnessPhone.trim()}',
                        style: pw.TextStyle(fontSize: 7.2, color: _ink),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Tableau central 3 colonnes : VÉHICULE A (Bleu) | 12. CIRCONSTANCES | VÉHICULE B (Ambre).
  pw.Widget _comparisonGridAB(
    AccidentDraft draft,
    ConstatDriverAData driverA,
  ) {
    final matched = _matchCircumstances(draft);
    return pw.Table(
      border: pw.TableBorder.all(color: _borderDark, width: 0.75),
      columnWidths: const {
        0: pw.FixedColumnWidth(167),
        1: pw.FixedColumnWidth(225),
        2: pw.FixedColumnWidth(167),
      },
      children: [
        pw.TableRow(
          children: [
            _vehicleColumnA(draft, driverA),
            _circumstancesColumn(matched),
            _vehicleColumnB(draft),
          ],
        ),
      ],
    );
  }

  pw.Widget _vehicleColumnA(AccidentDraft draft, ConstatDriverAData driverA) {
    final licenseDetails = [
      if (driverA.licenseNumber.isNotEmpty) 'N° ${driverA.licenseNumber}',
      if (driverA.licenseCategory.isNotEmpty) 'Cat. ${driverA.licenseCategory}',
      if (driverA.licenseIssuedAt.isNotEmpty) 'Dél. ${driverA.licenseIssuedAt}',
    ].join(' • ');

    return pw.Container(
      color: PdfColors.white,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            color: _bluePrimary,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'VÉHICULE A',
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 8.8,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  'DÉCLARANT',
                  style: pw.TextStyle(
                    color: _blueTint,
                    fontSize: 6.5,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          _partySubSection(
            number: '6',
            title: 'PRENEUR / CONDUCTEUR A',
            accent: _bluePrimary,
            tint: _blueTint,
            rows: [
              ('Nom & Prénom', _valueOrDash(driverA.fullName)),
              ('Téléphone', _valueOrDash(driverA.phone)),
              ('E-mail', _valueOrDash(driverA.email)),
              if (driverA.cinNumber.isNotEmpty) ('N° CIN', driverA.cinNumber),
            ],
          ),
          _partySubSection(
            number: '7',
            title: 'VÉHICULE A',
            accent: _bluePrimary,
            tint: _blueTint,
            rows: [
              ('Marque / Modèle', _valueOrDash(driverA.vehicleLabel)),
              ('Immatriculation', _valueOrDash(driverA.plate)),
            ],
            highlightLast: true,
          ),
          _partySubSection(
            number: '8',
            title: 'SOCIÉTÉ D’ASSURANCE A',
            accent: _bluePrimary,
            tint: _blueTint,
            rows: [
              ('Compagnie', _valueOrDash(driverA.insurerName)),
              ('N° de Police', _valueOrDash(driverA.policyNumber)),
              if (driverA.insuranceExpiry.isNotEmpty)
                ('Valable jusqu’au', driverA.insuranceExpiry),
            ],
          ),
          _partySubSection(
            number: '9',
            title: 'PERMIS DE CONDUIRE A',
            accent: _bluePrimary,
            tint: _blueTint,
            rows: [
              ('Détails permis', _valueOrDash(licenseDetails)),
            ],
          ),
          _partySubSection(
            number: '10',
            title: 'POINT DE CHOC INITIAL',
            accent: _bluePrimary,
            tint: _blueTint,
            rows: [
              (
                'Zones déclarées',
                draft.impactZones.isEmpty
                    ? 'Non précisé'
                    : draft.impactZones.join(', '),
              ),
            ],
            isLast: true,
          ),
        ],
      ),
    );
  }

  pw.Widget _vehicleColumnB(AccidentDraft draft) {
    return pw.Container(
      color: PdfColors.white,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            color: _amberPrimary,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'VÉHICULE B',
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 8.8,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  'TIERS IMPLIQUÉ',
                  style: pw.TextStyle(
                    color: _amberTint,
                    fontSize: 6.5,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          _partySubSection(
            number: '6',
            title: 'PRENEUR / CONDUCTEUR B',
            accent: _amberPrimary,
            tint: _amberTint,
            rows: [
              ('Nom & Prénom', _valueOrDash(draft.driverBName)),
              ('Dossier', 'Identifié sur place (QR / saisie)'),
            ],
          ),
          _partySubSection(
            number: '7',
            title: 'VÉHICULE B',
            accent: _amberPrimary,
            tint: _amberTint,
            rows: [
              ('Type', 'Véhicule tiers impliqué'),
              ('Immatriculation', _valueOrDash(draft.driverBPlate)),
            ],
            highlightLast: true,
          ),
          _partySubSection(
            number: '8',
            title: 'SOCIÉTÉ D’ASSURANCE B',
            accent: _amberPrimary,
            tint: _amberTint,
            rows: [
              ('Compagnie', _valueOrDash(draft.driverBInsurer)),
              ('N° de Police', _valueOrDash(draft.driverBPolicy)),
            ],
          ),
          _partySubSection(
            number: '9',
            title: 'PERMIS DE CONDUIRE B',
            accent: _amberPrimary,
            tint: _amberTint,
            rows: [
              ('N° de permis', _valueOrDash(draft.driverBPermit)),
              ('Validité', _valueOrDash(draft.driverBPermitExpiry)),
            ],
          ),
          _partySubSection(
            number: '10',
            title: 'CHOC & CONSTATATION B',
            accent: _amberPrimary,
            tint: _amberTint,
            rows: [
              (
                'Zones impactées',
                draft.impactZones.isEmpty
                    ? 'Voir croquis central'
                    : draft.impactZones.join(', '),
              ),
              ('Validation', 'Acceptation bilatérale requise'),
            ],
            isLast: true,
          ),
        ],
      ),
    );
  }

  pw.Widget _partySubSection({
    required String number,
    required String title,
    required PdfColor accent,
    required PdfColor tint,
    required List<(String, String)> rows,
    bool highlightLast = false,
    bool isLast = false,
  }) =>
      pw.Container(
        decoration: isLast
            ? null
            : pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(color: _borderLight, width: 0.5),
                ),
              ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              color: tint,
              child: pw.Text(
                '$number. $title',
                style: pw.TextStyle(
                  fontSize: 6.7,
                  fontWeight: pw.FontWeight.bold,
                  color: accent,
                ),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 3),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  for (int i = 0; i < rows.length; i++)
                    pw.Padding(
                      padding: pw.EdgeInsets.only(
                        bottom: i == rows.length - 1 ? 0 : 2,
                      ),
                      child: (highlightLast && i == rows.length - 1)
                          ? pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  rows[i].$1,
                                  style: pw.TextStyle(fontSize: 6, color: _muted),
                                ),
                                pw.Container(
                                  width: double.infinity,
                                  padding: const pw.EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 1.5,
                                  ),
                                  decoration: pw.BoxDecoration(
                                    color: tint,
                                    border: pw.Border.all(
                                      color: accent,
                                      width: 0.5,
                                    ),
                                    borderRadius: pw.BorderRadius.circular(2),
                                  ),
                                  child: pw.Text(
                                    rows[i].$2,
                                    style: pw.TextStyle(
                                      fontSize: 7.5,
                                      fontWeight: pw.FontWeight.bold,
                                      color: rows[i].$2 == 'Non renseigné'
                                          ? _muted
                                          : _ink,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : pw.RichText(
                              text: pw.TextSpan(
                                children: [
                                  pw.TextSpan(
                                    text: '${rows[i].$1} : ',
                                    style: pw.TextStyle(
                                      fontSize: 6.4,
                                      color: _muted,
                                    ),
                                  ),
                                  pw.TextSpan(
                                    text: rows[i].$2,
                                    style: pw.TextStyle(
                                      fontSize: 6.9,
                                      fontWeight: pw.FontWeight.bold,
                                      color: rows[i].$2 == 'Non renseigné'
                                          ? _muted
                                          : _ink,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                ],
              ),
            ),
          ],
        ),
      );

  pw.Widget _circumstancesColumn(_MatchedCircumstances matched) {
    final rows = <_CircumstanceRow>[
      for (int i = 0; i < officialCircumstances.length; i++)
        _CircumstanceRow(
          label: '${i + 1}. ${officialCircumstances[i]}',
          checkedA: matched.checkedIndicesA.contains(i),
          checkedB: matched.checkedIndicesB.contains(i),
        ),
      for (final custom in matched.extraItems)
        _CircumstanceRow(
          label: custom,
          checkedA: matched.extraA.contains(custom),
          checkedB: matched.extraB.contains(custom),
        ),
    ];

    return pw.Container(
      color: PdfColors.white,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            color: _ink,
            child: pw.Row(
              children: [
                pw.SizedBox(
                  width: 14,
                  child: pw.Text(
                    'A',
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                      color: PdfColor.fromHex('#93C5FD'),
                      fontSize: 8,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.Expanded(
                  child: pw.Text(
                    '12. CIRCONSTANCES',
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 8,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.SizedBox(
                  width: 14,
                  child: pw.Text(
                    'B',
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                      color: PdfColor.fromHex('#FCD34D'),
                      fontSize: 8,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            color: _slateRow,
            child: pw.Text(
              'Mettre une croix (X) dans chacune des cases utiles',
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(fontSize: 6, color: _muted),
            ),
          ),
          for (int i = 0; i < rows.length; i++)
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 3, vertical: 1.5),
              decoration: pw.BoxDecoration(
                color: (rows[i].checkedA || rows[i].checkedB)
                    ? PdfColor.fromHex('#F1F5FF')
                    : (i.isEven ? PdfColors.white : _slateRow),
                border: pw.Border(
                  top: pw.BorderSide(color: _borderLight, width: 0.35),
                ),
              ),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Container(
                    width: 14,
                    color: _blueTint,
                    alignment: pw.Alignment.center,
                    padding: const pw.EdgeInsets.symmetric(vertical: 0.5),
                    child: _checkBadge(
                      checked: rows[i].checkedA,
                      fill: _bluePrimary,
                      size: 8,
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 3.5),
                      child: pw.Text(
                        rows[i].label,
                        style: pw.TextStyle(
                          fontSize: 6.0,
                          fontWeight: (rows[i].checkedA || rows[i].checkedB)
                              ? pw.FontWeight.bold
                              : pw.FontWeight.normal,
                          color: _ink,
                        ),
                      ),
                    ),
                  ),
                  pw.Container(
                    width: 14,
                    color: _amberTint,
                    alignment: pw.Alignment.center,
                    padding: const pw.EdgeInsets.symmetric(vertical: 0.5),
                    child: _checkBadge(
                      checked: rows[i].checkedB,
                      fill: _amberPrimary,
                      size: 8,
                    ),
                  ),
                ],
              ),
            ),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 3.5),
            decoration: pw.BoxDecoration(
              color: _slateRow,
              border: pw.Border(
                top: pw.BorderSide(color: _borderDark, width: 0.6),
              ),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 1.5,
                  ),
                  decoration: pw.BoxDecoration(
                    color: _blueTint,
                    border: pw.Border.all(color: _bluePrimary, width: 0.6),
                  ),
                  child: pw.Text(
                    'A : ${matched.totalA}',
                    style: pw.TextStyle(
                      fontSize: 7,
                      fontWeight: pw.FontWeight.bold,
                      color: _bluePrimary,
                    ),
                  ),
                ),
                pw.Text(
                  'Total cases marquées',
                  style: pw.TextStyle(
                    fontSize: 6.5,
                    fontWeight: pw.FontWeight.bold,
                    color: _muted,
                  ),
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 1.5,
                  ),
                  decoration: pw.BoxDecoration(
                    color: _amberTint,
                    border: pw.Border.all(color: _amberPrimary, width: 0.6),
                  ),
                  child: pw.Text(
                    'B : ${matched.totalB}',
                    style: pw.TextStyle(
                      fontSize: 7,
                      fontWeight: pw.FontWeight.bold,
                      color: _amberPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Section 13 (Croquis vectoriel) & Section 11 (Observations).
  pw.Widget _sketchAndObservations(AccidentDraft draft) {
    final mediaExtras = <String>[
      '${draft.evidenceCount} photo(s)',
      if (draft.videoAdded) 'Vidéo de la scène',
      if (draft.voiceNoteAdded) 'Note vocale',
    ];

    return pw.Table(
      border: pw.TableBorder.all(color: _borderDark, width: 0.7),
      columnWidths: const {
        0: pw.FixedColumnWidth(342),
        1: pw.FixedColumnWidth(217),
      },
      children: [
        pw.TableRow(
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(4.5),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      _boxHeading('13. CROQUIS DE L’ACCIDENT AU MOMENT DU CHOC'),
                      pw.Text(
                        'Choc : ${draft.impactZones.isEmpty ? 'Non précisé' : draft.impactZones.join(', ')}',
                        style: pw.TextStyle(fontSize: 6.4, color: _muted),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 3),
                  _drawing(
                    draft.sketchStrokes,
                    height: 92,
                    empty: 'Aucun croquis tracé',
                  ),
                ],
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(4.5),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _boxHeading('11. OBSERVATIONS & PRÉCISIONS'),
                  pw.SizedBox(height: 3),
                  pw.Container(
                    width: double.infinity,
                    constraints: const pw.BoxConstraints(minHeight: 58),
                    padding: const pw.EdgeInsets.all(4.5),
                    decoration: pw.BoxDecoration(
                      color: _slateRow,
                      border: pw.Border.all(color: _borderLight, width: 0.5),
                      borderRadius: pw.BorderRadius.circular(3),
                    ),
                    child: pw.Text(
                      draft.observations.trim().isEmpty
                          ? 'Aucune observation complémentaire déclarée.'
                          : draft.observations.trim(),
                      style: pw.TextStyle(
                        fontSize: 7.4,
                        color: draft.observations.trim().isEmpty ? _muted : _ink,
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 5),
                  _boxHeading('PIÈCES NUMÉRIQUES JOINTES'),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    mediaExtras.join(' • '),
                    style: pw.TextStyle(
                      fontSize: 6.9,
                      fontWeight: pw.FontWeight.bold,
                      color: _bluePrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Section 14 & 15 : Signatures bilatérales des conducteurs A et B.
  pw.Widget _signaturesSection(
    AccidentDraft draft,
    ConstatDriverAData driverA,
  ) =>
      pw.Table(
        border: pw.TableBorder.all(color: _borderDark, width: 0.7),
        columnWidths: const {
          0: pw.FixedColumnWidth(279),
          1: pw.FixedColumnWidth(280),
        },
        children: [
          pw.TableRow(
            children: [
              _signatureBox(
                title: '14. SIGNATURE CONDUCTEUR A',
                signer: _valueOrDash(driverA.fullName),
                plate: driverA.plate,
                strokes: draft.driverASignature,
                accent: _bluePrimary,
                tint: _blueTint,
                border: _blueSoftBorder,
              ),
              _signatureBox(
                title: '15. SIGNATURE CONDUCTEUR B',
                signer: _valueOrDash(draft.driverBName),
                plate: draft.driverBPlate,
                strokes: draft.driverBSignature,
                accent: _amberPrimary,
                tint: _amberTint,
                border: _amberSoftBorder,
              ),
            ],
          ),
        ],
      );

  pw.Widget _signatureBox({
    required String title,
    required String signer,
    required String plate,
    required List<List<Map<String, double>>> strokes,
    required PdfColor accent,
    required PdfColor tint,
    required PdfColor border,
  }) =>
      pw.Container(
        padding: const pw.EdgeInsets.all(5),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 2.5),
              color: tint,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    title,
                    style: pw.TextStyle(
                      fontSize: 7.2,
                      fontWeight: pw.FontWeight.bold,
                      color: accent,
                    ),
                  ),
                  pw.Text(
                    plate.trim().isNotEmpty ? '$signer (${plate.trim()})' : signer,
                    style: pw.TextStyle(
                      fontSize: 6.7,
                      fontWeight: pw.FontWeight.bold,
                      color: _ink,
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 2.5),
            _drawing(
              strokes,
              height: 48,
              empty: 'Signature absente',
              borderColor: border,
              strokeHex: accent == _bluePrimary ? '#1537A8' : '#7A4300',
            ),
          ],
        ),
      );

  pw.Widget _sealBanner(
    DateTime sealedTimestamp, {
    String? constatRef,
    String? sha256Hex,
    required bool hasQr,
  }) {
    final hashSegment = (sha256Hex != null && sha256Hex.isNotEmpty)
        ? ' • Empreinte SHA-256 : ${sha256Hex.substring(0, sha256Hex.length >= 16 ? 16 : sha256Hex.length).toUpperCase()}...'
        : '';
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: pw.BoxDecoration(
        color: _blueTint,
        border: pw.Border.all(color: _blueSoftBorder, width: 0.6),
        borderRadius: pw.BorderRadius.circular(3),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'ATTESTATION DE SCELLEMENT & VALEUR PROBANTE',
            style: pw.TextStyle(
              fontSize: 6.8,
              fontWeight: pw.FontWeight.bold,
              color: _bluePrimary,
            ),
          ),
          pw.SizedBox(height: 1.5),
          pw.Text(
            'Document généré par Mon Constat Digital le ${_dateTime(sealedTimestamp)}'
            '${constatRef != null && constatRef.isNotEmpty ? ' (Dossier $constatRef)' : ''}'
            '$hashSegment. '
            '${hasQr ? 'Le QR Code JWS et la signature ECDSA P-256 intégrée au PDF garantissent l’intégrité des données et des deux signatures.' : 'Les informations et signatures ci-dessus proviennent de la déclaration établie conjointement par les conducteurs A et B.'}',
            style: pw.TextStyle(fontSize: 6.7, color: _ink),
          ),
        ],
      ),
    );
  }

  pw.Widget _annexHeader(AccidentDraft draft, int count) => pw.Container(
    width: double.infinity,
    padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 7),
    color: _ink,
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          'ANNEXE — PREUVES PHOTOGRAPHIQUES GÉOLOCALISÉES',
          style: pw.TextStyle(
            color: PdfColors.white,
            fontSize: 9.5,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.Text(
          '$count photo(s) • ${_dateTime(draft.occurredAt)}',
          style: pw.TextStyle(
            color: PdfColors.grey300,
            fontSize: 8,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ],
    ),
  );

  pw.Widget _footer(pw.Context context, {String? constatRef}) => pw.Container(
    margin: const pw.EdgeInsets.only(top: 6),
    padding: const pw.EdgeInsets.only(top: 4),
    decoration: pw.BoxDecoration(
      border: pw.Border(top: pw.BorderSide(color: _borderLight)),
    ),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          'Mon Constat Digital • Constat Amiable Tunisien (conforme FTUSA) — À transmettre sous 5 jours ouvrés à votre assureur',
          style: pw.TextStyle(fontSize: 6.8, color: _muted),
        ),
        pw.Text(
          '${constatRef != null && constatRef.isNotEmpty ? '$constatRef • ' : ''}Page ${context.pageNumber}/${context.pagesCount}',
          style: pw.TextStyle(fontSize: 6.8, color: _muted),
        ),
      ],
    ),
  );

  pw.Widget _boxHeading(String text) => pw.Text(
    text,
    style: pw.TextStyle(
      fontSize: 6.4,
      fontWeight: pw.FontWeight.bold,
      color: _bluePrimary,
    ),
  );

  pw.Widget _checkBadge({
    required bool checked,
    required PdfColor fill,
    double size = 8.5,
  }) =>
      pw.Container(
        width: size,
        height: size,
        alignment: pw.Alignment.center,
        decoration: pw.BoxDecoration(
          color: checked ? fill : PdfColors.white,
          border: pw.Border.all(
            color: checked ? fill : _borderDark,
            width: 0.7,
          ),
          borderRadius: pw.BorderRadius.circular(1.2),
        ),
        child: checked
            ? pw.Text(
                'X',
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: size * 0.7,
                  fontWeight: pw.FontWeight.bold,
                ),
              )
            : null,
      );

  pw.Widget _drawing(
    List<List<Map<String, double>>> strokes, {
    required double height,
    required String empty,
    PdfColor? borderColor,
    String strokeHex = '#0B172A',
  }) =>
      pw.Container(
        width: double.infinity,
        height: height,
        decoration: pw.BoxDecoration(
          color: PdfColors.white,
          border: pw.Border.all(color: borderColor ?? _borderLight, width: 0.6),
          borderRadius: pw.BorderRadius.circular(3),
        ),
        child: strokes.isEmpty
            ? pw.Center(
                child: pw.Text(
                  empty,
                  style: pw.TextStyle(fontSize: 7.5, color: _muted),
                ),
              )
            : pw.SvgImage(
                svg: _strokesSvg(strokes, strokeHex: strokeHex),
                fit: pw.BoxFit.contain,
              ),
      );

  String _strokesSvg(
    List<List<Map<String, double>>> strokes, {
    String strokeHex = '#0B172A',
  }) {
    final paths = strokes.where((stroke) => stroke.isNotEmpty).map((stroke) {
      if (stroke.length == 1) {
        final cx = (stroke.first['x'] ?? 0) * 1000;
        final cy = (stroke.first['y'] ?? 0) * 500;
        return '<circle cx="$cx" cy="$cy" r="4" fill="$strokeHex"/>';
      }
      final points = stroke
          .map(
            (point) => '${(point['x'] ?? 0) * 1000},${(point['y'] ?? 0) * 500}',
          )
          .join(' ');
      return '<polyline points="$points" fill="none" stroke="$strokeHex" stroke-width="5" stroke-linecap="round" stroke-linejoin="round"/>';
    }).join();
    return '<svg viewBox="0 0 1000 500" xmlns="http://www.w3.org/2000/svg">$paths</svg>';
  }

  _MatchedCircumstances _matchCircumstances(AccidentDraft draft) {
    final idxA = <int>{};
    final idxB = <int>{};
    final extraA = <String>{};
    final extraB = <String>{};

    void classify(Set<String> source, Set<int> targetIdx, Set<String> targetExtra) {
      for (final raw in source) {
        final matchedIndex = _findOfficialCircumstanceIndex(raw);
        if (matchedIndex != null) {
          targetIdx.add(matchedIndex);
        } else if (raw.trim().isNotEmpty) {
          targetExtra.add(raw.trim());
        }
      }
    }

    classify(draft.circumstancesA, idxA, extraA);
    classify(draft.circumstancesB, idxB, extraB);

    final extraItems = <String>[
      ...extraA,
      for (final b in extraB)
        if (!extraA.contains(b)) b,
    ];

    return _MatchedCircumstances(
      checkedIndicesA: idxA,
      checkedIndicesB: idxB,
      extraItems: extraItems,
      extraA: extraA,
      extraB: extraB,
      totalA: idxA.length + extraA.length,
      totalB: idxB.length + extraB.length,
    );
  }

  int? _findOfficialCircumstanceIndex(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;

    final numMatch = RegExp(r'^(\d{1,2})\s*[-–.)]\s*(.+)$').firstMatch(trimmed);
    if (numMatch != null) {
      final numVal = int.tryParse(numMatch.group(1)!);
      if (numVal != null &&
          numVal >= 1 &&
          numVal <= officialCircumstances.length) {
        return numVal - 1;
      }
    }

    final normalized = _norm(trimmed);
    const aliases = <String, int>{
      'en stationnement': 0,
      'en stationnement a l arret': 0,
      'quittait un stationnement': 1,
      'quittait un stationnement ouvrait une portiere': 1,
      'prenait un stationnement': 2,
      'changeait de file': 9,
      'doublait': 10,
      'virait a droite': 11,
      'virait a gauche': 12,
      'reculait': 13,
    };
    if (aliases.containsKey(normalized)) {
      return aliases[normalized];
    }

    for (int i = 0; i < officialCircumstances.length; i++) {
      if (_norm(officialCircumstances[i]) == normalized) {
        return i;
      }
    }
    return null;
  }

  String _norm(String input) => input
      .toLowerCase()
      .replaceAll('’', "'")
      .replaceAll(RegExp(r'[àâ]'), 'a')
      .replaceAll(RegExp(r'[éèêë]'), 'e')
      .replaceAll(RegExp(r'[îï]'), 'i')
      .replaceAll(RegExp(r'[ôö]'), 'o')
      .replaceAll(RegExp(r'[ùûü]'), 'u')
      .replaceAll('ç', 'c')
      .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
      .trim();

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

  String _valueOrDash(String value) =>
      value.trim().isEmpty ? 'Non renseigné' : value.trim();

  String _coordinates(AccidentDraft draft) {
    if (draft.latitude == null || draft.longitude == null) {
      return 'Non renseignées';
    }
    return '${draft.latitude!.toStringAsFixed(6)}, ${draft.longitude!.toStringAsFixed(6)}'
        '${draft.locationAccuracy == null ? '' : ' (±${draft.locationAccuracy!.round()} m)'}';
  }

  String _fileName(AccidentDraft draft) =>
      'constat_${draft.occurredAt.year}${draft.occurredAt.month.toString().padLeft(2, '0')}${draft.occurredAt.day.toString().padLeft(2, '0')}.pdf';

  String _dateOnly(DateTime value) {
    String two(int number) => number.toString().padLeft(2, '0');
    return '${two(value.day)}/${two(value.month)}/${value.year}';
  }

  String _timeOnly(DateTime value) {
    String two(int number) => number.toString().padLeft(2, '0');
    return '${two(value.hour)}:${two(value.minute)}';
  }

  String _dateTime(DateTime value) =>
      '${_dateOnly(value)} ${_timeOnly(value)}';
}

class _MatchedCircumstances {
  const _MatchedCircumstances({
    required this.checkedIndicesA,
    required this.checkedIndicesB,
    required this.extraItems,
    required this.extraA,
    required this.extraB,
    required this.totalA,
    required this.totalB,
  });

  final Set<int> checkedIndicesA;
  final Set<int> checkedIndicesB;
  final List<String> extraItems;
  final Set<String> extraA;
  final Set<String> extraB;
  final int totalA;
  final int totalB;
}

class _CircumstanceRow {
  const _CircumstanceRow({
    required this.label,
    required this.checkedA,
    required this.checkedB,
  });

  final String label;
  final bool checkedA;
  final bool checkedB;
}

class _PdfPhoto {
  const _PdfPhoto(this.label, this.bytes);
  final String label;
  final Uint8List bytes;
}
