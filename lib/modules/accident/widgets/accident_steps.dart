import 'package:flutter/material.dart';

import 'package:mon_constat_digital/core/theme/app_palette.dart';

class ContextStep extends StatelessWidget {
  const ContextStep({required this.place, super.key});
  final TextEditingController place;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      TextField(
        controller: place,
        decoration: const InputDecoration(
          labelText: 'Lieu',
          prefixIcon: Icon(Icons.location_on),
        ),
      ),
      const SizedBox(height: 12),
      const TextField(
        decoration: InputDecoration(
          labelText: 'Date et heure',
          prefixIcon: Icon(Icons.schedule),
        ),
      ),
      const SizedBox(height: 12),
      DropdownButtonFormField(
        items: [
          'Ensoleillé',
          'Pluie',
          'Brouillard',
        ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: (_) {},
        decoration: const InputDecoration(labelText: 'Météo'),
      ),
      const SizedBox(height: 12),
      const TextField(
        decoration: InputDecoration(
          labelText: 'État de la route et luminosité',
        ),
      ),
    ],
  );
}

class DescriptionStep extends StatelessWidget {
  const DescriptionStep({
    required this.type,
    required this.severity,
    required this.injured,
    required this.onTypeChanged,
    required this.onSeverityChanged,
    required this.onInjuredChanged,
    super.key,
  });
  final String type, severity;
  final bool injured;
  final ValueChanged<String> onTypeChanged, onSeverityChanged;
  final ValueChanged<bool> onInjuredChanged;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      DropdownButtonFormField<String>(
        initialValue: type,
        items: [
          'Collision',
          'Sortie de route',
          'Piéton',
          'Accident matériel',
          'Autre',
        ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: (v) => onTypeChanged(v!),
        decoration: const InputDecoration(labelText: "Type d'accident"),
      ),
      const SizedBox(height: 12),
      DropdownButtonFormField<String>(
        initialValue: severity,
        items: [
          'Matériel',
          'Léger',
          'Grave',
        ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: (v) => onSeverityChanged(v!),
        decoration: const InputDecoration(labelText: 'Gravité'),
      ),
      SwitchListTile(
        value: injured,
        onChanged: onInjuredChanged,
        title: const Text('Il y a des blessés'),
      ),
      if (injured)
        Card(
          color: context.palette.errorBg,
          child: const ListTile(
            title: Text(
              'Urgences : SAMU 190 • Police 197 • Protection civile 198',
            ),
          ),
        ),
      const TextField(
        decoration: InputDecoration(labelText: 'Témoin : nom et téléphone'),
      ),
    ],
  );
}

class EvidenceStep extends StatelessWidget {
  const EvidenceStep({super.key});
  @override
  Widget build(BuildContext context) => Column(
    children: <Widget>[
      ...[
        'Vue d’ensemble',
        'Dégâts véhicule A',
        'Dégâts véhicule B',
        'Plaques',
      ].map(
        (e) => Card(
          child: ListTile(
            leading: const Icon(Icons.camera_alt),
            title: Text(e),
            trailing: const Icon(Icons.add_circle_outline),
          ),
        ),
      ),
      const ListTile(
        leading: Icon(Icons.videocam),
        title: Text('Vidéo de la scène (max. 30 s)'),
      ),
      const ListTile(leading: Icon(Icons.mic), title: Text('Note vocale')),
    ],
  );
}
