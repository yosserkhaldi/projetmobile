import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:drift/native.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mon_constat_digital/core/network/api_client.dart';
import 'package:mon_constat_digital/core/network/token_storage.dart';
import 'package:mon_constat_digital/core/state/app_scope.dart';
import 'package:mon_constat_digital/modules/users/data/biometric_auth.dart';
import 'package:mon_constat_digital/modules/users/data/users_database.dart';
import 'package:mon_constat_digital/modules/users/screens/liveness_screen.dart';
import 'package:mon_constat_digital/modules/users/services/face_guide.dart';

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
  FakeBackend({Map<String, dynamic>? user, UsersDatabase? usersDb})
    : user = user ?? userJson(),
      usersDb = usersDb ?? UsersDatabase(NativeDatabase.memory());

  /// SQLite du module 1, en mémoire. Partagée pour simuler un redémarrage.
  final UsersDatabase usersDb;

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

  /// Permis signalés par l'IA, en attente d'un administrateur.
  List<Map<String, dynamic>> licenseReviews = [];

  /// Décision de l'IA simulée sur le prochain permis scanné.
  String licenseStatusAfterScan = 'VERIFIED';

  /// Ressemblance pièce / visage que l'IA du serveur simulé renvoie.
  double aiMatch = 0.9;

  /// Ce que l'OCR simulé lit sur la photo du permis (null : illisible).
  Map<String, dynamic>? licenseReading = {
    'number': '12/345678',
    'categories': ['B', 'B+E'],
    'issuedAt': '2018-06-15',
    'expiresAt': null,
  };

  /// Ce que l'OCR simulé lit sur le recto (données fictives).
  Map<String, dynamic> documentReading = {
    'number': '12345678',
    'lastNameAr': 'بن علي',
    'firstNameAr': 'سامي',
    'parentsAr': 'بن محمد بن صالح',
    'birthDate': '1999-03-12',
    'birthPlaceAr': 'صفاقس',
  };

  /// Réponses d'erreur forcées : `'POST /auth/login'` vers (status, code, message).
  final failures = <String, (int, String, String)>{};

  late final http.Client client = MockClient(_handle);

  late final AppStores stores = AppStores(
    storage: storage,
    biometric: biometric,
    usersDb: usersDb,
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
    // Photo du permis : l'IA simulée lit la carte, sans rien enregistrer.
    if (route == 'PUT /users/me/license-photo') {
      user = {
        ...user,
        'licensePhotoId': 'permis-${requests.length}.jpg',
        'license': {'status': licenseStatusAfterScan},
      };
      return _json(200, {'user': user, 'extracted': licenseReading});
    }
    // Recto de la pièce : l'IA simulée « lit » la carte.
    if (route == 'PUT /users/me/identity/front' ||
        route == 'POST /users/me/identity/front/from-license') {
      final type = route.startsWith('POST')
          ? 'LICENSE'
          : RegExp(
                  r'name="documentType"\s+(\w+)',
                ).firstMatch(latin1.decode(uploads[route]!.bodyBytes))?[1] ??
                'CIN';
      user = {
        ...user,
        'identity': {
          ...Map<String, dynamic>.from(user['identity'] as Map? ?? {}),
          'documentType': type,
          'frontId': 'front-${requests.length}.jpg',
          'extracted': {'type': type, ...documentReading},
        },
      };
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
    if (route == 'GET /users/stats') {
      return _json(200, {
        'users': {
          'total': 12,
          'active': 11,
          'suspended': 1,
          'phoneVerified': 9,
          'byRole': {'DRIVER': 9, 'AGENT': 2, 'ADMIN': 1},
        },
        'identity': {
          'UNVERIFIED': 4,
          'PENDING': 2,
          'VERIFIED': 3,
          'REJECTED': 0,
        },
        'licensesToReview': licenseReviews.length,
        'signIns7Days': {'success': 25, 'failed': 3},
        'companies': 3,
        'agencies': 5,
        'identityAi': {
          'requests': 8,
          'autoVerified': 5,
          'adminVerified': 1,
          'rejected': 1,
          'pending': 1,
          'autoRate': 0.63,
          'averageMatch': 0.71,
          'blocked': 1,
        },
        'signups': [
          for (var i = 0; i < 30; i += 1)
            {
              'date': '2026-10-${(i % 28 + 1).toString().padLeft(2, '0')}',
              'count': i % 3,
            },
        ],
      });
    }
    if (route == 'GET /users/me/export') {
      return _json(200, {
        'exportedAt': '2026-11-08T10:00:00.000Z',
        'legalBasis': 'Loi organique n° 2004-63',
        'account': user,
        'devices': sessions,
        'signIns': loginEvents,
      });
    }
    if (route == 'DELETE /users/me') return http.Response('', 204);
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
    if (route == 'POST /users/me/identity/liveness') {
      return _json(200, {
        'token': 'challenge-1',
        'steps': ['center', 'right', 'left'],
      });
    }
    if (route == 'POST /users/me/identity/selfie') {
      user = {
        ...user,
        'identity': {
          ...Map<String, dynamic>.from(user['identity'] as Map? ?? {}),
          'selfieId': 'selfie.jpg',
          'livenessAt': DateTime.now().toUtc().toIso8601String(),
        },
      };
      return _json(200, {'user': user});
    }
    if (route == 'POST /users/me/identity/submit') {
      final identity = Map<String, dynamic>.from(
        user['identity'] as Map? ?? {},
      );
      final automatic = aiMatch >= 0.6;
      user = {
        ...user,
        'identity': {
          ...identity,
          'status': automatic ? 'VERIFIED' : 'PENDING',
          'documentType': bodies[route]!['documentType'],
          'cinNumber': bodies[route]!['number'],
          'faceMatch': aiMatch,
          'autoVerified': automatic,
          if (automatic) 'selfieId': null,
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
    // Administration du permis et de l'identité d'un compte.
    if (route == 'GET /users/licenses/review') {
      return _json(200, {'items': licenseReviews});
    }
    final photo = RegExp(
      r'^/users/([^/]+)/(license-photo|identity/front|identity/back)$',
    ).firstMatch(path);
    if (photo != null && request.method == 'GET') {
      return http.Response.bytes(tinyPng, 200);
    }
    final account = RegExp(
      r'^/users/([^/]+)(/license(?:/(approve|reject))?|/identity/revoke)?$',
    ).firstMatch(path);
    if (account != null) {
      final found = _account(account[1]!);
      if (found == null) {
        return _json(404, {
          'error': {'code': 'NOT_FOUND', 'message': 'Compte introuvable.'},
        });
      }
      final body = bodies[route];
      final cleared = {
        'licenseNumber': null,
        'licenseCategory': null,
        'licenseIssuedAt': null,
        'licensePhotoId': null,
      };
      final updated = switch ((request.method, account[2], account[3])) {
        ('GET', null, _) => found,
        ('POST', _, 'approve') => {
          ...found,
          'license': {..._map(found['license']), 'status': 'VERIFIED'},
        },
        ('POST', _, 'reject') => {
          ...found,
          ...cleared,
          'license': {'status': 'REJECTED', 'rejectionReason': body?['reason']},
        },
        ('PATCH', '/license', _) => {...found, ...?body},
        ('DELETE', '/license', _) => {...found, ...cleared, 'license': null},
        ('POST', '/identity/revoke', _) => {
          ...found,
          'identity': {
            'status': 'REJECTED',
            'rejectionReason': body?['reason'],
          },
        },
        _ => null,
      };
      if (updated != null) {
        _saveAccount(updated);
        return _json(200, {'user': updated});
      }
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

  static Map<String, dynamic> _map(Object? value) =>
      Map<String, dynamic>.from(value as Map? ?? {});

  /// Compte connu du serveur simulé : liste des comptes ou file des permis.
  Map<String, dynamic>? _account(String id) {
    for (final account in [...users, ...licenseReviews]) {
      if (account['id'] == id) return account;
    }
    return null;
  }

  /// Remplace le compte partout ; décidé, son permis quitte la file.
  void _saveAccount(Map<String, dynamic> account) {
    users = [for (final u in users) u['id'] == account['id'] ? account : u];
    licenseReviews = [
      for (final u in licenseReviews)
        if (u['id'] != account['id'])
          u
        else if (_map(account['license'])['status'] == 'TO_REVIEW')
          account,
    ];
  }

  http.Response _json(int status, Object body) => http.Response(
    jsonEncode(body),
    status,
    headers: {'content-type': 'application/json; charset=utf-8'},
  );
}

/// Caméra simulée de la vérification du visage.
class FakeFaceCamera implements FaceCamera {
  FakeFaceCamera({this.fail = false});
  final bool fail;

  @override
  Future<void> open() async {
    if (fail) throw StateError('camera denied');
  }

  @override
  Widget preview() => const ColoredBox(color: Colors.black);

  @override
  Future<Uint8List> capture() async => tinyPng;

  @override
  Future<void> close() async {}
}

/// Détection simulée sur le téléphone : renvoie les poses dans l'ordre
/// (null : aucun visage), puis la dernière indéfiniment.
class FakeFaceGuide implements FaceGuide {
  FakeFaceGuide(this.poses);
  final List<FacePose?> poses;
  int seen = 0;

  @override
  Future<FacePose?> poseOf(Uint8List jpeg) async =>
      poses[seen < poses.length ? seen++ : poses.length - 1];

  @override
  Future<void> close() async {}
}
