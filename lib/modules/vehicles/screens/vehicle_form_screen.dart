import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:mon_constat_digital/core/state/app_scope.dart';
import 'package:mon_constat_digital/core/theme/app_colors.dart';
import 'package:mon_constat_digital/core/theme/app_palette.dart';
import 'package:mon_constat_digital/modules/accident/services/accident_media_service.dart';
import 'package:mon_constat_digital/modules/users/widgets/company_picker.dart';
import 'package:mon_constat_digital/modules/vehicles/models/vehicle.dart';
import 'package:mon_constat_digital/modules/vehicles/services/vehicle_ocr_service.dart';

/// Formulaire d'ajout et de modification d'un véhicule.
///
/// Si [existing] est fourni, le formulaire est en mode édition.
/// Sinon, un nouvel ID est généré à la sauvegarde.
class VehicleFormScreen extends StatefulWidget {
  const VehicleFormScreen({this.existing, super.key});
  final Vehicle? existing;

  @override
  State<VehicleFormScreen> createState() => _VehicleFormScreenState();
}

class _VehicleFormScreenState extends State<VehicleFormScreen> {
  final _form = GlobalKey<FormState>();
  bool _saving = false;

  final _ocr = VehicleOcrService();
  final _media = AccidentMediaService();
  bool _scanning = false;

  String? _companyId;
  String? _companyName;

