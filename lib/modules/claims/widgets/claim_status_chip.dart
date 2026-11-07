import 'package:flutter/material.dart';

import 'package:mon_constat_digital/core/theme/app_palette.dart';

import 'package:mon_constat_digital/modules/claims/models/claim_status.dart';

/// Pastille de statut. Couleurs : DESIGN.md, section 7.
class ClaimStatusChip extends StatelessWidget {
  const ClaimStatusChip(this.status, {super.key});
  final String status;

  @override
  Widget build(BuildContext context) {
    final (background, text) = switch (status) {
      ClaimStatus.draft => (
        context.palette.surfaceAlt,
        context.palette.textMuted,
      ),
      ClaimStatus.signed || ClaimStatus.closed => (
        context.palette.successBg,
        context.palette.successText,
      ),
      ClaimStatus.documentRequested => (
        context.palette.warningBg,
        context.palette.warningText,
      ),
      ClaimStatus.expertise => (
        context.palette.primaryTint,
        context.palette.primaryText,
      ),
      ClaimStatus.rejected => (
        context.palette.errorBg,
        context.palette.errorText,
      ),
      _ => (context.palette.primaryTint, context.palette.primaryText),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: text,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
