import 'package:flutter/material.dart';

class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Numéros d’urgence')),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        ListTile(
          leading: CircleAvatar(child: Text('190')),
          title: Text('SAMU'),
          trailing: Icon(Icons.call),
        ),
        ListTile(
          leading: CircleAvatar(child: Text('197')),
          title: Text('Police'),
          trailing: Icon(Icons.call),
        ),
        ListTile(
          leading: CircleAvatar(child: Text('198')),
          title: Text('Protection civile'),
          trailing: Icon(Icons.call),
        ),
      ],
    ),
  );
}
