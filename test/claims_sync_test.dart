import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mon_constat_digital/core/network/api_client.dart';
import 'package:mon_constat_digital/modules/claims/data/claims_api.dart';
import 'package:mon_constat_digital/modules/claims/data/claims_database.dart';
import 'package:mon_constat_digital/modules/claims/models/claim.dart';
import 'package:mon_constat_digital/modules/claims/models/claim_status.dart';
import 'package:mon_constat_digital/modules/claims/state/claim_store.dart';
import 'package:mon_constat_digital/modules/claims/state/claims_sync.dart';
import 'package:mon_constat_digital/modules/claims/state/message_store.dart';
import 'package:mon_constat_digital/modules/users/models/app_user.dart';
import 'package:mon_constat_digital/modules/users/state/user_store.dart';

import 'support/fake_backend.dart';

/// Serveur simulé : on choisit sa réponse et on garde les requêtes reçues.
class FakeServer {
  final requests = <http.Request>[];
  Object? failure;
  int status = 200;
  Map<String, dynamic> snapshot = {
    'claims': <Object>[],
    'notifications': <Object>[],
    'messages': <Object>[],
  };

  late final client = MockClient((request) async {
    if (failure case final error?) throw error;
    if (request.url.path.endsWith('/sync')) {
      return http.Response.bytes(utf8.encode(jsonEncode(snapshot)), 200);
    }
    requests.add(request);
    return http.Response('{}', status);
  });

  List<String> get paths =>
      requests.map((r) => r.url.path.replaceFirst('/api/claims', '')).toList();
}

Map<String, dynamic> serverClaim(String id, String status) => {
  'id': id,
  'type': 'Collision',
  'place': 'Tunis',
  'date': '12/10/2026 18:40',
  'status': status,
  'severity': 'Grave',
  'events': [
    {'label': status, 'createdAt': '2026-11-07T10:00:00.000Z'},
  ],
  'documents': <Object>[],
  'requests': <Object>[],
};

class Device {
  Device(this.db, this.server)
    : claims = ClaimStore(dao: db.claimsDao),
      messages = MessageStore(dao: db.claimsDao) {
    final storage = MemoryStorage();
    final client = ApiClient(
      storage: storage,
      httpClient: server.client,
      baseUrl: 'http://api.test/api',
    );
    users = UserStore(client, storage, FakeBiometric())
      ..currentUser = AppUser.fromJson(userJson());
    sync = ClaimsSync(
      api: ClaimsApi(client),
      dao: db.claimsDao,
      claims: claims,
      messages: messages,
      users: users,
    );
  }

  final ClaimsDatabase db;
  final FakeServer server;
  final ClaimStore claims;
  final MessageStore messages;
  late final UserStore users;
  late final ClaimsSync sync;

  Future<void> settle() async {
    await claims.saved;
    await messages.saved;
    await sync.synchronize();
  }

  Future<int> pending() async => (await db.claimsDao.pendingRequests()).length;
}

Claim newClaim() => Claim(
  id: 'SIN-1',
  type: 'Collision',
  place: 'Sfax',
  date: '2026-11-07 10:00',
  severity: 'Grave',
  status: ClaimStatus.transmitted,
);

