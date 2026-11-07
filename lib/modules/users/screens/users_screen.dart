import 'package:flutter/material.dart';

import 'package:mon_constat_digital/core/state/app_scope.dart';
import 'package:mon_constat_digital/core/theme/app_colors.dart';
import 'package:mon_constat_digital/modules/users/models/app_user.dart';
import 'package:mon_constat_digital/modules/users/screens/agent_form_screen.dart';
import 'package:mon_constat_digital/modules/users/widgets/form_widgets.dart';
import 'package:mon_constat_digital/shared/navigation.dart';
import 'package:mon_constat_digital/shared/widgets/page_head.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});
  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final _search = TextEditingController();
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
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
      await admin.loadUsers(query: _search.text.trim());
    } catch (e) {
      if (mounted) setState(() => _error = errorMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _run(Future<void> Function() action) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await action();
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(errorMessage(e))));
    }
  }

  Future<void> _changeRole(AppUser user) async {
    final admin = AppScope.of(context).admin;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _RoleSheet(
        user: user,
        onSave: (role, companyId) =>
            admin.setRole(user, role, companyId: companyId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stores = AppScope.of(context);
    final admin = stores.admin;
    final myId = stores.users.currentUser?.id;
    return SafeArea(
      child: Column(
        children: [
          PageHead(
            'Gestion des comptes',
            subtitle: 'Rôles, agents et suspensions',
            actions: [
              IconButton.filled(
                tooltip: 'Créer un agent',
                onPressed: () => open(context, const AgentFormScreen()),
                icon: const Icon(Icons.person_add_alt),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
            child: TextField(
              controller: _search,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _load(),
              decoration: const InputDecoration(
                hintText: 'Nom, e-mail ou téléphone',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(child: _body(admin.users, myId)),
        ],
      ),
    );
  }

  Widget _body(List<AppUser> users, String? myId) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ErrorBanner(_error!),
            TextButton(onPressed: _load, child: const Text('Réessayer')),
          ],
        ),
      );
    }
    if (users.isEmpty) {
      return const Center(child: Text('Aucun compte trouvé.'));
    }
    final admin = AppScope.of(context).admin;
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: users.length,
      itemBuilder: (_, i) {
        final user = users[i];
        final isMe = user.id == myId;
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              child: Text(user.firstName.characters.first.toUpperCase()),
            ),
            title: Text(
              user.name,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: Text(
              '${user.email}\n${user.role.label}'
              '${user.companyName == null ? '' : ' • ${user.companyName}'}',
              style: const TextStyle(color: AppColors.textMuted),
            ),
            isThreeLine: true,
            // Un administrateur ne peut pas modifier son propre compte ici.
            onTap: isMe ? null : () => _changeRole(user),
            trailing: Switch(
              value: user.active,
              onChanged: isMe
                  ? null
                  : (active) => _run(() => admin.setActive(user, active)),
            ),
          ),
        );
      },
    );
  }
}

class _RoleSheet extends StatefulWidget {
  const _RoleSheet({required this.user, required this.onSave});
  final AppUser user;
  final Future<void> Function(UserRole role, String? companyId) onSave;

  @override
  State<_RoleSheet> createState() => _RoleSheetState();
}

class _RoleSheetState extends State<_RoleSheet> with FormActions {
  late UserRole _role = widget.user.role;
  late String? _companyId = widget.user.companyId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await AppScope.of(context).admin.loadCompanies();
      } catch (e) {
        if (mounted) setState(() => error = errorMessage(e));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final companies = AppScope.of(context).admin.companies;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        20 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.user.name,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 14),
            if (error != null) ...[
              ErrorBanner(error!),
              const SizedBox(height: 14),
            ],
            DropdownButtonFormField<UserRole>(
              initialValue: _role,
              decoration: const InputDecoration(labelText: 'Rôle'),
              items: [
                for (final role in UserRole.values)
                  DropdownMenuItem(value: role, child: Text(role.label)),
              ],
              onChanged: (value) => setState(() => _role = value!),
            ),
            if (_role == UserRole.agent) ...[
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                // La valeur n'est affichée qu'une fois les compagnies chargées.
                key: ValueKey(companies.length),
                initialValue: companies.any((c) => c.id == _companyId)
                    ? _companyId
                    : null,
                decoration: const InputDecoration(labelText: 'Compagnie'),
                validator: Validators.required,
                items: [
                  for (final company in companies)
                    DropdownMenuItem(
                      value: company.id,
                      child: Text(company.name),
                    ),
                ],
                onChanged: (value) => setState(() => _companyId = value),
              ),
            ],
            const SizedBox(height: 18),
            BusyButton(
              label: 'Enregistrer',
              busy: busy,
              onPressed: () {
                final navigator = Navigator.of(context);
                submit(() async {
                  await widget.onSave(
                    _role,
                    _role == UserRole.agent ? _companyId : null,
                  );
                  navigator.pop();
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
