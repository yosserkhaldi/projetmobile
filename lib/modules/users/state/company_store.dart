import 'package:flutter/foundation.dart';

import 'package:mon_constat_digital/core/network/api_client.dart';
import 'package:mon_constat_digital/modules/users/data/users_database.dart';
import 'package:mon_constat_digital/modules/users/models/company.dart';

/// Référentiel des compagnies d'assurance et de leurs agences.
///
/// Utilisable par tous les modules : `AppScope.of(context).companies`.
/// La liste vient de l'API et une copie est gardée en SQLite, pour choisir un
/// assureur même sans réseau (constat sur les lieux de l'accident).
class CompanyStore extends ChangeNotifier {
  CompanyStore(this._api, this._db);

  final ApiClient _api;
  final UsersDatabase? _db;

  List<Company> companies = const [];

  /// La liste affichée vient de la copie locale (pas de réseau).
  bool offline = false;

  /// Date de la copie locale affichée hors ligne.
  DateTime? syncedAt;

  Company? byId(String? id) {
    for (final company in companies) {
      if (company.id == id) return company;
    }
    return null;
  }

  /// Charge depuis l'API et met la copie locale à jour. Sans réseau, reprend
  /// la copie locale ; l'erreur n'est relancée que s'il n'y en a pas.
  Future<void> load() async {
    try {
      final response = await _api.get('/companies') as Map<String, dynamic>;
      companies = [
        for (final item in response['items'] as List)
          Company.fromJson(item as Map<String, dynamic>),
      ];
      offline = false;
      syncedAt = DateTime.now();
      notifyListeners();
      await _db?.replaceCompanies(companies);
    } on ApiException catch (error) {
      if (!error.isNetwork || _db == null) rethrow;
      final cached = await _db.loadCompanies();
      if (cached.isEmpty) rethrow;
      companies = cached;
      offline = true;
      syncedAt = await _db.companiesSyncedAt();
      notifyListeners();
    }
  }
}
