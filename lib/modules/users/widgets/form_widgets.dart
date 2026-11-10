import 'package:flutter/material.dart';

import 'package:mon_constat_digital/core/network/api_client.dart';
import 'package:mon_constat_digital/core/theme/app_colors.dart';
import 'package:mon_constat_digital/core/theme/app_theme.dart';
import 'package:mon_constat_digital/l10n/l10n.dart';
import 'package:mon_constat_digital/modules/users/data/biometric_auth.dart';

/// Règles des champs, avec les messages dans la langue de l'application.
class Validators {
  const Validators(this.t);
  final AppLocalizations t;

  String? required(String? value) =>
      (value ?? '').trim().isEmpty ? t.requiredField : null;

  String? email(String? value) =>
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch((value ?? '').trim())
      ? null
      : t.invalidEmail;

  String? phone(String? value) =>
      RegExp(
        r'^\+?\d{8,15}$',
      ).hasMatch((value ?? '').replaceAll(RegExp(r'[\s.-]'), ''))
      ? null
      : t.invalidPhone;

  String? password(String? value) =>
      (value ?? '').length < 8 ? t.passwordTooShort : null;

  String? code(String? value) =>
      RegExp(r'^\d{6}$').hasMatch((value ?? '').trim()) ? null : t.codeFormat;
}

/// Message à afficher pour une erreur.
///
/// En français, le message de l'API est le plus précis. Dans les autres
/// langues, le code d'erreur est traduit ici.
String errorMessage(BuildContext context, Object error) {
  final t = context.t;
  if (error is BiometricException) return t.errorBiometricUnavailable;
  if (error is! ApiException) return t.errorGeneric;
  if (error.isNetwork) return t.errorNetwork;
  if (t.localeName == 'fr') return error.message;
  return switch (error.code) {
    'INVALID_CREDENTIALS' => t.errorInvalidCredentials,
    'ACCOUNT_LOCKED' => t.errorAccountLocked,
    'ACCOUNT_SUSPENDED' => t.errorAccountSuspended,
    'ALREADY_EXISTS' => t.errorAlreadyExists,
    'INVALID_CODE' => t.errorInvalidCode,
    'CODE_COOLDOWN' => t.errorCodeCooldown,
    'SESSION_EXPIRED' || 'TOKEN_INVALID' => t.errorSessionExpired,
    'BIOMETRIC_INVALID' => t.errorBiometricInvalid,
    'FILE_TOO_LARGE' => t.errorFileTooLarge,
    'UNSUPPORTED_IMAGE' => t.errorUnsupportedImage,
    'COMPANY_IN_USE' => t.errorCompanyInUse,
    'SELF_CHANGE' => t.errorSelfChange,
    'VALIDATION_ERROR' => t.errorInvalidData,
    'IDENTITY_LOCKED' => t.errorIdentityLocked,
    'ADMIN_CANNOT_DELETE' => t.errorAdminCannotDelete,
    'IDENTITY_PHOTOS_REQUIRED' => t.identityPhotosRequired,
    'CIN_IN_USE' => t.errorCinInUse,
    'IDENTITY_NOT_VERIFIED' => t.errorIdentityNotVerified,
    'IDENTITY_NOT_PENDING' => t.errorIdentityNotPending,
    'NO_FACE_ON_DOCUMENT' => t.errorNoFaceOnDocument,
    'BACK_HAS_FACE' => t.errorBackHasFace,
    'WRONG_DOCUMENT' => t.errorWrongDocument,
    'NOT_A_LICENSE' => t.errorNotALicense,
    'BACK_NOT_RECOGNIZED' => t.errorBackNotRecognized,
    'IDENTITY_BLOCKED' => t.errorIdentityBlocked,
    'AI_QUOTA_EXCEEDED' => t.errorAiQuota,
    'IDENTITY_RETRY_LATER' => t.errorIdentityRetryLater,
    'LICENSE_PHOTO_MISSING' => t.errorLicensePhotoMissing,
    'SELFIE_REQUIRED' => t.faceCheckRequired,
    'LIVENESS_NO_FACE' => t.errorLivenessNoFace,
    'LIVENESS_MANY_FACES' => t.errorLivenessManyFaces,
    'LIVENESS_NOT_CENTERED' => t.errorLivenessNotCentered,
    'LIVENESS_NO_TURN' => t.errorLivenessNoTurn,
    'LIVENESS_DIFFERENT_FACES' => t.errorLivenessDifferentFaces,
    'LIVENESS_EXPIRED' => t.errorLivenessExpired,
    'FACE_ENGINE_UNAVAILABLE' => t.errorFaceEngine,
    _ => t.errorGeneric,
  };
}

/// Champ avec le libellé au-dessus, comme sur la maquette.
class LabeledField extends StatelessWidget {
  const LabeledField({
    required this.label,
    this.controller,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.readOnly = false,
    this.onTap,
    this.autofillHints,
    this.hint,
    this.style,
    this.textDirection,
    this.prefixIcon,
    this.prefixText,
    super.key,
  });

  final String label;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool obscureText, readOnly;
  final Widget? suffixIcon;
  final VoidCallback? onTap;
  final Iterable<String>? autofillHints;
  final String? hint;
  final TextStyle? style;

  /// Force le sens d'écriture (numéros, e-mails) quand l'interface est en arabe.
  final TextDirection? textDirection;

  /// Icône à gauche du champ, pour le reconnaître d'un coup d'œil.
  final IconData? prefixIcon;

