import 'package:flutter/material.dart';

import 'package:mon_constat_digital/core/theme/app_colors.dart';
import 'package:mon_constat_digital/modules/accident/models/accident_draft.dart';
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
  const CircumstancesStep({
    required this.draft,
    required this.observations,
    required this.onChanged,
    super.key,
  });
  final AccidentDraft draft;
  final TextEditingController observations;
  final VoidCallback onChanged;

  static const choices = [
    'En stationnement',
    'Quittait un stationnement',
    'Changeait de file',
    'Doublait',
    'Virait à droite',
    'Virait à gauche',
    'Reculait',
  ];

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Que faisait votre véhicule ?',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
      ),
      const SizedBox(height: 4),
      const Text(
        'Sélectionnez une ou plusieurs circonstances.',
        style: TextStyle(color: AppColors.textMuted),
      ),
      const SizedBox(height: 16),
      for (final choice in choices)
        Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: CheckboxListTile(
            value: draft.circumstances.contains(choice),
            activeColor: AppColors.primary,
            controlAffinity: ListTileControlAffinity.leading,
            title: Text(
              choice,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            onChanged: (selected) {
              selected ?? false
                  ? draft.circumstances.add(choice)
                  : draft.circumstances.remove(choice);
              onChanged();
            },
          ),
        ),
      const SizedBox(height: 10),
      TextField(
        controller: observations,
        maxLines: 3,
        onChanged: (value) {
          draft.observations = value;
          onChanged();
        },
        decoration: const InputDecoration(
          labelText: 'Observations complémentaires',
          alignLabelWithHint: true,
        ),
      ),
    ],
  );
}

class SketchStep extends StatelessWidget {
  const SketchStep({required this.draft, required this.onChanged, super.key});
  final AccidentDraft draft;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Croquis et point de choc',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
      ),
      const SizedBox(height: 12),
      Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            draft.sketchConfirmed = !draft.sketchConfirmed;
            onChanged();
          },
          child: Container(
            height: 220,
            width: double.infinity,
            decoration: BoxDecoration(
              color: draft.sketchConfirmed
                  ? AppColors.primaryTint
                  : AppColors.surface,
              border: Border.all(
                color: draft.sketchConfirmed
                    ? AppColors.primary
                    : AppColors.border,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  draft.sketchConfirmed
                      ? Icons.check_circle
                      : Icons.gesture_rounded,
                  size: 56,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 8),
                Text(
                  draft.sketchConfirmed
                      ? 'Croquis confirmé'
                      : 'Zone de croquis tactile',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const Text('Touchez pour confirmer le schéma'),
              ],
            ),
          ),
        ),
      ),
      const SizedBox(height: 18),
      const Text(
        'Zone de choc sur votre véhicule',
        style: TextStyle(fontWeight: FontWeight.w800),
      ),
      const SizedBox(height: 10),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: ['Avant', 'Arrière', 'Côté gauche', 'Côté droit']
            .map(
              (zone) => FilterChip(
                label: Text(zone),
                selected: draft.impactZones.contains(zone),
                selectedColor: AppColors.primaryTint,
                checkmarkColor: AppColors.primary,
                onSelected: (selected) {
                  selected
                      ? draft.impactZones.add(zone)
                      : draft.impactZones.remove(zone);
                  onChanged();
                },
              ),
            )
            .toList(),
      ),
    ],
  );
}

class SignatureStep extends StatelessWidget {
  const SignatureStep({
    required this.draft,
    required this.onChanged,
    super.key,
  });
  final AccidentDraft draft;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      const Text('Relisez les informations puis signez dans les deux zones.'),
      const SizedBox(height: 16),
      SignatureBox(
        'Signature conducteur A',
        signed: draft.driverASigned,
        onTap: () {
          draft.driverASigned = !draft.driverASigned;
          onChanged();
        },
      ),
      const SizedBox(height: 14),
      SignatureBox(
        'Signature conducteur B',
        signed: draft.driverBSigned,
        onTap: () {
          draft.driverBSigned = !draft.driverBSigned;
          onChanged();
        },
      ),
      const SizedBox(height: 14),
      const Card(
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
