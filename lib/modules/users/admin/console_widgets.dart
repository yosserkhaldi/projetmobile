import 'package:flutter/material.dart';

import 'package:intl/intl.dart' show DateFormat;

import 'package:mon_constat_digital/core/state/app_scope.dart';
import 'package:mon_constat_digital/core/theme/app_theme.dart';
import 'package:mon_constat_digital/l10n/l10n.dart';
import 'package:mon_constat_digital/modules/users/models/app_user.dart';
import 'package:mon_constat_digital/modules/users/models/identity_attempt.dart';
import 'package:mon_constat_digital/modules/users/models/license_reading.dart';
import 'package:mon_constat_digital/modules/users/widgets/form_widgets.dart';

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
        // Coupé par « … » plutôt que de déborder sur un petit écran.
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: foreground,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
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

/// Contrôles de l'IA sur une demande, pour voir d'un coup d'œil pourquoi elle
/// attend un administrateur.
class IdentityChecklist extends StatelessWidget {
  const IdentityChecklist({required this.identity, super.key});
  final Identity identity;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final p = context.palette;
    final checks = identity.checks;
    final match = identity.faceMatch;
    final number = checks?.numberRead;
    final items = <(String, bool?)>[
      (t.checkLiveness, identity.livenessAt != null ? true : null),
      (t.checkFace, match == null ? null : match >= 0.6),
      (
        number == null ? t.checkNumberUnread : t.checkNumber(number),
        checks?.numberMatches,
      ),
      if (identity.documentType.hasBack) (t.checkBack, checks?.backRecognized),
      if (checks?.nameMatches != null) (t.checkName, checks!.nameMatches),
      if (checks?.notExpired != null) (t.checkExpiry, checks!.notExpired),
      if (checks?.birthDateMatches != null)
        (t.checkBirthDate, checks!.birthDateMatches),
    ];
    return Column(
      key: const Key('identity-checklist'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.checksTitle.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
            color: p.textMuted,
          ),
        ),
        for (final (label, ok) in items)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Row(
              children: [
                Icon(
                  switch (ok) {
                    true => Icons.check_circle,
                    false => Icons.cancel,
                    null => Icons.help_outline,
                  },
                  size: 18,
                  color: switch (ok) {
                    true => p.successText,
                    false => p.errorText,
                    null => p.textMuted,
                  },
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(label)),
              ],
            ),
          ),
      ],
    );
  }
}

/// État du permis : validé, à vérifier, refusé. null : aucun permis contrôlé.
StatusChip? licenseChip(BuildContext context, LicenseStatus? status) {
  final t = context.t;
  final p = context.palette;
  return switch (status) {
    LicenseStatus.verified => StatusChip(
      label: t.licenseStatusVerified,
      background: p.successBg,
      foreground: p.successText,
      icon: Icons.verified_outlined,
    ),
    LicenseStatus.toReview => StatusChip(
      label: t.licenseStatusToReview,
      background: p.warningBg,
      foreground: p.warningText,
      icon: Icons.report_problem_outlined,
    ),
    LicenseStatus.rejected => StatusChip(
      label: t.licenseStatusRejected,
      background: p.errorBg,
      foreground: p.errorText,
      icon: Icons.block,
    ),
    null => null,
  };
}

