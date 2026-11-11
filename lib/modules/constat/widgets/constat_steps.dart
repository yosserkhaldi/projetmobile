import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mon_constat_digital/core/network/api_client.dart';
import 'package:mon_constat_digital/core/state/app_scope.dart';
import 'package:mon_constat_digital/core/theme/app_palette.dart';

import 'package:mon_constat_digital/core/theme/app_colors.dart';
import 'package:mon_constat_digital/modules/accident/models/accident_draft.dart';
import 'package:mon_constat_digital/modules/accident/services/accident_media_service.dart';
import 'package:mon_constat_digital/modules/accident/services/accident_pdf_service.dart';
import 'package:mon_constat_digital/modules/accident/services/driving_license_ocr_service.dart';
import 'package:mon_constat_digital/modules/accident/widgets/accident_review.dart';
import 'package:mon_constat_digital/modules/constat/widgets/signature_box.dart';
import 'package:mon_constat_digital/modules/users/widgets/company_picker.dart';
import 'package:mon_constat_digital/shared/widgets/drawing_pad.dart';

class GuestDriverStep extends StatefulWidget {
  const GuestDriverStep({
    required this.draft,
    required this.onChanged,
    super.key,
  });
  final AccidentDraft draft;
  final VoidCallback onChanged;

  @override
  State<GuestDriverStep> createState() => _GuestDriverStepState();
}

