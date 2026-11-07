import 'package:flutter/material.dart';

import 'package:mon_constat_digital/core/network/api_client.dart';
import 'package:mon_constat_digital/core/network/token_storage.dart';
import 'package:mon_constat_digital/modules/claims/state/claim_store.dart';
import 'package:mon_constat_digital/modules/claims/state/claims_sync.dart';
import 'package:mon_constat_digital/modules/accident/state/accident_store.dart';
import 'package:mon_constat_digital/modules/claims/state/message_store.dart';
import 'package:mon_constat_digital/modules/users/data/biometric_auth.dart';
import 'package:mon_constat_digital/modules/users/state/admin_store.dart';
import 'package:mon_constat_digital/modules/users/state/user_store.dart';
import 'package:mon_constat_digital/modules/vehicles/state/vehicle_store.dart';

/// Regroupe l'état de chaque module. Chaque module garde son propre store.
class AppStores {
  AppStores({SessionStorage? storage, ApiClient? api, BiometricAuth? biometric})
    : storage = storage ?? const SecureSessionStorage() {
    this.api = api ?? ApiClient(storage: this.storage);
    users = UserStore(
      this.api,
      this.storage,
      biometric ?? DeviceBiometricAuth(),
    );
    admin = AdminStore(this.api);
    listenable = Listenable.merge([
      accidents,
      users,
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
  final accidents = AccidentStore();
  final vehicles = VehicleStore();
  final claims = ClaimStore();
  final messages = MessageStore();

  /// Absent dans les tests d'écran : seule l'application le démarre.
  ClaimsSync? claimsSync;

  void startClaimsSync() {
    claimsSync ??= ClaimsSync.start(
      client: api,
      claims: claims,
      messages: messages,
      users: users,
    );
  }

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
