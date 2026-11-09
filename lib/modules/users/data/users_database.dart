import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/foundation.dart';

import 'package:mon_constat_digital/modules/users/models/app_user.dart';
import 'package:mon_constat_digital/modules/users/models/company.dart';

part 'users_database.g.dart';

// Base SQLite du module 1, sur le téléphone.
//
// Le constat se remplit souvent sans réseau, sur les lieux de l'accident.
// On y garde donc :
// - le profil du conducteur (identité, permis, état de la CIN), repris par le
//   constat du module 4 pour pré-remplir la partie du conducteur A ;
// - le référentiel des compagnies et agences, pour choisir l'assureur
//   (contrat du module 2, assureur du conducteur B) même hors ligne.
// Les secrets (jetons, clé biométrique) restent dans le stockage sécurisé.

/// Profil du compte connecté. Une seule ligne.
@DataClassName('CachedProfileRow')
class CachedProfiles extends Table {
  @override
  String get tableName => 'cached_profile';

  TextColumn get userId => text()();
  TextColumn get firstName => text()();
  TextColumn get lastName => text()();
  TextColumn get phone => text()();
  TextColumn get licenseNumber => text().nullable()();
  TextColumn get licenseCategory => text().nullable()();
  TextColumn get licenseIssuedAt => text().nullable()();
  TextColumn get identityStatus => text()();

  /// Profil complet (AppUser.toJson), pour le reconstruire tel quel.
  TextColumn get json => text()();
  DateTimeColumn get syncedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {userId};
}

@DataClassName('CompanyRow')
class Companies extends Table {
  @override
  String get tableName => 'companies';

  TextColumn get id => text()();
  TextColumn get name => text()();
  DateTimeColumn get syncedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('AgencyRow')
class Agencies extends Table {
  @override
  String get tableName => 'agencies';

  TextColumn get id => text()();
  TextColumn get companyId =>
      text().references(Companies, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text()();
  TextColumn get city => text()();

  @override
  Set<Column> get primaryKey => {id};
}

/// File d'attente des modifications faites hors ligne, envoyées à l'API dans
/// l'ordre dès que le réseau revient.
@DataClassName('PendingChangeRow')
class PendingChanges extends Table {
  @override
  String get tableName => 'pending_changes';

  IntColumn get id => integer().autoIncrement()();

  /// Type de modification : `profile` (PATCH /users/me).
  TextColumn get kind => text()();

  /// Champs modifiés, en JSON. Plusieurs modifications hors ligne du même
  /// type sont fusionnées dans une seule ligne.
  TextColumn get payload => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  IntColumn get attempts => integer().withDefault(const Constant(0))();

  /// Motif du dernier refus du serveur. La ligne n'est plus renvoyée
  /// automatiquement tant que l'utilisateur ne réessaie pas.
  TextColumn get lastError => text().nullable()();
}

@DriftDatabase(tables: [CachedProfiles, Companies, Agencies, PendingChanges])
class UsersDatabase extends _$UsersDatabase {
  /// Les tests passent une base en mémoire (`NativeDatabase.memory()`).
  UsersDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'mon_constat_users'));

