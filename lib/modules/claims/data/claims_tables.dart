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
  TextColumn get expertPhone => text().nullable()();
  TextColumn get expertPlace => text().nullable()();
  TextColumn get expertKind => text().nullable()();
  TextColumn get appointmentState => text().nullable()();
  TextColumn get appointmentBy => text().nullable()();
  TextColumn get appointmentNote => text().nullable()();
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

  /// Lecture de la pièce par l'IA, encodée en JSON.
  TextColumn get analysis => text().nullable()();
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
  BoolColumn get multipart => boolean().withDefault(const Constant(false))();
  TextColumn get filePath => text().nullable()();

  /// Contenu du fichier quand le navigateur ne donne pas de chemin.
  BlobColumn get fileBytes => blob().nullable()();
  TextColumn get fileName => text().nullable()();

  /// Auteur du changement : le rôle actif peut changer avant l'envoi.
  TextColumn get actorId => text()();
  TextColumn get actorRole => text()();
  TextColumn get actorName => text()();
}

/// Dernière analyse reçue du serveur, lisible hors ligne.
@DataClassName('ClaimInsightRow')
class ClaimInsights extends Table {
  TextColumn get claimId => text()();
  TextColumn get json => text()();

  @override
  Set<Column> get primaryKey => {claimId};
}
