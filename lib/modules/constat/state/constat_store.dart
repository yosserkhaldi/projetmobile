import 'dart:typed_data';

import 'package:flutter/foundation.dart';

import 'package:mon_constat_digital/core/network/api_client.dart';
import 'package:mon_constat_digital/modules/accident/models/accident_draft.dart';
import 'package:mon_constat_digital/modules/accident/services/accident_pdf_service.dart';
import 'package:mon_constat_digital/modules/constat/models/constat.dart';
import 'package:mon_constat_digital/modules/constat/services/constat_crypto_service.dart';
import 'package:mon_constat_digital/modules/constat/services/constat_service.dart';

class ConstatStore extends ChangeNotifier {
  ConstatStore({
    required ApiClient api,
    ConstatService? service,
    ConstatCryptoService? cryptoService,
    AccidentPdfService? pdfService,
  })  : _service = service ?? ConstatService(api: api),
        _crypto = cryptoService ?? const ConstatCryptoService(),
        _pdf = pdfService ?? AccidentPdfService();

  final ConstatService _service;
  final ConstatCryptoService _crypto;
  final AccidentPdfService _pdf;

  List<Constat> constats = [];
  Constat? lastSealedConstat;
  Uint8List? lastSealedPdfBytes;
  bool isSealing = false;
  bool isLoading = false;
  String? error;

  ConstatCryptoService get crypto => _crypto;

  Future<void> loadConstats() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      constats = await _service.listConstats();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Scelle un constat : génère le PDF officiel, calcule son SHA-256 et le persiste côté API.
  Future<Constat> sealAndSubmit({
    required AccidentDraft draft,
    String? accidentId,
    String? driverAName,
    String? driverAPlate,
    String? driverAInsurer,
    String? driverAPolicy,
    String? companyAId,
    String? companyBId,
  }) async {
    isSealing = true;
    error = null;
    notifyListeners();

    try {
      // 1. Génération du PDF
      final pdfBytes = await _pdf.build(draft);
      lastSealedPdfBytes = pdfBytes;

      // 2. Calcul du hash SHA-256
      final hash = _crypto.computeSha256(pdfBytes);

      // 3. Soumission sécurisée à l'API
      final sealed = await _service.sealConstat(
        draft: draft,
        pdfBytes: pdfBytes,
        sha256Hash: hash,
        accidentId: accidentId,
        driverAPolicy: driverAPolicy,
        companyAId: companyAId,
        companyBId: companyBId,
      );

      lastSealedConstat = sealed;
      constats.insert(0, sealed);
      return sealed;
    } catch (e) {
      error = e.toString();
      rethrow;
    } finally {
      isSealing = false;
      notifyListeners();
    }
  }
}

