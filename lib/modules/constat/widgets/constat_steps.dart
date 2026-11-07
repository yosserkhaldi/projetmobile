import 'package:flutter/material.dart';

import 'package:mon_constat_digital/core/theme/app_palette.dart';
import 'package:mon_constat_digital/modules/constat/widgets/signature_box.dart';

class GuestDriverStep extends StatelessWidget {
  const GuestDriverStep({required this.guest, super.key});
  final TextEditingController guest;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      const Card(
        child: ListTile(
          leading: Icon(Icons.screen_lock_portrait),
          title: Text('Mode invité isolé'),
          subtitle: Text('Le conducteur B ne peut pas consulter vos données.'),
        ),
      ),
      TextField(
        controller: guest,
        decoration: const InputDecoration(labelText: 'Nom du conducteur B'),
      ),
      const SizedBox(height: 12),
      const TextField(
        decoration: InputDecoration(labelText: 'Permis / véhicule / assurance'),
      ),
      const SizedBox(height: 12),
      OutlinedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.qr_code_scanner),
        label: const Text('Rejoindre par QR code'),
      ),
    ],
  );
}

class CircumstancesStep extends StatelessWidget {
  const CircumstancesStep({required this.observations, super.key});
  final TextEditingController observations;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      for (final e in [
        'En stationnement',
        'Quittait un stationnement',
        'Changeait de file',
        'Doublait',
        'Virait à droite',
        'Virait à gauche',
        'Reculait',
      ])
        CheckboxListTile(value: false, onChanged: (_) {}, title: Text(e)),
      TextField(
        controller: observations,
        maxLines: 3,
        decoration: const InputDecoration(labelText: 'Observations'),
      ),
    ],
  );
}

class SketchStep extends StatelessWidget {
  const SketchStep({super.key});
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Container(
        height: 220,
        decoration: BoxDecoration(
          color: context.palette.surface,
          border: Border.all(color: context.palette.primaryText),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.gesture, size: 60),
              Text('Zone de croquis tactile'),
              Text('Dessinez les véhicules, voies et panneaux'),
            ],
          ),
        ),
      ),
      const SizedBox(height: 12),
      Wrap(
        spacing: 8,
        children: ['Avant', 'Arrière', 'Côté gauche', 'Côté droit']
            .map(
              (e) => FilterChip(
                label: Text(e),
                selected: false,
                onSelected: (_) {},
              ),
            )
            .toList(),
      ),
    ],
  );
}

class SignatureStep extends StatelessWidget {
  const SignatureStep({super.key});
  @override
  Widget build(BuildContext context) => const Column(
    children: [
      Text('Relisez les informations puis signez dans les deux zones.'),
      SizedBox(height: 16),
      SignatureBox('Signature conducteur A'),
      SizedBox(height: 14),
      SignatureBox('Signature conducteur B'),
      SizedBox(height: 14),
      Card(
        child: ListTile(
          leading: Icon(Icons.lock),
          title: Text('Verrouillage SHA-256'),
          subtitle: Text(
            'Le constat sera rendu infalsifiable après la double signature.',
          ),
        ),
      ),
    ],
  );
}
