import 'package:flutter/material.dart';

import 'package:mon_constat_digital/core/theme/app_palette.dart';

import 'package:mon_constat_digital/modules/claims/models/claim.dart';
import 'package:mon_constat_digital/modules/claims/models/claim_insight.dart';
import 'package:mon_constat_digital/modules/claims/widgets/claim_status_chip.dart';
import 'package:mon_constat_digital/modules/claims/widgets/motion.dart';
import 'package:mon_constat_digital/l10n/l10n.dart';
import 'package:mon_constat_digital/modules/claims/l10n/claims_text.dart';

const _mono = 'JetBrainsMono';

class ClaimCard extends StatelessWidget {
  const ClaimCard(this.claim, {this.insight, super.key});
  final Claim claim;

  /// Affiche ce qui rend le dossier prioritaire, pour l'agent.
  final ClaimInsight? insight;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final meta = TextStyle(color: p.textMuted, fontSize: 13);
    return InkPanel(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  claim.id,
                  style: TextStyle(
                    fontFamily: _mono,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: p.textMuted,
                  ),
                ),
              ),
              ClaimStatusChip(claim.status),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${context.t.claimValue(claim.type)} • '
            '${context.t.claimValue(claim.severity)}',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: p.text,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Flexible(
                child: Text(
                  claim.place,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: meta,
                ),
              ),
              Text('  ·  ', style: meta),
              Text(
                claim.date,
                style: meta.copyWith(
                  fontFamily: _mono,
                  fontSize: 12,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          if (insight case final insight? when insight.isForAgent) ...[
            const SizedBox(height: 12),
            _PriorityBar(insight.priority),
            if (insight.reasons.isNotEmpty || claim.companyId == null) ...[
              const SizedBox(height: 8),
              // Une seule ligne qui défile : la carte garde sa hauteur.
              XStrip(
                gap: 6,
                children: [
                  for (final reason in insight.reasons)
                    QuietTag(reason, color: p.text, dot: ClaimsColors.critical),
                  // Visible de tous les agents tant que l'assureur manque.
                  if (claim.companyId == null)
                    QuietTag(
                      context.t.claimsNoCompany,
                      color: p.text,
                      dot: ClaimsColors.info,
                    ),
                ],
              ),
            ],
            if (insight.nextAction != null) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.arrow_forward, size: 16, color: p.primaryText),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      insight.nextAction!,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: p.primaryText,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }
}

/// Score de priorité de 0 à 100, coloré par seuils comme une jauge Grafana.
class _PriorityBar extends StatelessWidget {
  const _PriorityBar(this.score);
  final int score;

  @override
  Widget build(BuildContext context) {
    final color = ClaimsColors.threshold(score);
    return Row(
      children: [
        Text(
          context.t.claimsPriorityScore('$score'),
          style: TextStyle(
            color: context.palette.textMuted,
            fontFamily: _mono,
            fontSize: 12,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GrowingBar(
            value: score / 100,
            color: color,
            height: 4,
            track: context.palette.surfaceAlt,
          ),
        ),
      ],
    );
  }
}
