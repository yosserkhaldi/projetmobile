import 'dart:async';

import 'package:drift/drift.dart';
import 'package:mon_constat_digital/modules/claims/data/claims_database.dart';

/// Chargé automatiquement par `flutter test` pour tous les tests.
///
/// Les tests d'écran gardent les stores en mémoire : pas de fichier SQLite
/// partagé entre eux. Les tests de persistance passent leur propre base.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  ClaimsDatabase.shared = ClaimsDatabase(
    LazyDatabase(() => throw StateError('SQLite désactivé dans les tests')),
  );
  await testMain();
}
