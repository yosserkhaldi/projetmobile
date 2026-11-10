import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;

import 'package:mon_constat_digital/core/state/app_scope.dart';
import 'package:mon_constat_digital/core/theme/app_theme.dart';
import 'package:mon_constat_digital/l10n/l10n.dart';
import 'package:mon_constat_digital/modules/users/admin/console_widgets.dart';
import 'package:mon_constat_digital/modules/users/models/app_user.dart';
import 'package:mon_constat_digital/modules/users/screens/license_review_screen.dart';
import 'package:mon_constat_digital/modules/users/widgets/dashboard_widgets.dart';
import 'package:mon_constat_digital/modules/users/widgets/form_widgets.dart';
import 'package:mon_constat_digital/modules/users/widgets/skeleton.dart';

/// Tableau de bord de la console : indicateurs, graphiques, et ce qui attend
/// une action de l'administrateur.
class ConsoleDashboard extends StatefulWidget {
  const ConsoleDashboard({
    required this.onReview,
    required this.onSeeAllIdentities,
    super.key,
  });

  final void Function(AppUser user) onReview;
  final VoidCallback onSeeAllIdentities;

  @override
  State<ConsoleDashboard> createState() => _ConsoleDashboardState();
}

class _ConsoleDashboardState extends State<ConsoleDashboard> {
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final admin = AppScope.of(context).admin;
    setState(() => _error = null);
    try {
      await Future.wait([admin.loadStats(), admin.loadPendingIdentities()]);
    } catch (e) {
      if (mounted) setState(() => _error = errorMessage(context, e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final admin = AppScope.of(context).admin;
    final stats = admin.stats;
    return ListView(
      padding: const EdgeInsets.fromLTRB(32, 28, 32, 40),
      children: [
        ConsoleHeader(
          title: t.consoleDashboard,
          subtitle: _today(context),
          actions: [
            OutlinedButton.icon(
              onPressed: _load,
              style: OutlinedButton.styleFrom(minimumSize: const Size(0, 44)),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(t.refresh),
            ),
          ],
        ),
        if (_error != null) ...[
          ErrorBanner(_error!),
          const SizedBox(height: 16),
        ],
        if (stats == null && _error == null)
          const SkeletonDashboard(columns: 4),
        if (stats != null) ...[
          LicenseReviewAlert(count: stats['licensesToReview'] as int? ?? 0),
          ..._grid(context, dashboardSections(context, stats)),
        ],
      ],
    );
  }

  String _today(BuildContext context) {
    final text = DateFormat.yMMMMEEEEd(
      context.t.localeName,
    ).format(DateTime.now());
    return text[0].toUpperCase() + text.substring(1);
  }

  List<Widget> _grid(BuildContext context, DashboardSections sections) {
    const gap = SizedBox(width: 16);
    return [
      SizedBox(
        height: 150,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final (index, kpi) in sections.kpis.indexed) ...[
              if (index > 0) gap,
              Expanded(child: kpi),
            ],
          ],
        ),
      ),
      const SizedBox(height: 16),
      IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(flex: 3, child: sections.signups),
            gap,
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [sections.roles, sections.identity],
              ),
            ),
          ],
        ),
      ),
      IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(flex: 3, child: _ToHandle(widget: widget)),
            gap,
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [sections.ai, sections.accidents],
              ),
            ),
          ],
        ),
      ),
    ];
  }
}

/// Les demandes d'identité les plus anciennes, à examiner en priorité.
class _ToHandle extends StatelessWidget {
  const _ToHandle({required this.widget});
  final ConsoleDashboard widget;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final p = context.palette;
    final pending = AppScope.of(context).admin.pendingIdentities;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ConsoleCard(
        title: t.consoleToHandle,
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
        trailing: pending.isEmpty
            ? null
            : TextButton(
                onPressed: widget.onSeeAllIdentities,
                child: Text(t.consoleSeeAll),
              ),
        child: pending.isEmpty
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  children: [
                    Icon(Icons.task_alt_rounded, color: p.successText),
                    const SizedBox(width: 10),
                    Text(
                      t.consoleNothingToHandle,
                      style: TextStyle(color: p.textMuted),
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  for (final user in pending.take(5))
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: InitialAvatar(user.firstName),
                      title: Text(
                        user.name,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(
                        '${t.identityTitle} · CIN ${user.identity.cinNumber ?? ''}',
                        style: TextStyle(color: p.textMuted),
                      ),
                      trailing: FilledButton.tonal(
                        onPressed: () => widget.onReview(user),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(0, 38),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                        ),
                        child: Text(t.consoleReview),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
