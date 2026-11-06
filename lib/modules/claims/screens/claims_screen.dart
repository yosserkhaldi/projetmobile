import 'package:flutter/material.dart';

import 'package:mon_constat_digital/core/state/app_scope.dart';
import 'package:mon_constat_digital/modules/claims/screens/claim_detail_screen.dart';
import 'package:mon_constat_digital/modules/claims/widgets/claim_card.dart';
import 'package:mon_constat_digital/shared/navigation.dart';
import 'package:mon_constat_digital/shared/widgets/page_head.dart';

class ClaimsScreen extends StatelessWidget {
  const ClaimsScreen({this.agentMode = false, super.key});
  final bool agentMode;
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context).claims;
    return SafeArea(
      child: Column(
        children: [
          PageHead(
            agentMode ? 'Sinistres reçus' : 'Mes dossiers',
            subtitle: 'Suivi en temps réel',
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Filtrer par numéro, statut ou gravité',
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: s.claims.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (_, i) => InkWell(
                onTap: () => open(
                  context,
                  ClaimDetail(s.claims[i], agentMode: agentMode),
                ),
                child: ClaimCard(s.claims[i]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