void main() {
  late Directory dir;
  late File file;
  late FakeServer server;

  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);
  setUp(() {
    dir = Directory.systemTemp.createTempSync('sync_test');
    file = File('${dir.path}/claims.sqlite');
    server = FakeServer();
  });
  tearDown(() => dir.deleteSync(recursive: true));

  Future<Device> device() async {
    final value = Device(ClaimsDatabase(NativeDatabase(file)), server);
    await value.claims.saved;
    await value.messages.saved;
    addTearDown(value.db.close);
    return value;
  }

  test('hors ligne, tout reste local puis part dans l’ordre', () async {
    final phone = await device();
    server.failure = const SocketException('pas de réseau');

    final claim = newClaim();
    phone.claims.addClaim(claim);
    await phone.claims.saved;
    phone.messages.sendMessage('SIN-1', 'Sami', phone.sync.users.role, 'Salut');
    await phone.settle();

    expect(phone.sync.online, isFalse);
    expect(await phone.pending(), 2);
    expect(phone.claims.claims.first.id, 'SIN-1');

    server
      ..failure = null
      ..snapshot['claims'] = [serverClaim('SIN-1', ClaimStatus.transmitted)];
    await phone.sync.synchronize();

    expect(phone.sync.online, isTrue);
    expect(await phone.pending(), 0);
    expect(server.paths, ['', '/SIN-1/messages']);
  });

  test('un renvoi garde la même clé, sans perte ni doublon', () async {
    final phone = await device();
    server.status = 500;
    phone.claims.addClaim(newClaim());
    await phone.settle();
    expect(await phone.pending(), 1);

    server.status = 201;
    await phone.sync.synchronize();

    expect(server.requests.length, greaterThanOrEqualTo(2));
    final keys = server.requests.map((r) => r.headers['Idempotency-Key']);
    expect(keys.toSet(), hasLength(1));
    expect(keys.first, isNotEmpty);
    expect(await phone.pending(), 0);
  });

  test('une erreur serveur bloque la file pour garder l’ordre', () async {
    final phone = await device();
    final claim = newClaim();
    server.status = 503;
    phone.claims.addClaim(claim);
    phone.claims.takeCharge(claim, 'Leïla');
    await phone.settle();
    expect(server.paths.toSet(), {''});
    expect(await phone.pending(), 2);
  });

  test('la file survit au redémarrage de l’application', () async {
    server.failure = const SocketException('pas de réseau');
    final first = Device(ClaimsDatabase(NativeDatabase(file)), server);
    await first.claims.saved;
    first.claims.addClaim(newClaim());
    await first.settle();
    await first.db.close();

    server.failure = null;
    final second = await device();
    expect(await second.pending(), 1);
    await second.sync.synchronize();
    expect(await second.pending(), 0);
    expect(server.paths, ['']);
  });

  test('un refus métier sort de la file et le serveur fait foi', () async {
    final phone = await device();
    server.snapshot['claims'] = [serverClaim('SIN-1', ClaimStatus.transmitted)];
    await phone.settle();
    final claim = phone.claims.claimById('SIN-1')!;

    server
      ..status = 409
      ..snapshot['claims'] = [serverClaim('SIN-1', ClaimStatus.rejected)];
    phone.claims.takeCharge(claim, 'Leïla');
    expect(claim.status, ClaimStatus.inReview);
    await phone.settle();

    expect(await phone.pending(), 0);
    expect(claim.status, ClaimStatus.rejected);
  });

  test('une mise à jour garde l’objet ouvert à l’écran', () async {
    final phone = await device();
    server.snapshot['claims'] = [serverClaim('SIN-1', ClaimStatus.inReview)];
    await phone.settle();
    final opened = phone.claims.claimById('SIN-1')!;

    server.snapshot['claims'] = [serverClaim('SIN-1', ClaimStatus.expertise)];
    await phone.settle();

    expect(identical(phone.claims.claimById('SIN-1'), opened), isTrue);
    expect(opened.status, ClaimStatus.expertise);
    expect(opened.timeline, [ClaimStatus.expertise]);
    expect(opened.timelineDates[0], DateTime.utc(2026, 11, 7, 10).toLocal());
  });

  test('ne remplace rien tant qu’un changement attend', () async {
    final phone = await device();
    phone.claims.addClaim(newClaim());
    await phone.claims.saved;
    final done = await phone.db.claimsDao.replaceFromServer(
      const ServerSnapshot([], [], []),
    );
    expect(done, isFalse);
    final saved = await phone.db.claimsDao.loadClaims();
    expect(saved.map((c) => c.id), contains('SIN-1'));
  });

  test('sans synchronisation, aucune requête n’est mise en file', () async {
    final db = ClaimsDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final store = ClaimStore(dao: db.claimsDao);
    await store.saved;
    store.addClaim(newClaim());
    await store.saved;
    expect(await db.claimsDao.pendingRequests(), isEmpty);
  });

  test('un compte n’envoie pas les changements d’un autre', () async {
    final phone = await device();
    await phone.db.claimsDao.enqueue(
      const ApiRequest(
        id: 'autre',
        method: 'POST',
        path: '/SIN-9/take-charge',
        identity: (id: 'quelqu-un-d-autre', role: 'agent', name: 'Autre'),
      ),
    );
    await phone.settle();
    expect(server.paths, isEmpty);
    expect(await phone.pending(), 1);
  });

  test('sans utilisateur connecté, rien ne part', () async {
    final phone = await device();
    phone.users.currentUser = null;
    await phone.sync.synchronize();
    expect(server.requests, isEmpty);
  });
}
