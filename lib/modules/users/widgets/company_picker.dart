import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;

import 'package:mon_constat_digital/core/state/app_scope.dart';
import 'package:mon_constat_digital/core/theme/app_theme.dart';
import 'package:mon_constat_digital/l10n/l10n.dart';
import 'package:mon_constat_digital/modules/users/models/company.dart';
import 'package:mon_constat_digital/modules/users/widgets/form_widgets.dart';

/// Choix d'une compagnie d'assurance (et de son agence) dans le référentiel
/// du module 1, au lieu d'un texte libre. Fonctionne hors ligne (SQLite).
///
/// ```dart
/// CompanyPicker(
///   companyId: contract.companyId,
///   agencyId: contract.agencyId,
///   onChanged: (company, agency) => setState(() { ... }),
/// )
/// ```
/// L'identifiant renvoyé (`company.id`) est celui de l'API : c'est lui qu'il
/// faut enregistrer dans le contrat, pour que le sinistre arrive aux agents
/// de cette compagnie.
class CompanyPicker extends StatefulWidget {
  const CompanyPicker({
    required this.onChanged,
    this.companyId,
    this.agencyId,
    this.withAgency = true,
    this.required = true,
    super.key,
  });

  final String? companyId, agencyId;
  final void Function(Company? company, Agency? agency) onChanged;

  /// Affiche aussi le choix de l'agence de la compagnie.
  final bool withAgency;
  final bool required;

  @override
  State<CompanyPicker> createState() => _CompanyPickerState();
}

class _CompanyPickerState extends State<CompanyPicker> {
  late String? _companyId = widget.companyId;
  late String? _agencyId = widget.agencyId;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final store = AppScope.of(context).companies;
    try {
      await store.load();
      if (mounted) setState(() => _error = null);
    } catch (e) {
      if (mounted) setState(() => _error = errorMessage(context, e));
    }
  }

  void _select(Company? company, Agency? agency) {
    setState(() {
      _companyId = company?.id;
      _agencyId = agency?.id;
    });
    widget.onChanged(company, agency);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final p = context.palette;
    final store = AppScope.of(context).companies;
    final companies = store.companies;
    final company = store.byId(_companyId);
    final agencies = company?.agencies ?? const <Agency>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_error != null) ...[
          ErrorBanner(_error!),
          TextButton(onPressed: _load, child: Text(t.retry)),
        ],
        DropdownButtonFormField<String>(
          key: ValueKey('company-${companies.length}'),
          initialValue: company?.id,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: t.companyLabel,
            prefixIcon: const Icon(Icons.business_outlined),
          ),
          validator: widget.required
              ? (value) => value == null ? t.requiredField : null
              : null,
          items: [
            for (final c in companies)
              DropdownMenuItem(value: c.id, child: Text(c.name)),
          ],
          onChanged: (id) => _select(store.byId(id), null),
        ),
        if (widget.withAgency && agencies.isNotEmpty) ...[
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            key: ValueKey('agency-$_companyId'),
            initialValue: agencies.any((a) => a.id == _agencyId)
                ? _agencyId
                : null,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: t.agencyLabel,
              prefixIcon: const Icon(Icons.storefront_outlined),
            ),
            items: [
              for (final a in agencies)
                DropdownMenuItem(
                  value: a.id,
                  child: Text('${a.name} · ${a.city}'),
                ),
            ],
            onChanged: (id) =>
                _select(company, agencies.where((a) => a.id == id).firstOrNull),
          ),
        ],
        if (store.offline && store.syncedAt != null) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.cloud_off_outlined, size: 14, color: p.textMuted),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  t.companiesOffline(
                    DateFormat.yMMMd(t.localeName).format(store.syncedAt!),
                  ),
                  style: TextStyle(color: p.textMuted, fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
