import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mon_constat_digital/core/network/api_client.dart';
import 'package:mon_constat_digital/core/network/token_storage.dart';
import 'package:mon_constat_digital/core/state/app_scope.dart';

class MemoryStorage implements SessionStorage {
  final values = <String, String>{};

  /// Simule un stockage illisible.
  bool broken = false;

  @override
  Future<String?> read(String key) async {
    if (broken) throw StateError('stockage illisible');
    return values[key];
  }

  @override
  Future<void> write(String key, String value) async => values[key] = value;

  @override
  Future<void> delete(String key) async => values.remove(key);
}

Map<String, dynamic> userJson({
  String id = 'u1',
  String firstName = 'Sami',
  String lastName = 'Ben Ali',
  String email = 'sami@example.com',
  String phone = '+21620000001',
  bool phoneVerified = true,
  String role = 'DRIVER',
  bool active = true,
}) => {
  'id': id,
  'firstName': firstName,
  'lastName': lastName,
  'email': email,
  'phone': phone,
  'phoneVerified': phoneVerified,
  'role': role,
  'active': active,
  'language': 'FR',
  'licenseNumber': null,
  'licenseCategory': null,
  'licenseIssuedAt': null,
  'company': null,
};

/// Imite l'API sans réseau. `user` est le compte renvoyé à la connexion.
class FakeBackend {
  FakeBackend({Map<String, dynamic>? user}) : user = user ?? userJson();

  Map<String, dynamic> user;
  final storage = MemoryStorage();
  final requests = <String>[];
  final bodies = <String, Map<String, dynamic>>{};

  /// Le serveur est injoignable.
  bool offline = false;

  /// Le prochain jeton présenté sera refusé (401), comme un jeton expiré.
  String validAccessToken = 'access-1';
  int refreshCount = 0;
  bool refreshAllowed = true;
  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> companies = [];

  /// Réponses d'erreur forcées : `'POST /auth/login'` vers (status, code, message).
  final failures = <String, (int, String, String)>{};

  late final http.Client client = MockClient(_handle);

  late final AppStores stores = AppStores(
    storage: storage,
    api: ApiClient(storage: storage, httpClient: client, baseUrl: 'http://api'),
  );

  Map<String, dynamic> _session() => {
    'user': user,
    'accessToken': validAccessToken,
    'refreshToken': 'refresh-$refreshCount',
  };

  Future<http.Response> _handle(http.Request request) async {
    if (offline) throw http.ClientException('offline');
    final route = '${request.method} ${request.url.path}';
    requests.add(route);
    if (request.body.isNotEmpty) {
      bodies[route] = jsonDecode(request.body) as Map<String, dynamic>;
    }

    final failure = failures[route];
    if (failure != null) {
      return _json(failure.$1, {
        'error': {'code': failure.$2, 'message': failure.$3},
      });
    }

    switch (route) {
      case 'POST /auth/login':
      case 'POST /auth/register':
        return _json(200, _session());
      case 'POST /auth/refresh':
        if (!refreshAllowed) {
          return _json(401, {
            'error': {
              'code': 'SESSION_EXPIRED',
              'message': 'Session expirée. Reconnectez-vous.',
            },
          });
        }
        refreshCount += 1;
        validAccessToken = 'access-${refreshCount + 1}';
        return _json(200, _session());
      case 'POST /auth/logout':
      case 'POST /auth/phone/send':
      case 'POST /auth/password/forgot':
      case 'POST /auth/password/reset':
        return http.Response('', 204);
    }

    // Toutes les routes ci-dessous exigent un jeton valide.
    if (request.headers['Authorization'] != 'Bearer $validAccessToken') {
      return _json(401, {
        'error': {'code': 'TOKEN_INVALID', 'message': 'Jeton invalide.'},
      });
    }

    final path = request.url.path;
    if (route == 'POST /auth/phone/verify') {
      user = {...user, 'phoneVerified': true};
      return _json(200, {'user': user});
    }
    if (route == 'GET /users/me') return _json(200, {'user': user});
    if (route == 'PATCH /users/me') {
      user = {...user, ...bodies[route]!};
      return _json(200, {'user': user});
    }
    if (route == 'GET /users') {
      return _json(200, {
        'items': users,
        'total': users.length,
        'page': 1,
        'pageSize': 100,
      });
    }
    final status = RegExp(r'^/users/(.+)/status$').firstMatch(path);
    if (status != null) {
      final index = users.indexWhere((u) => u['id'] == status[1]);
      users[index] = {...users[index], ...bodies[route]!};
      return _json(200, {'user': users[index]});
    }
    if (route == 'GET /companies') return _json(200, {'items': companies});
    if (route == 'POST /companies') {
      companies = [
        ...companies,
        {'id': 'c${companies.length}', ...bodies[route]!, 'agencies': []},
      ];
      return _json(201, {'company': companies.last});
    }
    return _json(404, {
      'error': {'code': 'NOT_FOUND', 'message': 'Route inconnue : $route'},
    });
  }

  http.Response _json(int status, Object body) => http.Response(
    jsonEncode(body),
    status,
    headers: {'content-type': 'application/json; charset=utf-8'},
  );
}