class _GuestDriverStepState extends State<GuestDriverStep> {
  final _media = AccidentMediaService();
  final _ocr = DrivingLicenseOcrService();
  bool _scanning = false;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Card(
        color: context.palette.primaryTint,
        child: ListTile(
          leading: Icon(Icons.screen_lock_portrait),
          title: Text('Informations du conducteur B'),
          subtitle: Text(
            'Données nécessaires au constat, isolées de votre profil.',
          ),
        ),
      ),
      const SizedBox(height: 10),
      Card(
        color: context.palette.successBg,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.document_scanner_outlined,
                    color: context.palette.successText,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Scanner le permis avec l’IA',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                'La photo est analysée localement. Vérifiez toujours les données détectées.',
                style: TextStyle(color: context.palette.textMuted),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _scanning ? null : _scanLicense,
                  icon: _scanning
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.camera_alt_outlined),
                  label: Text(
                    _scanning ? 'Analyse en cours…' : 'Photographier le permis',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 12),
      _DriverField(
        initialValue: widget.draft.driverBName,
        label: 'Nom complet *',
        icon: Icons.person_outline,
        onChanged: (value) {
          widget.draft.driverBName = value;
          widget.onChanged();
        },
      ),
      const SizedBox(height: 12),
      _DriverField(
        initialValue: widget.draft.driverBPermit,
        label: 'Numéro de permis',
        icon: Icons.badge_outlined,
        onChanged: (value) {
          widget.draft.driverBPermit = value;
          widget.onChanged();
        },
      ),
      const SizedBox(height: 12),
      DateField(
        key: const ValueKey('driver-b-permit-expiry'),
        value: widget.draft.driverBPermitExpiry,
        label: 'Date de validité du permis',
        onChanged: (value) {
          widget.draft.driverBPermitExpiry = value;
          widget.onChanged();
          setState(() {});
        },
      ),
      const SizedBox(height: 12),
      _DriverField(
        initialValue: widget.draft.driverBPlate,
        label: 'Immatriculation *',
        icon: Icons.directions_car_outlined,
        capitalization: TextCapitalization.characters,
        onChanged: (value) {
          widget.draft.driverBPlate = value;
          widget.onChanged();
        },
      ),
      const SizedBox(height: 18),
      Text(
        'ASSURANCE',
        style: TextStyle(
          color: context.palette.textMuted,
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: .5,
        ),
      ),
      const SizedBox(height: 8),
      // Selection via CompanyPicker (module 1 - Iheb) pour obtenir un UUID
      // companyBId transmis au backend : permet aux agents de la compagnie B
      // de recevoir le sinistre automatiquement.
      CompanyPicker(
        companyId: widget.draft.driverBCompanyId,
        withAgency: false,
        required: false,
        onChanged: (company, _) {
          widget.draft.driverBCompanyId = company?.id;
          // On garde aussi le nom lisible dans driverBInsurer pour l'affichage
          widget.draft.driverBInsurer = company?.name ?? '';
          widget.onChanged();
        },
      ),
      const SizedBox(height: 12),
      _DriverField(
        initialValue: widget.draft.driverBPolicy,
        label: 'N° de police / attestation d’assurance',
        icon: Icons.verified_user_outlined,
        capitalization: TextCapitalization.characters,
        onChanged: (value) {
          widget.draft.driverBPolicy = value;
          widget.onChanged();
        },
      ),
    ],
  );

  Future<void> _scanLicense() async {
    setState(() => _scanning = true);
    try {
      final path = await _media.capturePhoto('permis_conducteur_b');
      if (path == null || !mounted) return;
      final data = await _read(path);
      if (data == null || !mounted) return;
      if (data.rawText.isEmpty) {
        _message(
          'Aucun texte détecté. Reprenez la photo avec plus de lumière.',
        );
        return;
      }
      final confirmed = await showDialog<DrivingLicenseData>(
        context: context,
        builder: (_) => _LicenseReviewDialog(data: data),
      );
      if (confirmed == null || !mounted) return;
      widget.draft
        ..driverBName = confirmed.fullName
        ..driverBPermit = confirmed.licenseNumber
        ..driverBPermitExpiry = confirmed.expiryDate;
      widget.onChanged();
      setState(() {});
      _message('Permis analysé. Vérifiez les champs avant de continuer.');
    } catch (_) {
      if (mounted) {
        _message('Analyse impossible. Vérifiez la photo et réessayez.');
      }
    } finally {
      if (mounted) setState(() => _scanning = false);
    }
  }

  /// Lecture par l'IA du serveur, la même que pour le permis du profil.
  /// Hors ligne : la lecture du téléphone (ML Kit), moins précise. null si
  /// la photo est refusée (message affiché).
  Future<DrivingLicenseData?> _read(String path) async {
    final api = AppScope.of(context).api;
    final bytes = await File(path).readAsBytes();
    try {
      final body =
          await api.upload(
                '/accidents/license-scan',
                method: 'POST',
                field: 'photo',
                bytes: bytes,
                filename: 'permis.jpg',
              )
              as Map<String, dynamic>;
      final license = body['license'] as Map<String, dynamic>;
      final name = [license['firstName'], license['lastName']]
          .whereType<String>()
          .where((part) => part.trim().isNotEmpty)
          .join(' ');
      return DrivingLicenseData(
        fullName: name,
        licenseNumber: license['number'] as String? ?? '',
        expiryDate: DateField.normalize(license['expiresAt'] as String? ?? ''),
        rawText: '',
      );
    } on ApiException catch (error) {
      if (!error.isNetwork) {
        _message(error.message);
        return null;
      }
      return _ocr.scan(path);
    }
  }

  void _message(String text) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text)));
}

class _LicenseReviewDialog extends StatefulWidget {
  const _LicenseReviewDialog({required this.data});
  final DrivingLicenseData data;

  @override
  State<_LicenseReviewDialog> createState() => _LicenseReviewDialogState();
}

