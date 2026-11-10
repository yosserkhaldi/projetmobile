import 'dart:convert';
import 'dart:typed_data';

import 'package:mon_constat_digital/core/network/api_client.dart';
import 'package:mon_constat_digital/modules/accident/models/accident_draft.dart';
import 'package:mon_constat_digital/modules/constat/models/constat.dart';

class ConstatService {
  const ConstatService({required ApiClient api}) : _api = api;

  final ApiClient _api;

  /// Soumet un constat scellé avec son document PDF et son empreinte SHA-256.
  /// Le conducteur A vient du brouillon, rempli depuis le profil et le
  /// véhicule choisi (AccidentDraft.driverA…).
  Future<Constat> sealConstat({
    required AccidentDraft draft,
    required Uint8List pdfBytes,
    required String sha256Hash,
    String? signaturesHash,
    DateTime? signedAt,
    bool deferEmail = false,
    String? accidentId,
    String? driverAName,
    String? driverAPlate,
    String? driverAInsurer,
    String? driverAPolicy,
    String? companyAId,
    String? companyBId,
  }) async {
    final signedIso = (signedAt ?? DateTime.now()).toUtc().toIso8601String();
    final resolvedDriverAName =
        _firstNonEmpty(driverAName, draft.driverAName) ?? 'Conducteur A';
    final resolvedDriverAPlate =
        _firstNonEmpty(driverAPlate, draft.driverAPlate) ?? 'Non renseignée';
    final resolvedDriverAInsurer =
        _firstNonEmpty(driverAInsurer, draft.driverAInsurer) ?? 'Non renseigné';
    final resolvedDriverAPolicy = _firstNonEmpty(driverAPolicy, draft.driverAPolicy);
    final resolvedCompanyAId = _firstNonEmpty(companyAId, draft.driverACompanyId);
    final payload = {
      if (accidentId != null && accidentId.isNotEmpty) 'accidentId': accidentId,
      'sha256Hash': sha256Hash,
      if (signaturesHash != null && signaturesHash.isNotEmpty)
        'signaturesHash': signaturesHash,
      if (deferEmail) 'deferEmail': true,
      'driverAName': resolvedDriverAName,
      'driverAPlate': resolvedDriverAPlate,
      'driverAInsurer': resolvedDriverAInsurer,
      'driverAPolicy': ?resolvedDriverAPolicy,
      'companyAId': ?resolvedCompanyAId,
      'driverBName': draft.driverBName.isNotEmpty ? draft.driverBName : 'Conducteur B',
      'driverBPlate': draft.driverBPlate.isNotEmpty ? draft.driverBPlate : 'B-Plate',
      'driverBInsurer': draft.driverBInsurer.isNotEmpty ? draft.driverBInsurer : 'Assureur B',
      if (draft.driverBPolicy.isNotEmpty) 'driverBPolicy': draft.driverBPolicy,
      if (companyBId != null && companyBId.isNotEmpty) 'companyBId': companyBId,
      'place': draft.place,
      'occurredAt': draft.occurredAt.toUtc().toIso8601String(),
      'circumstancesA': draft.circumstancesA.toList(),
      'circumstancesB': draft.circumstancesB.toList(),
      'impactZones': draft.impactZones.toList(),
      'observations': draft.observations,
      'sketchData': draft.sketchStrokes,
      'driverASignedAt': signedIso,
      'driverBSignedAt': signedIso,
    };

    final response = await _api.upload(
      '/constats',
      method: 'POST',
      field: 'pdf',
      bytes: pdfBytes,
      filename: 'constat-${sha256Hash.substring(0, 8)}.pdf',
      fields: {'data': jsonEncode(payload)},
    );

    return Constat.fromJson(response['constat'] as Map<String, dynamic>);
  }

  /// Envoie l'exemplaire PDF contenant le QR Code pour signature ECDSA P-256 finale.
  Future<Uint8List> finalizePdf(String constatId, Uint8List stampedPdfBytes) =>
      _api.uploadForBytes(
        '/constats/$constatId/finalize-pdf',
        method: 'POST',
        field: 'pdf',
        bytes: stampedPdfBytes,
        filename: 'constat-signed.pdf',
      );

  static String? _firstNonEmpty(String? primary, String? fallback) {
    if (primary != null && primary.trim().isNotEmpty) return primary.trim();
    if (fallback != null && fallback.trim().isNotEmpty) return fallback.trim();
    return null;
  }

  /// Liste les constats scellés pour l'utilisateur connecté.
  Future<List<Constat>> listConstats() async {
    final response = await _api.get('/constats');
    final list = response['constats'] as List<dynamic>? ?? [];
    return list
        .map((e) => Constat.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Récupère un constat par son identifiant.
  Future<Constat> getConstat(String id) async {
    final response = await _api.get('/constats/$id');
    return Constat.fromJson(response['constat'] as Map<String, dynamic>);
  }

  /// Télécharge le PDF scellé.
  Future<Uint8List> getPdf(String id) => _api.getBytes('/constats/$id/pdf');

  /// Vérifie publiquement un constat par son empreinte SHA-256.
  Future<Map<String, dynamic>> verifyHash(String hash) async {
    final response = await _api.get('/constats/verify/$hash');
    return response as Map<String, dynamic>;
  }
}

