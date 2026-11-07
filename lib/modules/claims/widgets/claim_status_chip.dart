import 'package:flutter/material.dart';

import 'package:mon_constat_digital/core/theme/app_colors.dart';
import 'package:mon_constat_digital/modules/claims/models/claim_status.dart';

/// Pastille de statut. Couleurs : DESIGN.md, section 7.
class ClaimStatusChip extends StatelessWidget {
  const ClaimStatusChip(this.status, {super.key});
  final String status;

  @override
  Widget build(BuildContext context) {
    final (background, text) = switch (status) {
      ClaimStatus.draft => (AppColors.surfaceAlt, AppColors.textMuted),
      ClaimStatus.signed ||
      ClaimStatus.closed => (AppColors.successBg, AppColors.successText),
      ClaimStatus.documentRequested => (
        AppColors.warningBg,
        AppColors.warningText,
      ),
      ClaimStatus.expertise => (AppColors.primaryTint, AppColors.primaryDark),
      ClaimStatus.rejected => (AppColors.errorBg, AppColors.errorText),
      _ => (AppColors.primaryTint, AppColors.primary),
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
