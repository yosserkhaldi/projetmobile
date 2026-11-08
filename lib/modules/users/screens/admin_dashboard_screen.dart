import 'package:flutter/material.dart';

import 'package:mon_constat_digital/core/state/app_scope.dart';
import 'package:mon_constat_digital/core/theme/app_colors.dart';
import 'package:mon_constat_digital/core/theme/app_theme.dart';
import 'package:mon_constat_digital/l10n/l10n.dart';
import 'package:mon_constat_digital/modules/users/models/app_user.dart';
import 'package:mon_constat_digital/modules/users/widgets/form_widgets.dart';
import 'package:mon_constat_digital/shared/widgets/page_head.dart';

/// Tableau de bord administrateur (1.4), sur les données réelles des comptes.
/// Les indicateurs d'accidents arrivent avec les modules 3 et 5.
class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
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
      await admin.loadStats();
    } catch (e) {
      if (mounted) setState(() => _error = errorMessage(context, e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final stats = AppScope.of(context).admin.stats;
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          children: [
            PageHead(t.adminTitle, subtitle: t.adminSubtitle),
            if (_error != null) ...[
              ErrorBanner(_error!),
              TextButton(onPressed: _load, child: Text(t.retry)),
            ],
            if (stats == null && _error == null)
              const Padding(
                padding: EdgeInsets.all(40),
                child: Center(child: CircularProgressIndicator()),
              ),
            if (stats != null) ..._content(context, stats),
          ],
        ),
      ),
    );
  }

  List<Widget> _content(BuildContext context, Map<String, dynamic> stats) {
    final t = context.t;
    final p = context.palette;
    final users = stats['users'] as Map<String, dynamic>;
    final identity = stats['identity'] as Map<String, dynamic>;
    final signIns = stats['signIns7Days'] as Map<String, dynamic>;
    final byRole = users['byRole'] as Map<String, dynamic>;
    final total = users['total'] as int;
    final phones = total == 0
        ? 0
        : ((users['phoneVerified'] as int) * 100 / total).round();
    final signups = [
      for (final day in stats['signups'] as List)
        (day as Map<String, dynamic>)['count'] as int,
    ];

    return [
      GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        childAspectRatio: 1.35,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        children: [
          _Kpi(
            icon: Icons.people_alt_outlined,
            label: t.dashUsers,
            value: '$total',
            detail: t.dashActive(users['active'] as int),
          ),
          _Kpi(
            icon: Icons.badge_outlined,
            label: t.dashPendingIds,
            value: '${identity['PENDING']}',
            detail: t.dashVerifiedIds(identity['VERIFIED'] as int),
            highlight: (identity['PENDING'] as int) > 0,
          ),
          _Kpi(
            icon: Icons.verified_outlined,
            label: t.dashPhones,
            value: '$phones %',
            detail: '${users['phoneVerified']} / $total',
          ),
          _Kpi(
            icon: Icons.login_rounded,
            label: t.dashSignIns,
            value: '${signIns['success']}',
            detail: t.dashFailed(signIns['failed'] as int),
          ),
        ],
      ),
      const SizedBox(height: 14),
      _Panel(
        title: t.dashSignupsTitle,
        child: SizedBox(height: 120, child: _Bars(values: signups)),
      ),
      _Panel(
        title: t.dashRolesTitle,
        child: _Split(
          total: total,
          parts: [
            (
              UserRole.driver.labelIn(t),
              byRole['DRIVER'] as int,
              AppColors.primary,
            ),
            (
              UserRole.agent.labelIn(t),
              byRole['AGENT'] as int,
              AppColors.accent,
            ),
            (UserRole.admin.labelIn(t), byRole['ADMIN'] as int, AppColors.ink),
          ],
        ),
      ),
      _Panel(
        title: t.dashIdentityTitle,
        footer: t.dashNetwork(
          stats['companies'] as int,
          stats['agencies'] as int,
        ),
        child: _Split(
          total: (byRole['DRIVER'] as int),
          parts: [
            (
              t.identityStatusVerified,
              identity['VERIFIED'] as int,
              p.successText,
            ),
            (
              t.identityStatusPending,
              identity['PENDING'] as int,
              AppColors.accent,
            ),
            (
              t.identityStatusRejected,
              identity['REJECTED'] as int,
              p.errorText,
            ),
            (
              t.identityStatusUnverified,
              identity['UNVERIFIED'] as int,
              p.border,
            ),
          ],
        ),
      ),
      _Panel(
        title: t.dashAccidentsTitle,
        child: Row(
          children: [
            Icon(Icons.map_outlined, size: 36, color: p.textMuted),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                t.dashAccidentsPending,
                style: TextStyle(color: p.textMuted, height: 1.4),
              ),
            ),
          ],
        ),
      ),
    ];
  }
}

class _Kpi extends StatelessWidget {
  const _Kpi({
    required this.icon,
    required this.label,
    required this.value,
    required this.detail,
    this.highlight = false,
  });

  final IconData icon;
  final String label, value, detail;

  /// Une action attend l'administrateur.
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: highlight ? p.warningBg : p.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: highlight ? AppColors.accent : p.borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: highlight ? p.warningText : p.primaryText,
            size: 22,
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontFamily: AppFonts.display,
              fontWeight: FontWeight.w800,
              fontSize: 28,
              height: 1,
              color: highlight ? p.warningText : p.text,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          ),
          Text(
            detail,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: p.textMuted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.title, required this.child, this.footer});
  final String title;
  final Widget child;
  final String? footer;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title.toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
                color: p.textMuted,
              ),
            ),
            const SizedBox(height: 12),
            child,
            if (footer != null) ...[
              const SizedBox(height: 12),
              Text(footer!, style: TextStyle(color: p.textMuted, fontSize: 12)),
            ],
          ],
        ),
      ),
    );
  }
}

/// Barres verticales, une par jour. Le dernier jour est mis en avant.
class _Bars extends StatelessWidget {
  const _Bars({required this.values});
  final List<int> values;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final max = values.fold<int>(1, (a, b) => b > a ? b : a);
    return Column(
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final (index, value) in values.indexed)
                Expanded(
                  child: Tooltip(
                    message: '$value',
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 1.5),
                      height: value == 0 ? 3 : 100 * value / max,
                      decoration: BoxDecoration(
                        color: value == 0
                            ? p.surfaceAlt
                            : index == values.length - 1
                            ? AppColors.accent
                            : p.primaryText,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'J-${values.length - 1}',
              style: TextStyle(color: p.textMuted, fontSize: 11),
            ),
            Text(
              '${values.fold<int>(0, (a, b) => a + b)}',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            Text('J', style: TextStyle(color: p.textMuted, fontSize: 11)),
          ],
        ),
      ],
    );
  }
}

/// Barre empilée et légende : parts d'un total.
class _Split extends StatelessWidget {
  const _Split({required this.total, required this.parts});
  final int total;
  final List<(String, int, Color)> parts;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            height: 12,
            child: total == 0
                ? Container(color: p.surfaceAlt)
                : Row(
                    children: [
                      for (final (_, count, color) in parts)
                        if (count > 0)
                          Expanded(
                            flex: count,
                            child: Container(color: color),
                          ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 14,
          runSpacing: 6,
          children: [
            for (final (label, count, color) in parts)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$label  $count',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }
}
