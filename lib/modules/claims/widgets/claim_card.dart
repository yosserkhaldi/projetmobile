import 'package:flutter/material.dart';

import 'package:mon_constat_digital/core/theme/app_palette.dart';
import 'package:mon_constat_digital/modules/claims/models/claim.dart';

class ClaimCard extends StatelessWidget {
  const ClaimCard(this.claim, {super.key});
  final Claim claim;
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
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              Chip(label: Text(claim.status)),
            ],
          ),
          Text('${claim.type} • ${claim.severity}'),
          const SizedBox(height: 4),
          Text(claim.place, style: TextStyle(color: context.palette.textMuted)),
          Text(claim.date, style: TextStyle(color: context.palette.textMuted)),
        ],
      ),
    ),
  );
}
