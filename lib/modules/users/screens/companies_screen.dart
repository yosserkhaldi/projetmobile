import 'package:flutter/material.dart';

import 'package:mon_constat_digital/core/state/app_scope.dart';
import 'package:mon_constat_digital/core/theme/app_colors.dart';
import 'package:mon_constat_digital/modules/users/models/company.dart';
import 'package:mon_constat_digital/modules/users/widgets/form_widgets.dart';
import 'package:mon_constat_digital/shared/widgets/page_head.dart';

class CompaniesScreen extends StatefulWidget {
  const CompaniesScreen({super.key});
  @override
  State<CompaniesScreen> createState() => _CompaniesScreenState();
}

class _CompaniesScreenState extends State<CompaniesScreen> {
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final admin = AppScope.of(context).admin;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await admin.loadCompanies();
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

  Future<void> _editCompany([Company? company]) async {
    final admin = AppScope.of(context).admin;
    final values = await showDialog<List<String>>(
      context: context,
      builder: (_) => _NameDialog(
        title: company == null ? 'Nouvelle compagnie' : 'Renommer la compagnie',
        fields: const ['Nom de la compagnie'],
        initial: [company?.name ?? ''],
      ),
    );
    if (values == null) return;
    await _run(
      () => company == null
          ? admin.createCompany(values[0])
          : admin.renameCompany(company, values[0]),
    );
  }

  Future<void> _addAgency(Company company) async {
    final admin = AppScope.of(context).admin;
    final values = await showDialog<List<String>>(
      context: context,
      builder: (_) => const _NameDialog(
        title: 'Nouvelle agence',
        fields: ["Nom de l'agence", 'Ville'],
        initial: ['', ''],
      ),
    );
    if (values == null) return;
    await _run(() => admin.addAgency(company, values[0], values[1]));
  }

  Future<void> _deleteCompany(Company company) async {
    final admin = AppScope.of(context).admin;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Supprimer ${company.name} ?'),
        content: const Text('Ses agences seront aussi supprimées.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.errorText),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirmed == true) await _run(() => admin.deleteCompany(company));
  }

  @override
  Widget build(BuildContext context) {
    final admin = AppScope.of(context).admin;
    return SafeArea(
      child: Column(
        children: [
          PageHead(
            "Compagnies d'assurance",
            subtitle: 'Compagnies et agences',
            actions: [
              IconButton.filled(
                tooltip: 'Ajouter une compagnie',
                onPressed: _editCompany,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          Expanded(child: _body(admin.companies)),
        ],
      ),
    );
  }

  Widget _body(List<Company> companies) {
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
    if (companies.isEmpty) {
      return const Center(child: Text('Aucune compagnie enregistrée.'));
    }
    final admin = AppScope.of(context).admin;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final company in companies)
          Card(
            clipBehavior: Clip.antiAlias,
            child: ExpansionTile(
              leading: const Icon(Icons.business_outlined),
              title: Text(
                company.name,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text(
                '${company.agencies.length} agence${company.agencies.length > 1 ? 's' : ''}',
                style: const TextStyle(color: AppColors.textMuted),
              ),
              shape: const Border(),
              children: [
                for (final agency in company.agencies)
                  ListTile(
                    dense: true,
                    title: Text(agency.name),
                    subtitle: Text(agency.city),
                    trailing: IconButton(
                      tooltip: "Supprimer l'agence",
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () =>
                          _run(() => admin.deleteAgency(company, agency)),
                    ),
                  ),
                OverflowBar(
                  alignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => _addAgency(company),
                      child: const Text('Ajouter une agence'),
                    ),
                    TextButton(
                      onPressed: () => _editCompany(company),
                      child: const Text('Renommer'),
                    ),
                    TextButton(
                      onPressed: () => _deleteCompany(company),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.errorText,
                      ),
                      child: const Text('Supprimer'),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _NameDialog extends StatefulWidget {
  const _NameDialog({
    required this.title,
    required this.fields,
    required this.initial,
  });
  final String title;
  final List<String> fields;
  final List<String> initial;

  @override
  State<_NameDialog> createState() => _NameDialogState();
}

class _NameDialogState extends State<_NameDialog> {
  final _form = GlobalKey<FormState>();
  late final _controllers = [
    for (final value in widget.initial) TextEditingController(text: value),
  ];

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.title),
    content: Form(
      key: _form,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < widget.fields.length; i += 1) ...[
            if (i > 0) const SizedBox(height: 12),
            LabeledField(
              label: widget.fields[i],
              controller: _controllers[i],
              validator: Validators.required,
            ),
          ],
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Annuler'),
      ),
      FilledButton(
        onPressed: () {
          if (_form.currentState!.validate()) {
            Navigator.pop(context, [
              for (final controller in _controllers) controller.text.trim(),
            ]);
          }
        },
        child: const Text('Enregistrer'),
      ),
    ],
  );
}
