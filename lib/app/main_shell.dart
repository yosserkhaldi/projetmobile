import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:mon_constat_digital/app/driver_home.dart';
import 'package:mon_constat_digital/core/state/app_scope.dart';
import 'package:mon_constat_digital/core/theme/app_colors.dart';
import 'package:mon_constat_digital/core/theme/app_theme.dart';
import 'package:mon_constat_digital/l10n/l10n.dart';
import 'package:mon_constat_digital/modules/claims/screens/agent_dashboard_screen.dart';
import 'package:mon_constat_digital/modules/claims/screens/claims_screen.dart';
import 'package:mon_constat_digital/modules/accident/screens/declarations_screen.dart';
import 'package:mon_constat_digital/modules/claims/screens/messages_screen.dart';
import 'package:mon_constat_digital/modules/users/admin/admin_console.dart';
import 'package:mon_constat_digital/modules/users/models/app_user.dart';
import 'package:mon_constat_digital/modules/users/screens/admin_dashboard_screen.dart';
import 'package:mon_constat_digital/modules/users/screens/companies_screen.dart';
import 'package:mon_constat_digital/modules/users/screens/identity_review_screen.dart';
import 'package:mon_constat_digital/modules/users/screens/profile_screen.dart';
import 'package:mon_constat_digital/modules/users/screens/users_screen.dart';
import 'package:mon_constat_digital/modules/vehicles/screens/vehicles_screen.dart';

/// Un onglet de la barre de navigation.
class _Tab {
  const _Tab(
    this.label,
    this.icon,
    this.activeIcon,
    this.page, {
    this.badge = 0,
    this.primary = false,
  });

  final String label;
  final IconData icon, activeIcon;
  final Widget page;

  /// Nombre à traiter (messages non lus, identités en attente).
  final int badge;

  /// Action principale de l'application (déclarer un accident) : bouton
  /// rond au centre de la barre.
  final bool primary;
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int index = 0;

  /// Onglets déjà ouverts : gardés en vie (défilement, données chargées),
  /// les autres ne sont construits qu'à la première visite.
  final _visited = <int>{0};
  UserRole? _role;

  List<_Tab> _tabs(BuildContext context, UserRole role) {
    final t = context.t;
    final stores = AppScope.of(context);
    final unread = stores.messages.unreadCount(role);
    return switch (role) {
      UserRole.driver => [
        _Tab(
          t.navHome,
          Icons.home_outlined,
          Icons.home_rounded,
          const DriverHome(),
        ),
        _Tab(
          t.navVehicles,
          Icons.directions_car_outlined,
          Icons.directions_car_filled,
          const VehiclesScreen(),
        ),
        _Tab(
          t.navDeclarations,
          Icons.description_outlined,
          Icons.description,
          const DeclarationsScreen(),
          primary: true,
        ),
        _Tab(
          t.navMessages,
          Icons.chat_bubble_outline,
          Icons.chat_bubble,
          const MessagesScreen(),
          badge: unread,
        ),
        _Tab(
          t.navProfile,
          Icons.person_outline,
          Icons.person,
          const ProfileScreen(),
        ),
      ],
      UserRole.agent => [
        _Tab(
          t.navDashboard,
          Icons.space_dashboard_outlined,
          Icons.space_dashboard,
          const AgentDashboard(),
        ),
        _Tab(
          t.navCases,
          Icons.folder_outlined,
          Icons.folder,
          const ClaimsScreen(agentMode: true),
        ),
        _Tab(
          t.navMessages,
          Icons.chat_bubble_outline,
          Icons.chat_bubble,
          const MessagesScreen(),
          badge: unread,
        ),
        _Tab(
          t.navProfile,
          Icons.person_outline,
          Icons.person,
          const ProfileScreen(),
        ),
      ],
      UserRole.admin => [
        _Tab(
          t.navDashboard,
          Icons.space_dashboard_outlined,
          Icons.space_dashboard,
          const AdminDashboard(),
        ),
        _Tab(
          t.navAccounts,
          Icons.people_outline,
          Icons.people,
          const UsersScreen(),
        ),
        _Tab(
          t.navIdentities,
          Icons.verified_user_outlined,
          Icons.verified_user,
          const IdentityReviewScreen(),
          badge: stores.admin.pendingIdentities.length,
        ),
        _Tab(
          t.navCompanies,
          Icons.apartment_outlined,
          Icons.apartment,
          const CompaniesScreen(),
        ),
        _Tab(
          t.navProfile,
          Icons.person_outline,
          Icons.person,
          const ProfileScreen(),
        ),
      ],
    };
  }

