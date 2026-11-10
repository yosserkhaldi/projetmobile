import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mon_constat_digital/core/network/api_client.dart';
import 'package:mon_constat_digital/modules/users/data/users_database.dart';
import 'package:mon_constat_digital/modules/users/models/app_user.dart';
import 'package:mon_constat_digital/modules/users/models/company.dart';
import 'package:mon_constat_digital/modules/users/state/company_store.dart';

import 'support/fake_backend.dart';

AppUser sami({String licence = '12/345678'}) => AppUser.fromJson({
  ...userJson(),
  'licenseNumber': licence,
  'licenseCategory': 'B',
  'licenseIssuedAt': '2015-06-01',
  'identity': {'status': 'VERIFIED', 'cinNumber': '12345678'},
});

const star = Company(
  id: 'c-star',
  name: 'STAR Assurances',
  agencies: [
    Agency(id: 'a2', name: 'Agence Lac', city: 'Tunis'),
    Agency(id: 'a1', name: 'Agence Ariana', city: 'Ariana'),
  ],
);
const comar = Company(id: 'c-comar', name: 'COMAR', agencies: []);

void main() {
  late UsersDatabase db;

  setUp(() => db = UsersDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  group('profil hors ligne', () {
    test('enregistré, relu tel quel, puis effacé', () async {
      expect(await db.loadProfile(), isNull);
      await db.saveProfile(sami());

      final saved = await db.loadProfile();
      expect(saved!.name, 'Sami Ben Ali');
      expect(saved.licenseNumber, '12/345678');
      expect(saved.identity.status, IdentityStatus.verified);
      expect(saved.identity.cinNumber, '12345678');

      await db.clearProfile();
      expect(await db.loadProfile(), isNull);
    });

    test('une seule ligne : la nouvelle version remplace l ancienne', () async {
      await db.saveProfile(sami());
      await db.saveProfile(sami(licence: '99/000001'));
      expect((await db.loadProfile())!.licenseNumber, '99/000001');
      expect(await db.select(db.cachedProfiles).get(), hasLength(1));
    });
  });

  group("file d'attente hors ligne", () {
    test('les modifications du même type sont fusionnées', () async {
      await db.enqueue('profile', {'firstName': 'Samir', 'phone': '20111222'});
      await db.enqueue('profile', {'firstName': 'Sam', 'licenseNumber': 'X1'});
      final rows = await db.pending();
      expect(rows, hasLength(1));
      expect(jsonDecode(rows.single.payload), {
        'firstName': 'Sam',
        'phone': '20111222',
        'licenseNumber': 'X1',
      });
    });

    test(
      'refus enregistré, puis effacé par une nouvelle modification',
      () async {
        await db.enqueue('profile', {'phone': '20111222'});
        final id = (await db.pending()).single.id;
        await db.markFailed(id, 'Téléphone déjà utilisé.');
        var row = (await db.pending()).single;
        expect(row.lastError, 'Téléphone déjà utilisé.');
        expect(row.attempts, 1);

        await db.enqueue('profile', {'phone': '20333444'});
        row = (await db.pending()).single;
        expect(row.lastError, isNull);
      },
    );

    test('suppression d une ligne et vidage complet', () async {
      await db.enqueue('profile', {'firstName': 'A'});
      await db.enqueue('language', {'language': 'AR'});
      final rows = await db.pending();
      expect(rows.map((r) => r.kind), ['profile', 'language']);
      await db.removePending(rows.first.id);
      expect((await db.pending()).single.kind, 'language');
      await db.clearPending();
      expect(await db.pending(), isEmpty);
    });
  });

  group('référentiel des compagnies', () {
    test('triées par nom, agences rattachées et triées', () async {
      await db.replaceCompanies([star, comar]);
      final list = await db.loadCompanies();
      expect(list.map((c) => c.name), ['COMAR', 'STAR Assurances']);
      expect(list[1].agencies.map((a) => a.name), [
        'Agence Ariana',
        'Agence Lac',
      ]);
      expect(await db.companiesSyncedAt(), isNotNull);
    });

    test('la nouvelle liste remplace entièrement l ancienne', () async {
      await db.replaceCompanies([star, comar]);
      await db.replaceCompanies([comar]);
      final list = await db.loadCompanies();
      expect(list.map((c) => c.id), ['c-comar']);
      expect(await db.select(db.agencies).get(), isEmpty);
    });
  });

  group('CompanyStore', () {
    late FakeBackend backend;
    late CompanyStore store;

    setUp(() {
      backend = FakeBackend()
        ..companies = [
          {
            'id': 'c-star',
            'name': 'STAR Assurances',
            'agencies': [
              {'id': 'a1', 'name': 'Agence Lac', 'city': 'Tunis'},
            ],
          },
        ];
      final api = ApiClient(
        storage: backend.storage,
        httpClient: backend.client,
        baseUrl: 'http://api',
      );
      store = CompanyStore(api, db);
      return api.openSession({
        'accessToken': 'access-1',
        'refreshToken': 'refresh-0',
      });
    });

    test('en ligne : liste du serveur, copiée en SQLite', () async {
      await store.load();
      expect(store.offline, isFalse);
      expect(store.byId('c-star')!.agencies.single.city, 'Tunis');
      final cached = await db.loadCompanies();
      expect(cached.single.name, 'STAR Assurances');
    });

    test('hors ligne : reprend la copie SQLite et le signale', () async {
      await store.load();
      backend.offline = true;
      final offlineStore = CompanyStore(
        ApiClient(
          storage: backend.storage,
          httpClient: backend.client,
          baseUrl: 'http://api',
        ),
        db,
      );
      await offlineStore.load();
      expect(offlineStore.offline, isTrue);
      expect(offlineStore.companies.single.name, 'STAR Assurances');
      expect(offlineStore.syncedAt, isNotNull);
    });

    test('hors ligne sans copie : l erreur réseau remonte', () async {
      backend.offline = true;
      await expectLater(
        store.load(),
        throwsA(isA<ApiException>().having((e) => e.isNetwork, 'réseau', true)),
      );
    });
  });
}
