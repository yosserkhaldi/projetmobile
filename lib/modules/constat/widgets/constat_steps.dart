import 'package:flutter/material.dart';

import 'package:mon_constat_digital/core/theme/app_colors.dart';
import 'package:mon_constat_digital/modules/accident/models/accident_draft.dart';
import 'package:mon_constat_digital/modules/accident/widgets/accident_review.dart';
import 'package:mon_constat_digital/modules/constat/widgets/signature_box.dart';
import 'package:mon_constat_digital/shared/widgets/drawing_pad.dart';

class GuestDriverStep extends StatelessWidget {
  const GuestDriverStep({
    required this.draft,
    required this.onChanged,
    super.key,
  });
  final AccidentDraft draft;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Card(
        color: AppColors.primaryTint,
        child: ListTile(
          leading: Icon(Icons.screen_lock_portrait),
          title: Text('Informations du conducteur B'),
          subtitle: Text(
            'Données nécessaires au constat, isolées de votre profil.',
          ),
        ),
      ),
      const SizedBox(height: 10),
      _DriverField(
        initialValue: draft.driverBName,
        label: 'Nom complet *',
        icon: Icons.person_outline,
        onChanged: (value) {
          draft.driverBName = value;
          onChanged();
        },
      ),
      const SizedBox(height: 12),
      _DriverField(
        initialValue: draft.driverBPermit,
        label: 'Numéro de permis',
        icon: Icons.badge_outlined,
        onChanged: (value) {
          draft.driverBPermit = value;
          onChanged();
        },
      ),
      const SizedBox(height: 12),
      _DriverField(
        initialValue: draft.driverBPlate,
        label: 'Immatriculation *',
        icon: Icons.directions_car_outlined,
        capitalization: TextCapitalization.characters,
        onChanged: (value) {
          draft.driverBPlate = value;
          onChanged();
        },
      ),
      const SizedBox(height: 18),
      const Text(
        'ASSURANCE',
        style: TextStyle(
          color: AppColors.textMuted,
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: .5,
        ),
      ),
      const SizedBox(height: 8),
      _DriverField(
        initialValue: draft.driverBInsurer,
        label: 'Compagnie d’assurance *',
        icon: Icons.shield_outlined,
        onChanged: (value) {
          draft.driverBInsurer = value;
          onChanged();
        },
      ),
      const SizedBox(height: 16),
      SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Le partage sécurisé par QR code sera ajouté ultérieurement.',
              ),
            ),
          ),
          icon: const Icon(Icons.qr_code_scanner),
          label: const Text('Remplir ensemble par QR code'),
        ),
      ),
    ],
  );
}

class _DriverField extends StatelessWidget {
  const _DriverField({
    required this.initialValue,
    required this.label,
    required this.icon,
    required this.onChanged,
    this.capitalization = TextCapitalization.none,
  });
  final String initialValue, label;
  final IconData icon;
  final ValueChanged<String> onChanged;
  final TextCapitalization capitalization;

  @override
  Widget build(BuildContext context) => TextFormField(
    initialValue: initialValue,
    textCapitalization: capitalization,
    onChanged: onChanged,
    decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
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
      DrawingPad(
        strokes: draft.sketchStrokes,
        hint: 'Dessinez les voies, les véhicules et leur direction',
        onChanged: () {
          draft.sketchConfirmed = draft.sketchStrokes.isNotEmpty;
          onChanged();
        },
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
        strokes: draft.driverASignature,
        onChanged: () {
          draft.driverASigned = draft.driverASignature.isNotEmpty;
          onChanged();
        },
      ),
      const SizedBox(height: 14),
      SignatureBox(
        'Signature conducteur B',
        strokes: draft.driverBSignature,
        onChanged: () {
          draft.driverBSigned = draft.driverBSignature.isNotEmpty;
          onChanged();
        },
      ),
      const SizedBox(height: 14),
      AccidentReview(draft: draft),
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
