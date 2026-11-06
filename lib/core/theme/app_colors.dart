import 'package:flutter/material.dart';

/// Palette de la charte graphique. Voir DESIGN.md, section 3.
abstract final class AppColors {
  static const ink = Color(0xFF0B1626);
  static const primary = Color(0xFF1537A8);
  static const primaryDark = Color(0xFF0E2878);
  static const primaryRaised = Color(0xFF2448BD);
  static const primaryTint = Color(0xFFE7ECFB);
  static const accent = Color(0xFFF5A524);
  static const accentDark = Color(0xFFC98200);
  static const canvas = Color(0xFFF2F4F7);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceAlt = Color(0xFFEEF1F5);
  static const textMuted = Color(0xFF4A5568);
  static const border = Color(0xFFDCE1E8);
  static const borderSoft = Color(0xFFE4E8EE);

  static const navy800 = Color(0xFF16243A);
  static const navy700 = Color(0xFF1E2D45);
  static const onDarkStrong = Color(0xFFC9D3E3);
  static const onDarkBody = Color(0xFFB5C0D3);
  static const onDarkFaint = Color(0xFF9AA8BD);
  static const onPrimaryMuted = Color(0xFFC9D6FA);

  static const warningBg = Color(0xFFFFF1D6);
  static const warningText = Color(0xFF7A4300);
  static const successBg = Color(0xFFE4F4F0);
  static const successText = Color(0xFF0F6B5E);
  static const errorBg = Color(0xFFFDECEA);
  static const errorText = Color(0xFFA3261A);
  static const errorSolid = Color(0xFFC2331D);

  /// Le conducteur A est toujours bleu, le conducteur B toujours ambre.
  static const driverA = primary;
  static const driverB = accent;
}
