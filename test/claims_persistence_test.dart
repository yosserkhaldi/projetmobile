import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mon_constat_digital/core/state/app_scope.dart';
import 'package:mon_constat_digital/modules/claims/data/claims_database.dart';
import 'package:mon_constat_digital/modules/claims/models/claim.dart';
import 'package:mon_constat_digital/modules/claims/screens/claim_detail_screen.dart';
import 'package:mon_constat_digital/modules/claims/state/claim_store.dart';
import 'package:mon_constat_digital/modules/claims/state/message_store.dart';

void main() {
  late Directory dir;
  late File file;

  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);

  setUp(() {
    dir = Directory.systemTemp.createTempSync('claims_test');
    file = File('${dir.path}/claims.sqlite');
  });
  tearDown(() => dir.deleteSync(recursive: true));

  /// Ouvre le fichier, exécute [body], puis ferme : comme un lancement de l'app.
  Future<void> session(Future<void> Function(ClaimsDatabase db) body) async {
    final db = ClaimsDatabase(NativeDatabase(file));
    await body(db);
    await db.close();
  }

  test('les données de démonstration sont écrites une seule fois', () async {
    for (var launch = 0; launch < 2; launch++) {
      await session((db) async {
        final claims = ClaimStore(dao: db.claimsDao);
        final messages = MessageStore(dao: db.claimsDao);
        await claims.saved;
        await messages.saved;
        expect(claims.claims.map((c) => c.id), ['SIN-2026-0418']);
        expect(claims.notifications, [
          'Votre dossier SIN-2026-0418 est en instruction.',
          'Votre contrat expire dans 7 jours.',
        ]);
        expect(messages.messages, hasLength(2));
      });
    }
  });

  test('un dossier et son suivi survivent au redémarrage', () async {
    await session((db) async {
      final store = ClaimStore(dao: db.claimsDao);
      await store.saved;
      final claim = Claim(
        id: 'SIN-1',
        type: 'Collision',
        place: 'Sfax',
        date: '2026-11-07 10:00',
        severity: 'Corporel',
        status: 'Transmis',
      );
      claim.timeline.addAll(['Déclaration complétée', 'Double signature']);
      store.addClaim(claim);
      store.updateClaim(claim, 'En instruction');
      store.addDocument(claim);
      await store.saved;
    });

    await session((db) async {
      final store = ClaimStore(dao: db.claimsDao);
      await store.saved;
      expect(store.claims.map((c) => c.id), ['SIN-1', 'SIN-2026-0418']);
      final claim = store.claims.first;
      expect(claim.status, 'En instruction');
      expect(claim.severity, 'Corporel');
      expect(claim.timeline, [
        'Brouillon créé',
        'Déclaration complétée',
        'Double signature',
        'En instruction',
      ]);
      expect(claim.documents, ['Document-1.pdf']);
      expect(store.notifications.first, 'SIN-1 : En instruction');
      expect(store.notifications, hasLength(3));
    });
  });

  test('les messages survivent au redémarrage, dans l’ordre', () async {
    await session((db) async {
      final store = MessageStore(dao: db.claimsDao);
      await store.saved;
      store.sendMessage('Sami Ben Ali', '  Devis envoyé  ');
      store.sendMessage('Sami Ben Ali', '   ');
      await store.saved;
    });

    await session((db) async {
      final store = MessageStore(dao: db.claimsDao);
      await store.saved;
      expect(store.messages, hasLength(3));
      expect(store.messages.last.text, 'Devis envoyé');
    });
  });

  test('sans base disponible, le store continue en mémoire', () async {
    final db = ClaimsDatabase(NativeDatabase.memory());
    await db.close();
    final store = ClaimStore(dao: db.claimsDao);
    await store.saved;

    store.addClaim(
      Claim(id: 'SIN-2', type: 'Vol', place: 'Tunis', date: 'hier'),
    );
    await store.saved;

    expect(store.claims.first.id, 'SIN-2');
    expect(store.claims, hasLength(2));
  });

  group('écran dossier agent', () {
    Future<Claim> pumpDetail(WidgetTester tester, String status) async {
      tester.view.physicalSize = const Size(430, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final claim = Claim(
        id: 'SIN-3',
        type: 'Collision',
        place: 'Tunis',
        date: 'hier',
        status: status,
      );
      await tester.pumpWidget(
        AppScope(
          stores: AppStores(),
          child: MaterialApp(home: ClaimDetail(claim, agentMode: true)),
        ),
      );
      return claim;
    }

    testWidgets('ouvre un dossier au statut Transmis', (tester) async {
      await pumpDetail(tester, 'Transmis');
      expect(tester.takeException(), isNull);
      expect(find.text('Instruction'), findsOneWidget);
    });

    testWidgets('reste ouvert après une décision', (tester) async {
      final claim = await pumpDetail(tester, 'En instruction');
      await tester.tap(find.text('Enregistrer la décision'));
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(claim.status, 'Décision enregistrée');
    });
  });
}
