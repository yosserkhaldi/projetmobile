import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:mon_constat_digital/core/theme/app_palette.dart';
import 'package:video_player/video_player.dart';

import 'package:mon_constat_digital/core/theme/app_colors.dart';
import 'package:mon_constat_digital/modules/accident/models/accident_draft.dart';
import 'package:mon_constat_digital/modules/accident/screens/location_picker_screen.dart';
import 'package:mon_constat_digital/modules/accident/services/accident_location_service.dart';
import 'package:mon_constat_digital/modules/accident/services/accident_media_service.dart';

class ContextStep extends StatefulWidget {
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
  State<ContextStep> createState() => _ContextStepState();
}

class _ContextStepState extends State<ContextStep> {
  final _locationService = AccidentLocationService();
  bool _locating = false;
  String? _locationError;

  @override
  void initState() {
    super.initState();
    if (widget.draft.latitude == null &&
        !Platform.environment.containsKey('FLUTTER_TEST')) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _detectAndAsk());
    }
  }

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
        controller: widget.place,
        onChanged: (value) {
          widget.draft.place = value;
          widget.onChanged();
        },
        validator: (value) => value == null || value.trim().length < 3
            ? 'Indiquez le lieu de l’accident'
            : null,
        decoration: InputDecoration(
          labelText: 'Lieu de l’accident',
          prefixIcon: const Icon(Icons.location_on_outlined),
          suffixIcon: IconButton(
            tooltip: 'Choisir sur la carte',
            onPressed: _locating ? null : _chooseLocation,
            icon: _locating
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.my_location),
          ),
        ),
      ),
      if (_locationError != null)
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.error_outline, color: AppColors.errorSolid),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _locationError!,
                  style: TextStyle(color: context.palette.errorText),
                ),
              ),
            ],
          ),
        ),
      if (widget.draft.latitude != null)
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            'GPS ${widget.draft.latitude!.toStringAsFixed(6)}, '
            '${widget.draft.longitude!.toStringAsFixed(6)} • '
            'précision ±${(widget.draft.locationAccuracy ?? 0).round()} m',
            style: TextStyle(
              color: context.palette.successText,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      const SizedBox(height: 12),
      InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () async {
          final date = await showDatePicker(
            context: context,
            initialDate: widget.draft.occurredAt,
            firstDate: DateTime.now().subtract(const Duration(days: 7)),
            lastDate: DateTime.now(),
          );
          if (date == null || !context.mounted) return;
          final time = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.fromDateTime(widget.draft.occurredAt),
          );
          if (time == null) return;
          widget.draft.occurredAt = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
          widget.onChanged();
        },
        child: InputDecorator(
          decoration: const InputDecoration(
            labelText: 'Date et heure',
            prefixIcon: Icon(Icons.schedule_outlined),
          ),
          child: Text(_dateTime(widget.draft.occurredAt)),
        ),
      ),
      const SizedBox(height: 18),
      const Text('Météo', style: TextStyle(fontWeight: FontWeight.w800)),
      const SizedBox(height: 8),
      _Choices(
        values: const ['Ensoleillé', 'Pluie', 'Brouillard'],
        selected: widget.draft.weather,
        onSelected: (value) {
          widget.draft.weather = value;
          widget.onChanged();
        },
      ),
      const SizedBox(height: 16),
      const Text('Chaussée', style: TextStyle(fontWeight: FontWeight.w800)),
      const SizedBox(height: 8),
      _Choices(
        values: const ['Sèche', 'Mouillée', 'Glissante'],
        selected: widget.draft.road,
        onSelected: (value) {
          widget.draft.road = value;
          widget.onChanged();
        },
      ),
      const SizedBox(height: 16),
      DropdownButtonFormField<String>(
        initialValue: widget.draft.light,
        items: const [
          'Jour',
          'Crépuscule',
          'Nuit éclairée',
          'Nuit sombre',
        ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: (value) {
          if (value == null) return;
          widget.draft.light = value;
          widget.onChanged();
        },
        decoration: const InputDecoration(
          labelText: 'Luminosité',
          prefixIcon: Icon(Icons.light_mode_outlined),
        ),
      ),
    ],
  );

  Future<void> _chooseLocation() async {
    setState(() {
      _locating = true;
      _locationError = null;
    });
    try {
      final location = await Navigator.push<AccidentLocation>(
        context,
        MaterialPageRoute(
          builder: (_) => LocationPickerScreen(
            initialLatitude: widget.draft.latitude,
            initialLongitude: widget.draft.longitude,
            initialLabel: widget.draft.place,
          ),
        ),
      );
      if (location == null) return;
      if (!mounted) return;
      _applyLocation(location);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lieu de l’accident confirmé et sauvegardé.'),
        ),
      );
    } on AccidentLocationException catch (error) {
      if (mounted) setState(() => _locationError = error.message);
    } catch (_) {
      if (mounted) {
        setState(() {
          _locationError = 'Position indisponible. Réessayez dans un instant.';
        });
      }
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  Future<void> _detectAndAsk() async {
    if (_locating || !mounted) return;
    setState(() {
      _locating = true;
      _locationError = null;
    });
    try {
      final detected = await _locationService.determineLocation();
      if (!mounted) return;
      final useDetected = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          icon: Icon(Icons.my_location, color: context.palette.primaryText),
          title: const Text('Position détectée'),
          content: Text(
            '${detected.label}\n\nVoulez-vous utiliser cette localisation ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Choisir une autre'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Utiliser cette position'),
            ),
          ],
        ),
      );
      if (!mounted) return;
      if (useDetected ?? false) {
        _applyLocation(detected);
      } else {
        final selected = await Navigator.push<AccidentLocation>(
          context,
          MaterialPageRoute(
            builder: (_) => LocationPickerScreen(
              initialLatitude: detected.latitude,
              initialLongitude: detected.longitude,
              initialLabel: detected.label,
            ),
          ),
        );
        if (selected != null && mounted) _applyLocation(selected);
      }
    } on AccidentLocationException catch (error) {
      if (mounted) setState(() => _locationError = error.message);
    } catch (_) {
      if (mounted) {
        setState(() => _locationError = 'Localisation automatique impossible.');
      }
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  void _applyLocation(AccidentLocation location) {
    widget.place.text = location.label;
    widget.draft
      ..place = location.label
      ..latitude = location.latitude
      ..longitude = location.longitude
      ..locationAccuracy = location.accuracy;
    widget.onChanged();
  }

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
          color: context.palette.errorBg,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sécurisez la zone et appelez les secours',
                  style: TextStyle(
                    color: context.palette.errorText,
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

class EvidenceStep extends StatefulWidget {
  const EvidenceStep({required this.draft, required this.onChanged, super.key});
  final AccidentDraft draft;
  final VoidCallback onChanged;

  @override
  State<EvidenceStep> createState() => _EvidenceStepState();
}

class _EvidenceStepState extends State<EvidenceStep> {
  final _media = AccidentMediaService();
  final _voiceRecorder = AccidentVoiceRecorder();
  final _audioPlayer = AudioPlayer();
  bool _recording = false;
  bool _capturingVideo = false;

  AccidentDraft get draft => widget.draft;
  VoidCallback get onChanged => widget.onChanged;

  @override
  void dispose() {
    _voiceRecorder.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

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
                    ? context.palette.successBg
                    : context.palette.primaryTint,
                backgroundImage: draft.evidencePaths[entry.key] != null
                    ? FileImage(File(draft.evidencePaths[entry.key]!))
                    : null,
                child: draft.evidencePaths[entry.key] == null
                    ? Icon(
                        entry.value ? Icons.check : Icons.camera_alt_outlined,
                        color: entry.value
                            ? context.palette.successText
                            : context.palette.primaryText,
                      )
                    : null,
              ),
              title: Text(
                entry.key,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: Text(
                entry.value
                    ? 'Photo enregistrée • touchez pour reprendre'
                    : 'Touchez pour ouvrir la caméra',
              ),
              trailing: Icon(
                entry.value ? Icons.refresh : Icons.add_circle_outline,
              ),
              onTap: () async {
                final photoPath = await _media.capturePhoto(entry.key);
                if (photoPath == null) return;
                draft.evidencePaths[entry.key] = photoPath;
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
        subtitle: _capturingVideo
            ? 'Ouverture de la caméra…'
            : draft.videoAdded
            ? 'Vidéo enregistrée • touchez pour la lire'
            : 'Filmez la scène • 30 secondes maximum',
        selected: draft.videoAdded,
        onTap: _capturingVideo
            ? null
            : draft.videoAdded
            ? _showVideoActions
            : _captureVideo,
      ),
      _MediaTile(
        icon: _recording ? Icons.stop_circle_outlined : Icons.mic_none_outlined,
        title: _recording ? 'Arrêter l’enregistrement' : 'Note vocale',
        subtitle: _recording
            ? 'Enregistrement en cours… touchez pour arrêter'
            : draft.voiceNoteAdded
            ? 'Note enregistrée • touchez pour écouter'
            : 'Décrivez la scène avec votre voix',
        selected: draft.voiceNoteAdded,
        active: _recording,
        onTap: _recording
            ? _stopRecording
            : draft.voiceNoteAdded
            ? _showAudioActions
            : _startRecording,
      ),
      const SizedBox(height: 16),
      AccidentSummary(draft: draft),
    ],
  );

  Future<void> _captureVideo() async {
    setState(() => _capturingVideo = true);
    try {
      final savedPath = await _media.captureVideo();
      if (savedPath == null || !mounted) return;
      draft
        ..videoPath = savedPath
        ..videoAdded = true;
      onChanged();
      setState(() {});
    } catch (_) {
      if (mounted) _message('Impossible d’enregistrer la vidéo.');
    } finally {
      if (mounted) setState(() => _capturingVideo = false);
    }
  }

  Future<void> _startRecording() async {
    try {
      final destination = await _media.voiceNoteDestination();
      final allowed = await _voiceRecorder.start(destination);
      if (!mounted) return;
      if (!allowed) {
        _message('Autorisez le microphone pour enregistrer une note vocale.');
        return;
      }
      draft.voiceNotePath = destination;
      setState(() => _recording = true);
    } catch (_) {
      if (mounted) _message('Impossible de démarrer le microphone.');
    }
  }

  Future<void> _stopRecording() async {
    final savedPath = await _voiceRecorder.stop();
    if (!mounted) return;
    draft
      ..voiceNotePath = savedPath ?? draft.voiceNotePath
      ..voiceNoteAdded = savedPath != null;
    onChanged();
    setState(() => _recording = false);
  }

  Future<void> _showVideoActions() async {
    final file = File(draft.videoPath);
    if (draft.videoPath.isEmpty || !await file.exists()) {
      _clearVideo();
      _message('La vidéo n’existe plus. Vous pouvez la reprendre.');
      return;
    }
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (_) =>
          _VideoPreviewDialog(path: draft.videoPath, onDelete: _clearVideo),
    );
  }

  Future<void> _showAudioActions() async {
    final file = File(draft.voiceNotePath);
    if (draft.voiceNotePath.isEmpty || !await file.exists()) {
      _clearAudio();
      _message('La note vocale n’existe plus. Vous pouvez la refaire.');
      return;
    }
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Note vocale',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 14),
              ListTile(
                leading: const Icon(Icons.play_circle_outline),
                title: const Text('Écouter'),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  await _audioPlayer.play(
                    DeviceFileSource(draft.voiceNotePath),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.refresh),
                title: const Text('Refaire l’enregistrement'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _clearAudio();
                  _startRecording();
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.delete_outline,
                  color: AppColors.errorSolid,
                ),
                title: const Text('Supprimer'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _clearAudio();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _clearVideo() {
    if (draft.videoPath.isNotEmpty) File(draft.videoPath).delete().ignore();
    draft
      ..videoPath = ''
      ..videoAdded = false;
    onChanged();
    if (mounted) setState(() {});
  }

  void _clearAudio() {
    _audioPlayer.stop();
    if (draft.voiceNotePath.isNotEmpty) {
      File(draft.voiceNotePath).delete().ignore();
    }
    draft
      ..voiceNotePath = ''
      ..voiceNoteAdded = false;
    onChanged();
    if (mounted) setState(() {});
  }

  void _message(String text) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text)));
}

