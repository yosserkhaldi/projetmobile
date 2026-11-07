import 'package:flutter_test/flutter_test.dart';
import 'package:mon_constat_digital/core/network/api_client.dart';

import 'support/fake_backend.dart';

void main() {
  late FakeBackend backend;
  late ApiClient api;

  setUp(() async {
    backend = FakeBackend();
    // Seulement le client : pas besoin du reste de l'application.
    api = ApiClient(
      storage: backend.storage,
      httpClient: backend.client,
      baseUrl: 'http://api',
    );
    await api.openSession({
      'accessToken': 'access-1',
      'refreshToken': 'refresh-0',
    });
  });

  test('jeton valide : aucune demande de renouvellement', () async {
    await api.get('/users/me');
    expect(backend.requests, ['GET /users/me']);
  });

  test('jeton expiré : renouvelle puis rejoue la requête', () async {
    backend.validAccessToken = 'autre-jeton';
    final response = await api.get('/users/me') as Map;
    expect(response['user'], isNotNull);
    expect(backend.requests, [
      'GET /users/me',
      'POST /auth/refresh',
      'GET /users/me',
    ]);
    expect(backend.storage.values['refresh_token'], 'refresh-1');
  });

  test('requêtes simultanées : un seul renouvellement', () async {
    backend.validAccessToken = 'autre-jeton';
    await Future.wait([
      api.get('/users/me'),
      api.get('/users/me'),
      api.get('/companies'),
    ]);
    expect(backend.refreshCount, 1);
  });

  test('renouvellement refusé : session fermée et signalée', () async {
    backend
      ..validAccessToken = 'autre-jeton'
      ..refreshAllowed = false;
    var expired = 0;
    api.onSessionExpired = () => expired += 1;
    await expectLater(
      api.get('/users/me'),
      throwsA(
        isA<ApiException>().having((e) => e.code, 'code', 'SESSION_EXPIRED'),
      ),
    );
    expect(expired, 1);
    expect(await api.hasStoredSession(), isFalse);
  });

  test('sans réseau : la session est conservée', () async {
    backend.offline = true;
    await expectLater(
      api.get('/users/me'),
      throwsA(isA<ApiException>().having((e) => e.isNetwork, 'réseau', isTrue)),
    );
    expect(await api.hasStoredSession(), isTrue);
  });

  test(
    'envoi de fichier : rejoué avec un nouveau jeton après un 401',
    () async {
      backend.validAccessToken = 'autre-jeton';
      await api.upload(
        '/users/me/photo',
        field: 'photo',
        bytes: [1, 2, 3],
        filename: 'a.jpg',
      );
      expect(backend.requests, [
        'PUT /users/me/photo',
        'POST /auth/refresh',
        'PUT /users/me/photo',
      ]);
    },
  );

  test('téléchargement protégé : renvoie les octets', () async {
    expect(await api.getBytes('/users/u1/photo'), tinyPng);
  });

  test("erreur métier : garde le code et le message de l'API", () async {
    backend.failures['GET /companies'] = (409, 'CONFLICT', 'Message clair.');
    await expectLater(
      api.get('/companies'),
      throwsA(
        isA<ApiException>()
            .having((e) => e.status, 'status', 409)
            .having((e) => e.code, 'code', 'CONFLICT')
            .having((e) => e.message, 'message', 'Message clair.'),
      ),
    );
  });
}
