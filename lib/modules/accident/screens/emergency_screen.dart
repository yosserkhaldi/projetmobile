import 'package:flutter/material.dart';
import 'package:mon_constat_digital/l10n/l10n.dart';

class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(context.t.accEmergencyNumbers)),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ListTile(
          leading: const CircleAvatar(child: Text('190')),
          title: Text(context.t.accSamu),
          trailing: const Icon(Icons.call),
        ),
        ListTile(
          leading: const CircleAvatar(child: Text('197')),
          title: Text(context.t.accPolice),
          trailing: const Icon(Icons.call),
        ),
        ListTile(
          leading: const CircleAvatar(child: Text('198')),
          title: Text(context.t.accCivilProtection),
          trailing: const Icon(Icons.call),
        ),
      ],
    ),
  );
}