/// Contrôles croisés du permis avec le compte : ce qui a fait douter l'IA.
class LicenseChecklist extends StatelessWidget {
  const LicenseChecklist({required this.reading, super.key});
  final LicenseReading reading;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final p = context.palette;
    final items = <(String, bool?)>[
      (t.checkLicenseName, reading.nameMatchesAccount),
      (t.checkLicenseBirth, reading.birthDateMatchesIdentity),
      (t.checkLicenseCin, reading.cinMatchesIdentity),
      if (reading.numberMatchesReading != null)
        (t.checkLicenseNumber, reading.numberMatchesReading),
    ];
    return Column(
      key: const Key('license-checklist'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.aiChecksTitle.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
            color: p.textMuted,
          ),
        ),
        for (final (label, ok) in items)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Row(
              children: [
                Icon(
                  switch (ok) {
                    true => Icons.check_circle,
                    false => Icons.cancel,
                    null => Icons.help_outline,
                  },
                  size: 18,
                  color: switch (ok) {
                    true => p.successText,
                    false => p.errorText,
                    null => p.textMuted,
                  },
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    ok == null ? '$label · ${t.checkNotCompared}' : label,
                    style: TextStyle(color: ok == null ? p.textMuted : null),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Verdict de l'IA sur une demande : ressemblance pièce / visage.
StatusChip aiMatchChip(BuildContext context, Identity identity) {
  final t = context.t;
  final p = context.palette;
  final match = identity.faceMatch;
  if (match == null) {
    return StatusChip(
      label: t.aiNoConclusion,
      background: p.surfaceAlt,
      foreground: p.textMuted,
      icon: Icons.psychology_alt_outlined,
    );
  }
  final (bg, fg) = match >= 0.6
      ? (p.successBg, p.successText)
      : match >= 0.35
      ? (p.warningBg, p.warningText)
      : (p.errorBg, p.errorText);
  return StatusChip(
    label: t.aiMatch((match * 100).round()),
    background: bg,
    foreground: fg,
    icon: Icons.face_retouching_natural,
  );
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

/// Bouton « Demandes de ce compte » : ouvre l'historique des demandes
/// d'identité, pour repérer quelqu'un qui essaie plusieurs pièces.
class AttemptHistoryButton extends StatelessWidget {
  const AttemptHistoryButton({required this.user, super.key});
  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: TextButton.icon(
        key: const Key('attempt-history'),
        onPressed: () => showDialog<void>(
          context: context,
          builder: (_) => _AttemptHistoryDialog(user: user),
        ),
        icon: const Icon(Icons.history, size: 18),
        label: Text(
          user.identity.refusals > 0
              ? '${t.attemptsTitle} · ${t.refusalsCount(user.identity.refusals)}'
              : t.attemptsTitle,
        ),
      ),
    );
  }
}

class _AttemptHistoryDialog extends StatelessWidget {
  const _AttemptHistoryDialog({required this.user});
  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final p = context.palette;
    final admin = AppScope.of(context).admin;
    String outcome(AttemptOutcome o) => switch (o) {
      AttemptOutcome.autoVerified => t.outcomeAuto,
      AttemptOutcome.verified => t.outcomeVerified,
      AttemptOutcome.rejected => t.outcomeRejected,
      AttemptOutcome.pending => t.outcomePending,
    };
    return AlertDialog(
      title: Text('${t.attemptsTitle} · ${user.name}'),
      content: SizedBox(
        width: 480,
        child: FutureBuilder<List<IdentityAttempt>>(
          future: admin.identityAttempts(user),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text(errorMessage(context, snapshot.error!));
            }
            final items = snapshot.data;
            if (items == null) {
              return const SizedBox(
                height: 80,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            return ListView(
              shrinkWrap: true,
              children: [
                for (final a in items)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      switch (a.outcome) {
                        AttemptOutcome.rejected => Icons.cancel,
                        AttemptOutcome.pending => Icons.hourglass_top,
                        _ => Icons.check_circle,
                      },
                      color: switch (a.outcome) {
                        AttemptOutcome.rejected => p.errorText,
                        AttemptOutcome.pending => p.warningText,
                        _ => p.successText,
                      },
                    ),
                    title: Text(
                      '${outcome(a.outcome)} · ${a.documentType} ${a.number}',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      [
                        DateFormat.yMMMd(
                          t.localeName,
                        ).add_Hm().format(a.createdAt),
                        if (a.faceMatch != null)
                          t.aiMatch((a.faceMatch! * 100).round()),
                        ?a.reason,
                      ].join(' · '),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(MaterialLocalizations.of(context).closeButtonLabel),
        ),
      ],
    );
  }
}