  void _select(int value) {
    if (value == index) return;
    HapticFeedback.selectionClick();
    setState(() {
      index = value;
      _visited.add(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context).users;
    // Administrateur sur grand écran (ordinateur, tablette) : la console.
    if (store.role == UserRole.admin &&
        MediaQuery.sizeOf(context).width >= adminConsoleMinWidth) {
      return const AdminConsole();
    }
    // Autre compte (déconnexion, changement de rôle) : on repart de zéro.
    if (_role != store.role) {
      _role = store.role;
      index = 0;
      _visited
        ..clear()
        ..add(0);
    }
    final tabs = _tabs(context, store.role);
    if (index >= tabs.length) index = 0;
    final p = context.palette;
    return Scaffold(
      backgroundColor: p.canvas,
      body: IndexedStack(
        index: index,
        children: [
          for (final (i, tab) in tabs.indexed)
            _visited.contains(i) ? tab.page : const SizedBox.shrink(),
        ],
      ),
      bottomNavigationBar: _FloatingNavBar(
        tabs: tabs,
        index: index,
        onSelect: _select,
      ),
    );
  }
}

/// Barre flottante : arrondie, légèrement surélevée, centrée sur grand écran.
/// Icône pleine pour l'onglet actif, pastilles ambre pour ce qui attend.
class _FloatingNavBar extends StatelessWidget {
  const _FloatingNavBar({
    required this.tabs,
    required this.index,
    required this.onSelect,
  });

  final List<_Tab> tabs;
  final int index;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: p.borderSoft),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.07),
                    blurRadius: 18,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(26),
                child: NavigationBar(
                  height: 70,
                  selectedIndex: index,
                  onDestinationSelected: onSelect,
                  backgroundColor: p.surface,
                  elevation: 0,
                  labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
                  indicatorShape: const StadiumBorder(),
                  // Le bouton central est déjà un cercle plein : pas de
                  // pastille claire derrière lui.
                  indicatorColor: tabs[index].primary
                      ? Colors.transparent
                      : null,
                  destinations: [
                    for (final (i, tab) in tabs.indexed)
                      tab.primary
                          ? _primaryDestination(context, tab, i == index)
                          : NavigationDestination(
                              icon: _withBadge(tab.badge, Icon(tab.icon)),
                              selectedIcon: _withBadge(
                                tab.badge,
                                Icon(tab.activeIcon),
                              ),
                              label: tab.label,
                              tooltip: tab.label,
                            ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Pastille ambre : ce qui demande une action maintenant (DESIGN.md).
  Widget _withBadge(int count, Widget icon) => Badge(
    isLabelVisible: count > 0,
    backgroundColor: AppColors.accent,
    textColor: AppColors.ink,
    label: Text(count > 99 ? '99+' : '$count'),
    child: icon,
  );

  /// Déclarer un accident : bouton rond bleu au centre, sans indicateur.
  NavigationDestination _primaryDestination(
    BuildContext context,
    _Tab tab,
    bool selected,
  ) {
    // Le cercle tient dans la barre (pas de débordement rogné par les coins
    // arrondis) ; son libellé reste aligné sur ceux des autres onglets.
    Widget button(bool active) => SizedBox(
      width: 40,
      height: 32,
      child: OverflowBox(
        maxWidth: 40,
        maxHeight: 40,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: active ? AppColors.primaryDark : AppColors.primary,
            shape: BoxShape.circle,
            border: Border.all(color: context.palette.surface, width: 3),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.30),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            active ? tab.activeIcon : Icons.add_rounded,
            color: Colors.white,
            size: 22,
          ),
        ),
      ),
    );
    return NavigationDestination(
      icon: button(false),
      selectedIcon: button(true),
      label: tab.label,
      tooltip: tab.label,
    );
  }
}
