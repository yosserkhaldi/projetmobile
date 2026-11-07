import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mon_constat_digital/modules/claims/data/claims_database.dart';
import 'package:mon_constat_digital/modules/claims/models/claim.dart';
import 'package:mon_constat_digital/modules/claims/models/claim_status.dart';
import 'package:mon_constat_digital/modules/claims/state/claim_store.dart';
import 'package:mon_constat_digital/modules/claims/state/message_store.dart';
import 'package:mon_constat_digital/modules/users/models/app_user.dart';

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

  Claim newClaim() => Claim(
    id: 'SIN-1',
    type: 'Collision',
    place: 'Sfax',
    date: '2026-11-07 10:00',
    severity: 'Grave',
    status: ClaimStatus.transmitted,
  );

  test('les données de démonstration sont écrites une seule fois', () async {
    for (var launch = 0; launch < 2; launch++) {
      await session((db) async {
        final claims = ClaimStore(dao: db.claimsDao);
        final messages = MessageStore(dao: db.claimsDao);
        await claims.saved;
        await messages.saved;
        expect(claims.claims.map((c) => c.id), ['SIN-2026-0418']);
        expect(claims.notifications.first.body, contains('en instruction'));
        expect(claims.notifications, hasLength(2));
        expect(messages.messages, hasLength(2));
      });
    }
  });

  test('tout le suivi d’un dossier survit au redémarrage', () async {
    final appointment = DateTime(2026, 12, 1);
    await session((db) async {
      final store = ClaimStore(dao: db.claimsDao);
      await store.saved;
      final claim = newClaim()
        ..circumstances.add('Reculait')
        ..impactZones.add('Avant')
        ..observations = 'Pluie';
      store.addClaim(claim);
      store.takeCharge(claim, 'Leïla Mansour');
      store.requestDocument(claim, 'Devis', note: 'Garage agréé');
      store.addDocument(
        claim,
        'devis.pdf',
        path: '/tmp/devis.pdf',
        request: claim.openRequests.first,
      );
      store.scheduleExpertise(claim, 'M. Trabelsi', appointment);
      store.addExpertReport(claim, 'rapport.pdf');
      store.closeClaim(claim, 100, 1250.5);
      await store.saved;
    });

    await session((db) async {
      final store = ClaimStore(dao: db.claimsDao);
      await store.saved;
      expect(store.claims.map((c) => c.id), ['SIN-1', 'SIN-2026-0418']);
      final claim = store.claims.first;
      expect(claim.status, ClaimStatus.closed);
      expect(claim.severity, 'Grave');
      expect(claim.agentName, 'Leïla Mansour');
      expect(claim.circumstances, ['Reculait']);
      expect(claim.impactZones, ['Avant']);
      expect(claim.observations, 'Pluie');
      expect(claim.expertName, 'M. Trabelsi');
      expect(claim.expertAppointment, appointment);
      expect(claim.responsibility, 100);
      expect(claim.indemnity, 1250.5);
      expect(claim.timeline, [
        'Brouillon créé',
        ClaimStatus.inReview,
        'Pièce demandée : Devis',
        ClaimStatus.inReview,
        ClaimStatus.expertise,
        'Rapport d’expertise joint',
        ClaimStatus.closed,
      ]);
      expect(claim.timelineDates, hasLength(7));
      expect(claim.documents.map((d) => d.name), ['devis.pdf', 'rapport.pdf']);
      expect(claim.documents.first.path, '/tmp/devis.pdf');
      expect(claim.documents.last.kind, ClaimDocument.expertReport);
      expect(claim.requests.single.note, 'Garage agréé');
      expect(claim.requests.single.isOpen, isFalse);
    });
  });

  test('l’état lu des notifications survit au redémarrage', () async {
    await session((db) async {
      final store = ClaimStore(dao: db.claimsDao);
      await store.saved;
      store.markAllNotificationsRead(UserRole.driver);
      store.addClaim(newClaim());
      await store.saved;
    });
    await session((db) async {
      final store = ClaimStore(dao: db.claimsDao);
      await store.saved;
      expect(store.unreadCount(UserRole.driver), 0);
      expect(store.unreadCount(UserRole.agent), 1);
    });
  });

  test('messages, pièces jointes et accusés survivent, par dossier', () async {
    await session((db) async {
      final store = MessageStore(dao: db.claimsDao);
      await store.saved;
      store.sendMessage('SIN-1', 'Sami', UserRole.driver, '  Devis envoyé  ');
      store.sendMessage('SIN-1', 'Sami', UserRole.driver, '   ');
      store.sendMessage(
        'SIN-1',
        'Sami',
        UserRole.driver,
        '',
        attachmentName: 'devis.pdf',
      );
      store.markRead('SIN-1', UserRole.agent);
      await store.saved;
    });
    await session((db) async {
      final store = MessageStore(dao: db.claimsDao);
      await store.saved;
      final messages = store.messagesFor('SIN-1');
      expect(messages, hasLength(2));
      expect(messages.first.text, 'Devis envoyé');
      expect(messages.last.attachmentName, 'devis.pdf');
      expect(messages.every((m) => m.read), isTrue);
      expect(store.messagesFor('SIN-2026-0418'), hasLength(2));
    });
  });

  test('sans base disponible, le store continue en mémoire', () async {
    final db = ClaimsDatabase(NativeDatabase.memory());
    await db.close();
    final store = ClaimStore(dao: db.claimsDao);
    await store.saved;

    store.addClaim(newClaim());
    await store.saved;

    expect(store.claims.first.id, 'SIN-1');
    expect(store.claims, hasLength(2));
  });

  test('la migration v1 vers v2 garde les données', () async {
    final v1 = ClaimsDatabase(
      NativeDatabase(
        file,
        setup: (raw) {
          if (raw.userVersion != 0) return;
          raw.execute('''
            CREATE TABLE claims (id TEXT NOT NULL PRIMARY KEY, type TEXT NOT NULL,
              place TEXT NOT NULL, date TEXT NOT NULL, status TEXT NOT NULL,
              severity TEXT NOT NULL);
            CREATE TABLE claim_timeline_events (
              id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
              claim_id TEXT NOT NULL REFERENCES claims (id) ON DELETE CASCADE,
              label TEXT NOT NULL,
              created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')));
            CREATE TABLE claim_documents (
              id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
              claim_id TEXT NOT NULL REFERENCES claims (id) ON DELETE CASCADE,
              name TEXT NOT NULL,
              created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')));
            CREATE TABLE claim_notifications (
              id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, claim_id TEXT,
              body TEXT NOT NULL, is_read INTEGER NOT NULL DEFAULT 0,
              created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')));
            CREATE TABLE chat_messages (
              id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, claim_id TEXT,
              author TEXT NOT NULL, body TEXT NOT NULL,
              is_read INTEGER NOT NULL DEFAULT 1,
              sent_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')));
            INSERT INTO claims VALUES
              ('A', 'Vol', 'Tunis', 'x', 'Accepté', 'Léger'),
              ('B', 'Vol', 'Tunis', 'x', 'Expertise planifiée', 'Léger'),
              ('C', 'Vol', 'Tunis', 'x', 'Décision enregistrée', 'Léger');
            INSERT INTO claim_timeline_events (claim_id, label) VALUES ('A', 'Accepté');
            INSERT INTO claim_documents (claim_id, name) VALUES ('A', 'a.pdf'), ('A', 'b.pdf');
            INSERT INTO claim_notifications (body) VALUES ('n1'), ('n2');
            INSERT INTO chat_messages (claim_id, author, body) VALUES
              ('A', 'Agent Leïla', 'm1'), ('A', 'Sami', 'm2');
            PRAGMA user_version = 1;
          ''');
        },
      ),
    );
    final claims = ClaimStore(dao: v1.claimsDao);
    final messages = MessageStore(dao: v1.claimsDao);
    await claims.saved;
    await messages.saved;

    final statuses = {for (final c in claims.claims) c.id: c.status};
    expect(statuses, {
      'A': ClaimStatus.closed,
      'B': ClaimStatus.expertise,
      'C': ClaimStatus.inReview,
    });
    final documents = claims.claimById('A')!.documents;
    expect(documents.map((d) => d.name), ['a.pdf', 'b.pdf']);
    expect(documents.first.id, isNot(documents.last.id));
    expect(documents.first.id, isNotEmpty);
    expect(claims.notifications, hasLength(2));
    expect(messages.messages.map((m) => m.senderRole), [
      UserRole.agent,
      UserRole.driver,
    ]);
    await v1.close();
  });
}
