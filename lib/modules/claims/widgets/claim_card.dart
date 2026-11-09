import 'package:flutter/material.dart';

import 'package:mon_constat_digital/core/theme/app_palette.dart';

import 'package:mon_constat_digital/modules/claims/models/claim.dart';
import 'package:mon_constat_digital/modules/claims/models/claim_insight.dart';
import 'package:mon_constat_digital/modules/claims/widgets/claim_status_chip.dart';
import 'package:mon_constat_digital/modules/claims/widgets/motion.dart';
import 'package:mon_constat_digital/l10n/l10n.dart';
import 'package:mon_constat_digital/modules/claims/l10n/claims_text.dart';

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
          Text(
            '${context.t.claimValue(claim.type)} • '
            '${context.t.claimValue(claim.severity)}',
          ),
          const SizedBox(height: 4),
          Text(claim.place, style: TextStyle(color: context.palette.textMuted)),
          Text(
            claim.date,
            style: TextStyle(
              color: context.palette.textMuted,
              fontFamily: 'JetBrainsMono',
              fontSize: 12,
            ),
          ),
          if (insight case final insight? when insight.isForAgent) ...[
            const SizedBox(height: 10),
            _PriorityBar(insight.priority),
            if (insight.reasons.isNotEmpty || claim.companyId == null) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final reason in insight.reasons) _ReasonChip(reason),
                  // Visible de tous les agents tant que l'assureur manque.
                  if (claim.companyId == null)
                    _ReasonChip(
                      context.t.claimsNoCompany,
                      color: ClaimsColors.sky,
                      icon: Icons.domain_disabled_outlined,
                    ),
                ],
              ),
            ],
            if (insight.nextAction != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.arrow_circle_right,
                    size: 18,
                    color: ClaimsColors.indigo,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      insight.nextAction!,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ],
      ),
    ),
  );
}

/// Score de priorité de 0 à 100 : vert, ambre, puis corail.
class _PriorityBar extends StatelessWidget {
  const _PriorityBar(this.score);
  final int score;

  @override
  Widget build(BuildContext context) {
    final color = score >= 60
        ? ClaimsColors.coral
        : score >= 30
        ? ClaimsColors.amber
        : ClaimsColors.teal;
    return Row(
      children: [
        Text(
          context.t.claimsPriorityScore('$score'),
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GrowingBar(value: score / 100, color: color, height: 8),
        ),
      ],
    );
  }
}

class _ReasonChip extends StatelessWidget {
  const _ReasonChip(
    this.text, {
    this.color = ClaimsColors.coral,
    this.icon = Icons.flag,
  });
  final String text;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .15),
      borderRadius: BorderRadius.circular(99),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}
