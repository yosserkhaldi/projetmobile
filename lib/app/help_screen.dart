import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Assistance')),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        ExpansionTile(
          title: Text('Comment remplir un constat ?'),
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Suivez les sept étapes guidées. Chaque étape est sauvegardée localement.',
              ),
            ),
          ],
        ),
        ExpansionTile(
          title: Text('Puis-je travailler hors ligne ?'),
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Oui. Le dossier sera synchronisé dès le retour du réseau.',
              ),
            ),
          ],
        ),
        ListTile(
          leading: Icon(Icons.support_agent),
          title: Text('Contacter le support'),
        ),
      ],
    ),
  );
}