class _LicenseReviewDialogState extends State<_LicenseReviewDialog> {
  late final TextEditingController _name;
  late final TextEditingController _number;
  // Date lue par l'OCR, gardée seulement si c'est une vraie date.
  late String _expiry = DateField.normalize(widget.data.expiryDate);

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.data.fullName);
    _number = TextEditingController(text: widget.data.licenseNumber);
  }

  @override
  void dispose() {
    _name.dispose();
    _number.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Vérifier les données détectées'),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'L’OCR peut faire des erreurs. Corrigez les champs avant confirmation.',
            style: TextStyle(color: context.palette.textMuted),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'Nom complet'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _number,
            decoration: const InputDecoration(labelText: 'Numéro du permis'),
          ),
          const SizedBox(height: 10),
          DateField(
            value: _expiry,
            label: 'Date de validité',
            onChanged: (value) => setState(() => _expiry = value),
          ),
          const SizedBox(height: 12),
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: const Text('Texte reconnu par ML Kit'),
            children: [
              SelectableText(
                widget.data.rawText,
                style: TextStyle(
                  fontSize: 12,
                  color: context.palette.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Annuler'),
      ),
      FilledButton(
        onPressed: () => Navigator.pop(
          context,
          DrivingLicenseData(
            fullName: _name.text.trim(),
            licenseNumber: _number.text.trim(),
            expiryDate: _expiry,
            rawText: widget.data.rawText,
          ),
        ),
        child: const Text('Utiliser ces données'),
      ),
    ],
  );
}

/// Date choisie dans un calendrier (JJ/MM/AAAA) : on ne peut plus y taper
/// n'importe quoi.
class DateField extends StatelessWidget {
  const DateField({
    required this.value,
    required this.label,
    required this.onChanged,
    super.key,
  });

  /// Date au format JJ/MM/AAAA, ou vide.
  final String value;
  final String label;
  final ValueChanged<String> onChanged;

  /// « 2031-05-12 », « 12-05-2031 », « 12.05.2031 » → « 12/05/2031 » ; vide
  /// si ce n'est pas une date (texte mal lu par l'OCR).
  static String normalize(String raw) {
    final text = raw.trim();
    final iso = RegExp(r'^(\d{4})[-/.](\d{1,2})[-/.](\d{1,2})$').firstMatch(text);
    final local = RegExp(r'^(\d{1,2})[-/.](\d{1,2})[-/.](\d{4})$').firstMatch(text);
    final (day, month, year) = iso != null
        ? (iso[3]!, iso[2]!, iso[1]!)
        : local != null
        ? (local[1]!, local[2]!, local[3]!)
        : ('', '', '');
    final date = DateTime.tryParse(
      '$year-${month.padLeft(2, '0')}-${day.padLeft(2, '0')}',
    );
    if (date == null || date.day != int.parse(day)) return '';
    return format(date);
  }

  static String format(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/${date.year}';

  static DateTime? parse(String value) {
    final parts = value.split('/');
    if (parts.length != 3) return null;
    return DateTime.tryParse(
      '${parts[2]}-${parts[1].padLeft(2, '0')}-${parts[0].padLeft(2, '0')}',
    );
  }

  Future<void> _pick(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: parse(value) ?? now,
      firstDate: DateTime(1990),
      lastDate: DateTime(now.year + 30),
      helpText: label,
    );
    if (picked != null) onChanged(format(picked));
  }

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () => _pick(context),
    borderRadius: BorderRadius.circular(12),
    child: InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.event_available_outlined),
        suffixIcon: value.isEmpty
            ? const Icon(Icons.calendar_month_outlined)
            : IconButton(
                tooltip: 'Effacer la date',
                icon: const Icon(Icons.close),
                onPressed: () => onChanged(''),
              ),
      ),
      isEmpty: value.isEmpty,
      child: Text(value),
    ),
  );
}

class _DriverField extends StatefulWidget {
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
  State<_DriverField> createState() => _DriverFieldState();
}

