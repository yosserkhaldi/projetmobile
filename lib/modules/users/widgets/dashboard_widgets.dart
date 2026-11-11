import 'package:flutter/material.dart';

import 'package:mon_constat_digital/core/theme/app_colors.dart';
import 'package:mon_constat_digital/core/theme/app_theme.dart';
import 'package:mon_constat_digital/l10n/l10n.dart';
import 'package:mon_constat_digital/modules/users/models/app_user.dart';
import 'package:mon_constat_digital/modules/users/widgets/activity_panel.dart';

/// Les blocs du tableau de bord, assemblés différemment sur téléphone (liste)
/// et sur la console d'administration (grille).
class DashboardSections {
  DashboardSections({
    required this.kpis,
    required this.signups,
    required this.roles,
    required this.identity,
    required this.ai,
    required this.accidents,
  });

  final List<Widget> kpis;
  final Widget signups, roles, identity, accidents;

  /// Bilan de la vérification d'identité par l'IA.
  final Widget ai;

  /// Disposition téléphone : KPI en grille 2 × 2, puis les panneaux.
  List<Widget> get phone => [
    GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.35,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      children: kpis,
    ),
    const SizedBox(height: 14),
    signups,
    roles,
    identity,
    ai,
    accidents,
  ];
}

/// Panneau « Vérification par l'IA » : volume, part validée sans
/// administrateur, ressemblance moyenne, comptes bloqués, et répartition des
/// décisions.
Widget _aiPanel(BuildContext context, Map<String, dynamic>? ai) {
  final t = context.t;
  final p = context.palette;
  if (ai == null) return const SizedBox.shrink();
  final requests = ai['requests'] as int;
  String percent(Object? value) =>
      value == null ? '—' : '${((value as num) * 100).round()} %';
  Widget figure(String value, String label) => Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontFamily: AppFonts.display,
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: p.textMuted, fontSize: 12, height: 1.3),
        ),
      ],
    ),
  );
  return DashPanel(
    key: const Key('dash-ai'),
    title: t.dashAiTitle,
    footer: t.dashAiFooter,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            figure('$requests', t.dashAiRequests),
            figure(percent(ai['autoRate']), t.dashAiAutoRate),
            figure(percent(ai['averageMatch']), t.dashAiAverageMatch),
            figure('${ai['blocked']}', t.dashAiBlocked),
          ],
        ),
        const SizedBox(height: 14),
        SplitBar(
          total: requests,
          parts: [
            (t.outcomeAuto, ai['autoVerified'] as int, p.successText),
            (t.outcomeVerified, ai['adminVerified'] as int, AppColors.primary),
            (t.outcomePending, ai['pending'] as int, AppColors.accent),
            (t.outcomeRejected, ai['rejected'] as int, p.errorText),
          ],
        ),
      ],
    ),
  );
}

DashboardSections dashboardSections(
  BuildContext context,
  Map<String, dynamic> stats,
) {
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

  return DashboardSections(
    kpis: [
      Kpi(
        icon: Icons.people_alt_outlined,
        label: t.dashUsers,
        value: '$total',
        detail: t.dashActive(users['active'] as int),
      ),
      Kpi(
        icon: Icons.badge_outlined,
        label: t.dashPendingIds,
        value: '${identity['PENDING']}',
        // Part validée par la reconnaissance faciale, quand il y en a une.
        detail: (stats['identityAutoVerified'] as int? ?? 0) > 0
            ? t.dashVerifiedIdsAi(
                identity['VERIFIED'] as int,
                stats['identityAutoVerified'] as int,
              )
            : t.dashVerifiedIds(identity['VERIFIED'] as int),
        highlight: (identity['PENDING'] as int) > 0,
      ),
      Kpi(
        icon: Icons.verified_outlined,
        label: t.dashPhones,
        value: '$phones %',
        detail: '${users['phoneVerified']} / $total',
      ),
      Kpi(
        icon: Icons.login_rounded,
        label: t.dashSignIns,
        value: '${signIns['success']}',
        detail: t.dashFailed(signIns['failed'] as int),
      ),
    ],
    signups: DashPanel(
      title: t.dashSignupsTitle,
      child: SizedBox(height: 120, child: SignupBars(values: signups)),
    ),
    roles: DashPanel(
      title: t.dashRolesTitle,
      child: SplitBar(
        total: total,
        parts: [
          (
            UserRole.driver.labelIn(t),
            byRole['DRIVER'] as int,
            AppColors.primary,
          ),
          (UserRole.agent.labelIn(t), byRole['AGENT'] as int, AppColors.accent),
          (UserRole.admin.labelIn(t), byRole['ADMIN'] as int, AppColors.ink),
        ],
      ),
    ),
    identity: DashPanel(
      title: t.dashIdentityTitle,
      footer: t.dashNetwork(
        stats['companies'] as int,
        stats['agencies'] as int,
      ),
      child: SplitBar(
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
          (t.identityStatusRejected, identity['REJECTED'] as int, p.errorText),
          (t.identityStatusUnverified, identity['UNVERIFIED'] as int, p.border),
        ],
      ),
    ),
    ai: _aiPanel(context, stats['identityAi'] as Map<String, dynamic>?),
    accidents: ActivityPanel(
      activity: stats['activity'] as Map<String, dynamic>?,
    ),
  );
}

class Kpi extends StatelessWidget {
  const Kpi({
    required this.icon,
    required this.label,
    required this.value,
    required this.detail,
    this.highlight = false,
    super.key,
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

class DashPanel extends StatelessWidget {
  const DashPanel({
    required this.title,
    required this.child,
    this.footer,
    super.key,
  });
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
class SignupBars extends StatelessWidget {
  const SignupBars({required this.values, super.key});
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
class SplitBar extends StatelessWidget {
  const SplitBar({required this.total, required this.parts, super.key});
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
