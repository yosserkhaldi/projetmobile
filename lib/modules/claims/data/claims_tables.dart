import 'package:drift/drift.dart';

/// Tables SQLite du module 5.
///
/// Aucune clé étrangère vers les tables des autres modules : ce fichier reste
/// indépendant de leur avancement.
@DataClassName('ClaimRow')
class Claims extends Table {
  TextColumn get id => text()();
  TextColumn get type => text()();
  TextColumn get place => text()();
  TextColumn get date => text()();
  TextColumn get status => text()();
  TextColumn get severity => text()();
  TextColumn get observations => text().withDefault(const Constant(''))();

  /// Listes encodées en JSON.
  TextColumn get circumstances => text().withDefault(const Constant('[]'))();
  TextColumn get impactZones => text().withDefault(const Constant('[]'))();

  TextColumn get agentName => text().nullable()();
  TextColumn get expertName => text().nullable()();
  DateTimeColumn get expertAppointment => dateTime().nullable()();
  IntColumn get responsibility => integer().nullable()();
  RealColumn get indemnity => real().nullable()();
  TextColumn get decisionReason => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('TimelineEventRow')
class ClaimTimelineEvents extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get claimId =>
      text().references(Claims, #id, onDelete: KeyAction.cascade)();
  TextColumn get label => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('DocumentRow')
@TableIndex(name: 'claim_documents_uid', columns: {#uid}, unique: true)
class ClaimDocuments extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uid => text().withDefault(const Constant(''))();
  TextColumn get claimId =>
      text().references(Claims, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text()();
  TextColumn get kind => text().withDefault(const Constant('Pièce'))();
  TextColumn get path => text().nullable()();
  TextColumn get requestId => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('DocumentRequestRow')
class DocumentRequests extends Table {
  TextColumn get id => text()();
  TextColumn get claimId =>
      text().references(Claims, #id, onDelete: KeyAction.cascade)();
  TextColumn get label => text()();
  TextColumn get note => text().withDefault(const Constant(''))();
  TextColumn get documentId => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// [claimId] est vide pour une notification sans dossier (alerte de contrat).
/// [audience] est le rôle destinataire : `driver` ou `agent`.
@DataClassName('NotificationRow')
@TableIndex(name: 'claim_notifications_uid', columns: {#uid}, unique: true)
class ClaimNotifications extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uid => text().withDefault(const Constant(''))();
  TextColumn get claimId => text().nullable()();
  TextColumn get audience => text().withDefault(const Constant('driver'))();
  TextColumn get body => text()();
  BoolColumn get isRead => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('ChatMessageRow')
@TableIndex(name: 'chat_messages_uid', columns: {#uid}, unique: true)
class ChatMessages extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uid => text().withDefault(const Constant(''))();
  TextColumn get claimId => text().nullable()();
  TextColumn get author => text()();
  TextColumn get senderRole => text().withDefault(const Constant('driver'))();
  TextColumn get body => text()();
  TextColumn get attachmentName => text().nullable()();
  TextColumn get attachmentPath => text().nullable()();
  BoolColumn get isRead => boolean().withDefault(const Constant(true))();
  DateTimeColumn get sentAt => dateTime().withDefault(currentDateAndTime)();
}

/// File d'attente vers l'API : une ligne par changement à envoyer.
@DataClassName('OutboxRow')
class SyncOutbox extends Table {
  IntColumn get seq => integer().autoIncrement()();
  TextColumn get id => text().unique()();
  TextColumn get method => text()();
  TextColumn get path => text()();
  TextColumn get body => text().withDefault(const Constant('{}'))();
  TextColumn get filePath => text().nullable()();
}
