import 'package:flutter/material.dart';

import 'package:mon_constat_digital/core/theme/app_theme.dart';
import 'package:mon_constat_digital/l10n/l10n.dart';
import 'package:mon_constat_digital/modules/users/models/app_user.dart';

/// Texte des boutons de la console : plus discret que sur téléphone.
const consoleButtonText = TextStyle(fontSize: 14, fontWeight: FontWeight.w700);

/// En-tête d'une page de la console : titre, sous-titre et actions.
class ConsoleHeader extends StatelessWidget {
  const ConsoleHeader({
    required this.title,
    this.subtitle,
    this.actions = const [],
    super.key,
  });

  final String title;
  final String? subtitle;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: AppFonts.display,
                  fontWeight: FontWeight.w800,
                  fontSize: 28,
                  letterSpacing: -0.6,
                  color: context.palette.text,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: TextStyle(color: context.palette.textMuted),
                ),
              ],
            ],
          ),
        ),
        for (final action in actions) ...[const SizedBox(width: 10), action],
      ],
    ),
  );
}

/// Carte de la console : bordure fine, titre en petites capitales.
class ConsoleCard extends StatelessWidget {
  const ConsoleCard({
    required this.child,
    this.title,
    this.trailing,
    this.padding = const EdgeInsets.all(20),
    this.expand = false,
    super.key,
  });

  final String? title;
  final Widget? trailing;
  final EdgeInsets padding;
  final Widget child;

  /// Le contenu prend toute la hauteur de la carte (panneaux côte à côte).
  /// À laisser à `false` dans une liste qui défile.
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: p.borderSoft),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null)
            Padding(
              padding: EdgeInsets.fromLTRB(padding.left, 16, padding.right, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title!.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                        color: p.textMuted,
                      ),
                    ),
                  ),
                  ?trailing,
                ],
              ),
            ),
          if (expand)
            Expanded(
              child: Padding(padding: padding, child: child),
            )
          else
            Padding(padding: padding, child: child),
        ],
      ),
    );
  }
}

/// Pastille d'état (rôle, identité, statut du compte).
class StatusChip extends StatelessWidget {
  const StatusChip({
    required this.label,
    required this.background,
    required this.foreground,
    this.icon,
    super.key,
  });

  final String label;
  final Color background, foreground;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(AppRadius.pill),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 13, color: foreground),
          const SizedBox(width: 5),
        ],
        Text(
          label,
          style: TextStyle(
            color: foreground,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    ),
  );
}

StatusChip identityChip(BuildContext context, IdentityStatus status) {
  final t = context.t;
  final p = context.palette;
  return switch (status) {
    IdentityStatus.verified => StatusChip(
      label: t.identityStatusVerified,
      background: p.successBg,
      foreground: p.successText,
      icon: Icons.verified_user_outlined,
    ),
    IdentityStatus.pending => StatusChip(
      label: t.identityStatusPending,
      background: p.warningBg,
      foreground: p.warningText,
      icon: Icons.hourglass_top_rounded,
    ),
    IdentityStatus.rejected => StatusChip(
      label: t.identityStatusRejected,
      background: p.errorBg,
      foreground: p.errorText,
      icon: Icons.gpp_bad_outlined,
    ),
    IdentityStatus.unverified => StatusChip(
      label: t.identityStatusUnverified,
      background: p.surfaceAlt,
      foreground: p.textMuted,
    ),
  };
}

StatusChip roleChip(BuildContext context, UserRole role) {
  final p = context.palette;
  final (bg, fg) = switch (role) {
    UserRole.admin => (p.hero, Colors.white),
    UserRole.agent => (p.warningBg, p.warningText),
    UserRole.driver => (p.primaryTint, p.primaryText),
  };
  return StatusChip(
    label: role.labelIn(context.t),
    background: bg,
    foreground: fg,
  );
}

/// Initiale sur fond teinté, pour les listes.
class InitialAvatar extends StatelessWidget {
  const InitialAvatar(this.name, {this.size = 38, super.key});
  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: p.primaryTint,
        borderRadius: BorderRadius.circular(size / 3.2),
      ),
      child: Text(
        name.isEmpty ? '?' : name.characters.first.toUpperCase(),
        style: TextStyle(
          fontFamily: AppFonts.display,
          fontWeight: FontWeight.w800,
          fontSize: size * 0.42,
          color: p.primaryText,
        ),
      ),
    );
  }
}

/// État vide centré, avec une icône.
class ConsoleEmpty extends StatelessWidget {
  const ConsoleEmpty({required this.icon, required this.text, super.key});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 44, color: context.palette.textMuted),
          const SizedBox(height: 12),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(color: context.palette.textMuted),
          ),
        ],
      ),
    ),
  );
}
