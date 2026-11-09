import 'dart:async';

import 'package:flutter/material.dart';

import 'package:mon_constat_digital/core/state/app_scope.dart';
import 'package:mon_constat_digital/core/theme/app_theme.dart';
import 'package:mon_constat_digital/l10n/l10n.dart';
import 'package:mon_constat_digital/modules/users/admin/console_widgets.dart';
import 'package:mon_constat_digital/modules/users/models/app_user.dart';
import 'package:mon_constat_digital/modules/users/screens/agent_form_screen.dart';
import 'package:mon_constat_digital/modules/users/screens/users_screen.dart';
import 'package:mon_constat_digital/modules/users/widgets/form_widgets.dart';

/// Gestion des comptes en tableau : recherche, filtre par rôle, actions.
class ConsoleAccounts extends StatefulWidget {
  const ConsoleAccounts({super.key});

  @override
  State<ConsoleAccounts> createState() => _ConsoleAccountsState();
}

class _ConsoleAccountsState extends State<ConsoleAccounts> {
  final _search = TextEditingController();
  Timer? _debounce;
  UserRole? _role;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final admin = AppScope.of(context).admin;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await admin.loadUsers(query: _search.text.trim(), role: _role);
    } catch (e) {
      if (mounted) setState(() => _error = errorMessage(context, e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onSearch(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), _load);
  }

  Future<void> _run(Future<void> Function() action) async {
    final messenger = ScaffoldMessenger.of(context);
    String describe(Object error) => errorMessage(context, error);
    try {
      await action();
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(describe(e))));
    }
  }

  Future<void> _changeRole(AppUser user) async {
    final admin = AppScope.of(context).admin;
    await showDialog<void>(
      context: context,
      builder: (_) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: RoleSheet(
            user: user,
            onSave: (role, companyId) =>
                admin.setRole(user, role, companyId: companyId),
          ),
        ),
      ),
    );
  }

  Future<void> _createAgent() async {
    await showDialog<void>(
      context: context,
      builder: (_) => Dialog(
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520, maxHeight: 760),
          child: const AgentFormScreen(),
        ),
      ),
    );
    if (mounted) await _load();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final stores = AppScope.of(context);
    final admin = stores.admin;
    final myId = stores.users.currentUser?.id;
    final filters = [
      (null, t.filterAll),
      (UserRole.driver, t.filterDrivers),
      (UserRole.agent, t.filterAgents),
      (UserRole.admin, t.filterAdmins),
    ];
    return ListView(
      padding: const EdgeInsets.fromLTRB(32, 28, 32, 40),
      children: [
        ConsoleHeader(
          title: t.accountsTitle,
          subtitle: t.accountsSubtitle,
          actions: [
            FilledButton.icon(
              onPressed: _createAgent,
              style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
              icon: const Icon(Icons.person_add_alt_1_outlined, size: 18),
              label: Text(t.createAgentTitle),
            ),
          ],
        ),
        // Passe sur deux lignes sur un petit écran plutôt que de déborder.
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Wrap(
                spacing: 16,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SizedBox(
                    width: 340,
                    child: TextField(
                      controller: _search,
                      onChanged: _onSearch,
                      onSubmitted: (_) => _load(),
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: t.searchHint,
                        prefixIcon: const Icon(Icons.search, size: 20),
                      ),
                    ),
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final (role, label) in filters)
                        ChoiceChip(
                          label: Text(label),
                          selected: _role == role,
                          onSelected: (_) {
                            setState(() => _role = role);
                            _load();
                          },
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                t.accountsCount(admin.usersTotal),
                style: TextStyle(
                  color: context.palette.textMuted,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_error != null) ...[
          ErrorBanner(_error!),
          const SizedBox(height: 12),
        ],
        ConsoleCard(
          padding: EdgeInsets.zero,
          child: _loading && admin.users.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(48),
                  child: Center(child: CircularProgressIndicator()),
                )
              : admin.users.isEmpty
              ? ConsoleEmpty(
                  icon: Icons.person_search_outlined,
                  text: t.noAccounts,
                )
              : _table(context, admin.users, myId),
        ),
      ],
    );
  }

  Widget _table(BuildContext context, List<AppUser> users, String? myId) {
    final t = context.t;
    final p = context.palette;
    final admin = AppScope.of(context).admin;
    TextStyle head() => TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w800,
      letterSpacing: 0.4,
      color: p.textMuted,
    );
    return LayoutBuilder(
      builder: (context, box) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: box.maxWidth),
          child: DataTable(
            headingRowHeight: 48,
            dataRowMinHeight: 64,
            dataRowMaxHeight: 72,
            horizontalMargin: 20,
            columnSpacing: 28,
            headingRowColor: WidgetStatePropertyAll(p.surfaceAlt),
            dividerThickness: 1,
            columns: [
              DataColumn(label: Text(t.colUser.toUpperCase(), style: head())),
              DataColumn(
                label: Text(t.phoneLabel.toUpperCase(), style: head()),
              ),
              DataColumn(label: Text(t.roleLabel.toUpperCase(), style: head())),
              DataColumn(
                label: Text(t.companyLabel.toUpperCase(), style: head()),
              ),
              DataColumn(
                label: Text(t.sectionIdentity.toUpperCase(), style: head()),
              ),
              DataColumn(label: Text(t.colStatus.toUpperCase(), style: head())),
              const DataColumn(label: SizedBox.shrink()),
            ],
            rows: [
              for (final user in users)
                DataRow(
                  cells: [
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InitialAvatar(user.firstName, size: 36),
                          const SizedBox(width: 12),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                user.email,
                                style: TextStyle(
                                  color: p.textMuted,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    DataCell(
                      Text(
                        ltr(user.phone),
                        style: const TextStyle(
                          fontFamily: AppFonts.mono,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    DataCell(roleChip(context, user.role)),
                    DataCell(
                      Text(
                        user.companyName ?? '—',
                        style: TextStyle(
                          color: user.companyName == null
                              ? p.textMuted
                              : p.text,
                        ),
                      ),
                    ),
                    DataCell(
                      user.role == UserRole.driver
                          ? identityChip(context, user.identity.status)
                          : Text('—', style: TextStyle(color: p.textMuted)),
                    ),
                    DataCell(
                      StatusChip(
                        label: user.active ? t.statusActive : t.statusSuspended,
                        background: user.active ? p.successBg : p.errorBg,
                        foreground: user.active ? p.successText : p.errorText,
                      ),
                    ),
                    DataCell(
                      user.id == myId
                          ? const SizedBox.shrink()
                          : PopupMenuButton<String>(
                              tooltip: t.edit,
                              icon: const Icon(Icons.more_horiz),
                              onSelected: (action) => switch (action) {
                                'role' => _changeRole(user),
                                _ => _run(
                                  () => admin.setActive(user, !user.active),
                                ),
                              },
                              itemBuilder: (_) => [
                                PopupMenuItem(
                                  value: 'role',
                                  child: ListTile(
                                    dense: true,
                                    leading: const Icon(Icons.badge_outlined),
                                    title: Text(t.changeRole),
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'status',
                                  child: ListTile(
                                    dense: true,
                                    leading: Icon(
                                      user.active
                                          ? Icons.block_outlined
                                          : Icons.check_circle_outline,
                                      color: user.active ? p.errorText : null,
                                    ),
                                    title: Text(
                                      user.active
                                          ? t.suspendAccount
                                          : t.reactivateAccount,
                                      style: TextStyle(
                                        color: user.active ? p.errorText : null,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
