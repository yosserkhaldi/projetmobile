import 'package:flutter/material.dart';

import 'package:mon_constat_digital/core/theme/app_palette.dart';
import 'package:mon_constat_digital/core/state/app_scope.dart';
import 'package:mon_constat_digital/l10n/l10n.dart';
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
    final done = context.t.passwordChanged;
    submit(() async {
      await users.resetPassword(
        email: _email.text.trim(),
        code: _code.text.trim(),
        password: _password.text,
      );
      messenger.showSnackBar(SnackBar(content: Text(done)));
      navigator.pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final v = validators;
    return Scaffold(
      appBar: AppBar(title: Text(t.forgotTitle)),
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
                      ? t.forgotCodeSent(ltr(_email.text.trim()))
                      : t.forgotIntro,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.45,
                    color: context.palette.textMuted,
                  ),
                ),
                const SizedBox(height: 18),
                if (error != null) ...[
                  ErrorBanner(error!),
                  const SizedBox(height: 14),
                ],
                LabeledField(
                  label: t.emailLabel,
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  validator: v.email,
                  readOnly: _codeSent,
                  textDirection: TextDirection.ltr,
                ),
                if (_codeSent) ...[
                  const SizedBox(height: 14),
                  LabeledField(
                    label: t.codeFromEmailLabel,
                    controller: _code,
                    keyboardType: TextInputType.number,
                    validator: v.code,
                    textDirection: TextDirection.ltr,
                  ),
                  const SizedBox(height: 14),
                  PasswordField(
                    label: t.newPasswordLabel,
                    controller: _password,
                    validator: v.password,
                    autofillHints: const [AutofillHints.newPassword],
                  ),
                ],
                const SizedBox(height: 22),
                BusyButton(
                  label: _codeSent ? t.changePassword : t.receiveCode,
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
}
