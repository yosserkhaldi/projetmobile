import 'package:flutter/material.dart';

import 'package:mon_constat_digital/core/state/app_scope.dart';
import 'package:mon_constat_digital/core/theme/app_theme.dart';
import 'package:mon_constat_digital/l10n/l10n.dart';
import 'package:mon_constat_digital/modules/users/admin/console_widgets.dart';
import 'package:mon_constat_digital/modules/users/models/company.dart';
import 'package:mon_constat_digital/modules/users/screens/companies_screen.dart';
import 'package:mon_constat_digital/modules/users/widgets/form_widgets.dart';

/// Compagnies à gauche, agences de la compagnie choisie à droite.
class ConsoleCompanies extends StatefulWidget {
  const ConsoleCompanies({super.key});

  @override
  State<ConsoleCompanies> createState() => _ConsoleCompaniesState();
}

class _ConsoleCompaniesState extends State<ConsoleCompanies> {
  String? _selectedId;
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
      final list = admin.companies;
      if (mounted && !list.any((c) => c.id == _selectedId)) {
        setState(() => _selectedId = list.firstOrNull?.id);
      }
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

  Future<List<String>?> _ask(
    String title,
    List<String> fields,
    List<String> initial,
  ) => showDialog<List<String>>(
    context: context,
    builder: (_) => NameDialog(title: title, fields: fields, initial: initial),
  );

  Future<void> _newCompany() async {
    final t = context.t;
    final admin = AppScope.of(context).admin;
    final values = await _ask(t.newCompany, [t.companyNameLabel], ['']);
    if (values == null) return;
    await _run(() async {
      await admin.createCompany(values[0]);
      final created = admin.companies.where((c) => c.name == values[0]);
      if (created.isNotEmpty) setState(() => _selectedId = created.first.id);
    });
  }

  Future<void> _rename(Company company) async {
    final t = context.t;
    final admin = AppScope.of(context).admin;
    final values = await _ask(
      t.renameCompany,
      [t.companyNameLabel],
      [company.name],
    );
    if (values != null) {
      await _run(() => admin.renameCompany(company, values[0]));
    }
  }

