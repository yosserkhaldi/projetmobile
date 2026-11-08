import 'package:flutter/foundation.dart';

import 'package:mon_constat_digital/core/network/api_client.dart';
import 'package:mon_constat_digital/modules/users/models/app_user.dart';
import 'package:mon_constat_digital/modules/users/models/company.dart';

/// Comptes et compagnies. La lecture des compagnies est ouverte à tous les
/// comptes connectés, le reste est réservé aux administrateurs.
class AdminStore extends ChangeNotifier {
  AdminStore(this._api);

  final ApiClient _api;

  List<AppUser> users = const [];
  int usersTotal = 0;
  List<Company> companies = const [];

  /// Statistiques des comptes pour le tableau de bord.
  Map<String, dynamic>? stats;

  Future<void> loadStats() async {
    stats = await _api.get('/users/stats') as Map<String, dynamic>;
    notifyListeners();
  }

  /// Identités en attente de vérification, les plus anciennes d'abord.
  List<AppUser> pendingIdentities = const [];

  Future<void> loadUsers({String query = ''}) async {
    final response =
        await _api.get(
              '/users',
              query: {if (query.isNotEmpty) 'q': query, 'pageSize': '100'},
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

  Future<void> rejectIdentity(AppUser user, String reason) => _decideIdentity(
    _api.post('/users/${user.id}/identity/reject', body: {'reason': reason}),
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

  Future<void> loadCompanies() async {
    final response = await _api.get('/companies') as Map<String, dynamic>;
    companies = (response['items'] as List)
        .map((company) => Company.fromJson(company as Map<String, dynamic>))
        .toList();
    notifyListeners();
  }

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
