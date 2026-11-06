import 'package:flutter/material.dart';

import 'package:mon_constat_digital/core/state/app_scope.dart';
import 'package:mon_constat_digital/modules/users/screens/auth_screen.dart';
import 'package:mon_constat_digital/shared/widgets/page_head.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController name;
  bool ready = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!ready) {
      name = TextEditingController(text: AppScope.of(context).users.userName);
      ready = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context).users;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            const PageHead(
              'Mon profil',
              subtitle: 'Identité, permis et préférences',
            ),
            const CircleAvatar(radius: 44, child: Icon(Icons.person, size: 45)),
            const SizedBox(height: 18),
            TextField(
              controller: name,
              decoration: const InputDecoration(labelText: 'Nom et prénom'),
            ),
            const SizedBox(height: 12),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Téléphone',
                prefixIcon: Icon(Icons.phone),
              ),
            ),
            const SizedBox(height: 12),
            const TextField(
              decoration: InputDecoration(
                labelText: 'N° de permis',
                prefixIcon: Icon(Icons.badge),
              ),
            ),
            const SizedBox(height: 12),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Catégorie et date de délivrance',
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: s.language,
              decoration: const InputDecoration(labelText: 'Langue'),
              items: [
                'Français',
                'العربية',
                'English',
              ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) {
                if (v != null) s.language = v;
              },
            ),
            SwitchListTile(
              value: s.biometric,
              onChanged: (v) => setState(() => s.biometric = v),
              title: const Text('Connexion biométrique'),
              subtitle: const Text(
                'Empreinte digitale ou reconnaissance faciale',
              ),
            ),
            FilledButton(
              onPressed: () {
                s.updateProfile(name.text, s.language, s.biometric);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profil enregistré')),
                );
              },
              child: const Text('Enregistrer'),
            ),
            TextButton.icon(
              onPressed: () => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const AuthScreen()),
                (_) => false,
              ),
              icon: const Icon(Icons.logout),
              label: const Text('Se déconnecter'),
            ),
          ],
        ),
      ),
    );
  }
}
