import 'package:flutter/material.dart';

import 'package:mon_constat_digital/core/state/app_scope.dart';
import 'package:mon_constat_digital/core/theme/app_colors.dart';
import 'package:mon_constat_digital/modules/claims/screens/claim_detail_screen.dart';
import 'package:mon_constat_digital/modules/claims/widgets/claim_card.dart';
import 'package:mon_constat_digital/shared/navigation.dart';
import 'package:mon_constat_digital/shared/widgets/page_head.dart';

class AgentDashboard extends StatelessWidget {
  const AgentDashboard({super.key});
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context).claims;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const PageHead("Espace agent", subtitle: 'Instruction des sinistres'),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _metric('À traiter', '${s.claims.length}', AppColors.warningText),
              _metric('En expertise', '3', AppColors.primary),
              _metric('Clôturés', '18', AppColors.successText),
            ],
          ),
          const SizedBox(height: 22),
          const Text(
            'Dossiers prioritaires',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          ...s.claims.map(
            (c) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                onTap: () => open(context, ClaimDetail(c, agentMode: true)),
                child: ClaimCard(c),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metric(String t, String v, Color c) => SizedBox(
    width: 110,
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
