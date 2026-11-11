import 'package:flutter/foundation.dart';

import 'package:mon_constat_digital/core/network/api_client.dart';
import 'package:mon_constat_digital/l10n/app_localizations.dart';
import 'package:mon_constat_digital/modules/vehicles/data/vehicle_database.dart';
import 'package:mon_constat_digital/modules/vehicles/models/vehicle.dart';
import 'package:mon_constat_digital/modules/vehicles/services/vehicle_ai_service.dart';

/// Gère la liste des véhicules du conducteur connecté.
///
/// Persiste dans SQLite via [VehicleDatabase], puis sur le serveur
/// (/api/vehicles) : c'est là que l'assureur du véhicule est connu, pour lui
/// adresser les sinistres.
/// Compatible hors-ligne : les modifications sont immédiatement appliquées
/// en mémoire, écrites en base, puis envoyées ; ce qui n'a pas pu partir est
/// renvoyé à la prochaine synchronisation ([syncWithServer]).
class VehicleStore extends ChangeNotifier {
  VehicleStore(this._db, {ApiClient? api}) : _api = api;

  final VehicleDatabase _db;

  /// Absent dans certains tests : tout reste alors sur le téléphone.
  final ApiClient? _api;

  // Liste en mémoire — seule source de vérité pour l'UI.
  final List<Vehicle> _vehicles = [];

  bool _loaded = false;
  Future<void>? _initializing;

  List<Vehicle> get vehicles =>
      _vehicles.where((v) => !v.archived).toList();

  List<Vehicle> get archived =>
      _vehicles.where((v) => v.archived).toList();

  List<Vehicle> get all => List.unmodifiable(_vehicles);

  bool get loaded => _loaded;

  // ── Alertes ────────────────────────────────────────────────────────────────

  /// Toutes les alertes d'échéance actives, triées par urgence.
  List<VehicleAlert> get alerts {
    final result = <VehicleAlert>[];
    for (final v in vehicles) {
      final insurance = v.daysUntilInsuranceExpiry;
      if (insurance < 0) {
        result.add(VehicleAlert(
          vehicle: v,
          kind: AlertKind.insuranceExpired,
          daysRemaining: insurance,
        ));
      } else if (insurance <= 30) {
        result.add(VehicleAlert(
          vehicle: v,
          kind: AlertKind.insuranceExpiring,
          daysRemaining: insurance,
        ));
      }

      final technical = v.daysUntilTechnicalExpiry;
      if (technical != null) {
        if (technical < 0) {
          result.add(VehicleAlert(
            vehicle: v,
            kind: AlertKind.technicalExpired,
            daysRemaining: technical,
          ));
        } else if (technical <= 30) {
          result.add(VehicleAlert(
            vehicle: v,
            kind: AlertKind.technicalExpiring,
            daysRemaining: technical,
          ));
        }
      }
    }
    // Priorité : expirés d'abord, puis les plus proches.
    result.sort((a, b) => a.daysRemaining.compareTo(b.daysRemaining));
    return result;
  }

  int get alertCount => alerts.length;

  // ── Initialisation ────────────────────────────────────────────────────────

  /// Charge les véhicules depuis SQLite au démarrage. Un deuxième appel
  /// attend le premier : la synchronisation ne commence qu'une fois la base
  /// lue, sinon la lecture effacerait ce qu'elle vient d'ajouter.
  Future<void> initialize() => _initializing ??= _load();

  Future<void> _load() async {
    try {
      final rows = await _db.loadAll();
      _vehicles
        ..clear()
        ..addAll(rows);
      _loaded = true;
    } finally {
      notifyListeners();
    }
  }

  // ── CRUD ───────────────────────────────────────────────────────────────────

  /// Modifiés ou supprimés hors ligne, à envoyer à la prochaine
  /// synchronisation.
  final Set<String> _pendingUpdates = {};
  final Set<String> _pendingDeletes = {};

