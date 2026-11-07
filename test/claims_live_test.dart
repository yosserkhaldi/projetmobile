import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mon_constat_digital/modules/claims/data/claims_api.dart';
import 'package:mon_constat_digital/modules/claims/data/claims_database.dart';
import 'package:mon_constat_digital/modules/claims/models/claim.dart';
import 'package:mon_constat_digital/modules/claims/models/claim_status.dart';
import 'package:mon_constat_digital/modules/claims/state/claim_store.dart';
import 'package:mon_constat_digital/modules/claims/state/claims_sync.dart';
import 'package:mon_constat_digital/modules/claims/state/message_store.dart';
import 'package:mon_constat_digital/modules/users/models/app_user.dart';
import 'package:mon_constat_digital/modules/users/state/user_store.dart';

/// Deux téléphones contre la vraie API :
/// `LIVE_API_URL=http://localhost:3000 flutter test test/claims_live_test.dart`
void main() {
  final url = Platform.environment['LIVE_API_URL'];

  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);

  Future<(ClaimStore, MessageStore, ClaimsSync)> phone(UserRole role) async {
    final db = ClaimsDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final claims = ClaimStore(dao: db.claimsDao);
    final messages = MessageStore(dao: db.claimsDao);
    await claims.saved;
    await messages.saved;
    final users = UserStore()
      ..setRole(role)
      ..updateProfile(
        role == UserRole.agent ? 'Leïla Mansour' : 'Sami Ben Ali',
        'Français',
        false,
      );
    final sync = ClaimsSync(
      api: ClaimsApi(url!),
      dao: db.claimsDao,
      claims: claims,
      messages: messages,
      users: users,
    );
    addTearDown(sync.dispose);
    return (claims, messages, sync);
  }

  /// Attend qu'une mise à jour arrive en direct, sans rien demander.
  Future<void> until(bool Function() test) async {
    for (var i = 0; i < 100; i++) {
      if (test()) return;
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
    fail('Mise à jour en direct non reçue');
  }

  test(
    'le conducteur et l’agent suivent le même dossier en direct',
    skip: url == null ? 'LIVE_API_URL absent' : false,
    () async {
      final (driverClaims, driverChat, driverSync) = await phone(
        UserRole.driver,
      );
      final (agentClaims, agentChat, agentSync) = await phone(UserRole.agent);
      await driverSync.synchronize();
      await agentSync.synchronize();
      driverSync.connect();
      agentSync.connect();
      await Future<void>.delayed(const Duration(milliseconds: 500));

      final id = 'SIN-LIVE-${DateTime.now().millisecondsSinceEpoch}';
      driverClaims.addClaim(
        Claim(
            id: id,
            type: 'Collision',
            place: 'Sousse',
            date: '2026-11-07 10:00',
            severity: 'Grave',
            status: ClaimStatus.transmitted,
          )
          ..circumstances.add('Reculait')
          ..timeline.add('Transmis aux assureurs'),
      );

      await until(() => agentClaims.claimById(id) != null);
      final seen = agentClaims.claimById(id)!;
      expect(seen.circumstances, ['Reculait']);

      agentClaims.takeCharge(seen, 'Leïla Mansour');
      final mine = driverClaims.claimById(id)!;
      await until(() => mine.status == ClaimStatus.inReview);
      expect(mine.agentName, 'Leïla Mansour');

      agentClaims.requestDocument(seen, 'Devis', note: 'Garage agréé');
      await until(() => mine.openRequests.length == 1);
      expect(mine.status, ClaimStatus.documentRequested);
      expect(
        driverClaims.notifications.map((n) => n.body),
        contains('$id : Pièce demandée : Devis'),
      );

      final path = '${Directory.systemTemp.path}/devis_live.pdf';
      File(path).writeAsStringSync('devis');
      driverClaims.addDocument(
        mine,
        'devis.pdf',
        path: path,
        request: mine.openRequests.first,
      );
      await until(() => seen.status == ClaimStatus.inReview);
      expect(seen.documents.single.name, 'devis.pdf');
      final bytes = await agentSync.api.download(
        'document',
        seen.documents.single.id,
        agentSync.identity,
      );
      expect(String.fromCharCodes(bytes), 'devis');

      driverChat.sendMessage(id, 'Sami Ben Ali', UserRole.driver, 'Merci');
      await until(() => agentChat.messagesFor(id).length == 1);
      expect(agentChat.messagesFor(id).single.author, 'Sami Ben Ali');

      agentChat.markRead(id, UserRole.agent);
      await until(() => driverChat.messagesFor(id).single.read);

      agentClaims.closeClaim(seen, 100, 1250.5);
      await until(() => mine.status == ClaimStatus.closed);
      expect(mine.indemnity, 1250.5);
      expect(mine.responsibility, 100);
    },
    timeout: const Timeout(Duration(seconds: 40)),
  );
}
