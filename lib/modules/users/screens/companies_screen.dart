import 'package:flutter/material.dart';

import 'package:mon_constat_digital/shared/widgets/page_head.dart';

class CompaniesScreen extends StatelessWidget {
  const CompaniesScreen({super.key});
  @override
  Widget build(BuildContext context) => SafeArea(
    child: ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const PageHead(
          "Compagnies d'assurance",
          subtitle: 'Compagnies et agences',
        ),
        for (final e in [
          'STAR Assurances • 18 agences',
          'COMAR • 12 agences',
          'GAT Assurances • 15 agences',
        ])
          Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.business)),
              title: Text(e),
              trailing: const Icon(Icons.edit_outlined),
            ),
          ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.add),
          label: const Text('Ajouter une compagnie'),
        ),
      ],
    ),
  );
}
