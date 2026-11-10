import 'package:flutter/material.dart';

import 'package:mon_constat_digital/core/state/app_scope.dart';
import 'package:mon_constat_digital/core/theme/app_theme.dart';
import 'package:mon_constat_digital/l10n/l10n.dart';
import 'package:mon_constat_digital/modules/users/widgets/form_widgets.dart';

/// Inscription : un e-mail et un mot de passe, rien de plus. Le nom, le
/// téléphone (vérifié par un code), le permis et l'identité sont demandés
/// juste après, dans l'accueil (OnboardingScreen).
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with FormActions {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    for (final controller in [_email, _password, _confirm]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _register() {
    final users = AppScope.of(context).users;
    final navigator = Navigator.of(context);
    submit(() async {
      await users.register(email: _email.text.trim(), password: _password.text);
      // Compte ouvert : l'accueil s'affiche sous cet écran, qu'on referme.
      navigator.popUntil((route) => route.isFirst);
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
                        title: t.registerStepAccount,
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
                        ],
                      ),
                      gap,
                      FormStepCard(
                        number: 2,
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
