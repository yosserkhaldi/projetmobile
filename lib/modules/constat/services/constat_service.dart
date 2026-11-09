import 'dart:convert';
import 'dart:typed_data';

import 'package:mon_constat_digital/core/network/api_client.dart';
import 'package:mon_constat_digital/modules/accident/models/accident_draft.dart';
import 'package:mon_constat_digital/modules/constat/models/constat.dart';

class ConstatService {
  const ConstatService({required ApiClient api}) : _api = api;

  final ApiClient _api;

  /// Soumet un constat scellé avec son document PDF et son empreinte SHA-256.
  Future<Constat> sealConstat({
    required AccidentDraft draft,
    required Uint8List pdfBytes,
    required String sha256Hash,
    String? accidentId,
    String? driverAPolicy,
    String? companyAId,
    String? companyBId,
  }) async {
    final payload = {
      if (accidentId != null) 'accidentId': accidentId,
      'sha256Hash': sha256Hash,
      'driverAName': 'Conducteur A',
      'driverAPlate': 'A-Plate',
      'driverAInsurer': 'Assureur A',
      if (driverAPolicy != null) 'driverAPolicy': driverAPolicy,
      if (companyAId != null) 'companyAId': companyAId,
      'driverBName': draft.driverBName.isNotEmpty ? draft.driverBName : 'Conducteur B',
      'driverBPlate': draft.driverBPlate.isNotEmpty ? draft.driverBPlate : 'B-Plate',
      'driverBInsurer': draft.driverBInsurer.isNotEmpty ? draft.driverBInsurer : 'Assureur B',
      if (draft.driverBPolicy.isNotEmpty) 'driverBPolicy': draft.driverBPolicy,
      if (companyBId != null) 'companyBId': companyBId,
      'place': draft.place,
      'occurredAt': draft.occurredAt.toIso8601String(),
      'circumstancesA': draft.circumstancesA,
      'circumstancesB': draft.circumstancesB,
      'impactZones': draft.impactZones,
      'observations': draft.observations,
      'sketchData': draft.sketchStrokes,
      'driverASignedAt': DateTime.now().toIso8601String(),
      'driverBSignedAt': DateTime.now().toIso8601String(),
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

