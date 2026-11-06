import 'package:flutter/material.dart';

import 'package:mon_constat_digital/core/theme/app_colors.dart';
import 'package:mon_constat_digital/modules/accident/models/accident_draft.dart';

class ContextStep extends StatelessWidget {
  const ContextStep({
    required this.draft,
    required this.place,
    required this.onChanged,
    super.key,
  });
  final AccidentDraft draft;
  final TextEditingController place;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const _SectionIntro(
        icon: Icons.location_on_outlined,
        title: 'Où et quand ?',
        text: 'Vérifiez les informations détectées automatiquement.',
      ),
      TextFormField(
        controller: place,
        onChanged: (value) {
          draft.place = value;
          onChanged();
        },
        validator: (value) => value == null || value.trim().length < 3
            ? 'Indiquez le lieu de l’accident'
            : null,
        decoration: InputDecoration(
          labelText: 'Lieu de l’accident',
          prefixIcon: const Icon(Icons.location_on_outlined),
          suffixIcon: IconButton(
            tooltip: 'Actualiser la position',
            onPressed: () {
              place.text = 'Position GPS détectée — Tunis';
              draft.place = place.text;
              onChanged();
            },
            icon: const Icon(Icons.my_location),
          ),
        ),
      ),
      const SizedBox(height: 12),
      InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () async {
          final date = await showDatePicker(
            context: context,
            initialDate: draft.occurredAt,
            firstDate: DateTime.now().subtract(const Duration(days: 7)),
            lastDate: DateTime.now(),
          );
          if (date == null || !context.mounted) return;
          final time = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.fromDateTime(draft.occurredAt),
          );
          if (time == null) return;
          draft.occurredAt = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
          onChanged();
        },
        child: InputDecorator(
          decoration: const InputDecoration(
            labelText: 'Date et heure',
            prefixIcon: Icon(Icons.schedule_outlined),
          ),
          child: Text(_dateTime(draft.occurredAt)),
        ),
      ),
      const SizedBox(height: 18),
      const Text('Météo', style: TextStyle(fontWeight: FontWeight.w800)),
      const SizedBox(height: 8),
      _Choices(
        values: const ['Ensoleillé', 'Pluie', 'Brouillard'],
        selected: draft.weather,
        onSelected: (value) {
          draft.weather = value;
          onChanged();
        },
      ),
      const SizedBox(height: 16),
      const Text('Chaussée', style: TextStyle(fontWeight: FontWeight.w800)),
      const SizedBox(height: 8),
      _Choices(
        values: const ['Sèche', 'Mouillée', 'Glissante'],
        selected: draft.road,
        onSelected: (value) {
          draft.road = value;
          onChanged();
        },
      ),
      const SizedBox(height: 16),
      DropdownButtonFormField<String>(
        initialValue: draft.light,
        items: const [
          'Jour',
          'Crépuscule',
          'Nuit éclairée',
          'Nuit sombre',
        ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: (value) {
          if (value == null) return;
          draft.light = value;
          onChanged();
        },
        decoration: const InputDecoration(
          labelText: 'Luminosité',
          prefixIcon: Icon(Icons.light_mode_outlined),
        ),
      ),
    ],
  );

  static String _dateTime(DateTime value) {
    String two(int number) => number.toString().padLeft(2, '0');
    return '${two(value.day)}/${two(value.month)}/${value.year} • '
        '${two(value.hour)}:${two(value.minute)}';
  }
}

