import 'package:flutter/material.dart';

import 'package:mon_constat_digital/core/state/app_scope.dart';
import 'package:mon_constat_digital/modules/users/screens/otp_screen.dart';
import 'package:mon_constat_digital/modules/users/widgets/form_widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with FormActions {
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    for (final controller in [
      _firstName,
      _lastName,
      _email,
      _phone,
      _password,
      _confirm,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _register() {
    final users = AppScope.of(context).users;
    final navigator = Navigator.of(context);
    submit(() async {
      await users.register(
        firstName: _firstName.text.trim(),
        lastName: _lastName.text.trim(),
        email: _email.text.trim(),
        phone: _phone.text.trim(),
        password: _password.text,
      );
      navigator.pushReplacement(
        MaterialPageRoute(builder: (_) => const OtpScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Créer un compte')),
    body: SafeArea(
      child: Form(
        key: formKey,
        child: AutofillGroup(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (error != null) ...[
                  ErrorBanner(error!),
                  const SizedBox(height: 14),
                ],
                LabeledField(
                  label: 'Prénom',
                  controller: _firstName,
                  validator: Validators.required,
                  autofillHints: const [AutofillHints.givenName],
                ),
                const SizedBox(height: 14),
                LabeledField(
                  label: 'Nom',
                  controller: _lastName,
                  validator: Validators.required,
                  autofillHints: const [AutofillHints.familyName],
                ),
                const SizedBox(height: 14),
                LabeledField(
                  label: 'E-mail',
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                  autofillHints: const [AutofillHints.email],
                ),
                const SizedBox(height: 14),
                LabeledField(
                  label: 'Téléphone',
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  validator: Validators.phone,
                  hint: '20 123 456',
                  autofillHints: const [AutofillHints.telephoneNumber],
                ),
                const SizedBox(height: 14),
                PasswordField(
                  label: 'Mot de passe',
                  controller: _password,
                  validator: Validators.password,
                  autofillHints: const [AutofillHints.newPassword],
                ),
                const SizedBox(height: 14),
                PasswordField(
                  label: 'Confirmer le mot de passe',
                  controller: _confirm,
                  validator: (value) => value == _password.text
                      ? null
                      : 'Les mots de passe ne correspondent pas.',
                ),
                const SizedBox(height: 22),
                BusyButton(
                  label: 'Créer mon compte',
                  busy: busy,
                  onPressed: _register,
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
