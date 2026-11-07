// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'claims_dao.dart';

// ignore_for_file: type=lint
mixin _$ClaimsDaoMixin on DatabaseAccessor<ClaimsDatabase> {
  $ClaimsTable get claims => attachedDatabase.claims;
  $ClaimTimelineEventsTable get claimTimelineEvents =>
      attachedDatabase.claimTimelineEvents;
  $ClaimDocumentsTable get claimDocuments => attachedDatabase.claimDocuments;
  $DocumentRequestsTable get documentRequests =>
      attachedDatabase.documentRequests;
  $ClaimNotificationsTable get claimNotifications =>
      attachedDatabase.claimNotifications;
  $ChatMessagesTable get chatMessages => attachedDatabase.chatMessages;
  $SyncOutboxTable get syncOutbox => attachedDatabase.syncOutbox;
  $ClaimInsightsTable get claimInsights => attachedDatabase.claimInsights;
  ClaimsDaoManager get managers => ClaimsDaoManager(this);
}

class ClaimsDaoManager {
  final _$ClaimsDaoMixin _db;
  ClaimsDaoManager(this._db);
  $$ClaimsTableTableManager get claims =>
      $$ClaimsTableTableManager(_db.attachedDatabase, _db.claims);
  $$ClaimTimelineEventsTableTableManager get claimTimelineEvents =>
      $$ClaimTimelineEventsTableTableManager(
        _db.attachedDatabase,
        _db.claimTimelineEvents,
      );
  $$ClaimDocumentsTableTableManager get claimDocuments =>
      $$ClaimDocumentsTableTableManager(
        _db.attachedDatabase,
        _db.claimDocuments,
      );
  $$DocumentRequestsTableTableManager get documentRequests =>
      $$DocumentRequestsTableTableManager(
        _db.attachedDatabase,
        _db.documentRequests,
      );
  $$ClaimNotificationsTableTableManager get claimNotifications =>
      $$ClaimNotificationsTableTableManager(
        _db.attachedDatabase,
        _db.claimNotifications,
      );
  $$ChatMessagesTableTableManager get chatMessages =>
      $$ChatMessagesTableTableManager(_db.attachedDatabase, _db.chatMessages);
  $$SyncOutboxTableTableManager get syncOutbox =>
      $$SyncOutboxTableTableManager(_db.attachedDatabase, _db.syncOutbox);
  $$ClaimInsightsTableTableManager get claimInsights =>
      $$ClaimInsightsTableTableManager(_db.attachedDatabase, _db.claimInsights);
}