  /// La base du téléphone, ou `null` là où SQLite n'est pas configuré (web) :
  /// l'application marche alors sans copie hors ligne.
  static UsersDatabase? tryOpen() {
    if (kIsWeb) return null;
    try {
      return UsersDatabase();
    } catch (_) {
      return null;
    }
  }

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      // Version 2 : file d'attente hors ligne.
      if (from < 2) await m.createTable(pendingChanges);
    },
    beforeOpen: (_) => customStatement('PRAGMA foreign_keys = ON'),
  );

  // --- Profil ---------------------------------------------------------------

  Future<void> saveProfile(AppUser user) => transaction(() async {
    // Un seul compte par téléphone : l'ancien profil est remplacé.
    await delete(cachedProfiles).go();
    await into(cachedProfiles).insert(
      CachedProfilesCompanion.insert(
        userId: user.id,
        firstName: user.firstName,
        lastName: user.lastName,
        phone: user.phone,
        licenseNumber: Value(user.licenseNumber),
        licenseCategory: Value(user.licenseCategory),
        licenseIssuedAt: Value(user.licenseIssuedAt),
        identityStatus: user.identity.status.apiValue,
        json: jsonEncode(user.toJson()),
        syncedAt: DateTime.now(),
      ),
    );
  });

  Future<AppUser?> loadProfile() async {
    final row = await select(cachedProfiles).getSingleOrNull();
    return row == null
        ? null
        : AppUser.fromJson(jsonDecode(row.json) as Map<String, dynamic>);
  }

  Future<void> clearProfile() => delete(cachedProfiles).go();

  // --- Compagnies -------------------------------------------------------------

  /// Remplace tout le référentiel par la liste reçue de l'API.
  Future<void> replaceCompanies(List<Company> list) => transaction(() async {
    final now = DateTime.now();
    await delete(agencies).go();
    await delete(companies).go();
    await batch((b) {
      b.insertAll(companies, [
        for (final c in list)
          CompaniesCompanion.insert(id: c.id, name: c.name, syncedAt: now),
      ]);
      b.insertAll(agencies, [
        for (final c in list)
          for (final a in c.agencies)
            AgenciesCompanion.insert(
              id: a.id,
              companyId: c.id,
              name: a.name,
              city: a.city,
            ),
      ]);
    });
  });

  Future<List<Company>> loadCompanies() async {
    final companyRows = await (select(
      companies,
    )..orderBy([(c) => OrderingTerm.asc(c.name)])).get();
    final agencyRows = await (select(
      agencies,
    )..orderBy([(a) => OrderingTerm.asc(a.name)])).get();
    return [
      for (final c in companyRows)
        Company(
          id: c.id,
          name: c.name,
          agencies: [
            for (final a in agencyRows)
              if (a.companyId == c.id)
                Agency(id: a.id, name: a.name, city: a.city),
          ],
        ),
    ];
  }

  /// Date de la dernière liste reçue du serveur, `null` si jamais reçue.
  Future<DateTime?> companiesSyncedAt() async {
    final row = await (select(companies)..limit(1)).getSingleOrNull();
    return row?.syncedAt;
  }

  // --- File d'attente hors ligne ----------------------------------------------

  /// Ajoute une modification, ou la fusionne avec celle du même type déjà en
  /// attente : les champs les plus récents l'emportent.
  Future<void> enqueue(String kind, Map<String, Object?> changes) =>
      transaction(() async {
        final now = DateTime.now();
        final existing = await (select(
          pendingChanges,
        )..where((c) => c.kind.equals(kind))).getSingleOrNull();
        if (existing == null) {
          await into(pendingChanges).insert(
            PendingChangesCompanion.insert(
              kind: kind,
              payload: jsonEncode(changes),
              createdAt: now,
              updatedAt: now,
            ),
          );
          return;
        }
        final merged = {
          ...jsonDecode(existing.payload) as Map<String, dynamic>,
          ...changes,
        };
        await (update(
          pendingChanges,
        )..where((c) => c.id.equals(existing.id))).write(
          PendingChangesCompanion(
            payload: Value(jsonEncode(merged)),
            updatedAt: Value(now),
            // Nouvelle modification : on retente même après un refus.
            lastError: const Value(null),
          ),
        );
      });

  /// Modifications en attente, les plus anciennes d'abord.
  Future<List<PendingChangeRow>> pending() =>
      (select(pendingChanges)..orderBy([(c) => OrderingTerm.asc(c.id)])).get();

  Future<void> removePending(int id) =>
      (delete(pendingChanges)..where((c) => c.id.equals(id))).go();

  Future<void> markFailed(int id, String error) =>
      (update(pendingChanges)..where((c) => c.id.equals(id))).write(
        PendingChangesCompanion.custom(
          attempts: pendingChanges.attempts + const Constant(1),
          lastError: Variable(error),
        ),
      );

  Future<void> markAttempted(int id) =>
      (update(pendingChanges)..where((c) => c.id.equals(id))).write(
        PendingChangesCompanion.custom(
          attempts: pendingChanges.attempts + const Constant(1),
        ),
      );

  Future<void> clearPending() => delete(pendingChanges).go();

  /// L'utilisateur demande de réessayer après un refus du serveur.
  Future<void> clearPendingErrors() => update(
    pendingChanges,
  ).write(const PendingChangesCompanion(lastError: Value(null)));
}
