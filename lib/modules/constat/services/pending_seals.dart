import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import 'package:mon_constat_digital/core/network/api_client.dart';
import 'package:mon_constat_digital/core/state/app_scope.dart';
import 'package:mon_constat_digital/modules/accident/models/accident_draft.dart';
import 'package:mon_constat_digital/modules/accident/services/accident_pdf_service.dart';

/// Constats signés hors ligne : scellés sur le téléphone, ils attendent le
/// réseau pour être scellés sur le serveur (déclaration, PDF signé, QR) et
/// rattachés à leur sinistre. La file vit dans un fichier JSON de
/// l'application, et survit à un redémarrage.
class PendingSeals {
  PendingSeals._();

  static bool _running = false;

  static Future<File> _file() async {
    final documents = await getApplicationDocumentsDirectory();
    return File(path.join(documents.path, 'pending_seals.json'));
  }

  static Future<List<Map<String, dynamic>>> _load() async {
    try {
      final file = await _file();
      if (!await file.exists()) return [];
      return (jsonDecode(await file.readAsString()) as List)
          .cast<Map<String, dynamic>>();
    } catch (error) {
      debugPrint('File des constats hors ligne illisible : $error');
      return [];
    }
  }

  static Future<void> _save(List<Map<String, dynamic>> jobs) async {
    final file = await _file();
    await file.writeAsString(jsonEncode(jobs));
  }

  /// Nombre de constats en attente pour ce compte.
  static Future<int> count(String userId) async =>
      (await _load()).where((job) => job['userId'] == userId).length;

  /// Ajoute un constat signé hors ligne à la file.
  static Future<void> add({
    required String userId,
    required String claimId,
    required AccidentDraft draft,
    required ConstatDriverAData driverA,
    String? companyAId,
    String? companyBId,
  }) async {
    final jobs = await _load();
    jobs.add({
      'userId': userId,
      'claimId': claimId,
      'clientId': draft.clientId,
      'draft': draft.toDatabaseMap(currentStep: 6),
      'driverA': _driverAToJson(driverA),
      'companyAId': companyAId,
      'companyBId': companyBId,
    });
    await _save(jobs);
  }

  /// Envoie ce qui peut l'être. Hors ligne, la file reste pour plus tard.
  static Future<void> retry(AppStores stores) async {
    final user = stores.users.currentUser;
    if (_running || user == null) return;
    _running = true;
    try {
      final jobs = await _load();
      if (jobs.isEmpty) return;
      final remaining = <Map<String, dynamic>>[];
      for (final job in jobs) {
        if (job['userId'] != user.id) {
          remaining.add(job);
          continue;
        }
        if (!await _send(stores, job)) remaining.add(job);
      }
      await _save(remaining);
    } finally {
      _running = false;
    }
  }

  /// true quand le constat est scellé et rattaché, ou ne pourra jamais l'être.
  static Future<bool> _send(AppStores stores, Map<String, dynamic> job) async {
    final api = stores.api;
    final draft = AccidentDraft.fromDatabaseMap(
      (job['draft'] as Map).cast<String, Object?>(),
    )..clientId = job['clientId'] as String;
    final driverA = _driverAFromJson(
      (job['driverA'] as Map).cast<String, dynamic>(),
    );
    try {
      var constatId = job['constatId'] as String?;
      if (constatId == null) {
        final accidentId = await stores.accidents.submitToServer(
          api,
          draft,
          clientId: draft.clientId,
        );
        if (accidentId == null) return false; // toujours hors ligne
        final constat = await stores.constats.sealAndSubmit(
          draft: draft,
          accidentId: accidentId,
          driverAName: driverA.fullName,
          driverAPlate: driverA.plate,
          driverAInsurer: driverA.insurerName,
          driverAPolicy: driverA.policyNumber,
          companyAId: job['companyAId'] as String?,
          companyBId: job['companyBId'] as String?,
          driverA: driverA,
        );
        constatId = constat.id;
        // Scellé : un nouvel essai ne le scellera pas une seconde fois.
        job['constatId'] = constatId;
      }
      await api.post(
        '/claims/${job['claimId']}/constat',
        body: {'constatId': constatId},
      );
      return true;
    } on ApiException catch (error) {
      // Réseau coupé, ou sinistre pas encore arrivé (sa file d'envoi passe
      // juste après) : on réessaiera.
      if (error.isNetwork || error.status == 404) return false;
      debugPrint('Constat hors ligne abandonné : ${error.message}');
      return true;
    } catch (error) {
      debugPrint('Constat hors ligne non scellé : $error');
      return false;
    }
  }

  static Map<String, String> _driverAToJson(ConstatDriverAData a) => {
    'fullName': a.fullName,
    'phone': a.phone,
    'email': a.email,
    'cinNumber': a.cinNumber,
    'licenseNumber': a.licenseNumber,
    'licenseCategory': a.licenseCategory,
    'licenseIssuedAt': a.licenseIssuedAt,
    'vehicleBrand': a.vehicleBrand,
    'vehicleModel': a.vehicleModel,
    'vehicleYear': a.vehicleYear,
    'plate': a.plate,
    'insurerName': a.insurerName,
    'policyNumber': a.policyNumber,
    'insuranceExpiry': a.insuranceExpiry,
  };

  static ConstatDriverAData _driverAFromJson(Map<String, dynamic> j) {
    String v(String key) => j[key] as String? ?? '';
    return ConstatDriverAData(
      fullName: v('fullName'),
      phone: v('phone'),
      email: v('email'),
      cinNumber: v('cinNumber'),
      licenseNumber: v('licenseNumber'),
      licenseCategory: v('licenseCategory'),
      licenseIssuedAt: v('licenseIssuedAt'),
      vehicleBrand: v('vehicleBrand'),
      vehicleModel: v('vehicleModel'),
      vehicleYear: v('vehicleYear'),
      plate: v('plate'),
      insurerName: v('insurerName'),
      policyNumber: v('policyNumber'),
      insuranceExpiry: v('insuranceExpiry'),
    );
  }
}
