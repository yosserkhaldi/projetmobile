import 'dart:io';

import 'package:flutter/material.dart';

import 'package:mon_constat_digital/core/theme/app_colors.dart';
import 'package:mon_constat_digital/modules/accident/models/accident_draft.dart';
import 'package:mon_constat_digital/shared/widgets/drawing_pad.dart';

class AccidentReview extends StatelessWidget {
  const AccidentReview({required this.draft, super.key});
  final AccidentDraft draft;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Divider(height: 32),
      Text('Constat complété', style: Theme.of(context).textTheme.titleLarge),
      const Text(
        'Vérifiez toutes les informations avant la transmission.',
        style: TextStyle(color: AppColors.textMuted),
      ),
      const SizedBox(height: 14),
      _Section(
        title: 'Accident',
        icon: Icons.car_crash_outlined,
        rows: [
          ('Lieu', draft.place),
          ('Date et heure', _dateTime(draft.occurredAt)),
          ('Type', '${draft.type} • ${draft.severity}'),
          ('Conditions', '${draft.weather} • ${draft.road} • ${draft.light}'),
          (
            'Véhicules / blessés',
            '${draft.vehicleCount} véhicule(s) • ${draft.injuredCount} blessé(s)',
          ),
          if (draft.witnessName.isNotEmpty)
            ('Témoin', '${draft.witnessName} ${draft.witnessPhone}'),
        ],
      ),
      _Section(
        title: 'Conducteur B',
        icon: Icons.person_outline,
        rows: [
          ('Nom', draft.driverBName),
          if (draft.driverBPermit.isNotEmpty) ('Permis', draft.driverBPermit),
          ('Immatriculation', draft.driverBPlate),
          ('Assurance', draft.driverBInsurer),
        ],
      ),
      _Section(
        title: 'Circonstances',
        icon: Icons.fact_check_outlined,
        rows: [
          ('Sélection', draft.circumstances.join(', ')),
          if (draft.observations.isNotEmpty)
            ('Observations', draft.observations),
          ('Zones de choc', draft.impactZones.join(', ')),
        ],
      ),
      const _ReviewTitle('Photos'),
      _PhotoGrid(draft: draft),
      const SizedBox(height: 16),
      const _ReviewTitle('Croquis'),
      DrawingPreview(
        strokes: draft.sketchStrokes,
        height: 160,
        emptyLabel: 'Croquis manquant',
      ),
      const SizedBox(height: 16),
      const _ReviewTitle('Signatures'),
      Row(
        children: [
          Expanded(
            child: Column(
              children: [
                const Text('Conducteur A'),
                const SizedBox(height: 5),
                DrawingPreview(strokes: draft.driverASignature),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              children: [
                const Text('Conducteur B'),
                const SizedBox(height: 5),
                DrawingPreview(strokes: draft.driverBSignature),
              ],
            ),
          ),
        ],
      ),
    ],
  );

  static String _dateTime(DateTime value) =>
      '${value.day.toString().padLeft(2, '0')}/'
      '${value.month.toString().padLeft(2, '0')}/${value.year} '
      '${value.hour.toString().padLeft(2, '0')}:'
      '${value.minute.toString().padLeft(2, '0')}';
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.icon, required this.rows});
  final String title;
  final IconData icon;
  final List<(String, String)> rows;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 12),
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
            ],
          ),
          const Divider(height: 20),
          for (final row in rows)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 105,
                    child: Text(
                      row.$1,
                      style: const TextStyle(color: AppColors.textMuted),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      row.$2.isEmpty ? 'Non renseigné' : row.$2,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    ),
  );
}

class _ReviewTitle extends StatelessWidget {
  const _ReviewTitle(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.w900)),
  );
}

class _PhotoGrid extends StatelessWidget {
  const _PhotoGrid({required this.draft});
  final AccidentDraft draft;

  @override
  Widget build(BuildContext context) {
    final photos = draft.evidencePaths.entries
        .where(
          (entry) => entry.value != null && File(entry.value!).existsSync(),
        )
        .toList();
    if (photos.isEmpty) return const Text('Aucune photo enregistrée.');
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: photos.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (context, index) => ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.file(File(photos[index].value!), fit: BoxFit.cover),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                color: Colors.black54,
                padding: const EdgeInsets.all(6),
                child: Text(
                  photos[index].key,
                  style: const TextStyle(color: Colors.white, fontSize: 11),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
