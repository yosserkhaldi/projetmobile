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
    ClaimNotifications,
    ChatMessages,
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
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (_) => customStatement('PRAGMA foreign_keys = ON'),
  );
}
