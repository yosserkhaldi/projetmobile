import 'package:flutter/material.dart';

import 'package:mon_constat_digital/core/state/app_scope.dart';
import 'package:mon_constat_digital/core/theme/app_colors.dart';
import 'package:mon_constat_digital/core/theme/app_theme.dart';
import 'package:mon_constat_digital/l10n/l10n.dart';
import 'package:mon_constat_digital/modules/users/models/app_user.dart';
import 'package:mon_constat_digital/modules/users/screens/forgot_password_screen.dart';
import 'package:mon_constat_digital/modules/users/screens/register_screen.dart';
import 'package:mon_constat_digital/modules/users/widgets/form_widgets.dart';
import 'package:mon_constat_digital/shared/navigation.dart';

/// Écran de connexion. Le rôle vient du compte : il n'est plus choisi ici.
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with FormActions {
  final _identifier = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _identifier.dispose();
    _password.dispose();
    super.dispose();
  }

  void _biometricLogin() {
    final users = AppScope.of(context).users;
    submit(
      () => users.loginWithBiometric(context.t.biometricLoginReason),
      validate: false,
    );
  }

  void _login() {
    final users = AppScope.of(context).users;
    submit(() => users.login(_identifier.text.trim(), _password.text));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.ink,
    body: SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: _Hero()),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.canvas,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Form(
                    key: formKey,
                    child: AutofillGroup(child: _form(context)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _form(BuildContext context) {
    final t = context.t;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          t.loginTitle,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontSize: 22, letterSpacing: -0.4),
        ),
        const SizedBox(height: 16),
        if (error != null) ...[ErrorBanner(error!), const SizedBox(height: 16)],
        LabeledField(
          label: t.identifierLabel,
          controller: _identifier,
          keyboardType: TextInputType.emailAddress,
          validator: validators.required,
          textDirection: TextDirection.ltr,
          autofillHints: const [AutofillHints.username],
        ),
        const SizedBox(height: 16),
        PasswordField(
          label: t.passwordLabel,
          controller: _password,
          validator: validators.required,
          autofillHints: const [AutofillHints.password],
        ),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: TextButton(
            onPressed: () => open(context, const ForgotPasswordScreen()),
            child: Text(
              t.forgotPasswordLink,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
        const SizedBox(height: 4),
        BusyButton(label: t.signIn, busy: busy, onPressed: _login),
        if (AppScope.of(context).users.biometricEnabled) ...[
          const SizedBox(height: 14),
          Row(
            children: [
              const Expanded(child: Divider(color: AppColors.border)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  t.or,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Expanded(child: Divider(color: AppColors.border)),
            ],
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: busy ? null : _biometricLogin,
            icon: const Icon(Icons.fingerprint),
            label: Text(t.biometricButton),
          ),
        ],
        const SizedBox(height: 16),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              t.noAccount,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: () => open(context, const RegisterScreen()),
              child: Text(
                t.createAccountLink,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 36, 24, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Icon(
                  Icons.description_outlined,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  t.brand,
                  style: const TextStyle(
                    fontFamily: AppFonts.display,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    letterSpacing: -0.3,
                    color: Colors.white,
                  ),
                ),
              ),
              const _LanguageToggle(),
            ],
          ),
          const SizedBox(height: 26),
          Text.rich(
            TextSpan(
              style: const TextStyle(
                fontFamily: AppFonts.display,
                fontWeight: FontWeight.w800,
                fontSize: 38,
                height: 1.05,
                letterSpacing: -1.2,
                color: Colors.white,
              ),
              children: [
                TextSpan(text: '${t.heroTitleLine1}\n'),
                TextSpan(
                  text: t.heroTitleLine2,
                  style: const TextStyle(color: AppColors.accent),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            t.heroSubtitle,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: AppColors.onDarkBody,
            ),
          ),
        ],
      ),
    );
  }
}

/// Sélecteur FR / ع / EN de la maquette.
class _LanguageToggle extends StatelessWidget {
  const _LanguageToggle();

  @override
  Widget build(BuildContext context) {
    final users = AppScope.of(context).users;
    const labels = {
      AppLanguage.fr: 'FR',
      AppLanguage.ar: 'ع',
      AppLanguage.en: 'EN',
    };
    return Semantics(
      label: context.t.languageSwitcher,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.navy800,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final MapEntry(key: language, value: label) in labels.entries)
              _LanguageChip(
                label: label,
                tooltip: language.label,
                selected: users.language == language,
                onTap: () => users.setLanguage(language),
              ),
          ],
        ),
      ),
    );
  }
}

class _LanguageChip extends StatelessWidget {
  const _LanguageChip({
    required this.label,
    required this.tooltip,
    required this.selected,
    required this.onTap,
  });

  final String label, tooltip;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: Semantics(
      selected: selected,
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          constraints: const BoxConstraints(minWidth: 40, minHeight: 36),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
              color: selected ? AppColors.ink : AppColors.onDarkStrong,
            ),
          ),
        ),
      ),
    ),
  );
}
