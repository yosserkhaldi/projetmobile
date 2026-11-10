import 'dart:convert';

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
    ConstatDriverAData? driverA,
  }) async {
    isSealing = true;
    error = null;
    notifyListeners();

    try {
      final sealedAt = DateTime.now().toUtc();
      final effectiveDriverA = driverA ??
          ConstatDriverAData(
            fullName: driverAName ?? '',
            plate: driverAPlate ?? '',
            insurerName: driverAInsurer ?? '',
            policyNumber: driverAPolicy ?? '',
          );

      // 1. Génération du PDF canonique avec horodatage local figé + hash SHA-256 des signatures
      final localSealedAt = sealedAt.toLocal();
      final pdfBytes = await _pdf.build(
        draft,
        generatedAt: localSealedAt,
        driverA: effectiveDriverA,
      );
      lastSealedPdfBytes = pdfBytes;

      final hash = _crypto.computeSha256(pdfBytes);
      final signaturesHash = _crypto.computeSignaturesHash(
        draft.driverASignature,
        draft.driverBSignature,
      );

      // 2. Enregistrement serveur + génération du jeton JWS et du QR Code certifié
      final sealed = await _service.sealConstat(
        draft: draft,
        pdfBytes: pdfBytes,
        sha256Hash: hash,
        signaturesHash: signaturesHash,
        signedAt: sealedAt,
        deferEmail: true,
        accidentId: accidentId,
        driverAName: driverAName,
        driverAPlate: driverAPlate,
        driverAInsurer: driverAInsurer,
        driverAPolicy: driverAPolicy,
        companyAId: companyAId,
        companyBId: companyBId,
      );

      // 3. Reconstruit l'exemplaire visuel unique avec QR Code, puis le fait
      //    signer ECDSA P-256 (/ByteRange) côté serveur : un seul fichier PDF officiel.
      if ((sealed.verifierUrl != null && sealed.verifierUrl!.isNotEmpty) ||
          (sealed.qrCodeBase64 != null && sealed.qrCodeBase64!.isNotEmpty)) {
        try {
          final qrBytes = (sealed.qrCodeBase64 != null &&
                  sealed.qrCodeBase64!.isNotEmpty)
              ? base64Decode(sealed.qrCodeBase64!)
              : null;
          final stampedPdf = await _pdf.build(
            draft,
            qrCodeBytes: qrBytes,
            verifierUrl: sealed.verifierUrl,
            generatedAt: localSealedAt,
            driverA: effectiveDriverA,
            constatRef: sealed.id.substring(0, 8).toUpperCase(),
            sha256Hex: hash,
          );
          lastSealedPdfBytes = await _service.finalizePdf(sealed.id, stampedPdf);
        } catch (err) {
          debugPrint('[ConstatStore] Finalisation PDF ECDSA repliée : $err');
          try {
            lastSealedPdfBytes = await _service.getPdf(sealed.id);
          } catch (_) {}
        }
      }

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