  Future<void> _scanCard() async {
    setState(() => _scanning = true);
    try {
      final photo = await _media.capturePhoto('carte_grise');
      if (photo != null) {
        final data = await _ocr.scan(photo);
        setState(() {
          if (data.plate.isNotEmpty) _plate.text = data.plate;
          if (data.brand.isNotEmpty) _brand.text = data.brand;
          if (data.model.isNotEmpty) _model.text = data.model;
          if (data.year.isNotEmpty) _year.text = data.year;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Carte grise analysée avec succès par l’IA !')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du scan IA : $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _scanning = false);
    }
  }

  // Contrôleurs de saisie
  late final TextEditingController _plate;
  late final TextEditingController _brand;
  late final TextEditingController _model;
  late final TextEditingController _year;
  late final TextEditingController _policy;
  late final TextEditingController _insurer;
  late final TextEditingController _insuranceExpiry;
  late final TextEditingController _technicalExpiry;
  late final TextEditingController _color;
  late final TextEditingController _mileage;

  late VehicleType _type;
  late FuelType _fuel;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final v = widget.existing;
    _companyId = v?.companyId;
    _companyName = v?.companyName;
    _plate = TextEditingController(text: v?.plate ?? '');
    _brand = TextEditingController(text: v?.brand ?? '');
    _model = TextEditingController(text: v?.model ?? '');
    _year = TextEditingController(text: v?.year ?? '');
    _policy = TextEditingController(text: v?.policy ?? '');
    _insurer = TextEditingController(text: v?.insurerName ?? v?.companyName ?? '');
    _insuranceExpiry = TextEditingController(text: v?.insuranceExpiry ?? '');
    _technicalExpiry = TextEditingController(text: v?.technicalExpiry ?? '');
    _color = TextEditingController(text: v?.color ?? '');
    _mileage = TextEditingController(
      text: v?.mileage != null ? '${v!.mileage}' : '',
    );
    _type = v?.type ?? VehicleType.car;
    _fuel = v?.fuel ?? FuelType.petrol;
  }

  @override
  void dispose() {
    for (final c in [
      _plate,
      _brand,
      _model,
      _year,
      _policy,
      _insurer,
      _insuranceExpiry,
      _technicalExpiry,
      _color,
      _mileage,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Modifier le véhicule' : 'Ajouter un véhicule'),
      ),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          children: [
            Card(
              color: AppColors.successBg,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.document_scanner_outlined,
                          color: AppColors.successText,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Scanner la carte grise avec l’IA',
                            style: TextStyle(fontWeight: FontWeight.w900),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Remplissez automatiquement les informations par reconnaissance optique on-device.',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _scanning ? null : _scanCard,
                        icon: _scanning
                            ? const SizedBox.square(
                                dimension: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.camera_alt_outlined),
                        label: Text(
                          _scanning ? 'Analyse IA en cours…' : 'Photographier la carte grise',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // ── Identification ─────────────────────────────────────────────
            _Section(label: 'Identification du véhicule'),
            _Field(
              controller: _plate,
              label: 'Immatriculation *',
              hint: 'Ex : 215 تونس 4521',
              icon: Icons.confirmation_number_outlined,
              validator: _required,
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _Field(
                    controller: _brand,
                    label: 'Marque *',
                    hint: 'Peugeot',
                    icon: Icons.branding_watermark_outlined,
                    validator: _required,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _Field(
                    controller: _model,
                    label: 'Modèle *',
                    hint: '208',
                    icon: Icons.directions_car_outlined,
                    validator: _required,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _Field(
                    controller: _year,
                    label: 'Année *',
                    hint: '2021',
                    icon: Icons.calendar_today_outlined,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                    ],
                    validator: _yearValidator,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _Field(
                    controller: _color,
                    label: 'Couleur',
                    hint: 'Blanc',
                    icon: Icons.palette_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Type et carburant
            Row(
              children: [
                Expanded(
                  child: _DropdownField<VehicleType>(
                    label: 'Type',
                    value: _type,
                    items: const {
                      VehicleType.car: 'Voiture',
                      VehicleType.moto: 'Moto',
                      VehicleType.truck: 'Camion',
                      VehicleType.van: 'Camionnette',
                      VehicleType.other: 'Autre',
                    },
                    onChanged: (v) => setState(() => _type = v!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DropdownField<FuelType>(
                    label: 'Carburant',
                    value: _fuel,
                    items: const {
                      FuelType.petrol: 'Essence',
                      FuelType.diesel: 'Diesel',
                      FuelType.electric: 'Électrique',
                      FuelType.hybrid: 'Hybride',
                      FuelType.other: 'Autre',
                    },
                    onChanged: (v) => setState(() => _fuel = v!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _Field(
              controller: _mileage,
              label: 'Kilométrage',
              hint: '75000',
              icon: Icons.speed_outlined,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              suffix: const Text('km'),
            ),

            // ── Assurance ──────────────────────────────────────────────────
            _Section(label: 'Contrat d\'assurance'),
            CompanyPicker(
              companyId: _companyId,
              withAgency: false,
              required: true,
              onChanged: (company, agency) {
                setState(() {
                  _companyId = company?.id;
                  _companyName = company?.name;
                  _insurer.text = company?.name ?? '';
                });
              },
            ),
            const SizedBox(height: 12),
            _Field(
              controller: _policy,
              label: 'N° de police *',
              hint: 'POL-884521',
              icon: Icons.article_outlined,
              validator: _required,
            ),
            const SizedBox(height: 12),
            _DateField(
              controller: _insuranceExpiry,
              label: 'Date d\'expiration assurance *',
              icon: Icons.event_outlined,
              validator: _dateValidator,
            ),

            // ── Visite technique ───────────────────────────────────────────
            _Section(label: 'Visite technique'),
            _DateField(
              controller: _technicalExpiry,
              label: 'Prochaine visite technique',
              icon: Icons.build_outlined,
              validator: null,
            ),

            const SizedBox(height: 32),

            // Bouton sauvegarder
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(_isEdit ? 'Enregistrer les modifications' : 'Ajouter le véhicule'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!(_form.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    try {
      final store = AppScope.of(context).vehicles;
      final vehicle = Vehicle(
        id: widget.existing?.id ?? _uuid(),
        plate: _plate.text.trim(),
        brand: _brand.text.trim(),
        model: _model.text.trim(),
        year: _year.text.trim(),
        policy: _policy.text.trim(),
        insurerName: _companyName ?? _insurer.text.trim(),
        companyId: _companyId,
        companyName: _companyName ?? _insurer.text.trim(),
        insuranceExpiry: _parseDate(_insuranceExpiry.text.trim()),
        technicalExpiry: _technicalExpiry.text.trim().isEmpty
            ? null
            : _parseDate(_technicalExpiry.text.trim()),
        color: _color.text.trim().isEmpty ? null : _color.text.trim(),
        mileage: _mileage.text.trim().isEmpty
            ? null
            : int.tryParse(_mileage.text.trim()),
        type: _type,
        fuel: _fuel,
        photoPath: widget.existing?.photoPath,
        claimCount: widget.existing?.claimCount ?? 0,
        archived: widget.existing?.archived ?? false,
        createdAt: widget.existing?.createdAt,
      );

      if (_isEdit) {
        await store.updateVehicle(vehicle);
      } else {
        await store.addVehicle(vehicle);
      }

      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ── Validators ─────────────────────────────────────────────────────────────

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Champ obligatoire.' : null;

  String? _yearValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'Champ obligatoire.';
    final y = int.tryParse(v.trim());
    if (y == null || y < 1950 || y > DateTime.now().year + 1) {
      return 'Année invalide.';
    }
    return null;
  }

  String? _dateValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'Champ obligatoire.';
    final parsed = DateTime.tryParse(_parseDate(v.trim()));
    return parsed == null ? 'Format JJ/MM/AAAA.' : null;
  }

  // ── Utils ───────────────────────────────────────────────────────────────────

  /// Convertit JJ/MM/AAAA → AAAA-MM-JJ pour le stockage.
  String _parseDate(String input) {
    final parts = input.split('/');
    if (parts.length == 3) {
      final day = parts[0].padLeft(2, '0');
      final month = parts[1].padLeft(2, '0');
      final year = parts[2];
      return '$year-$month-$day';
    }
    return input; // déjà ISO
  }

  /// UUID v4 simple (pas de dépendance supplémentaire).
  String _uuid() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final rand = Object().hashCode.abs();
    return '$now-$rand';
  }
}

// ── Widgets helpers du formulaire ─────────────────────────────────────────────

class _Section extends StatelessWidget {
  const _Section({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 14, top: 24),
    child: Text(
      label,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: context.palette.primaryText,
      ),
    ),
  );
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    required this.icon,
    this.hint,
    this.validator,
    this.keyboardType,
    this.inputFormatters,
    this.suffix,
    this.textCapitalization = TextCapitalization.sentences,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData icon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? suffix;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    decoration: InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
      suffix: suffix,
    ),
    validator: validator,
    keyboardType: keyboardType,
    inputFormatters: inputFormatters,
    textCapitalization: textCapitalization,
  );
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.controller,
    required this.label,
    required this.icon,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    decoration: InputDecoration(
      labelText: label,
      hintText: 'JJ/MM/AAAA',
      prefixIcon: Icon(icon),
      suffixIcon: IconButton(
        icon: const Icon(Icons.calendar_today, size: 20),
        onPressed: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now().add(const Duration(days: 30)),
            firstDate: DateTime(2000),
            lastDate: DateTime(2040),
          );
          if (picked != null) {
            controller.text =
                '${picked.day.toString().padLeft(2, '0')}/'
                '${picked.month.toString().padLeft(2, '0')}/'
                '${picked.year}';
          }
        },
      ),
    ),
    validator: validator,
    keyboardType: TextInputType.datetime,
    inputFormatters: [
      FilteringTextInputFormatter.allow(RegExp(r'[\d/]')),
      LengthLimitingTextInputFormatter(10),
    ],
  );
}

class _DropdownField<T> extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final T value;
  final Map<T, String> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) => DropdownButtonFormField<T>(
    value: value,
    decoration: InputDecoration(labelText: label),
    items: items.entries
        .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
        .toList(),
    onChanged: onChanged,
  );
}
