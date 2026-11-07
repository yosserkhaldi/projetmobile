import 'package:flutter/material.dart';

import 'package:mon_constat_digital/core/state/app_scope.dart';
import 'package:mon_constat_digital/core/theme/app_colors.dart';
import 'package:mon_constat_digital/core/theme/app_theme.dart';
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
    submit(users.loginWithBiometric, validate: false);
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

  Widget _form(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(
        'Connexion',
        style: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(fontSize: 22, letterSpacing: -0.4),
      ),
      const SizedBox(height: 16),
      if (error != null) ...[ErrorBanner(error!), const SizedBox(height: 16)],
      LabeledField(
        label: 'E-mail ou téléphone',
        controller: _identifier,
        keyboardType: TextInputType.emailAddress,
        validator: Validators.required,
        autofillHints: const [AutofillHints.username],
      ),
      const SizedBox(height: 16),
      PasswordField(
        label: 'Mot de passe',
        controller: _password,
        validator: Validators.required,
        autofillHints: const [AutofillHints.password],
      ),
      Align(
        alignment: AlignmentDirectional.centerEnd,
        child: TextButton(
          onPressed: () => open(context, const ForgotPasswordScreen()),
          child: const Text(
            'Mot de passe oublié ?',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ),
      const SizedBox(height: 4),
      BusyButton(label: 'Se connecter', busy: busy, onPressed: _login),
      if (AppScope.of(context).users.biometricEnabled) ...[
        const SizedBox(height: 14),
        const Row(
          children: [
            Expanded(child: Divider(color: AppColors.border)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'ou',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Expanded(child: Divider(color: AppColors.border)),
          ],
        ),
        const SizedBox(height: 14),
        OutlinedButton.icon(
          onPressed: busy ? null : _biometricLogin,
          icon: const Icon(Icons.fingerprint),
          label: const Text('Empreinte ou Face ID'),
        ),
      ],
      const SizedBox(height: 16),
      Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Text(
            'Pas encore de compte ?',
            style: TextStyle(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
          TextButton(
            onPressed: () => open(context, const RegisterScreen()),
            child: const Text(
              'Créer un compte',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    ],
  );
}

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) => Padding(
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
            const Text(
              'Mon Constat',
              style: TextStyle(
                fontFamily: AppFonts.display,
                fontWeight: FontWeight.w800,
                fontSize: 18,
                letterSpacing: -0.3,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 26),
        const Text.rich(
          TextSpan(
            style: TextStyle(
              fontFamily: AppFonts.display,
              fontWeight: FontWeight.w800,
              fontSize: 38,
              height: 1,
              letterSpacing: -1.2,
              color: Colors.white,
            ),
            children: [
              TextSpan(text: 'Le constat,\n'),
              TextSpan(
                text: 'sans papier.',
                style: TextStyle(color: AppColors.accent),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Déclarez, signez et suivez votre sinistre depuis votre téléphone.',
          style: TextStyle(
            fontSize: 15,
            height: 1.5,
            color: AppColors.onDarkBody,
          ),
        ),
      ],
    ),
  );
}
