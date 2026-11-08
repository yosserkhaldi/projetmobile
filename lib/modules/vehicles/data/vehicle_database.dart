import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:mon_constat_digital/modules/vehicles/models/vehicle.dart';

part 'vehicle_database.g.dart';

const _dbFileName = 'mon_constat_vehicles.db';

// ── Table ──────────────────────────────────────────────────────────────────

@DataClassName('VehicleRow')
class Vehicles extends Table {
  @override
  String get tableName => 'vehicles';

  TextColumn get id => text()();
  TextColumn get plate => text()();
  TextColumn get brand => text()();
  TextColumn get model => text()();
  TextColumn get year => text()();
  TextColumn get policy => text()();
  TextColumn get insurerName => text().withDefault(const Constant(''))();
  TextColumn get companyId => text().nullable()();
  TextColumn get companyName => text().nullable()();
  TextColumn get insuranceExpiry => text()();
  TextColumn get technicalExpiry => text().nullable()();
  TextColumn get color => text().nullable()();
  IntColumn get mileage => integer().nullable()();
  TextColumn get type =>
      text().withDefault(const Constant('car'))();
  TextColumn get fuel =>
      text().withDefault(const Constant('petrol'))();
  TextColumn get photoPath => text().nullable()();
  IntColumn get claimCount => integer().withDefault(const Constant(0))();
  BoolColumn get archived =>
      boolean().withDefault(const Constant(false))();
  TextColumn get createdAt => text()();

  @override
  Set<Column> get primaryKey => {id};
}

// ── Database ───────────────────────────────────────────────────────────────

@DriftDatabase(tables: [Vehicles])
class VehicleDatabase extends _$VehicleDatabase {
  VehicleDatabase([QueryExecutor? executor])
    : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(vehicles, vehicles.companyId);
        await m.addColumn(vehicles, vehicles.companyName);
      }
    },
  );

  // ── Queries ──────────────────────────────────────────────────────────────

  Future<List<Vehicle>> loadAll() async {
    final rows = await select(vehicles).get();
    return rows.map(_fromRow).toList();
  }

  Stream<List<Vehicle>> watchAll() =>
      select(vehicles).watch().map((rows) => rows.map(_fromRow).toList());

  Future<void> saveVehicle(Vehicle v) async {
    await into(vehicles).insertOnConflictUpdate(_toCompanion(v));
  }

  Future<void> deleteVehicle(String id) async {
    await (delete(vehicles)..where((t) => t.id.equals(id))).go();
  }

  Future<void> deleteAll() async {
    await delete(vehicles).go();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  static Vehicle _fromRow(VehicleRow r) => Vehicle.fromMap({
    'id': r.id,
    'plate': r.plate,
    'brand': r.brand,
    'model': r.model,
    'year': r.year,
    'policy': r.policy,
    'insurer_name': r.insurerName,
    'company_id': r.companyId,
    'company_name': r.companyName,
    'insurance_expiry': r.insuranceExpiry,
    'technical_expiry': r.technicalExpiry,
    'color': r.color,
    'mileage': r.mileage,
    'type': r.type,
    'fuel': r.fuel,
    'photo_path': r.photoPath,
    'claim_count': r.claimCount,
    'archived': r.archived ? 1 : 0,
    'created_at': r.createdAt,
  });

  static VehiclesCompanion _toCompanion(Vehicle v) {
    final m = v.toMap();
    return VehiclesCompanion(
      id: Value(m['id'] as String),
      plate: Value(m['plate'] as String),
      brand: Value(m['brand'] as String),
      model: Value(m['model'] as String),
      year: Value(m['year'] as String),
      policy: Value(m['policy'] as String),
      insurerName: Value(m['insurer_name'] as String? ?? ''),
      companyId: Value(m['company_id'] as String?),
      companyName: Value(m['company_name'] as String?),
      insuranceExpiry: Value(m['insurance_expiry'] as String),
      technicalExpiry: Value(m['technical_expiry'] as String?),
      color: Value(m['color'] as String?),
      mileage: Value(m['mileage'] as int?),
      type: Value(m['type'] as String? ?? 'car'),
      fuel: Value(m['fuel'] as String? ?? 'petrol'),
      photoPath: Value(m['photo_path'] as String?),
      claimCount: Value(m['claim_count'] as int? ?? 0),
      archived: Value((m['archived'] as int? ?? 0) == 1),
      createdAt: Value(m['created_at'] as String),
    );
  }
}

// ── Connection ─────────────────────────────────────────────────────────────

QueryExecutor _openConnection() => driftDatabase(
  name: 'mon_constat_vehicles',
  native: DriftNativeOptions(databasePath: _databasePath),
);

Future<String> _databasePath() async {
  if (Platform.isAndroid) {
    final support = await getApplicationSupportDirectory();
    final dir = Directory(p.join(support.parent.path, 'databases'));
    await dir.create(recursive: true);
    return p.join(dir.path, _dbFileName);
  }
  if (Platform.isIOS || Platform.isMacOS) {
    final docs = await getApplicationDocumentsDirectory();
    return p.join(docs.path, _dbFileName);
  }
  final support = await getApplicationSupportDirectory();
  return p.join(support.path, _dbFileName);
}
