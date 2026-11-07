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
class ClaimDocuments extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get claimId =>
      text().references(Claims, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// [claimId] est vide pour une notification sans dossier (alerte de contrat).
@DataClassName('NotificationRow')
class ClaimNotifications extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get claimId => text().nullable()();
  TextColumn get body => text()();
  BoolColumn get isRead => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('ChatMessageRow')
class ChatMessages extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get claimId => text().nullable()();
  TextColumn get author => text()();
  TextColumn get body => text()();
  BoolColumn get isRead => boolean().withDefault(const Constant(true))();
  DateTimeColumn get sentAt => dateTime().withDefault(currentDateAndTime)();
}
