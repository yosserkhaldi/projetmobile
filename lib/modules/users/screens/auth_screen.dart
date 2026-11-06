import 'package:flutter/material.dart';

import 'package:mon_constat_digital/app/main_shell.dart';
import 'package:mon_constat_digital/core/state/app_scope.dart';
import 'package:mon_constat_digital/core/theme/app_colors.dart';
import 'package:mon_constat_digital/modules/users/models/app_user.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final email = TextEditingController(text: 'sami@example.com');
  final password = TextEditingController(text: 'Password123!');
  bool login = true, hidden = true;
  UserRole role = UserRole.driver;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.car_crash_rounded,
                  size: 58,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 12),
                Text(
                  'Mon Constat Digital',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Text(
                  'Votre constat, simple, rapide et sécurisé.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                SegmentedButton<UserRole>(
                  segments: UserRole.values
                      .map(
                        (r) => ButtonSegment(
                          value: r,
                          label: Text(
                            r == UserRole.driver
                                ? 'Conducteur'
                                : r == UserRole.agent
                                ? 'Agent'
                                : 'Admin',
                          ),
                        ),
                      )
                      .toList(),
                  selected: {role},
                  onSelectionChanged: (v) => setState(() => role = v.first),
                ),
                const SizedBox(height: 20),
                if (!login) ...[
                  const TextField(
                    decoration: InputDecoration(
                      labelText: 'Nom et prénom',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const TextField(
                    decoration: InputDecoration(
                      labelText: 'Téléphone',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                TextField(
                  controller: email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'E-mail',
                    prefixIcon: Icon(Icons.mail_outline),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: password,
                  obscureText: hidden,
                  decoration: InputDecoration(
                    labelText: 'Mot de passe',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => hidden = !hidden),
                      icon: Icon(
                        hidden ? Icons.visibility : Icons.visibility_off,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: () {
                    AppScope.of(context).users.setRole(role);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const MainShell()),
                    );
                  },
                  icon: Icon(login ? Icons.login : Icons.person_add),
                  label: Text(login ? 'Se connecter' : 'Créer mon compte'),
                ),
                TextButton(
                  onPressed: () => setState(() => login = !login),
                  child: Text(
                    login ? 'Créer un compte' : 'J’ai déjà un compte',
                  ),
                ),
                TextButton(
                  onPressed: () => _otpDialog(context),
                  child: const Text('Mot de passe oublié / Vérification OTP'),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  void _otpDialog(BuildContext context) => showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Vérification'),
      content: const TextField(
        keyboardType: TextInputType.number,
        decoration: InputDecoration(labelText: 'Code OTP à 6 chiffres'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Valider'),
        ),
      ],
    ),
  );
}
