import 'package:flutter/foundation.dart';

import 'package:mon_constat_digital/core/network/api_client.dart';
import 'package:mon_constat_digital/modules/users/models/app_user.dart';
import 'package:mon_constat_digital/modules/users/models/identity_attempt.dart';
import 'package:mon_constat_digital/modules/users/models/company.dart';
import 'package:mon_constat_digital/modules/users/state/company_store.dart';

/// Comptes et compagnies. La lecture des compagnies est ouverte à tous les
/// comptes connectés, le reste est réservé aux administrateurs.
class AdminStore extends ChangeNotifier {
  AdminStore(this._api, this._companies);

  final ApiClient _api;

  /// Référentiel partagé (copie SQLite comprise), voir CompanyStore.
  final CompanyStore _companies;

  List<AppUser> users = const [];
  int usersTotal = 0;
  List<Company> get companies => _companies.companies;

  /// Statistiques des comptes pour le tableau de bord.
  Map<String, dynamic>? stats;

  Future<void> loadStats() async {
    stats = await _api.get('/users/stats') as Map<String, dynamic>;
    notifyListeners();
  }

  /// Identités en attente de vérification, les plus anciennes d'abord.
  List<AppUser> pendingIdentities = const [];

  Future<void> loadUsers({String query = '', UserRole? role}) async {
    final response =
        await _api.get(
              '/users',
              query: {
                if (query.isNotEmpty) 'q': query,
                'role': ?role?.apiValue,
                'pageSize': '100',
              },
            )
            as Map<String, dynamic>;
    users = (response['items'] as List)
        .map((user) => AppUser.fromJson(user as Map<String, dynamic>))
        .toList();
    usersTotal = response['total'] as int;
    notifyListeners();
  }

  Future<void> setActive(AppUser user, bool active) async {
    _replaceUser(
      await _api.patch('/users/${user.id}/status', body: {'active': active}),
    );
  }

  Future<void> setRole(AppUser user, UserRole role, {String? companyId}) async {
    _replaceUser(
      await _api.patch(
        '/users/${user.id}/role',
        body: {'role': role.apiValue, 'companyId': ?companyId},
      ),
    );
  }

  Future<void> createAgent({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    required String companyId,
  }) async {
    await _api.post(
      '/users/agents',
      body: {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phone': phone,
        'password': password,
        'companyId': companyId,
      },
    );
    await loadUsers();
  }

  Future<void> loadPendingIdentities() async {
    final response =
        await _api.get('/users/identity/pending') as Map<String, dynamic>;
    pendingIdentities = [
      for (final user in response['items'] as List)
        AppUser.fromJson(user as Map<String, dynamic>),
    ];
    notifyListeners();
  }

  Future<void> approveIdentity(AppUser user) =>
      _decideIdentity(_api.post('/users/${user.id}/identity/approve'), user);

  /// Débloque la vérification d'un compte (refus grave ou 3e refus).
  Future<void> unblockIdentity(AppUser user) async {
    await _api.post('/users/${user.id}/identity/unblock');
    await loadUsers();
  }

  /// Demandes passées d'un compte, les plus récentes d'abord.
  Future<List<IdentityAttempt>> identityAttempts(AppUser user) async {
    final body =
        await _api.get('/users/${user.id}/identity/attempts')
            as Map<String, dynamic>;
    return [
      for (final item in body['items'] as List)
        IdentityAttempt.fromJson(item as Map<String, dynamic>),
    ];
  }

  /// Refus. `severe` : refus définitif, plus de nouvelle demande.
  Future<void> rejectIdentity(AppUser user, IdentityRejection rejection) =>
      _decideIdentity(
        _api.post(
          '/users/${user.id}/identity/reject',
          body: {'reason': rejection.reason, 'severe': rejection.severe},
        ),
        user,
      );

  Future<void> _decideIdentity(Future<dynamic> decision, AppUser user) async {
    await decision;
    pendingIdentities = [
      for (final pending in pendingIdentities)
        if (pending.id != user.id) pending,
    ];
    notifyListeners();
  }

