import 'package:flutter/material.dart';

import 'package:mon_constat_digital/core/theme/app_palette.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Alertes d’échéance')),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: ListTile(
            leading: Icon(Icons.warning, color: context.palette.warningText),
            title: const Text('Assurance expire dans 7 jours'),
            subtitle: const Text('Peugeot 208 • POL-884521'),
          ),
        ),
        const Card(
          child: ListTile(
            leading: Icon(Icons.build),
            title: Text('Visite technique dans 30 jours'),
          ),
        ),
      ],
    ),
  );
}
