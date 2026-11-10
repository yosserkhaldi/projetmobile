import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Couleurs par rôle, en version claire et sombre. Voir DESIGN.md, section 3.
///
/// Dans les écrans : `context.palette.surface`, jamais une couleur fixe, pour
/// que le mode sombre fonctionne. Les couleurs qui ne changent pas (ambre,
/// conducteurs A et B) restent dans [AppColors].
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.canvas,
    required this.surface,
    required this.surfaceAlt,
    required this.text,
    required this.textMuted,
    required this.border,
    required this.borderSoft,
    required this.primary,
    required this.primaryText,
    required this.primaryTint,
    required this.hero,
    required this.heroRing,
    required this.heroTrack,
    required this.licenseCard,
    required this.licenseChip,
    required this.warningBg,
    required this.warningText,
    required this.successBg,
    required this.successText,
    required this.errorBg,
    required this.errorText,
  });

  /// Fond de l'écran.
  final Color canvas;

  /// Cartes, champs, barre de navigation.
  final Color surface;

  /// Étiquettes, pistes de progression, séparateurs internes.
  final Color surfaceAlt;
  final Color text, textMuted, border, borderSoft;

  /// Remplissage des boutons principaux.
  final Color primary;

  /// Liens, icônes et texte d'action sur [surface].
  final Color primaryText;
  final Color primaryTint;

  /// Blocs foncés (en-tête du profil, carte « Un accident ? »).
  final Color hero, heroRing, heroTrack;
  final Color licenseCard, licenseChip;
  final Color warningBg, warningText, successBg, successText;
  final Color errorBg, errorText;

  static const light = AppPalette(
    canvas: AppColors.canvas,
    surface: AppColors.surface,
    surfaceAlt: AppColors.surfaceAlt,
    text: AppColors.ink,
    textMuted: AppColors.textMuted,
    border: AppColors.border,
    borderSoft: AppColors.borderSoft,
    primary: AppColors.primary,
    primaryText: AppColors.primary,
    primaryTint: AppColors.primaryTint,
    hero: AppColors.ink,
    heroRing: AppColors.navy800,
    heroTrack: AppColors.navy700,
    licenseCard: AppColors.primary,
    licenseChip: AppColors.primaryRaised,
    warningBg: AppColors.warningBg,
    warningText: AppColors.warningText,
    successBg: AppColors.successBg,
    successText: AppColors.successText,
    errorBg: AppColors.errorBg,
    errorText: AppColors.errorText,
  );

  /// Bleu nuit plus profond que l'encre, pour que les blocs foncés se
  /// détachent encore. Contrastes vérifiés (WCAG AA) dans DESIGN.md.
  static const dark = AppPalette(
    canvas: Color(0xFF0A111C),
    surface: Color(0xFF131D2C),
    surfaceAlt: Color(0xFF1A2638),
    text: Color(0xFFE8EDF5),
    textMuted: Color(0xFF9AA8BD),
    border: Color(0xFF2A3850),
    borderSoft: Color(0xFF223047),
    primary: Color(0xFF3358D4),
    primaryText: Color(0xFF8FA8FF),
    primaryTint: Color(0xFF1B2B57),
    hero: AppColors.navy800,
    heroRing: AppColors.navy700,
    heroTrack: Color(0xFF2A3A55),
    licenseCard: AppColors.primaryRaised,
    licenseChip: Color(0xFF3A5CD0),
    warningBg: Color(0xFF3A2A0A),
    warningText: Color(0xFFFFC766),
    successBg: Color(0xFF0F3B33),
    successText: Color(0xFF7FE0CC),
    errorBg: Color(0xFF3D1714),
    errorText: Color(0xFFFF9A8C),
  );

  @override
  AppPalette copyWith() => this;

  @override
  AppPalette lerp(AppPalette? other, double t) {
    if (other == null) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppPalette(
      canvas: mix(canvas, other.canvas),
      surface: mix(surface, other.surface),
      surfaceAlt: mix(surfaceAlt, other.surfaceAlt),
      text: mix(text, other.text),
      textMuted: mix(textMuted, other.textMuted),
      border: mix(border, other.border),
      borderSoft: mix(borderSoft, other.borderSoft),
      primary: mix(primary, other.primary),
      primaryText: mix(primaryText, other.primaryText),
      primaryTint: mix(primaryTint, other.primaryTint),
      hero: mix(hero, other.hero),
      heroRing: mix(heroRing, other.heroRing),
      heroTrack: mix(heroTrack, other.heroTrack),
      licenseCard: mix(licenseCard, other.licenseCard),
      licenseChip: mix(licenseChip, other.licenseChip),
      warningBg: mix(warningBg, other.warningBg),
      warningText: mix(warningText, other.warningText),
      successBg: mix(successBg, other.successBg),
      successText: mix(successText, other.successText),
      errorBg: mix(errorBg, other.errorBg),
      errorText: mix(errorText, other.errorText),
    );
  }
}

extension PaletteContext on BuildContext {
  /// Palette du thème de l'application ; hors de ce thème (widget testé
  /// seul, par exemple), la palette claire ou sombre par défaut.
  AppPalette get palette {
    final theme = Theme.of(this);
    return theme.extension<AppPalette>() ??
        (theme.brightness == Brightness.dark ? AppPalette.dark : AppPalette.light);
  }
}
