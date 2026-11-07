import 'package:flutter/material.dart';

import 'package:mon_constat_digital/core/state/app_scope.dart';
import 'package:mon_constat_digital/l10n/l10n.dart';
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
      if (mounted) setState(() => _error = errorMessage(context, e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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

  Future<void> _editCompany([Company? company]) async {
    final admin = AppScope.of(context).admin;
    final values = await showDialog<List<String>>(
      context: context,
      builder: (_) => _NameDialog(
        title: company == null ? context.t.newCompany : context.t.renameCompany,
        fields: [context.t.companyNameLabel],
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

  Future<void> _editAgency(Company company, [Agency? agency]) async {
    final admin = AppScope.of(context).admin;
    final values = await showDialog<List<String>>(
      context: context,
      builder: (_) => _NameDialog(
        title: agency == null ? context.t.newAgency : context.t.editAgency,
        fields: [context.t.agencyNameLabel, context.t.cityLabel],
        initial: [agency?.name ?? '', agency?.city ?? ''],
      ),
    );
    if (values == null) return;
    await _run(
      () => agency == null
          ? admin.addAgency(company, values[0], values[1])
          : admin.updateAgency(company, agency, values[0], values[1]),
    );
  }

  Future<void> _deleteCompany(Company company) async {
    final admin = AppScope.of(context).admin;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.t.deleteCompanyTitle(company.name)),
        content: Text(context.t.deleteCompanyBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(context.t.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.errorText),
            child: Text(context.t.delete),
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
            context.t.companiesTitle,
            subtitle: context.t.companiesSubtitle,
            actions: [
              IconButton.filled(
                tooltip: context.t.addCompany,
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
            TextButton(onPressed: _load, child: Text(context.t.retry)),
          ],
        ),
      );
    }
    if (companies.isEmpty) {
      return Center(child: Text(context.t.noCompanies));
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
                context.t.agencyCount(company.agencies.length),
                style: const TextStyle(color: AppColors.textMuted),
              ),
              shape: const Border(),
              children: [
                for (final agency in company.agencies)
                  ListTile(
                    dense: true,
                    title: Text(agency.name),
                    subtitle: Text(agency.city),
                    onTap: () => _editAgency(company, agency),
                    trailing: IconButton(
                      tooltip: context.t.deleteAgencyTooltip,
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () =>
                          _run(() => admin.deleteAgency(company, agency)),
                    ),
                  ),
                OverflowBar(
                  alignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => _editAgency(company),
                      child: Text(context.t.addAgency),
                    ),
                    TextButton(
                      onPressed: () => _editCompany(company),
                      child: Text(context.t.rename),
                    ),
                    TextButton(
                      onPressed: () => _deleteCompany(company),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.errorText,
                      ),
                      child: Text(context.t.delete),
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
              validator: Validators(context.t).required,
            ),
          ],
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text(context.t.cancel),
      ),
      FilledButton(
        onPressed: () {
          if (_form.currentState!.validate()) {
            Navigator.pop(context, [
              for (final controller in _controllers) controller.text.trim(),
            ]);
          }
        },
        child: Text(context.t.save),
      ),
    ],
  );
}
