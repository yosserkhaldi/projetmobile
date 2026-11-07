import 'package:flutter/material.dart';

import 'package:mon_constat_digital/core/state/app_scope.dart';
import 'package:mon_constat_digital/core/theme/app_colors.dart';
import 'package:mon_constat_digital/modules/claims/models/claim_status.dart';
import 'package:mon_constat_digital/modules/claims/screens/analytics_screen.dart';
import 'package:mon_constat_digital/modules/claims/screens/claim_detail_screen.dart';
import 'package:mon_constat_digital/modules/claims/screens/notifications_screen.dart';
import 'package:mon_constat_digital/modules/claims/widgets/claim_card.dart';
import 'package:mon_constat_digital/modules/claims/widgets/offline_banner.dart';
import 'package:mon_constat_digital/modules/users/models/app_user.dart';
import 'package:mon_constat_digital/shared/navigation.dart';
import 'package:mon_constat_digital/shared/widgets/page_head.dart';

class AgentDashboard extends StatelessWidget {
  const AgentDashboard({super.key});
  @override
  Widget build(BuildContext context) {
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
            'Espace agent',
            subtitle: 'Instruction des sinistres',
            actions: [
              IconButton(
                tooltip: 'Statistiques',
                onPressed: () => open(context, const AnalyticsScreen()),
                icon: const Icon(Icons.bar_chart),
              ),
              IconButton(
                tooltip: 'Notifications',
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
              _metric('À traiter', '${pending.length}', AppColors.warningText),
              _metric(
                'Expertises',
                '${s.countByStatus((e) => e == ClaimStatus.expertise)}',
                AppColors.primary,
              ),
              _metric(
                'Clôturés',
                '${s.countByStatus((e) => e == ClaimStatus.closed)}',
                AppColors.successText,
              ),
            ],
          ),
          const SizedBox(height: 22),
          const Text(
            'Dossiers prioritaires',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          if (pending.isEmpty)
            const Text(
              'Aucun dossier à traiter.',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ...pending.map(
            (c) => Padding(
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

  Widget _metric(String t, String v, Color c) => Expanded(
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Text(
              v,
              style: TextStyle(
                fontSize: 28,
                color: c,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(t, textAlign: TextAlign.center),
          ],
        ),
      ),
    ),
  );
}
