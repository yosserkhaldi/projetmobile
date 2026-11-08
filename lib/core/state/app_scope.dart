import 'package:flutter/material.dart';

import 'package:mon_constat_digital/core/network/api_client.dart';
import 'package:mon_constat_digital/core/network/device_identity.dart';
import 'package:mon_constat_digital/core/network/token_storage.dart';
import 'package:mon_constat_digital/modules/claims/state/claim_store.dart';
import 'package:mon_constat_digital/modules/accident/state/accident_store.dart';
import 'package:mon_constat_digital/modules/claims/state/message_store.dart';
import 'package:mon_constat_digital/modules/users/data/biometric_auth.dart';
import 'package:mon_constat_digital/modules/users/data/users_database.dart';
import 'package:mon_constat_digital/modules/users/state/admin_store.dart';
import 'package:mon_constat_digital/modules/users/state/company_store.dart';
import 'package:mon_constat_digital/modules/users/state/user_store.dart';
import 'package:mon_constat_digital/modules/vehicles/data/vehicle_database.dart';
import 'package:mon_constat_digital/modules/vehicles/state/vehicle_store.dart';

/// Regroupe l'état de chaque module. Chaque module garde son propre store.
class AppStores {
  AppStores({
    SessionStorage? storage,
    ApiClient? api,
    BiometricAuth? biometric,
    DeviceHeadersLoader? deviceHeaders,
    VehicleDatabase? vehicleDb,
    UsersDatabase? usersDb,
  }) : storage = storage ?? const SecureSessionStorage() {
    final localDb = usersDb ?? UsersDatabase.tryOpen();
    this.api = api ?? ApiClient(storage: this.storage);
    users = UserStore(
      this.api,
      this.storage,
      biometric ?? DeviceBiometricAuth(),
      deviceHeaders: deviceHeaders ?? loadDeviceHeaders,
      localDb: localDb,
    );
    companies = CompanyStore(this.api, localDb);
    admin = AdminStore(this.api, companies);
    vehicles = VehicleStore(vehicleDb ?? VehicleDatabase());
    listenable = Listenable.merge([
      accidents,
      users,
      companies,
      admin,
      vehicles,
      claims,
      messages,
    ]);
  }

  final SessionStorage storage;

  /// Client de l'API : ajoute le jeton et gère son renouvellement.
  late final ApiClient api;
  late final UserStore users;
  late final AdminStore admin;

  /// Compagnies et agences, pour tous les modules (copie hors ligne en SQLite).
  late final CompanyStore companies;
  final accidents = AccidentStore();
  late final VehicleStore vehicles;
  final claims = ClaimStore();
  final messages = MessageStore();

  late final Listenable listenable;
}

/// Donne accès aux stores : `AppScope.of(context).users`.
class AppScope extends InheritedNotifier<Listenable> {
  AppScope({required this.stores, required super.child, super.key})
    : super(notifier: stores.listenable);

  final AppStores stores;

  static AppStores of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.stores;
}
