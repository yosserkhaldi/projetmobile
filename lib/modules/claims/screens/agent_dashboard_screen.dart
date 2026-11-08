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
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(18),
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
              _metric(
                t.claimsToHandle,
                pending.length,
                ClaimsColors.amber,
                Icons.inbox_outlined,
              ),
              _metric(
                t.claimsExpertises,
                s.countByStatus((e) => e == ClaimStatus.expertise),
                ClaimsColors.violet,
                Icons.engineering_outlined,
              ),
              _metric(
                t.claimsClosedCount,
                s.countByStatus((e) => e == ClaimStatus.closed),
                ClaimsColors.teal,
                Icons.task_alt,
              ),
            ],
          ),
          const SizedBox(height: 22),
          Text(
            t.claimsPriority,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          if (pending.isEmpty)
            Text(
              t.claimsNothingToHandle,
              style: TextStyle(color: context.palette.textMuted),
            ),
          for (final (i, c) in pending.indexed)
            Appear(
              index: i,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  onTap: () => open(context, ClaimDetail(c, agentMode: true)),
                  child: ClaimCard(c, insight: s.insightFor(c.id)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _metric(String label, int value, Color color, IconData icon) =>
      Expanded(
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  color.withValues(alpha: .20),
                  color.withValues(alpha: .04),
                ],
              ),
            ),
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(height: 4),
                CountUp(
                  value,
                  style: TextStyle(
                    fontSize: 28,
                    color: color,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(label, textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      );
}