class DescriptionStep extends StatelessWidget {
  const DescriptionStep({
    required this.draft,
    required this.witnessName,
    required this.witnessPhone,
    required this.onChanged,
    super.key,
  });
  final AccidentDraft draft;
  final TextEditingController witnessName, witnessPhone;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const _SectionIntro(
        icon: Icons.car_crash_outlined,
        title: 'Que s’est-il passé ?',
        text: 'Ces informations permettent de prioriser votre dossier.',
      ),
      DropdownButtonFormField<String>(
        initialValue: draft.type,
        items: const [
          'Collision',
          'Sortie de route',
          'Piéton',
          'Accident matériel',
          'Autre',
        ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: (value) {
          if (value == null) return;
          draft.type = value;
          onChanged();
        },
        decoration: const InputDecoration(labelText: "Type d'accident"),
      ),
      const SizedBox(height: 12),
      DropdownButtonFormField<String>(
        initialValue: draft.severity,
        items: const [
          'Matériel',
          'Léger',
          'Grave',
        ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: (value) {
          if (value == null) return;
          draft.severity = value;
          onChanged();
        },
        decoration: const InputDecoration(labelText: 'Gravité'),
      ),
      const SizedBox(height: 16),
      Row(
        children: [
          Expanded(
            child: _Counter(
              label: 'Véhicules',
              value: draft.vehicleCount,
              minimum: 1,
              onChanged: (value) {
                draft.vehicleCount = value;
                onChanged();
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _Counter(
              label: 'Blessés',
              value: draft.injuredCount,
              minimum: 0,
              onChanged: (value) {
                draft.injuredCount = value;
                onChanged();
              },
            ),
          ),
        ],
      ),
      if (draft.hasInjured) ...[
        const SizedBox(height: 14),
        Card(
          color: AppColors.errorBg,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sécurisez la zone et appelez les secours',
                  style: TextStyle(
                    color: AppColors.errorText,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: const [
                    _EmergencyChip('SAMU', '190'),
                    _EmergencyChip('Police', '197'),
                    _EmergencyChip('Protection civile', '198'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
      const SizedBox(height: 18),
      const Text(
        'Témoin (optionnel)',
        style: TextStyle(fontWeight: FontWeight.w800),
      ),
      const SizedBox(height: 8),
      TextField(
        controller: witnessName,
        onChanged: (value) {
          draft.witnessName = value;
          onChanged();
        },
        decoration: const InputDecoration(
          labelText: 'Nom du témoin',
          prefixIcon: Icon(Icons.person_outline),
        ),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: witnessPhone,
        keyboardType: TextInputType.phone,
        onChanged: (value) {
          draft.witnessPhone = value;
          onChanged();
        },
        decoration: const InputDecoration(
          labelText: 'Téléphone',
          prefixIcon: Icon(Icons.phone_outlined),
        ),
      ),
    ],
  );
}

class EvidenceStep extends StatelessWidget {
  const EvidenceStep({required this.draft, required this.onChanged, super.key});
  final AccidentDraft draft;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _SectionIntro(
        icon: Icons.add_a_photo_outlined,
        title: 'Photos guidées',
        text: '${draft.evidenceCount}/4 vues ajoutées • 2 minimum requises',
      ),
      ...draft.evidence.entries.map(
        (entry) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Card(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 6,
              ),
              leading: CircleAvatar(
                backgroundColor: entry.value
                    ? AppColors.successBg
                    : AppColors.primaryTint,
                child: Icon(
                  entry.value ? Icons.check : Icons.camera_alt_outlined,
                  color: entry.value
                      ? AppColors.successText
                      : AppColors.primary,
                ),
              ),
              title: Text(
                entry.key,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: Text(
                entry.value ? 'Photo ajoutée' : 'Touchez pour simuler la prise',
              ),
              trailing: Icon(
                entry.value ? Icons.refresh : Icons.add_circle_outline,
              ),
              onTap: () {
                draft.evidence[entry.key] = true;
                onChanged();
              },
            ),
          ),
        ),
      ),
      const SizedBox(height: 8),
      _MediaTile(
        icon: Icons.videocam_outlined,
        title: 'Vidéo de la scène',
        subtitle: draft.videoAdded
            ? 'Vidéo ajoutée • 18 s'
            : '30 secondes maximum',
        selected: draft.videoAdded,
        onTap: () {
          draft.videoAdded = !draft.videoAdded;
          onChanged();
        },
      ),
      _MediaTile(
        icon: Icons.mic_none_outlined,
        title: 'Note vocale',
        subtitle: draft.voiceNoteAdded
            ? 'Note ajoutée • 12 s'
            : 'Décrivez la scène avec votre voix',
        selected: draft.voiceNoteAdded,
        onTap: () {
          draft.voiceNoteAdded = !draft.voiceNoteAdded;
          onChanged();
        },
      ),
      const SizedBox(height: 16),
      AccidentSummary(draft: draft),
    ],
  );
}

class AccidentSummary extends StatelessWidget {
  const AccidentSummary({required this.draft, super.key});
  final AccidentDraft draft;
  @override
  Widget build(BuildContext context) => Card(
    color: AppColors.ink,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'RÉCAPITULATIF',
            style: TextStyle(
              color: AppColors.onDarkFaint,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            draft.type,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            draft.place,
            style: const TextStyle(color: AppColors.onDarkBody),
          ),
          const SizedBox(height: 8),
          Text(
            '${draft.weather} • ${draft.road} • ${draft.light}\n'
            '${draft.vehicleCount} véhicule(s) • ${draft.injuredCount} blessé(s) • '
            '${draft.evidenceCount} photo(s)',
            style: const TextStyle(color: AppColors.onDarkStrong, height: 1.5),
          ),
        ],
      ),
    ),
  );
}

class _Choices extends StatelessWidget {
  const _Choices({
    required this.values,
    required this.selected,
    required this.onSelected,
  });
  final List<String> values;
  final String selected;
  final ValueChanged<String> onSelected;
  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 8,
    runSpacing: 8,
    children: values
        .map(
          (value) => ChoiceChip(
            label: Text(value),
            selected: selected == value,
            onSelected: (_) => onSelected(value),
          ),
        )
        .toList(),
  );
}

class _Counter extends StatelessWidget {
  const _Counter({
    required this.label,
    required this.value,
    required this.minimum,
    required this.onChanged,
  });
  final String label;
  final int value, minimum;
  final ValueChanged<int> onChanged;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: value > minimum ? () => onChanged(value - 1) : null,
                icon: const Icon(Icons.remove_circle_outline),
              ),
              Text(
                '$value',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              IconButton(
                onPressed: value < 9 ? () => onChanged(value + 1) : null,
                icon: const Icon(Icons.add_circle_outline),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

class _EmergencyChip extends StatelessWidget {
  const _EmergencyChip(this.label, this.number);
  final String label, number;
  @override
  Widget build(BuildContext context) => ActionChip(
    avatar: const Icon(Icons.call, size: 17),
    label: Text('$label $number'),
    onPressed: () => ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Appel du $number'))),
  );
}

class _MediaTile extends StatelessWidget {
  const _MediaTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });
  final IconData icon;
  final String title, subtitle;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: Icon(
        icon,
        color: selected ? AppColors.successText : AppColors.primary,
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
      subtitle: Text(subtitle),
      trailing: Icon(selected ? Icons.check_circle : Icons.chevron_right),
      onTap: onTap,
    ),
  );
}

class _SectionIntro extends StatelessWidget {
  const _SectionIntro({
    required this.icon,
    required this.title,
    required this.text,
  });
  final IconData icon;
  final String title, text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 18),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primaryTint,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 3),
              Text(text, style: const TextStyle(color: AppColors.textMuted)),
            ],
          ),
        ),
      ],
    ),
  );
}
