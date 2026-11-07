import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

import 'package:mon_constat_digital/modules/accident/models/accident_draft.dart';

class SavedAccidentDraft {
  const SavedAccidentDraft({required this.draft, required this.currentStep});

  final AccidentDraft draft;
  final int currentStep;
}

class AccidentDatabase {
  Database? _database;

  Future<Database> get _db async {
    if (_database != null) return _database!;
    final directory = await getDatabasesPath();
    _database = await openDatabase(
      path.join(directory, 'mon_constat_accidents.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE accident_draft (
            id INTEGER PRIMARY KEY CHECK (id = 1),
            current_step INTEGER NOT NULL,
            place TEXT NOT NULL,
            occurred_at TEXT NOT NULL,
            weather TEXT NOT NULL,
            road TEXT NOT NULL,
            light TEXT NOT NULL,
            type TEXT NOT NULL,
            severity TEXT NOT NULL,
            vehicle_count INTEGER NOT NULL,
            injured_count INTEGER NOT NULL,
            witness_name TEXT NOT NULL,
            witness_phone TEXT NOT NULL,
            evidence_json TEXT NOT NULL,
            video_added INTEGER NOT NULL,
            voice_note_added INTEGER NOT NULL,
            circumstances_json TEXT NOT NULL,
            observations TEXT NOT NULL,
            impact_zones_json TEXT NOT NULL,
            sketch_confirmed INTEGER NOT NULL,
            driver_a_signed INTEGER NOT NULL,
            driver_b_signed INTEGER NOT NULL,
            last_saved_at TEXT NOT NULL
          )
        ''');
      },
    );
    return _database!;
  }

  Future<SavedAccidentDraft?> loadDraft() async {
    final database = await _db;
    final rows = await database.query(
      'accident_draft',
      where: 'id = ?',
      whereArgs: [1],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final row = rows.first;
    return SavedAccidentDraft(
      draft: AccidentDraft.fromDatabaseMap(row),
      currentStep: row['current_step'] as int? ?? 0,
    );
  }

  Future<void> saveDraft(AccidentDraft draft, int currentStep) async {
    final database = await _db;
    await database.insert(
      'accident_draft',
      draft.toDatabaseMap(currentStep: currentStep),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteDraft() async {
    final database = await _db;
    await database.delete('accident_draft', where: 'id = ?', whereArgs: [1]);
  }

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}
