import 'package:flutter/material.dart';

import 'package:mon_constat_digital/core/theme/app_colors.dart';

class SignatureBox extends StatelessWidget {
  const SignatureBox(
    this.label, {
    required this.signed,
    required this.onTap,
    super.key,
  });
  final String label;
  final bool signed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 130,
        width: double.infinity,
        decoration: BoxDecoration(
          color: signed ? AppColors.primaryTint : AppColors.surface,
          border: Border.all(
            color: signed ? AppColors.primary : AppColors.border,
            width: signed ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              signed ? Icons.check_circle : Icons.draw_outlined,
              color: AppColors.primary,
              size: 30,
            ),
            const SizedBox(height: 7),
            Text(
              signed
                  ? '$label\nSignature enregistrée'
                  : '$label\nTouchez pour signer',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    ),
  );
}
