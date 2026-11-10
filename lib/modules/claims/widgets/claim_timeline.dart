import 'package:flutter/material.dart';

import 'package:mon_constat_digital/core/theme/app_palette.dart';

import 'package:mon_constat_digital/core/theme/app_colors.dart';
import 'package:mon_constat_digital/modules/claims/models/claim.dart';
import 'package:mon_constat_digital/modules/claims/models/claim_status.dart';
import 'package:mon_constat_digital/modules/claims/widgets/format.dart';
import 'package:mon_constat_digital/l10n/l10n.dart';
import 'package:mon_constat_digital/modules/claims/l10n/claims_text.dart';

/// Chronologie du dossier. Style des points : DESIGN.md, section 6.
///
/// Au-delà de [visible] étapes, seules les dernières restent affichées ; trois
/// points en haut déplient les précédentes.
class ClaimTimeline extends StatefulWidget {
  const ClaimTimeline(this.claim, {this.visible = 4, super.key});
  final Claim claim;
  final int visible;

  @override
  State<ClaimTimeline> createState() => _ClaimTimelineState();
}

class _ClaimTimelineState extends State<ClaimTimeline> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    final claim = widget.claim;
    final last = claim.timeline.length - 1;
    final finished = ClaimStatus.isFinal(claim.status);
    final hidden = expanded
        ? 0
        : (claim.timeline.length - widget.visible).clamp(0, last + 1);
    return AnimatedSize(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: Column(
        children: [
          if (hidden > 0) _More(hidden, () => setState(() => expanded = true)),
          for (final (index, label) in claim.timeline.indexed)
            if (index >= hidden)
              _Step(
                label: context.t.claimEvent(label),
                date: claim.timelineDates[index],
                current: index == last && !finished,
                showConnector: index != last,
              ),
        ],
      ),
    );
  }
}

/// Trois points à la place des étapes repliées, reliés à la suite.
class _More extends StatelessWidget {
  const _More(this.count, this.onTap);
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Semantics(
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Column(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: p.surface,
                      border: Border.all(color: p.border),
                    ),
                    child: Icon(Icons.more_horiz, size: 16, color: p.textMuted),
                  ),
                  Expanded(
                    child: Container(width: 2, color: AppColors.primary),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 2, bottom: 16),
                  child: Text(
                    context.t.claimsTimelineEarlier(count),
                    style: TextStyle(
                      color: p.primaryText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({
    required this.label,
    required this.date,
    required this.current,
    required this.showConnector,
  });
  final String label;
  final DateTime? date;
  final bool current, showConnector;

  @override
  Widget build(BuildContext context) => IntrinsicHeight(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Column(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: current ? AppColors.accent : AppColors.primary,
                border: current
                    ? Border.all(color: const Color(0xFFFFE3A8), width: 4)
                    : null,
              ),
              child: current
                  ? null
                  : const Icon(Icons.check, size: 14, color: Colors.white),
            ),
            if (showConnector)
              Expanded(child: Container(width: 2, color: AppColors.primary)),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: current ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
                if (date != null)
                  Text(
                    formatDateTime(date!),
                    style: TextStyle(
                      color: context.palette.textMuted,
                      fontFamily: 'JetBrainsMono',
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
