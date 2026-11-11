import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:mon_constat_digital/core/data/drift_web.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import 'package:mon_constat_digital/modules/accident/models/accident_draft.dart';

part 'accident_database.g.dart';

const _databaseFileName = 'mon_constat_accidents.db';

class SavedAccidentDraft {
  const SavedAccidentDraft({required this.draft, required this.currentStep});

  final AccidentDraft draft;
  final int currentStep;
}

/// Table du brouillon de constat (une seule ligne, id = 1).
///
/// Les noms SQL (table et colonnes) sont identiques à l'ancienne version
/// sqflite : le fichier existant sur l'appareil est réutilisé tel quel.
@DataClassName('AccidentDraftRow')
class AccidentDrafts extends Table {
  @override
  String get tableName => 'accident_draft';

  // CHECK (id = 1) : un seul brouillon. Pattern officiel Drift.
  // ignore: recursive_getters
  IntColumn get id => integer().check(id.equals(1))();
  IntColumn get currentStep => integer()();
  TextColumn get place => text()();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  RealColumn get locationAccuracy => real().nullable()();
  // Dates stockées en texte ISO-8601, comme avant.
  TextColumn get occurredAt => text()();
  TextColumn get weather => text()();
  TextColumn get road => text()();
  TextColumn get light => text()();
  TextColumn get type => text()();
  TextColumn get severity => text()();
  IntColumn get vehicleCount => integer()();
  IntColumn get injuredCount => integer()();
  TextColumn get witnessName => text()();
  TextColumn get witnessPhone => text()();
  TextColumn get evidenceJson => text()();
  TextColumn get evidencePathsJson =>
      text().withDefault(const Constant('{}'))();
  BoolColumn get videoAdded => boolean()();
  BoolColumn get voiceNoteAdded => boolean()();
  TextColumn get videoPath => text().withDefault(const Constant(''))();
  TextColumn get voiceNotePath => text().withDefault(const Constant(''))();
  TextColumn get driverBName => text().withDefault(const Constant(''))();
  TextColumn get driverBPermit => text().withDefault(const Constant(''))();
  TextColumn get driverBPermitExpiry =>
      text().withDefault(const Constant(''))();
  TextColumn get driverBPlate => text().withDefault(const Constant(''))();
  TextColumn get driverBInsurer => text().withDefault(const Constant(''))();
  TextColumn get driverBPolicy => text().withDefault(const Constant(''))();
  // Compagnie du conducteur B (CompanyPicker) et véhicule du conducteur A.
  TextColumn get driverBCompanyId => text().nullable()();
  TextColumn get vehicleId => text().nullable()();
  TextColumn get clientId => text().nullable()();
  TextColumn get circumstancesJson => text()();
  TextColumn get observations => text()();
  TextColumn get impactZonesJson => text()();
  BoolColumn get sketchConfirmed => boolean()();
  TextColumn get sketchStrokesJson =>
      text().withDefault(const Constant('[]'))();
  BoolColumn get driverASigned => boolean()();
  BoolColumn get driverBSigned => boolean()();
  TextColumn get driverASignatureJson =>
      text().withDefault(const Constant('[]'))();
  TextColumn get driverBSignatureJson =>
      text().withDefault(const Constant('[]'))();
  TextColumn get lastSavedAt => text()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [AccidentDrafts])
