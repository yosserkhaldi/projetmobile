import 'dart:convert';

import 'package:drift/drift.dart';

import 'package:mon_constat_digital/modules/claims/data/claims_database.dart';
import 'package:mon_constat_digital/modules/claims/data/claims_tables.dart';
import 'package:mon_constat_digital/modules/claims/models/chat_message.dart';
import 'package:mon_constat_digital/modules/claims/models/claim.dart';
import 'package:mon_constat_digital/modules/claims/models/claim_notification.dart';
import 'package:mon_constat_digital/modules/users/models/app_user.dart';

part 'claims_dao.g.dart';

/// Lectures et écritures SQLite du module 5. Convertit les lignes en modèles.
@DriftAccessor(
  tables: [
    Claims,
    ClaimTimelineEvents,
    ClaimDocuments,
    DocumentRequests,
    ClaimNotifications,
    ChatMessages,
    SyncOutbox,
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
    final requests = await (select(
      documentRequests,
    )..orderBy([(t) => OrderingTerm.asc(t.rowId)])).get();

    return rows.map((row) {
      final claim = Claim(
        id: row.id,
        type: row.type,
        place: row.place,
        date: row.date,
        status: row.status,
        severity: row.severity,
        observations: row.observations,
        agentName: row.agentName,
        expertName: row.expertName,
        expertAppointment: row.expertAppointment,
        responsibility: row.responsibility,
        indemnity: row.indemnity,
        decisionReason: row.decisionReason,
      );
      claim.circumstances.addAll(_decodeList(row.circumstances));
      claim.impactZones.addAll(_decodeList(row.impactZones));

      final claimEvents = events.where((e) => e.claimId == row.id).toList();
      claim.timeline
        ..clear()
        ..addAll(claimEvents.map((e) => e.label));
      claim.timelineDates.addAll({
        for (final (index, event) in claimEvents.indexed)
          index: event.createdAt,
      });

      claim.documents.addAll(
        documents
            .where((d) => d.claimId == row.id)
            .map(
              (d) => ClaimDocument(
                id: d.uid,
                name: d.name,
                kind: d.kind,
                path: d.path,
                requestId: d.requestId,
              ),
            ),
      );
      claim.requests.addAll(
        requests
            .where((r) => r.claimId == row.id)
            .map(
              (r) => DocumentRequest(
                id: r.id,
                label: r.label,
                note: r.note,
                documentId: r.documentId,
              ),
            ),
      );
      return claim;
    }).toList();
  }

  List<String> _decodeList(String json) =>
      (jsonDecode(json) as List<dynamic>).cast<String>();

  ClaimsCompanion _fields(Claim claim) => ClaimsCompanion(
    type: Value(claim.type),
    place: Value(claim.place),
    date: Value(claim.date),
    status: Value(claim.status),
    severity: Value(claim.severity),
    observations: Value(claim.observations),
    circumstances: Value(jsonEncode(claim.circumstances)),
    impactZones: Value(jsonEncode(claim.impactZones)),
    agentName: Value(claim.agentName),
    expertName: Value(claim.expertName),
    expertAppointment: Value(claim.expertAppointment),
    responsibility: Value(claim.responsibility),
    indemnity: Value(claim.indemnity),
    decisionReason: Value(claim.decisionReason),
  );

  Future<void> insertClaim(Claim claim) => transaction(() async {
    await into(claims).insert(_fields(claim).copyWith(id: Value(claim.id)));
    for (final label in claim.timeline) {
      await insertEvent(claim.id, label);
    }
    for (final document in claim.documents) {
      await insertDocument(claim.id, document);
    }
    for (final request in claim.requests) {
      await insertRequest(claim.id, request);
    }
  });

  /// Enregistre les champs du dossier et, si besoin, une étape de chronologie.
  Future<void> saveClaim(Claim snapshot, {String? event}) =>
      transaction(() async {
        await (update(
          claims,
        )..where((t) => t.id.equals(snapshot.id))).write(_fields(snapshot));
        if (event != null) await insertEvent(snapshot.id, event);
      });

  Future<void> insertEvent(String claimId, String label) => into(
    claimTimelineEvents,
  ).insert(ClaimTimelineEventsCompanion.insert(claimId: claimId, label: label));

  Future<void> insertDocument(String claimId, ClaimDocument document) =>
      into(claimDocuments).insert(
        ClaimDocumentsCompanion.insert(
          uid: Value(document.id),
          claimId: claimId,
          name: document.name,
          kind: Value(document.kind),
          path: Value(document.path),
          requestId: Value(document.requestId),
        ),
      );

  Future<void> insertRequest(String claimId, DocumentRequest request) =>
      into(documentRequests).insert(
        DocumentRequestsCompanion.insert(
          id: request.id,
          claimId: claimId,
          label: request.label,
          note: Value(request.note),
          documentId: Value(request.documentId),
        ),
      );

  Future<void> fulfillRequest(String requestId, String documentId) =>
      (update(documentRequests)..where((t) => t.id.equals(requestId))).write(
        DocumentRequestsCompanion(documentId: Value(documentId)),
      );

  /// Notifications de la plus récente à la plus ancienne.
  Future<List<ClaimNotification>> loadNotifications() async {
    final rows = await (select(
      claimNotifications,
    )..orderBy([(t) => OrderingTerm.desc(t.id)])).get();
    return rows
        .map(
          (row) => ClaimNotification(
            id: row.uid,
            body: row.body,
            audience: UserRole.values.byName(row.audience),
            claimId: row.claimId,
            createdAt: row.createdAt,
            read: row.isRead,
          ),
        )
        .toList();
  }

  Future<void> insertNotification(ClaimNotification notification) =>
      into(claimNotifications).insert(
        ClaimNotificationsCompanion.insert(
          uid: Value(notification.id),
          body: notification.body,
          audience: Value(notification.audience.name),
          claimId: Value(notification.claimId),
          isRead: Value(notification.read),
          createdAt: Value(notification.createdAt),
        ),
      );

  Future<void> markNotificationsRead(Iterable<String> ids) =>
      (update(claimNotifications)..where((t) => t.uid.isIn(ids))).write(
        const ClaimNotificationsCompanion(isRead: Value(true)),
      );

  /// Messages du plus ancien au plus récent.
  Future<List<ChatMessage>> loadMessages() async {
    final rows = await (select(
      chatMessages,
    )..orderBy([(t) => OrderingTerm.asc(t.id)])).get();
    return rows
        .map(
          (row) => ChatMessage(
            id: row.uid,
            claimId: row.claimId ?? '',
            author: row.author,
            senderRole: UserRole.values.byName(row.senderRole),
            text: row.body,
            sentAt: row.sentAt,
            attachmentName: row.attachmentName,
            attachmentPath: row.attachmentPath,
            read: row.isRead,
          ),
        )
        .toList();
  }

  Future<void> insertMessage(ChatMessage message) => into(chatMessages).insert(
    ChatMessagesCompanion.insert(
      uid: Value(message.id),
      claimId: Value(message.claimId),
      author: message.author,
      senderRole: Value(message.senderRole.name),
      body: message.text,
      attachmentName: Value(message.attachmentName),
      attachmentPath: Value(message.attachmentPath),
      isRead: Value(message.read),
      sentAt: Value(message.sentAt),
    ),
  );

  Future<void> markMessagesRead(Iterable<String> ids) =>
      (update(chatMessages)..where((t) => t.uid.isIn(ids))).write(
        const ChatMessagesCompanion(isRead: Value(true)),
      );
}