class _VideoPreviewDialog extends StatefulWidget {
  const _VideoPreviewDialog({required this.path, required this.onDelete});
  final String path;
  final VoidCallback onDelete;

  @override
  State<_VideoPreviewDialog> createState() => _VideoPreviewDialogState();
}

class _VideoPreviewDialogState extends State<_VideoPreviewDialog> {
  late final VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.path))
      ..initialize().then((_) {
        if (mounted) setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Vidéo de la scène'),
    content: _controller.value.isInitialized
        ? AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          )
        : const SizedBox(
            height: 180,
            child: Center(child: CircularProgressIndicator()),
          ),
    actions: [
      TextButton.icon(
        onPressed: () {
          widget.onDelete();
          Navigator.pop(context);
        },
        icon: const Icon(Icons.delete_outline),
        label: const Text('Supprimer'),
      ),
      FilledButton.icon(
        onPressed: _controller.value.isInitialized
            ? () {
                setState(() {
                  _controller.value.isPlaying
                      ? _controller.pause()
                      : _controller.play();
                });
              }
            : null,
        icon: Icon(
          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
        label: Text(_controller.value.isPlaying ? 'Pause' : 'Lire'),
      ),
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
    this.active = false,
  });
  final IconData icon;
  final String title, subtitle;
  final bool selected;
  final bool active;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: Icon(
        icon,
        color: active
            ? AppColors.errorSolid
            : selected
            ? context.palette.successText
            : context.palette.primaryText,
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
      subtitle: Text(subtitle),
      trailing: Icon(
        active
            ? Icons.stop_circle
            : selected
            ? Icons.check_circle
            : Icons.chevron_right,
      ),
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
            color: context.palette.primaryTint,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: context.palette.primaryText),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 3),
              Text(text, style: TextStyle(color: context.palette.textMuted)),
            ],
          ),
        ),
      ],
    ),
  );
}
