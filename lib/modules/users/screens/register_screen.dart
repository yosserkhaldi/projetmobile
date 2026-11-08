import 'package:flutter/material.dart';

import 'package:mon_constat_digital/core/state/app_scope.dart';
import 'package:mon_constat_digital/l10n/l10n.dart';
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
  Widget build(BuildContext context) {
    final t = context.t;
    final v = validators;
    return Scaffold(
      appBar: AppBar(title: Text(t.registerTitle)),
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
                    label: t.firstNameLabel,
                    controller: _firstName,
                    validator: v.required,
                    autofillHints: const [AutofillHints.givenName],
                  ),
                  const SizedBox(height: 14),
                  LabeledField(
                    label: t.lastNameLabel,
                    controller: _lastName,
                    validator: v.required,
                    autofillHints: const [AutofillHints.familyName],
                  ),
                  const SizedBox(height: 14),
                  LabeledField(
                    label: t.emailLabel,
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    validator: v.email,
                    textDirection: TextDirection.ltr,
                    autofillHints: const [AutofillHints.email],
                  ),
                  const SizedBox(height: 14),
                  LabeledField(
                    label: t.phoneLabel,
                    controller: _phone,
                    keyboardType: TextInputType.phone,
                    validator: v.phone,
                    hint: '20 123 456',
                    textDirection: TextDirection.ltr,
                    autofillHints: const [AutofillHints.telephoneNumber],
                  ),
                  const SizedBox(height: 14),
                  PasswordField(
                    label: t.passwordLabel,
                    controller: _password,
                    validator: v.password,
                    autofillHints: const [AutofillHints.newPassword],
                  ),
                  const SizedBox(height: 14),
                  PasswordField(
                    label: t.confirmPasswordLabel,
                    controller: _confirm,
                    validator: (value) =>
                        value == _password.text ? null : t.passwordsDontMatch,
                  ),
                  const SizedBox(height: 14),
                  // Loi n° 2004-63 : consentement explicite, non coché par défaut.
                  FormField<bool>(
                    initialValue: false,
                    validator: (value) =>
                        value == true ? null : t.consentRequired,
                    builder: (state) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CheckboxListTile(
                          key: const Key('consent'),
                          value: state.value,
                          onChanged: state.didChange,
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                          title: Text(
                            t.consentLabel,
                            style: const TextStyle(fontSize: 13, height: 1.4),
                          ),
                        ),
                        if (state.hasError)
                          Text(
                            state.errorText!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  BusyButton(
                    label: t.createMyAccount,
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
}