  /// Dossier complet d'un compte (identité et permis, même validés par l'IA).
  Future<AppUser> fetchUser(String id) async =>
      _applyUser(await _api.get('/users/$id'));

  /// Permis à vérifier : un contrôle croisé a échoué ou rien n'a pu être lu.
  List<AppUser> licenseReviews = const [];

  Future<void> loadLicenseReviews() async {
    final response =
        await _api.get('/users/licenses/review') as Map<String, dynamic>;
    licenseReviews = [
      for (final user in response['items'] as List)
        AppUser.fromJson(user as Map<String, dynamic>),
    ];
    notifyListeners();
  }

  Future<AppUser> approveLicense(AppUser user) =>
      _license(_api.post('/users/${user.id}/license/approve'));

  /// Refus : photo et informations effacées, le conducteur voit le motif.
  Future<AppUser> rejectLicense(AppUser user, String reason) => _license(
    _api.post('/users/${user.id}/license/reject', body: {'reason': reason}),
  );

  /// Correction des informations du permis.
  Future<AppUser> updateLicense(AppUser user, Map<String, dynamic> fields) =>
      _license(_api.patch('/users/${user.id}/license', body: fields));

  Future<AppUser> deleteLicense(AppUser user) =>
      _license(_api.delete('/users/${user.id}/license'));

  /// Annule une vérification d'identité, même validée par l'IA.
  Future<AppUser> revokeIdentity(AppUser user, String reason) async {
    final updated = _applyUser(
      await _api.post(
        '/users/${user.id}/identity/revoke',
        body: {'reason': reason},
      ),
    );
    _refreshStats();
    return updated;
  }

  Future<AppUser> _license(Future<dynamic> change) async {
    final updated = _applyUser(await change);
    // Décidé : le permis quitte la file.
    if (updated.license.status != LicenseStatus.toReview) {
      licenseReviews = [
        for (final user in licenseReviews)
          if (user.id != updated.id) user,
      ];
      notifyListeners();
    }
    _refreshStats();
    return updated;
  }

  /// Compteurs du tableau de bord à jour après une décision, sans attendre.
  void _refreshStats() {
    if (stats == null) return;
    loadStats().catchError((Object _) {});
  }

  /// Remplace le compte modifié dans les listes et le renvoie.
  AppUser _applyUser(dynamic response) {
    final updated = AppUser.fromJson(
      (response as Map<String, dynamic>)['user'] as Map<String, dynamic>,
    );
    users = [for (final user in users) user.id == updated.id ? updated : user];
    notifyListeners();
    return updated;
  }

  Future<void> loadCompanies() => _companies.load();

  Future<void> createCompany(String name) =>
      _thenReload(_api.post('/companies', body: {'name': name}));

  Future<void> renameCompany(Company company, String name) =>
      _thenReload(_api.patch('/companies/${company.id}', body: {'name': name}));

  Future<void> deleteCompany(Company company) =>
      _thenReload(_api.delete('/companies/${company.id}'));

  Future<void> addAgency(Company company, String name, String city) =>
      _thenReload(
        _api.post(
          '/companies/${company.id}/agencies',
          body: {'name': name, 'city': city},
        ),
      );

  Future<void> updateAgency(
    Company company,
    Agency agency,
    String name,
    String city,
  ) => _thenReload(
    _api.patch(
      '/companies/${company.id}/agencies/${agency.id}',
      body: {'name': name, 'city': city},
    ),
  );

  Future<void> deleteAgency(Company company, Agency agency) => _thenReload(
    _api.delete('/companies/${company.id}/agencies/${agency.id}'),
  );

  Future<void> _thenReload(Future<dynamic> change) async {
    await change;
    await loadCompanies();
  }

  void _replaceUser(dynamic response) {
    final updated = AppUser.fromJson(
      (response as Map<String, dynamic>)['user'] as Map<String, dynamic>,
    );
    users = [for (final user in users) user.id == updated.id ? updated : user];
    notifyListeners();
  }
}