class AccidentDatabase extends _$AccidentDatabase {
  /// [executor] permet d'injecter une base en mémoire pour les tests
  /// (`NativeDatabase.memory()`).
  AccidentDatabase([QueryExecutor? executor])
    : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(accidentDrafts, accidentDrafts.latitude);
        await m.addColumn(accidentDrafts, accidentDrafts.longitude);
        await m.addColumn(accidentDrafts, accidentDrafts.locationAccuracy);
      }
      if (from < 3) {
        await m.addColumn(accidentDrafts, accidentDrafts.evidencePathsJson);
        await m.addColumn(accidentDrafts, accidentDrafts.driverBName);
        await m.addColumn(accidentDrafts, accidentDrafts.driverBPermit);
        await m.addColumn(accidentDrafts, accidentDrafts.driverBPlate);
        await m.addColumn(accidentDrafts, accidentDrafts.driverBInsurer);
        await m.addColumn(accidentDrafts, accidentDrafts.driverBPolicy);
        await m.addColumn(accidentDrafts, accidentDrafts.sketchStrokesJson);
        await m.addColumn(accidentDrafts, accidentDrafts.driverASignatureJson);
        await m.addColumn(accidentDrafts, accidentDrafts.driverBSignatureJson);
      }
      if (from < 4) {
        await m.addColumn(accidentDrafts, accidentDrafts.driverBPermitExpiry);
      }
      if (from < 5) {
        await m.addColumn(accidentDrafts, accidentDrafts.videoPath);
        await m.addColumn(accidentDrafts, accidentDrafts.voiceNotePath);
      }
      if (from < 6) {
        await m.addColumn(accidentDrafts, accidentDrafts.driverBCompanyId);
        await m.addColumn(accidentDrafts, accidentDrafts.vehicleId);
      }
      if (from < 7) {
        await m.addColumn(accidentDrafts, accidentDrafts.clientId);
      }
    },
  );

  Future<SavedAccidentDraft?> loadDraft() async {
    final row = await (select(
      accidentDrafts,
    )..where((t) => t.id.equals(1))).getSingleOrNull();
    if (row == null) return null;
    return SavedAccidentDraft(
      draft: AccidentDraft.fromDatabaseMap(_rowToMap(row)),
      currentStep: row.currentStep,
    );
  }

  Future<void> saveDraft(AccidentDraft draft, int currentStep) async {
    final map = draft.toDatabaseMap(currentStep: currentStep);
    await into(accidentDrafts).insertOnConflictUpdate(_mapToCompanion(map));
  }

  Future<void> deleteDraft() async {
    await (delete(accidentDrafts)..where((t) => t.id.equals(1))).go();
  }

  /// Flux réactif du brouillon (bonus Drift : se met à jour à chaque écriture).
  Stream<AccidentDraft?> watchDraft() {
    return (select(
      accidentDrafts,
    )..where((t) => t.id.equals(1))).watchSingleOrNull().map(
      (row) =>
          row == null ? null : AccidentDraft.fromDatabaseMap(_rowToMap(row)),
    );
  }

  static Map<String, Object?> _rowToMap(AccidentDraftRow r) => {
    'id': r.id,
    'current_step': r.currentStep,
    'place': r.place,
    'latitude': r.latitude,
    'longitude': r.longitude,
    'location_accuracy': r.locationAccuracy,
    'occurred_at': r.occurredAt,
    'weather': r.weather,
    'road': r.road,
    'light': r.light,
    'type': r.type,
    'severity': r.severity,
    'vehicle_count': r.vehicleCount,
    'injured_count': r.injuredCount,
    'witness_name': r.witnessName,
    'witness_phone': r.witnessPhone,
    'evidence_json': r.evidenceJson,
    'evidence_paths_json': r.evidencePathsJson,
    'video_added': r.videoAdded ? 1 : 0,
    'voice_note_added': r.voiceNoteAdded ? 1 : 0,
    'video_path': r.videoPath,
    'voice_note_path': r.voiceNotePath,
    'driver_b_name': r.driverBName,
    'driver_b_permit': r.driverBPermit,
    'driver_b_permit_expiry': r.driverBPermitExpiry,
    'driver_b_plate': r.driverBPlate,
    'driver_b_insurer': r.driverBInsurer,
    'driver_b_policy': r.driverBPolicy,
    'driver_b_company_id': r.driverBCompanyId,
    'vehicle_id': r.vehicleId,
    'client_id': r.clientId,
    'circumstances_json': r.circumstancesJson,
    'observations': r.observations,
    'impact_zones_json': r.impactZonesJson,
    'sketch_confirmed': r.sketchConfirmed ? 1 : 0,
    'sketch_strokes_json': r.sketchStrokesJson,
    'driver_a_signed': r.driverASigned ? 1 : 0,
    'driver_b_signed': r.driverBSigned ? 1 : 0,
    'driver_a_signature_json': r.driverASignatureJson,
    'driver_b_signature_json': r.driverBSignatureJson,
    'last_saved_at': r.lastSavedAt,
  };

  static AccidentDraftsCompanion _mapToCompanion(Map<String, Object?> m) {
    return AccidentDraftsCompanion.insert(
      id: Value(m['id'] as int),
      currentStep: m['current_step'] as int,
      place: m['place'] as String,
      latitude: Value(m['latitude'] as double?),
      longitude: Value(m['longitude'] as double?),
      locationAccuracy: Value(m['location_accuracy'] as double?),
      occurredAt: m['occurred_at'] as String,
      weather: m['weather'] as String,
      road: m['road'] as String,
      light: m['light'] as String,
      type: m['type'] as String,
      severity: m['severity'] as String,
      vehicleCount: m['vehicle_count'] as int,
      injuredCount: m['injured_count'] as int,
      witnessName: m['witness_name'] as String,
      witnessPhone: m['witness_phone'] as String,
      evidenceJson: m['evidence_json'] as String,
      evidencePathsJson: Value(m['evidence_paths_json'] as String),
      videoAdded: m['video_added'] == 1,
      voiceNoteAdded: m['voice_note_added'] == 1,
      videoPath: Value(m['video_path'] as String),
      voiceNotePath: Value(m['voice_note_path'] as String),
      driverBName: Value(m['driver_b_name'] as String),
      driverBPermit: Value(m['driver_b_permit'] as String),
      driverBPermitExpiry: Value(m['driver_b_permit_expiry'] as String),
      driverBPlate: Value(m['driver_b_plate'] as String),
      driverBInsurer: Value(m['driver_b_insurer'] as String),
      driverBPolicy: Value(m['driver_b_policy'] as String),
      driverBCompanyId: Value(m['driver_b_company_id'] as String?),
      vehicleId: Value(m['vehicle_id'] as String?),
      clientId: Value(m['client_id'] as String?),
      circumstancesJson: m['circumstances_json'] as String,
      observations: m['observations'] as String,
      impactZonesJson: m['impact_zones_json'] as String,
      sketchConfirmed: m['sketch_confirmed'] == 1,
      sketchStrokesJson: Value(m['sketch_strokes_json'] as String),
      driverASigned: m['driver_a_signed'] == 1,
      driverBSigned: m['driver_b_signed'] == 1,
      driverASignatureJson: Value(m['driver_a_signature_json'] as String),
      driverBSignatureJson: Value(m['driver_b_signature_json'] as String),
      lastSavedAt: m['last_saved_at'] as String,
    );
  }
}

QueryExecutor _openConnection() {
  return driftDatabase(
    name: 'mon_constat_accidents',
    native: DriftNativeOptions(databasePath: _legacyDatabasePath),
    web: driftWebOptions,
  );
}

/// Même emplacement que `getDatabasesPath()` de sqflite, pour retrouver
/// le brouillon enregistré avant la migration vers Drift.
Future<String> _legacyDatabasePath() async {
  if (Platform.isAndroid) {
    final support = await getApplicationSupportDirectory(); // .../files
    final dir = Directory(path.join(support.parent.path, 'databases'));
    await dir.create(recursive: true);
    return path.join(dir.path, _databaseFileName);
  }
  if (Platform.isIOS || Platform.isMacOS) {
    final documents = await getApplicationDocumentsDirectory();
    return path.join(documents.path, _databaseFileName);
  }
  final support = await getApplicationSupportDirectory();
  return path.join(support.path, _databaseFileName);
}
