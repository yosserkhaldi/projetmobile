import 'package:drift_flutter/drift_flutter.dart';

/// Réglage commun des bases SQLite (drift) pour la version web.
///
/// `web/sqlite3.wasm` et `web/drift_worker.js` viennent de la release drift
/// 2.35.3 (github.com/simolus3/drift/releases). À mettre à jour en même temps
/// que le paquet drift.
final driftWebOptions = DriftWebOptions(
  sqlite3Wasm: Uri.parse('sqlite3.wasm'),
  driftWorker: Uri.parse('drift_worker.js'),
);