  Future<void> _delete(Company company) async {
    final t = context.t;
    final p = context.palette;
    final admin = AppScope.of(context).admin;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: Text(t.deleteCompanyTitle(company.name)),
        content: Text(t.deleteCompanyBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog, false),
            child: Text(t.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialog, true),
            style: FilledButton.styleFrom(backgroundColor: p.errorText),
            child: Text(t.delete),
          ),
        ],
      ),
    );
    if (confirmed == true) await _run(() => admin.deleteCompany(company));
  }

  Future<void> _editAgency(Company company, [Agency? agency]) async {
    final t = context.t;
    final admin = AppScope.of(context).admin;
    final values = await _ask(
      agency == null ? t.newAgency : t.editAgency,
      [t.agencyNameLabel, t.cityLabel],
      [agency?.name ?? '', agency?.city ?? ''],
    );
    if (values == null) return;
    await _run(
      () => agency == null
          ? admin.addAgency(company, values[0], values[1])
          : admin.updateAgency(company, agency, values[0], values[1]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final p = context.palette;
    final companies = AppScope.of(context).admin.companies;
    final selected = companies.where((c) => c.id == _selectedId).firstOrNull;
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 28, 32, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ConsoleHeader(
            title: t.companiesTitle,
            subtitle: t.companiesSubtitle,
            actions: [
              FilledButton.icon(
                onPressed: _newCompany,
                style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
                icon: const Icon(Icons.add_business_outlined, size: 18),
                label: Text(t.newCompany),
              ),
            ],
          ),
          if (_error != null) ...[
            ErrorBanner(_error!),
            const SizedBox(height: 12),
          ],
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 340,
                  child: ConsoleCard(
                    expand: true,
                    padding: const EdgeInsets.all(8),
                    child: _loading && companies.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(32),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        : companies.isEmpty
                        ? ConsoleEmpty(
                            icon: Icons.business_outlined,
                            text: t.noCompanies,
                          )
                        : SingleChildScrollView(
                            child: Column(
                              children: [
                                for (final company in companies)
                                  _CompanyItem(
                                    company: company,
                                    selected: company.id == _selectedId,
                                    onTap: () => setState(
                                      () => _selectedId = company.id,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: ConsoleCard(
                    expand: true,
                    padding: const EdgeInsets.all(24),
                    child: selected == null
                        ? ConsoleEmpty(
                            icon: Icons.storefront_outlined,
                            text: t.selectCompany,
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: p.primaryTint,
                                      borderRadius: BorderRadius.circular(
                                        AppRadius.input,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.business,
                                      color: p.primaryText,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          selected.name,
                                          style: const TextStyle(
                                            fontFamily: AppFonts.display,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 22,
                                          ),
                                        ),
                                        Text(
                                          t.agencyCount(
                                            selected.agencies.length,
                                          ),
                                          style: TextStyle(color: p.textMuted),
                                        ),
                                      ],
                                    ),
                                  ),
                                  TextButton.icon(
                                    onPressed: () => _rename(selected),
                                    icon: const Icon(
                                      Icons.edit_outlined,
                                      size: 18,
                                    ),
                                    label: Text(t.rename),
                                  ),
                                  TextButton.icon(
                                    onPressed: () => _delete(selected),
                                    style: TextButton.styleFrom(
                                      foregroundColor: p.errorText,
                                    ),
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      size: 18,
                                    ),
                                    label: Text(t.delete),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 22),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      t.agenciesTitle.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.6,
                                        color: p.textMuted,
                                      ),
                                    ),
                                  ),
                                  OutlinedButton.icon(
                                    onPressed: () => _editAgency(selected),
                                    style: OutlinedButton.styleFrom(
                                      minimumSize: const Size(0, 40),
                                      textStyle: consoleButtonText,
                                    ),
                                    icon: const Icon(Icons.add, size: 18),
                                    label: Text(t.addAgency),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Expanded(
                                child: selected.agencies.isEmpty
                                    ? ConsoleEmpty(
                                        icon: Icons.storefront_outlined,
                                        text: t.noAgencies,
                                      )
                                    : ListView.separated(
                                        itemCount: selected.agencies.length,
                                        separatorBuilder: (_, _) => Divider(
                                          height: 1,
                                          color: p.surfaceAlt,
                                        ),
                                        itemBuilder: (_, i) {
                                          final agency = selected.agencies[i];
                                          return ListTile(
                                            leading: Icon(
                                              Icons.storefront_outlined,
                                              color: p.primaryText,
                                            ),
                                            title: Text(
                                              agency.name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            subtitle: Row(
                                              children: [
                                                Icon(
                                                  Icons.place_outlined,
                                                  size: 14,
                                                  color: p.textMuted,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(agency.city),
                                              ],
                                            ),
                                            trailing: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                IconButton(
                                                  tooltip: t.editAgency,
                                                  onPressed: () => _editAgency(
                                                    selected,
                                                    agency,
                                                  ),
                                                  icon: const Icon(
                                                    Icons.edit_outlined,
                                                  ),
                                                ),
                                                IconButton(
                                                  tooltip:
                                                      t.deleteAgencyTooltip,
                                                  onPressed: () => _run(
                                                    () => AppScope.of(context)
                                                        .admin
                                                        .deleteAgency(
                                                          selected,
                                                          agency,
                                                        ),
                                                  ),
                                                  icon: Icon(
                                                    Icons.delete_outline,
                                                    color: p.errorText,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                              ),
                            ],
                          ),
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

class _CompanyItem extends StatelessWidget {
  const _CompanyItem({
    required this.company,
    required this.selected,
    required this.onTap,
  });

  final Company company;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Material(
      color: selected ? p.primaryTint : Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.input),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.input),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(
                Icons.business_outlined,
                color: selected ? p.primaryText : p.textMuted,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  company.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: selected ? p.primaryText : p.text,
                  ),
                ),
              ),
              StatusChip(
                label: '${company.agencies.length}',
                background: p.surfaceAlt,
                foreground: p.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
