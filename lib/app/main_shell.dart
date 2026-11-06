import 'package:flutter/material.dart';

import 'package:mon_constat_digital/app/driver_home.dart';
import 'package:mon_constat_digital/core/state/app_scope.dart';
import 'package:mon_constat_digital/modules/claims/screens/agent_dashboard_screen.dart';
import 'package:mon_constat_digital/modules/claims/screens/claims_screen.dart';
import 'package:mon_constat_digital/modules/accident/screens/declarations_screen.dart';
import 'package:mon_constat_digital/modules/claims/screens/messages_screen.dart';
import 'package:mon_constat_digital/modules/users/models/app_user.dart';
import 'package:mon_constat_digital/modules/users/screens/admin_dashboard_screen.dart';
import 'package:mon_constat_digital/modules/users/screens/companies_screen.dart';
import 'package:mon_constat_digital/modules/users/screens/profile_screen.dart';
import 'package:mon_constat_digital/modules/users/screens/users_screen.dart';
import 'package:mon_constat_digital/modules/vehicles/screens/vehicles_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int index = 0;
  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context).users;
    final pages = store.role == UserRole.driver
        ? const [
            DriverHome(),
            VehiclesScreen(),
            DeclarationsScreen(),
            MessagesScreen(),
            ProfileScreen(),
          ]
        : store.role == UserRole.agent
        ? const [
            AgentDashboard(),
            ClaimsScreen(agentMode: true),
            MessagesScreen(),
            ProfileScreen(),
          ]
        : const [
            AdminDashboard(),
            UsersScreen(),
            CompaniesScreen(),
            ProfileScreen(),
          ];
    final items = store.role == UserRole.driver
        ? const [
            ('Accueil', Icons.home_rounded),
            ('Véhicules', Icons.directions_car),
            ('Déclarations', Icons.description_outlined),
            ('Messages', Icons.chat),
            ('Profil', Icons.person),
          ]
        : store.role == UserRole.agent
        ? const [
            ('Tableau', Icons.dashboard),
            ('Sinistres', Icons.folder),
            ('Messages', Icons.chat),
            ('Profil', Icons.person),
          ]
        : const [
            ('Tableau', Icons.dashboard),
            ('Comptes', Icons.people),
            ('Compagnies', Icons.business),
            ('Profil', Icons.person),
          ];
    if (index >= pages.length) index = 0;
    return Scaffold(
      body: pages[index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (v) => setState(() => index = v),
        destinations: items
            .map((e) => NavigationDestination(icon: Icon(e.$2), label: e.$1))
            .toList(),
      ),
    );
  }
}
