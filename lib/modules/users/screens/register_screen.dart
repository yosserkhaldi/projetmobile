import 'package:flutter/material.dart';

import 'package:mon_constat_digital/core/state/app_scope.dart';
import 'package:mon_constat_digital/core/theme/app_theme.dart';
import 'package:mon_constat_digital/l10n/l10n.dart';
import 'package:mon_constat_digital/modules/users/screens/otp_screen.dart';
import 'package:mon_constat_digital/modules/users/widgets/form_widgets.dart';

/// Inscription en trois blocs : qui vous êtes, comment vous joindre, et un
/// mot de passe guidé par une jauge de robustesse.
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
    final p = context.palette;
    final v = validators;
    const gap = SizedBox(height: 14);
    return Scaffold(
      appBar: AppBar(title: Text(t.registerTitle)),
      body: SafeArea(
        child: Form(
          key: formKey,
          child: AutofillGroup(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        t.registerIntro,
                        style: TextStyle(color: p.textMuted, height: 1.45),
                      ),
                      const SizedBox(height: 16),
                      if (error != null) ...[ErrorBanner(error!), gap],
                      FormStepCard(
                        number: 1,
                        title: t.registerStepYou,
                        children: [
                          LabeledField(
                            label: t.firstNameLabel,
                            controller: _firstName,
                            validator: v.required,
                            prefixIcon: Icons.person_outline,
                            autofillHints: const [AutofillHints.givenName],
                          ),
                          gap,
                          LabeledField(
                            label: t.lastNameLabel,
                            controller: _lastName,
                            validator: v.required,
                            prefixIcon: Icons.badge_outlined,
                            autofillHints: const [AutofillHints.familyName],
                          ),
                        ],
                      ),
                      gap,
                      FormStepCard(
                        number: 2,
                        title: t.registerStepContact,
                        children: [
                          LabeledField(
                            label: t.emailLabel,
                            controller: _email,
                            keyboardType: TextInputType.emailAddress,
                            validator: v.email,
                            hint: 'nom@exemple.tn',
                            prefixIcon: Icons.mail_outline,
                            textDirection: TextDirection.ltr,
                            autofillHints: const [AutofillHints.email],
                          ),
                          gap,
                          LabeledField(
                            label: t.phoneLabel,
                            controller: _phone,
                            keyboardType: TextInputType.phone,
                            validator: v.phone,
                            hint: '20 123 456',
                            prefixIcon: Icons.phone_outlined,
                            prefixText: '+216',
                            textDirection: TextDirection.ltr,
                            autofillHints: const [
                              AutofillHints.telephoneNumber,
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            t.registerPhoneHint,
                            style: TextStyle(
                              color: p.textMuted,
                              fontSize: 12.5,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                      gap,
                      FormStepCard(
                        number: 3,
                        title: t.registerStepSecurity,
                        children: [
                          PasswordField(
                            label: t.passwordLabel,
                            controller: _password,
                            validator: v.password,
                            autofillHints: const [AutofillHints.newPassword],
                          ),
                          PasswordStrength(controller: _password),
                          gap,
                          // La coche apparaît dès que les deux saisies
                          // correspondent.
                          ListenableBuilder(
                            listenable: Listenable.merge([_password, _confirm]),
                            builder: (context, _) => PasswordField(
                              label: t.confirmPasswordLabel,
                              controller: _confirm,
                              validator: (value) => value == _password.text
                                  ? null
                                  : t.passwordsDontMatch,
                              suffix:
                                  _confirm.text.isNotEmpty &&
                                      _confirm.text == _password.text
                                  ? Icon(
                                      Icons.check_circle,
                                      key: const Key('passwords-match'),
                                      color: p.successText,
                                      size: 20,
                                    )
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      gap,
                      // Loi n° 2004-63 : consentement explicite, non coché par
                      // défaut.
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
                                style: const TextStyle(
                                  fontSize: 13,
                                  height: 1.4,
                                ),
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
                      const SizedBox(height: 18),
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
        ),
      ),
    );
  }
}
