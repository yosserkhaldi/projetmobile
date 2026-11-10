import 'package:flutter/material.dart';

import 'package:mon_constat_digital/core/theme/app_palette.dart';

import 'package:mon_constat_digital/core/state/app_scope.dart';
import 'package:mon_constat_digital/modules/claims/models/claim_status.dart';
import 'package:mon_constat_digital/modules/claims/screens/analytics_screen.dart';
import 'package:mon_constat_digital/modules/claims/screens/claim_detail_screen.dart';
import 'package:mon_constat_digital/modules/claims/screens/notifications_screen.dart';
import 'package:mon_constat_digital/modules/claims/widgets/claim_card.dart';
import 'package:mon_constat_digital/modules/claims/widgets/motion.dart';
import 'package:mon_constat_digital/modules/claims/widgets/offline_banner.dart';
import 'package:mon_constat_digital/modules/users/models/app_user.dart';
import 'package:mon_constat_digital/shared/navigation.dart';
import 'package:mon_constat_digital/shared/widgets/page_head.dart';
import 'package:mon_constat_digital/l10n/l10n.dart';

class AgentDashboard extends StatelessWidget {
  const AgentDashboard({super.key});
  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final s = AppScope.of(context).claims;
    final pending = s.byPriority(
      s.claims.where((claim) => ClaimStatus.isOpenForAgent(claim.status)),
    );
    final unread = s.unreadCount(UserRole.agent);
    return ClaimsStyle(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            const OfflineBanner(),
            PageHead(
              t.claimsAgentSpace,
              subtitle: t.claimsAgentSubtitle,
              actions: [
                IconButton(
                  tooltip: t.claimsStatistics,
                  onPressed: () => open(context, const AnalyticsScreen()),
                  icon: const Icon(Icons.bar_chart),
                ),
                IconButton(
                  tooltip: t.claimsNotifications,
                  onPressed: () => open(context, const NotificationsScreen()),
                  icon: Badge(
                    isLabelVisible: unread > 0,
                    label: Text('$unread'),
                    child: const Icon(Icons.notifications_outlined),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                _Stat(
                  t.claimsToHandle,
                  pending.length,
                  ClaimsColors.threshold(
                    pending.length,
                    warnAt: 5,
                    criticalAt: 10,
                  ),
                ),
                const SizedBox(width: 8),
                _Stat(
                  t.claimsExpertises,
                  s.countByStatus((e) => e == ClaimStatus.expertise),
                  ClaimsColors.info,
                ),
                const SizedBox(width: 8),
                _Stat(
                  t.claimsClosedCount,
                  s.countByStatus((e) => e == ClaimStatus.closed),
                  ClaimsColors.ok,
                ),
              ],
            ),
            SectionTitle(t.claimsPriority),
            if (pending.isEmpty)
              Text(
                t.claimsNothingToHandle,
                style: TextStyle(color: context.palette.textMuted),
              ),
            for (final (i, c) in pending.indexed)
              Appear(
                index: i,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: () => open(context, ClaimDetail(c, agentMode: true)),
                    child: ClaimCard(c, insight: s.insightFor(c.id)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Panneau « stat » : libellé, chiffre, pastille de seuil. Pas d'icône ni de
/// dégradé, le chiffre suffit.
class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value, this.color);
  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) => Expanded(
    child: InkPanel(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SeriesDot(color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: context.palette.textMuted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          CountUp(
            value,
            style: TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 26,
              fontWeight: FontWeight.w500,
              color: context.palette.text,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    ),
  );
}