class _DriverFieldState extends State<_DriverField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(covariant _DriverField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.initialValue,
        selection: TextSelection.collapsed(offset: widget.initialValue.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: _controller,
    textCapitalization: widget.capitalization,
    textInputAction: TextInputAction.next,
    onChanged: widget.onChanged,
    decoration: InputDecoration(
      labelText: widget.label,
      prefixIcon: Icon(widget.icon),
    ),
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
    '1 - En stationnement / À l’arrêt',
    '2 - Quittait un stationnement / ouvrait une portière',
    '3 - Prenait un stationnement',
    '4 - Sortait d’un parking, lieu privé ou chemin',
    '5 - S’engageait dans un parking, lieu privé ou chemin',
    '6 - S’engageait sur une place à sens giratoire',
    '7 - Circulait sur une place à sens giratoire',
    '8 - Heurtait à l’arrière (même sens, même file)',
    '9 - Roulait dans le même sens sur une file différente',
    '10 - Changeait de file',
    '11 - Doublait',
    '12 - Virait à droite',
    '13 - Virait à gauche',
    '14 - Reculait',
    '15 - Empiétait sur la chaussée en sens inverse',
    '16 - Venait de droite (dans un carrefour)',
    '17 - N’avait pas observé un signal de priorité',
  ];

  bool _isSelected(Set<String> selected, int index, String fullLabel) {
    if (selected.contains(fullLabel)) return true;
    final prefix = '${index + 1} - ';
    final shortText = fullLabel.substring(prefix.length).toLowerCase();
    for (final entry in selected) {
      final norm = entry.trim().toLowerCase();
      if (norm.startsWith('${index + 1} ') || norm.startsWith('${index + 1}-')) {
        return true;
      }
      if (shortText.startsWith(norm) && norm.length >= 6) return true;
    }
    return false;
  }

  void _toggle(Set<String> target, int index, String fullLabel, bool checked) {
    final prefix = '${index + 1} ';
    final shortText = fullLabel.substring('${index + 1} - '.length).toLowerCase();
    target.removeWhere((entry) {
      final norm = entry.trim().toLowerCase();
      return entry == fullLabel ||
          norm.startsWith(prefix) ||
          norm.startsWith('${index + 1}-') ||
          (shortText.startsWith(norm) && norm.length >= 6);
    });
    if (checked) {
      target.add(fullLabel);
    }
    onChanged();
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Circonstances de l’accident (FTUSA)',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
      ),
      const SizedBox(height: 4),
      Text(
        'Cochez la ou les cases utiles pour le véhicule A (bleu) et le véhicule B (ambre).',
        style: TextStyle(color: context.palette.textMuted),
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: context.palette.primaryTint,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Véhicule A : ${draft.circumstancesA.length} case(s)',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: context.palette.primaryText,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: context.palette.warningBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Véhicule B : ${draft.circumstancesB.length} case(s)',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: context.palette.warningText,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 10),
      Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Container(
              color: context.palette.hero,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: const Row(
                children: [
                  SizedBox(
                    width: 42,
                    child: Text(
                      'A',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF93C5FD),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '12. Circonstances',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 42,
                    child: Text(
                      'B',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFFFCD34D),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            for (int i = 0; i < choices.length; i++) ...[
              if (i > 0) const Divider(height: 1),
              Container(
                color: (_isSelected(draft.circumstancesA, i, choices[i]) ||
                        _isSelected(draft.circumstancesB, i, choices[i]))
                    ? context.palette.primaryTint.withAlpha(70)
                    : null,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Row(
                  children: [
                    Checkbox(
                      value: _isSelected(draft.circumstancesA, i, choices[i]),
                      activeColor: context.palette.primaryText,
                      onChanged: (selected) => _toggle(
                        draft.circumstancesA,
                        i,
                        choices[i],
                        selected ?? false,
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          choices[i],
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    Checkbox(
                      value: _isSelected(draft.circumstancesB, i, choices[i]),
                      activeColor: AppColors.accent,
                      onChanged: (selected) => _toggle(
                        draft.circumstancesB,
                        i,
                        choices[i],
                        selected ?? false,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      const SizedBox(height: 14),
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
      DrawingField(
        strokes: draft.sketchStrokes,
        title: 'Croquis de l’accident',
        hint: 'Dessinez les voies, les véhicules et leur direction',
        icon: Icons.draw_outlined,
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
                selectedColor: context.palette.primaryTint,
                checkmarkColor: context.palette.primaryText,
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
    this.driverA,
    super.key,
  });
  final AccidentDraft draft;
  final VoidCallback onChanged;
  final ConstatDriverAData? driverA;

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
      AccidentReview(draft: draft, driverA: driverA),
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
