import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mon_constat_digital/core/network/api_client.dart';
import 'package:mon_constat_digital/core/network/token_storage.dart';
import 'package:mon_constat_digital/core/state/app_scope.dart';
import 'package:mon_constat_digital/modules/users/data/biometric_auth.dart';

/// Plus petit PNG valide (1 × 1 pixel).
final tinyPng = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==',
);

/// Capteur biométrique simulé.
class FakeBiometric implements BiometricAuth {
  bool available = true;

  /// Réponse de l'utilisateur : reconnu (true) ou annulation (false).
  bool accept = true;
  int prompts = 0;

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<bool> authenticate(String reason) async {
    prompts += 1;
    return accept;
  }
}

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
  final headers = <String, Map<String, String>>{};
  final uploads = <String, http.Request>{};
  final biometric = FakeBiometric();
  int deviceKeys = 0;

  /// Le serveur est injoignable.
  bool offline = false;

  /// Le prochain jeton présenté sera refusé (401), comme un jeton expiré.
  String validAccessToken = 'access-1';
  int refreshCount = 0;
  bool refreshAllowed = true;
  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> companies = [];

  /// Appareils connectés : le premier est celui qui fait la requête.
  List<Map<String, dynamic>> sessions = [
    {
      'id': 's-current',
      'deviceName': 'Pixel de test',
      'ip': '127.0.0.1',
      'createdAt': '2026-11-07T08:00:00.000Z',
      'lastUsedAt': '2026-11-07T09:00:00.000Z',
      'current': true,
    },
    {
      'id': 's-pc',
      'deviceName': 'Chrome (web)',
      'ip': '10.0.0.2',
      'createdAt': '2026-11-06T08:00:00.000Z',
      'lastUsedAt': '2026-11-06T18:00:00.000Z',
      'current': false,
    },
  ];
  List<Map<String, dynamic>> loginEvents = [
    {
      'id': 'e2',
      'success': false,
      'method': 'password',
      'reason': 'wrong_password',
      'deviceName': 'Chrome (web)',
      'ip': '10.0.0.2',
      'createdAt': '2026-11-06T17:59:00.000Z',
    },
    {
      'id': 'e1',
      'success': true,
      'method': 'password',
      'reason': null,
      'deviceName': 'Pixel de test',
      'ip': '127.0.0.1',
      'createdAt': '2026-11-07T08:00:00.000Z',
    },
  ];
  List<Map<String, dynamic>> pendingIdentities = [];

  /// Réponses d'erreur forcées : `'POST /auth/login'` vers (status, code, message).
  final failures = <String, (int, String, String)>{};

  late final http.Client client = MockClient(_handle);

  late final AppStores stores = AppStores(
    storage: storage,
    biometric: biometric,
    deviceHeaders: (_) async => {
      'X-Device-Id': 'device-test',
      'X-Device-Name': 'Pixel de test',
    },
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
    headers[route] = request.headers;
    final type = request.headers['Content-Type'] ?? '';
    if (type.startsWith('application/json')) {
      bodies[route] = jsonDecode(request.body) as Map<String, dynamic>;
    } else if (type.startsWith('multipart/')) {
      uploads[route] = request;
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
      case 'POST /auth/biometric/login':
        deviceKeys += 1;
        return _json(200, {..._session(), 'deviceToken': 'device-$deviceKeys'});
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
    if (route == 'POST /auth/biometric') {
      deviceKeys += 1;
      return _json(201, {
        'deviceToken': 'device-$deviceKeys',
        'expiresAt': '2026-12-07T00:00:00.000Z',
      });
    }
    if (route == 'DELETE /auth/biometric') return http.Response('', 204);
    if (route == 'PUT /users/me/photo') {
      user = {...user, 'photoId': 'photo-${uploads.length}.jpg'};
      return _json(200, {'user': user});
    }
    if (route == 'GET /users/${user['id']}/photo') {
      return http.Response.bytes(tinyPng, 200);
    }
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
    if (route == 'GET /users/me/sessions') {
      return _json(200, {'items': sessions});
    }
    final revoke = RegExp(r'^/users/me/sessions/([^/]+)$').firstMatch(path);
    if (revoke != null && request.method == 'DELETE') {
      sessions = [
        for (final s in sessions)
          if (s['id'] != revoke[1]) s,
      ];
      return http.Response('', 204);
    }
    if (route == 'POST /users/me/sessions/revoke-others') {
      final others = sessions.where((s) => s['current'] != true).length;
      sessions = [
        for (final s in sessions)
          if (s['current'] == true) s,
      ];
      return _json(200, {'revoked': others});
    }
    if (route == 'GET /users/me/login-events') {
      return _json(200, {'items': loginEvents});
    }
    if (route == 'POST /users/me/identity/submit') {
      final identity = Map<String, dynamic>.from(
        user['identity'] as Map? ?? {},
      );
      user = {
        ...user,
        'identity': {
          ...identity,
          'status': 'PENDING',
          'cinNumber': bodies[route]!['cinNumber'],
          'submittedAt': '2026-11-07T10:00:00.000Z',
          'rejectionReason': null,
        },
      };
      return _json(200, {'user': user});
    }
    if (route == 'GET /users/identity/pending') {
      return _json(200, {'items': pendingIdentities});
    }
    final decision = RegExp(
      r'^/users/([^/]+)/identity/(approve|reject)$',
    ).firstMatch(path);
    if (decision != null) {
      final index = pendingIdentities.indexWhere((u) => u['id'] == decision[1]);
      final decided = {
        ...pendingIdentities.removeAt(index),
        'identity': {
          'status': decision[2] == 'approve' ? 'VERIFIED' : 'REJECTED',
          'rejectionReason': bodies[route]?['reason'],
        },
      };
      return _json(200, {'user': decided});
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
