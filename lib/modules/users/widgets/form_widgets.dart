import 'package:flutter/material.dart';

import 'package:mon_constat_digital/core/network/api_client.dart';
import 'package:mon_constat_digital/core/theme/app_colors.dart';
import 'package:mon_constat_digital/core/theme/app_theme.dart';
import 'package:mon_constat_digital/modules/users/data/biometric_auth.dart';

abstract final class Validators {
  static String? required(String? value) =>
      (value ?? '').trim().isEmpty ? 'Champ obligatoire.' : null;

  static String? email(String? value) =>
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch((value ?? '').trim())
      ? null
      : 'Adresse e-mail invalide.';

  static String? phone(String? value) =>
      RegExp(
        r'^\+?\d{8,15}$',
      ).hasMatch((value ?? '').replaceAll(RegExp(r'[\s.-]'), ''))
      ? null
      : 'Numéro de téléphone invalide.';

  static String? password(String? value) => (value ?? '').length < 8
      ? 'Le mot de passe doit contenir au moins 8 caractères.'
      : null;

  static String? code(String? value) =>
      RegExp(r'^\d{6}$').hasMatch((value ?? '').trim())
      ? null
      : 'Le code contient 6 chiffres.';
}

/// Message d'erreur affiché à partir de n'importe quelle exception.
String errorMessage(Object error) => switch (error) {
  ApiException(:final message) => message,
  BiometricException(:final message) => message,
  _ => 'Une erreur est survenue. Réessayez.',
};

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

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.textMuted,
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
        style:
            style ?? const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        decoration: InputDecoration(hintText: hint, suffixIcon: suffixIcon),
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
    super.key,
  });

  final String label;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final Iterable<String>? autofillHints;

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
    suffixIcon: IconButton(
      tooltip: _hidden ? 'Afficher le mot de passe' : 'Masquer le mot de passe',
      onPressed: () => setState(() => _hidden = !_hidden),
      icon: Icon(
        _hidden ? Icons.visibility_outlined : Icons.visibility_off_outlined,
      ),
    ),
  );
}

class ErrorBanner extends StatelessWidget {
  const ErrorBanner(this.message, {super.key});
  final String message;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColors.errorBg,
      borderRadius: BorderRadius.circular(AppRadius.input),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.error_outline, color: AppColors.errorText, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            message,
            style: const TextStyle(
              color: AppColors.errorText,
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
      if (mounted) setState(() => error = errorMessage(e));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }
}
