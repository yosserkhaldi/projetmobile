import 'package:flutter/material.dart';

import 'package:mon_constat_digital/core/theme/app_palette.dart';

import 'package:mon_constat_digital/core/state/app_scope.dart';
import 'package:mon_constat_digital/modules/claims/models/claim_filter.dart';
import 'package:mon_constat_digital/modules/claims/models/claim_status.dart';
import 'package:mon_constat_digital/modules/claims/screens/claim_detail_screen.dart';
import 'package:mon_constat_digital/modules/claims/widgets/claim_card.dart';
import 'package:mon_constat_digital/modules/claims/widgets/format.dart';
import 'package:mon_constat_digital/modules/claims/widgets/motion.dart';
import 'package:mon_constat_digital/modules/claims/widgets/offline_banner.dart';
import 'package:mon_constat_digital/shared/navigation.dart';
import 'package:mon_constat_digital/shared/widgets/page_head.dart';
import 'package:mon_constat_digital/l10n/l10n.dart';
import 'package:mon_constat_digital/modules/claims/l10n/claims_text.dart';

class ClaimsScreen extends StatefulWidget {
  const ClaimsScreen({this.agentMode = false, super.key});
  final bool agentMode;

  @override
  State<ClaimsScreen> createState() => _ClaimsScreenState();
}

class _ClaimsScreenState extends State<ClaimsScreen> {
  String query = '';
  String? status, severity;
  DateTimeRange? dates;

  Future<void> _pickDates() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      initialDateRange: dates,
    );
    if (range != null) setState(() => dates = range);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final store = AppScope.of(context).claims;
    final filter = ClaimFilter(
      query: query,
      status: status,
      severity: severity,
      dates: dates,
      display: t.claimValue,
    );
    final claims = store.claims.where(filter.matches).toList();
    return SafeArea(
      child: Column(
        children: [
          const OfflineBanner(),
          PageHead(
            widget.agentMode ? t.claimsReceived : t.claimsMyClaims,
            subtitle: t.claimsCount(
              '${claims.length}',
              '${store.claims.length}',
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              onChanged: (value) => setState(() => query = value),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: t.claimsFilterHint,
              ),
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _Menu(
                  label: t.claimsStatus,
                  value: status,
                  values: ClaimStatus.all,
                  onChanged: (value) => setState(() => status = value),
                ),
                const SizedBox(width: 8),
                _Menu(
                  label: t.claimsSeverity,
                  value: severity,
                  values: ClaimFilter.severities,
                  onChanged: (value) => setState(() => severity = value),
                ),
                const SizedBox(width: 8),
                InputChip(
                  label: Text(
                    dates == null
                        ? t.claimsDate
                        : '${formatDay(dates!.start)} – '
                              '${formatDay(dates!.end)}',
                  ),
                  onPressed: _pickDates,
                  onDeleted: dates == null
                      ? null
                      : () => setState(() => dates = null),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: claims.isEmpty
                ? Center(
                    child: Text(
                      t.claimsNoMatch,
                      style: TextStyle(color: context.palette.textMuted),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: claims.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => InkWell(
                      onTap: () => open(
                        context,
                        ClaimDetail(claims[i], agentMode: widget.agentMode),
                      ),
                      child: ClaimCard(
                        claims[i],
                        insight: widget.agentMode
                            ? store.insightFor(claims[i].id)
                            : null,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _Menu extends StatelessWidget {
  const _Menu({
    required this.label,
    required this.value,
    required this.values,
    required this.onChanged,
  });
  final String label;
  final String? value;
  final List<String> values;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) => PopupMenuButton<String>(
    tooltip: label,
    onSelected: (selected) => onChanged(selected.isEmpty ? null : selected),
    itemBuilder: (_) => [
      PopupMenuItem(value: '', child: Text(context.t.claimsAllOf(label))),
      ...values.map(
        (e) => PopupMenuItem(value: e, child: Text(context.t.claimValue(e))),
      ),
    ],
    child: Chip(
      label: Text(
        value == null ? label : '$label: ${context.t.claimValue(value!)}',
        style: value == null
            ? null
            : const TextStyle(
                color: ClaimsColors.violet,
                fontWeight: FontWeight.w800,
              ),
      ),
      avatar: Icon(
        value == null ? Icons.filter_list : Icons.filter_alt,
        size: 18,
        color: value == null ? null : ClaimsColors.violet,
      ),
      side: value == null
          ? null
          : const BorderSide(color: ClaimsColors.violet, width: 1.5),
      backgroundColor: value == null
          ? null
          : ClaimsColors.violet.withValues(alpha: .12),
    ),
  );
}