  /// Ajoute un véhicule. Un refus du serveur (plaque déjà enregistrée,
  /// données invalides) annule l'ajout et remonte l'erreur à l'écran ; hors
  /// ligne, il reste sur le téléphone et partira plus tard.
  Future<void> addVehicle(Vehicle v) async {
    _vehicles.add(v);
    notifyListeners();
    await _db.saveVehicle(v);
    try {
      await _send(v);
    } on ApiException {
      _vehicles.removeWhere((e) => e.id == v.id);
      notifyListeners();
      await _db.deleteVehicle(v.id);
      rethrow;
    }
  }

  /// Modifie un véhicule. Refusé par le serveur : l'ancienne version revient
  /// et l'erreur remonte à l'écran.
  Future<void> updateVehicle(Vehicle v) async {
    final idx = _vehicles.indexWhere((e) => e.id == v.id);
    if (idx == -1) return;
    final previous = _vehicles[idx];
    _vehicles[idx] = v;
    notifyListeners();
    await _db.saveVehicle(v);
    try {
      await _send(v);
    } on ApiException {
      final at = _vehicles.indexWhere((e) => e.id == v.id);
      if (at != -1) _vehicles[at] = previous;
      notifyListeners();
      await _db.saveVehicle(previous);
      rethrow;
    }
  }

  Future<void> removeVehicle(Vehicle v) async {
    _vehicles.removeWhere((e) => e.id == v.id);
    _pendingUpdates.remove(v.id);
    notifyListeners();
    await _db.deleteVehicle(v.id);
    final api = _api;
    if (api == null || !v.hasServerId) return;
    try {
      await api.delete('/vehicles/${v.id}');
    } on ApiException catch (error) {
      // Hors ligne : supprimé à la prochaine synchronisation, sans revenir
      // entre-temps. Déjà absent du serveur : rien à faire.
      if (error.isNetwork) {
        _pendingDeletes.add(v.id);
      } else if (error.status != 404) {
        rethrow;
      }
    }
  }

  // ── Serveur ────────────────────────────────────────────────────────────────

  /// Envoie un véhicule : modification s'il existe, sinon création. Une
  /// erreur réseau n'empêche rien : il partira à la prochaine synchronisation.
  Future<void> _send(Vehicle v) async {
    final api = _api;
    if (api == null) return;
    try {
      if (v.hasServerId) {
        try {
          await api.patch('/vehicles/${v.id}', body: v.toApi());
          _pendingUpdates.remove(v.id);
          return;
        } on ApiException catch (error) {
          if (error.status != 404) rethrow;
        }
      }
      final created =
          await api.post('/vehicles', body: v.toApi(withId: true))
              as Map<String, dynamic>;
      // Ancien identifiant (pas un UUID) : on adopte celui du serveur.
      if (created['id'] != v.id) await _replace(v, Vehicle.fromApi(created, local: v));
    } on ApiException catch (error) {
      // Hors ligne : il partira à la prochaine synchronisation. Un refus du
      // serveur remonte à l'appelant.
      if (!error.isNetwork) rethrow;
      _pendingUpdates.add(v.id);
    }
  }

  /// Envoi pendant une synchronisation : un refus est journalisé, pas levé.
  Future<void> _sendQuietly(Vehicle v) async {
    try {
      await _send(v);
    } on ApiException catch (error) {
      debugPrint('Véhicule non envoyé : ${error.message}');
    }
  }

  Future<void> _replace(Vehicle old, Vehicle fresh) async {
    final idx = _vehicles.indexWhere((e) => e.id == old.id);
    if (idx != -1) _vehicles[idx] = fresh;
    await _db.deleteVehicle(old.id);
    await _db.saveVehicle(fresh);
    notifyListeners();
  }

