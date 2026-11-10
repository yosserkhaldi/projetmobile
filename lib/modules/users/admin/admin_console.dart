import 'package:flutter/material.dart';

import 'package:mon_constat_digital/core/state/app_scope.dart';
import 'package:mon_constat_digital/core/theme/app_colors.dart';
import 'package:mon_constat_digital/core/theme/app_theme.dart';
import 'package:mon_constat_digital/l10n/l10n.dart';
import 'package:mon_constat_digital/modules/users/admin/console_accounts.dart';
import 'package:mon_constat_digital/modules/users/admin/console_companies.dart';
import 'package:mon_constat_digital/modules/users/admin/console_dashboard.dart';
import 'package:mon_constat_digital/modules/users/admin/console_identities.dart';
import 'package:mon_constat_digital/modules/users/admin/console_widgets.dart';
import 'package:mon_constat_digital/modules/users/models/app_user.dart';
import 'package:mon_constat_digital/modules/users/screens/profile_screen.dart';

/// Largeur à partir de laquelle l'administrateur a la console (ordinateur,
/// tablette) au lieu des onglets du téléphone.
const adminConsoleMinWidth = 1000.0;

enum ConsoleSection { dashboard, accounts, identities, companies, profile }

/// Console d'administration : barre latérale, barre du haut, pages larges.
/// Même application et mêmes données que sur téléphone.
class AdminConsole extends StatefulWidget {
  const AdminConsole({super.key});

  @override
  State<AdminConsole> createState() => _AdminConsoleState();
}

class _AdminConsoleState extends State<AdminConsole> {
  ConsoleSection _section = ConsoleSection.dashboard;

  /// Demande à ouvrir directement dans la file des identités.
  String? _identityToOpen;

  @override
  void initState() {
    super.initState();
    // Le compteur de la barre latérale a besoin de la file dès l'ouverture.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppScope.of(context).admin.loadPendingIdentities().catchError((_) {});
    });
  }

  void _go(ConsoleSection section, {AppUser? identity}) => setState(() {
    _section = section;
    _identityToOpen = identity?.id;
  });

  @override
  Widget build(BuildContext context) {
    final page = switch (_section) {
      ConsoleSection.dashboard => ConsoleDashboard(
        onReview: (user) => _go(ConsoleSection.identities, identity: user),
        onSeeAllIdentities: () => _go(ConsoleSection.identities),
      ),
      ConsoleSection.accounts => const ConsoleAccounts(),
      ConsoleSection.identities => ConsoleIdentities(
        key: ValueKey(_identityToOpen),
        initialUserId: _identityToOpen,
      ),
      ConsoleSection.companies => const ConsoleCompanies(),
      ConsoleSection.profile => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: const ProfileScreen(),
        ),
      ),
    };
    return Scaffold(
      body: Row(
        children: [
          _Sidebar(selected: _section, onSelect: _go),
          Expanded(
            child: Column(
              children: [
                const _TopBar(),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: KeyedSubtree(key: ValueKey(_section), child: page),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({required this.selected, required this.onSelect});

  final ConsoleSection selected;
  final void Function(ConsoleSection) onSelect;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final stores = AppScope.of(context);
    final user = stores.users.currentUser;
    final pending = stores.admin.pendingIdentities.length;
    final items = [
      (
        ConsoleSection.dashboard,
        Icons.space_dashboard_outlined,
        t.consoleDashboard,
        0,
      ),
      (ConsoleSection.accounts, Icons.people_alt_outlined, t.navAccounts, 0),
      (
        ConsoleSection.identities,
        Icons.verified_user_outlined,
        t.navIdentities,
        pending,
      ),
      (ConsoleSection.companies, Icons.business_outlined, t.navCompanies, 0),
    ];
    return Container(
      width: 260,
      color: AppColors.ink,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 26, 22, 30),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: const Icon(
                      Icons.description_outlined,
                      color: AppColors.ink,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.brand,
                          style: const TextStyle(
                            fontFamily: AppFonts.display,
                            fontWeight: FontWeight.w800,
                            fontSize: 17,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          t.adminTitle,
                          style: const TextStyle(
                            color: AppColors.onDarkFaint,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            for (final (section, icon, label, badge) in items)
              _NavItem(
                icon: icon,
                label: label,
                badge: badge,
                selected: selected == section,
                onTap: () => onSelect(section),
              ),
            const Spacer(),
            _NavItem(
              icon: Icons.person_outline,
              label: t.profileTitle,
              selected: selected == ConsoleSection.profile,
              onTap: () => onSelect(ConsoleSection.profile),
            ),
            if (user != null)
              Container(
                margin: const EdgeInsets.fromLTRB(14, 10, 14, 18),
                padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
                decoration: BoxDecoration(
                  color: AppColors.navy800,
                  borderRadius: BorderRadius.circular(AppRadius.input),
                ),
                child: Row(
                  children: [
                    InitialAvatar(user.firstName, size: 34),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            user.email,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.onDarkFaint,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: t.logout,
                      onPressed: stores.users.logout,
                      icon: const Icon(
                        Icons.logout_rounded,
                        color: AppColors.onDarkStrong,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.badge = 0,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final int badge;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
    child: Material(
      color: selected ? AppColors.navy700 : Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        hoverColor: AppColors.navy800,
        child: Container(
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: BorderDirectional(
              start: BorderSide(
                color: selected ? AppColors.accent : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 21,
                color: selected ? Colors.white : AppColors.onDarkFaint,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: selected ? Colors.white : AppColors.onDarkStrong,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              if (badge > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Text(
                    '$badge',
                    style: const TextStyle(
                      color: AppColors.ink,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Barre du haut : langue et apparence, accessibles sans quitter la page.
class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final p = context.palette;
    final users = AppScope.of(context).users;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: BoxDecoration(
        color: p.surface,
        border: Border(bottom: BorderSide(color: p.borderSoft)),
      ),
      child: Row(
        children: [
          Icon(Icons.shield_outlined, size: 18, color: p.textMuted),
          const SizedBox(width: 8),
          Text(
            t.adminSubtitle,
            style: TextStyle(color: p.textMuted, fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          PopupMenuButton<AppLanguage>(
            tooltip: t.languageLabel,
            initialValue: users.language,
            onSelected: users.setLanguage,
            itemBuilder: (_) => [
              for (final language in AppLanguage.values)
                PopupMenuItem(value: language, child: Text(language.label)),
            ],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.translate, size: 18, color: p.textMuted),
                  const SizedBox(width: 6),
                  Text(
                    users.language.label,
                    style: TextStyle(
                      color: p.text,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            tooltip: t.appearanceLabel,
            onPressed: () =>
                users.setThemeMode(dark ? ThemeMode.light : ThemeMode.dark),
            icon: Icon(
              dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              color: p.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
