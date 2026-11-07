import 'package:flutter/material.dart';

import 'package:mon_constat_digital/core/theme/app_colors.dart';
import 'package:mon_constat_digital/modules/claims/models/claim.dart';
import 'package:mon_constat_digital/modules/claims/models/claim_insight.dart';
import 'package:mon_constat_digital/modules/claims/widgets/claim_status_chip.dart';

class ClaimCard extends StatelessWidget {
  const ClaimCard(this.claim, {this.insight, super.key});
  final Claim claim;

  /// Affiche ce qui rend le dossier prioritaire, pour l'agent.
  final ClaimInsight? insight;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  claim.id,
                  style: const TextStyle(
                    fontFamily: 'JetBrainsMono',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              ClaimStatusChip(claim.status),
            ],
          ),
          const SizedBox(height: 6),
          Text('${claim.type} • ${claim.severity}'),
          const SizedBox(height: 4),
          Text(claim.place, style: const TextStyle(color: AppColors.textMuted)),
          Text(
            claim.date,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontFamily: 'JetBrainsMono',
              fontSize: 12,
            ),
          ),
          if (insight?.reasons.isNotEmpty ?? false) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(
                  Icons.priority_high,
                  size: 16,
                  color: AppColors.warningText,
                ),
                Expanded(
                  child: Text(
                    insight!.reasons.join(' • '),
                    style: const TextStyle(
                      color: AppColors.warningText,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    ),
  );
}