  /// À la connexion : les véhicules du compte sur le serveur rejoignent ceux
  /// du téléphone, et ce que le téléphone a de plus (créé hors ligne) part.
  Future<void> syncWithServer() async {
    final api = _api;
    if (api == null) return;
    await initialize();
    final List<Map<String, dynamic>> remote;
    try {
      remote = [
        for (final archived in ['false', 'true'])
          ...((await api.get(
                    '/vehicles',
                    query: {'archived': archived, 'pageSize': '50'},
                  )
                  as Map<String, dynamic>)['vehicles'] as List)
              .cast<Map<String, dynamic>>(),
      ];
    } on ApiException {
      return; // Hors ligne : on réessaiera à la prochaine connexion.
    }
    // Supprimés hors ligne : ils partent, et ne reviennent pas du serveur.
    for (final id in [..._pendingDeletes]) {
      try {
        await api.delete('/vehicles/$id');
        _pendingDeletes.remove(id);
      } on ApiException catch (error) {
        if (!error.isNetwork) _pendingDeletes.remove(id);
      }
    }
    final localIds = {for (final v in _vehicles) v.id};
    for (final json in remote) {
      if (localIds.contains(json['id']) || _pendingDeletes.contains(json['id'])) {
        continue;
      }
      final vehicle = Vehicle.fromApi(json);
      localIds.add(vehicle.id);
      _vehicles.add(vehicle);
      await _db.saveVehicle(vehicle);
    }
    // Créés ou modifiés hors ligne : le téléphone les envoie.
    final remoteIds = {for (final json in remote) json['id']};
    for (final vehicle in [..._vehicles]) {
      if (!remoteIds.contains(vehicle.id) ||
          _pendingUpdates.contains(vehicle.id)) {
        await _sendQuietly(vehicle);
      }
    }
    notifyListeners();
  }

  /// À la déconnexion : les véhicules ne restent pas pour le compte suivant
  /// sur ce téléphone. Ils sont sur le serveur et reviennent à la connexion.
  Future<void> clear() async {
    await initialize();
    // Ce qui n'est pas encore sur le serveur part avant d'être effacé.
    try {
      await syncWithServer();
    } catch (error) {
      debugPrint('Synchronisation avant déconnexion impossible : $error');
    }
    _vehicles.clear();
    _pendingUpdates.clear();
    _pendingDeletes.clear();
    notifyListeners();
    await _db.deleteAll();
  }

  Future<void> archiveVehicle(Vehicle v) async {
    final updated = v.copyWith(archived: !v.archived);
    await updateVehicle(updated);
  }

  Future<void> incrementClaimCount(String vehicleId) async {
    final idx = _vehicles.indexWhere((e) => e.id == vehicleId);
    if (idx == -1) return;
    final updated = _vehicles[idx].copyWith(
      claimCount: _vehicles[idx].claimCount + 1,
    );
    await updateVehicle(updated);
  }

  // ── IA ────────────────────────────────────────────────────────────────────

  /// Score de risque IA pour un véhicule donné, textes dans la langue [t].
  RiskScore riskScoreFor(Vehicle v, AppLocalizations t) =>
      VehicleAiService.instance.analyze(v, t);

  // ── Dispose ───────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _db.close();
    super.dispose();
  }
}

// ── Alerte ────────────────────────────────────────────────────────────────────

enum AlertKind {
  insuranceExpired,
  insuranceExpiring,
  technicalExpired,
  technicalExpiring,
}

class VehicleAlert {
  const VehicleAlert({
    required this.vehicle,
    required this.kind,
    required this.daysRemaining,
  });

  final Vehicle vehicle;
  final AlertKind kind;

  /// Jours restants. Négatif si déjà expiré.
  final int daysRemaining;

  bool get isExpired =>
      kind == AlertKind.insuranceExpired || kind == AlertKind.technicalExpired;

  String titleIn(AppLocalizations t) => switch (kind) {
    AlertKind.insuranceExpired => t.vehAlertInsuranceExpired,
    AlertKind.insuranceExpiring =>
      t.vehAlertInsuranceExpiring(daysRemaining),
    AlertKind.technicalExpired => t.vehAlertTechnicalExpired,
    AlertKind.technicalExpiring =>
      t.vehAlertTechnicalExpiring(daysRemaining),
  };

  String get subtitle => '${vehicle.brand} ${vehicle.model} · ${vehicle.plate}';
}
