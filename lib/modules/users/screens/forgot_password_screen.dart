import 'package:flutter/material.dart';

import 'package:mon_constat_digital/core/state/app_scope.dart';
import 'package:mon_constat_digital/core/theme/app_colors.dart';
import 'package:mon_constat_digital/modules/users/widgets/form_widgets.dart';

/// Deux étapes : demander un code par e-mail, puis choisir un nouveau mot de passe.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with FormActions {
  final _email = TextEditingController();
  final _code = TextEditingController();
  final _password = TextEditingController();
  bool _codeSent = false;

  @override
  void dispose() {
    _email.dispose();
    _code.dispose();
    _password.dispose();
    super.dispose();
  }

  void _sendCode() {
    final users = AppScope.of(context).users;
    submit(() async {
      await users.forgotPassword(_email.text.trim());
      setState(() => _codeSent = true);
    });
  }

  void _reset() {
    final users = AppScope.of(context).users;
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    submit(() async {
      await users.resetPassword(
        email: _email.text.trim(),
        code: _code.text.trim(),
        password: _password.text,
      );
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Mot de passe modifié. Vous pouvez vous connecter.'),
        ),
      );
      navigator.pop();
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Mot de passe oublié')),
    body: SafeArea(
      child: Form(
        key: formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _codeSent
                    ? 'Si un compte existe pour ${_email.text.trim()}, un code '
                          'valable 15 minutes vient de lui être envoyé.'
                    : 'Saisissez votre adresse e-mail pour recevoir un code de '
                          'réinitialisation.',
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.45,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 18),
              if (error != null) ...[
                ErrorBanner(error!),
                const SizedBox(height: 14),
              ],
              LabeledField(
                label: 'E-mail',
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                validator: Validators.email,
                readOnly: _codeSent,
              ),
              if (_codeSent) ...[
                const SizedBox(height: 14),
                LabeledField(
                  label: 'Code reçu par e-mail',
                  controller: _code,
                  keyboardType: TextInputType.number,
                  validator: Validators.code,
                ),
                const SizedBox(height: 14),
                PasswordField(
                  label: 'Nouveau mot de passe',
                  controller: _password,
                  validator: Validators.password,
                  autofillHints: const [AutofillHints.newPassword],
                ),
              ],
              const SizedBox(height: 22),
              BusyButton(
                label: _codeSent
                    ? 'Changer le mot de passe'
                    : 'Recevoir un code',
                busy: busy,
                onPressed: _codeSent ? _reset : _sendCode,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
