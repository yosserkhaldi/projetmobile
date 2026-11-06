import 'package:flutter/material.dart';

import 'package:mon_constat_digital/modules/claims/state/claim_store.dart';
import 'package:mon_constat_digital/modules/claims/state/message_store.dart';
import 'package:mon_constat_digital/modules/users/state/user_store.dart';
import 'package:mon_constat_digital/modules/vehicles/state/vehicle_store.dart';

/// Regroupe l'état de chaque module. Chaque module garde son propre store.
class AppStores {
  final users = UserStore();
  final vehicles = VehicleStore();
  final claims = ClaimStore();
  final messages = MessageStore();

  late final Listenable listenable = Listenable.merge([
    users,
    vehicles,
    claims,
    messages,
  ]);
}

/// Donne accès aux stores : `AppScope.of(context).users`.
class AppScope extends InheritedNotifier<Listenable> {
  AppScope({required this.stores, required super.child, super.key})
    : super(notifier: stores.listenable);

  final AppStores stores;

  static AppStores of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.stores;
}
