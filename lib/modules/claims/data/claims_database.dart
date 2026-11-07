import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'package:mon_constat_digital/modules/claims/data/claims_dao.dart';
import 'package:mon_constat_digital/modules/claims/data/claims_tables.dart';

part 'claims_database.g.dart';

/// Base SQLite locale du module 5 (fichier `claims.sqlite`).
///
/// Après une modification des tables : augmenter [schemaVersion], ajouter la
/// migration, puis lancer `dart run build_runner build`.
@DriftDatabase(
  tables: [
    Claims,
    ClaimTimelineEvents,
    ClaimDocuments,
    DocumentRequests,
    ClaimNotifications,
    ChatMessages,
    SyncOutbox,
  ],
  daos: [ClaimsDao],
)
class ClaimsDatabase extends _$ClaimsDatabase {
  ClaimsDatabase(super.executor);

  /// Connexion unique de l'application. Elle ne s'ouvre qu'à la première
  /// requête. `test/flutter_test_config.dart` la remplace pendant les tests.
  static ClaimsDatabase shared = ClaimsDatabase(
    driftDatabase(
      name: 'claims',
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.js'),
      ),
    ),
  );

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 2) await _upgradeToV2(m);
    },
    beforeOpen: (_) => customStatement('PRAGMA foreign_keys = ON'),
  );

  Future<void> _upgradeToV2(Migrator m) async {
    for (final column in [
      claims.observations,
      claims.circumstances,
      claims.impactZones,
      claims.agentName,
      claims.expertName,
      claims.expertAppointment,
      claims.responsibility,
      claims.indemnity,
      claims.decisionReason,
    ]) {
      await m.addColumn(claims, column);
    }
    for (final column in [
      claimDocuments.uid,
      claimDocuments.kind,
      claimDocuments.path,
      claimDocuments.requestId,
    ]) {
      await m.addColumn(claimDocuments, column);
    }
    await m.addColumn(claimNotifications, claimNotifications.uid);
    await m.addColumn(claimNotifications, claimNotifications.audience);
    for (final column in [
      chatMessages.uid,
      chatMessages.senderRole,
      chatMessages.attachmentName,
      chatMessages.attachmentPath,
    ]) {
      await m.addColumn(chatMessages, column);
    }
    await m.createTable(documentRequests);
    await m.createTable(syncOutbox);

    for (final table in [
      'claim_documents',
      'claim_notifications',
      'chat_messages',
    ]) {
      await customStatement(
        "UPDATE $table SET uid = lower(hex(randomblob(16))) WHERE uid = ''",
      );
    }
    await customStatement(
      "UPDATE chat_messages SET sender_role = 'agent' "
      "WHERE author LIKE 'Agent%'",
    );
    // Statuts de la v1 qui ne font pas partie du cycle de vie.
    await customStatement(
      "UPDATE claims SET status = 'Expertise' "
      "WHERE status = 'Expertise planifiée'",
    );
    await customStatement(
      "UPDATE claims SET status = 'Clôturé' WHERE status = 'Accepté'",
    );
    await customStatement(
      "UPDATE claims SET status = 'En instruction' "
      "WHERE status = 'Décision enregistrée'",
    );

    await m.create(claimDocumentsUid);
    await m.create(claimNotificationsUid);
    await m.create(chatMessagesUid);
  }
}
