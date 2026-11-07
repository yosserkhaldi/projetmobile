import 'package:drift/drift.dart';

import 'package:mon_constat_digital/modules/claims/data/claims_database.dart';
import 'package:mon_constat_digital/modules/claims/data/claims_tables.dart';
import 'package:mon_constat_digital/modules/claims/models/chat_message.dart';
import 'package:mon_constat_digital/modules/claims/models/claim.dart';

part 'claims_dao.g.dart';

/// Lectures et écritures SQLite du module 5. Convertit les lignes en modèles.
@DriftAccessor(
  tables: [
    Claims,
    ClaimTimelineEvents,
    ClaimDocuments,
    ClaimNotifications,
    ChatMessages,
  ],
)
class ClaimsDao extends DatabaseAccessor<ClaimsDatabase> with _$ClaimsDaoMixin {
  ClaimsDao(super.attachedDatabase);

  /// Dossiers du plus récent au plus ancien.
  Future<List<Claim>> loadClaims() async {
    final rows = await (select(
      claims,
    )..orderBy([(t) => OrderingTerm.desc(t.rowId)])).get();
    final events = await (select(
      claimTimelineEvents,
    )..orderBy([(t) => OrderingTerm.asc(t.id)])).get();
    final documents = await (select(
      claimDocuments,
    )..orderBy([(t) => OrderingTerm.asc(t.id)])).get();

    return rows.map((row) {
      final claim = Claim(
        id: row.id,
        type: row.type,
        place: row.place,
        date: row.date,
        status: row.status,
        severity: row.severity,
      );
      claim.timeline
        ..clear()
        ..addAll(events.where((e) => e.claimId == row.id).map((e) => e.label));
      claim.documents.addAll(
        documents.where((d) => d.claimId == row.id).map((d) => d.name),
      );
      return claim;
    }).toList();
  }

  Future<void> insertClaim(Claim claim) => transaction(() async {
    await into(claims).insert(
      ClaimsCompanion.insert(
        id: claim.id,
        type: claim.type,
        place: claim.place,
        date: claim.date,
        status: claim.status,
        severity: claim.severity,
      ),
    );
    for (final label in claim.timeline) {
      await _insertEvent(claim.id, label);
    }
    for (final name in claim.documents) {
      await insertDocument(claim.id, name);
    }
  });

  /// Le statut, la chronologie et la notification changent ensemble.
  Future<void> recordStatusChange(
    String claimId,
    String status,
    String notification,
  ) => transaction(() async {
    await (update(claims)..where((t) => t.id.equals(claimId))).write(
      ClaimsCompanion(status: Value(status)),
    );
    await _insertEvent(claimId, status);
    await insertNotification(notification, claimId: claimId);
  });

  Future<void> insertDocument(String claimId, String name) => into(
    claimDocuments,
  ).insert(ClaimDocumentsCompanion.insert(claimId: claimId, name: name));

  Future<void> _insertEvent(String claimId, String label) => into(
    claimTimelineEvents,
  ).insert(ClaimTimelineEventsCompanion.insert(claimId: claimId, label: label));

  /// Notifications de la plus récente à la plus ancienne.
  Future<List<String>> loadNotifications() async {
    final rows = await (select(
      claimNotifications,
    )..orderBy([(t) => OrderingTerm.desc(t.id)])).get();
    return rows.map((row) => row.body).toList();
  }

  Future<void> insertNotification(String body, {String? claimId}) =>
      into(claimNotifications).insert(
        ClaimNotificationsCompanion.insert(body: body, claimId: Value(claimId)),
      );

  /// Messages du plus ancien au plus récent.
  Future<List<ChatMessage>> loadMessages() async {
    final rows = await (select(
      chatMessages,
    )..orderBy([(t) => OrderingTerm.asc(t.id)])).get();
    return rows
        .map((row) => ChatMessage(row.author, row.body, read: row.isRead))
        .toList();
  }

  Future<void> insertMessage(ChatMessage message, {String? claimId}) =>
      into(chatMessages).insert(
        ChatMessagesCompanion.insert(
          author: message.author,
          body: message.text,
          isRead: Value(message.read),
          claimId: Value(claimId),
        ),
      );
}
