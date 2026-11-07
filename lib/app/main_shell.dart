import 'package:flutter/material.dart';

import 'package:mon_constat_digital/app/driver_home.dart';
import 'package:mon_constat_digital/core/state/app_scope.dart';
import 'package:mon_constat_digital/l10n/l10n.dart';
import 'package:mon_constat_digital/modules/claims/screens/agent_dashboard_screen.dart';
import 'package:mon_constat_digital/modules/claims/screens/claims_screen.dart';
import 'package:mon_constat_digital/modules/accident/screens/declarations_screen.dart';
import 'package:mon_constat_digital/modules/claims/screens/messages_screen.dart';
import 'package:mon_constat_digital/modules/users/models/app_user.dart';
import 'package:mon_constat_digital/modules/users/screens/admin_dashboard_screen.dart';
import 'package:mon_constat_digital/modules/users/screens/companies_screen.dart';
import 'package:mon_constat_digital/modules/users/screens/identity_review_screen.dart';
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
            IdentityReviewScreen(),
            CompaniesScreen(),
            ProfileScreen(),
          ];
    final t = context.t;
    final items = store.role == UserRole.driver
        ? [
            (t.navHome, Icons.home_rounded),
            (t.navVehicles, Icons.directions_car),
            (t.navDeclarations, Icons.description_outlined),
            (t.navMessages, Icons.chat),
            (t.navProfile, Icons.person),
          ]
        : store.role == UserRole.agent
        ? [
            (t.navDashboard, Icons.dashboard),
            (t.navCases, Icons.folder),
            (t.navMessages, Icons.chat),
            (t.navProfile, Icons.person),
          ]
        : [
            (t.navDashboard, Icons.dashboard),
            (t.navAccounts, Icons.people),
            (t.navIdentities, Icons.verified_user_outlined),
            (t.navCompanies, Icons.business),
            (t.navProfile, Icons.person),
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
