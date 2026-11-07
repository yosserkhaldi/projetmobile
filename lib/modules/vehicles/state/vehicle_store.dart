import 'package:flutter/foundation.dart';

import 'package:mon_constat_digital/modules/vehicles/data/vehicle_database.dart';
import 'package:mon_constat_digital/modules/vehicles/models/vehicle.dart';
import 'package:mon_constat_digital/modules/vehicles/services/vehicle_ai_service.dart';

/// Gère la liste des véhicules du conducteur connecté.
///
/// Persiste dans SQLite via [VehicleDatabase].
/// Compatible hors-ligne : les modifications sont immédiatement appliquées
/// en mémoire, puis écrites en base de façon asynchrone.
class VehicleStore extends ChangeNotifier {
  VehicleStore(this._db);

  final VehicleDatabase _db;

  // Liste en mémoire — seule source de vérité pour l'UI.
  final List<Vehicle> _vehicles = [];

  bool _loaded = false;
  bool _loading = false;

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

  /// Charge les véhicules depuis SQLite au démarrage.
  Future<void> initialize() async {
    if (_loaded || _loading) return;
    _loading = true;
    try {
      final rows = await _db.loadAll();
      _vehicles
        ..clear()
        ..addAll(rows);
      _loaded = true;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // ── CRUD ───────────────────────────────────────────────────────────────────

  Future<void> addVehicle(Vehicle v) async {
    _vehicles.add(v);
    notifyListeners();
    await _db.saveVehicle(v);
  }

  Future<void> updateVehicle(Vehicle v) async {
    final idx = _vehicles.indexWhere((e) => e.id == v.id);
    if (idx == -1) return;
    _vehicles[idx] = v;
    notifyListeners();
    await _db.saveVehicle(v);
  }

  Future<void> removeVehicle(Vehicle v) async {
    _vehicles.removeWhere((e) => e.id == v.id);
    notifyListeners();
    await _db.deleteVehicle(v.id);
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

  /// Score de risque IA pour un véhicule donné.
  RiskScore riskScoreFor(Vehicle v) =>
      VehicleAiService.instance.analyze(v);

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

  String get title => switch (kind) {
    AlertKind.insuranceExpired => 'Assurance EXPIRÉE',
    AlertKind.insuranceExpiring =>
      'Assurance expire dans $daysRemaining j.',
    AlertKind.technicalExpired => 'Visite technique EXPIRÉE',
    AlertKind.technicalExpiring =>
      'Visite technique dans $daysRemaining j.',
  };

  String get subtitle => '${vehicle.brand} ${vehicle.model} · ${vehicle.plate}';
}
