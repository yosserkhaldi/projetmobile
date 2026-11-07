import 'package:flutter/material.dart';

import 'package:mon_constat_digital/core/theme/app_palette.dart';

import 'package:mon_constat_digital/core/theme/app_colors.dart';
import 'package:mon_constat_digital/modules/claims/models/claim.dart';
import 'package:mon_constat_digital/modules/claims/models/claim_status.dart';
import 'package:mon_constat_digital/modules/claims/widgets/format.dart';

/// Chronologie du dossier. Style des points : DESIGN.md, section 6.
class ClaimTimeline extends StatelessWidget {
  const ClaimTimeline(this.claim, {super.key});
  final Claim claim;

  @override
  Widget build(BuildContext context) {
    final last = claim.timeline.length - 1;
    final finished = ClaimStatus.isFinal(claim.status);
    return Column(
      children: [
        for (final (index, label) in claim.timeline.indexed)
          _Step(
            label: label,
            date: claim.timelineDates[index],
            current: index == last && !finished,
            showConnector: index != last,
          ),
      ],
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
                    fontWeight: current ? FontWeight.w800 : FontWeight.w600,
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