  /// Texte fixe avant la saisie (indicatif « +216 »).
  final String? prefixText;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: context.palette.textMuted,
        ),
      ),
      const SizedBox(height: 6),
      TextFormField(
        key: ValueKey(label),
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        obscureText: obscureText,
        readOnly: readOnly,
        onTap: onTap,
        autofillHints: autofillHints,
        textDirection: textDirection,
        style:
            style ?? const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: hint,
          suffixIcon: suffixIcon,
          // Icône et indicatif toujours visibles, même champ vide.
          prefixIcon: prefixIcon == null && prefixText == null
              ? null
              : Padding(
                  padding: const EdgeInsetsDirectional.only(start: 12, end: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (prefixIcon != null)
                        Icon(
                          prefixIcon,
                          size: 20,
                          color: context.palette.textMuted,
                        ),
                      if (prefixText != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          prefixText!,
                          textDirection: TextDirection.ltr,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: context.palette.textMuted,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
        ),
      ),
    ],
  );
}

/// Champ de mot de passe avec le bouton afficher / masquer.
class PasswordField extends StatefulWidget {
  const PasswordField({
    required this.label,
    required this.controller,
    this.validator,
    this.autofillHints,
    this.suffix,
    super.key,
  });

  final String label;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final Iterable<String>? autofillHints;

  /// Affiché avant le bouton afficher / masquer (coche de confirmation).
  final Widget? suffix;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _hidden = true;

  @override
  Widget build(BuildContext context) => LabeledField(
    label: widget.label,
    controller: widget.controller,
    validator: widget.validator,
    obscureText: _hidden,
    autofillHints: widget.autofillHints,
    prefixIcon: Icons.lock_outline,
    suffixIcon: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ?widget.suffix,
        IconButton(
          tooltip: _hidden ? context.t.showPassword : context.t.hidePassword,
          onPressed: () => setState(() => _hidden = !_hidden),
          icon: Icon(
            _hidden ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          ),
        ),
      ],
    ),
  );
}

/// Règles du mot de passe : 8 caractères (obligatoire), puis une majuscule,
/// un chiffre et un symbole (recommandés).
({bool length, bool upper, bool digit, bool symbol}) passwordRules(
  String value,
) => (
  length: value.length >= 8,
  upper: RegExp('[A-Z]').hasMatch(value),
  digit: RegExp(r'\d').hasMatch(value),
  symbol: RegExp(r'[^A-Za-z0-9]').hasMatch(value),
);

/// Jauge de robustesse et règles du mot de passe, à jour à chaque frappe.
class PasswordStrength extends StatelessWidget {
  const PasswordStrength({required this.controller, super.key});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) {
      final t = context.t;
      final p = context.palette;
      final rules = passwordRules(controller.text);
      final extras = [rules.upper, rules.digit, rules.symbol].where((ok) => ok);
      final score = controller.text.isEmpty
          ? 0
          : rules.length
          ? 1 + extras.length
          : 1;
      final (label, color) = switch (score) {
        0 => ('', p.border),
        1 => (t.passwordWeak, p.errorText),
        2 => (t.passwordFair, AppColors.accent),
        3 => (t.passwordGood, p.primaryText),
        _ => (t.passwordStrong, p.successText),
      };
      Widget rule(bool ok, String text) => Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              ok ? Icons.check_circle : Icons.radio_button_unchecked,
              size: 16,
              color: ok ? p.successText : p.textMuted,
            ),
            const SizedBox(width: 6),
            Text(
              text,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: ok ? FontWeight.w700 : FontWeight.w600,
                color: ok ? p.successText : p.textMuted,
              ),
            ),
          ],
        ),
      );
      return Column(
        key: const Key('password-strength'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Row(
            children: [
              for (var i = 0; i < 4; i++) ...[
                if (i > 0) const SizedBox(width: 4),
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 5,
                    decoration: BoxDecoration(
                      color: i < score ? color : p.borderSoft,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ],
              const SizedBox(width: 10),
              SizedBox(
                width: 76,
                child: Text(
                  label,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          Wrap(
            spacing: 14,
            children: [
              rule(rules.length, t.passwordRuleLength),
              rule(rules.upper, t.passwordRuleUpper),
              rule(rules.digit, t.passwordRuleDigit),
              rule(rules.symbol, t.passwordRuleSymbol),
            ],
          ),
        ],
      );
    },
  );
}

/// Bloc numéroté d'un formulaire (« 1 Vous », « 2 Contact »…).
class FormStepCard extends StatelessWidget {
  const FormStepCard({
    required this.number,
    required this.title,
    required this.children,
    super.key,
  });

  final int number;
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: p.borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: p.primaryTint,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$number',
                  style: TextStyle(
                    color: p.primaryText,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class ErrorBanner extends StatelessWidget {
  const ErrorBanner(this.message, {super.key});
  final String message;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: context.palette.errorBg,
      borderRadius: BorderRadius.circular(AppRadius.input),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.error_outline, color: context.palette.errorText, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            message,
            style: TextStyle(
              color: context.palette.errorText,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
      ],
    ),
  );
}

/// Bouton principal qui affiche un indicateur pendant l'action.
class BusyButton extends StatelessWidget {
  const BusyButton({
    required this.label,
    required this.busy,
    required this.onPressed,
    super.key,
  });

  final String label;
  final bool busy;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => FilledButton(
    onPressed: busy ? null : onPressed,
    child: busy
        ? const SizedBox.square(
            dimension: 22,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          )
        : Text(label),
  );
}

/// Exécute une action de formulaire : indicateur, puis erreur éventuelle.
mixin FormActions<T extends StatefulWidget> on State<T> {
  final formKey = GlobalKey<FormState>();
  bool busy = false;
  String? error;

  Validators get validators => Validators(context.t);

  Future<void> submit(
    Future<void> Function() action, {
    bool validate = true,
  }) async {
    if (validate && !(formKey.currentState?.validate() ?? true)) return;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await action();
    } catch (e) {
      if (mounted) setState(() => error = errorMessage(context, e));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }
}
