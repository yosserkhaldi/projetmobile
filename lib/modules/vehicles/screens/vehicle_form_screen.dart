import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:mon_constat_digital/core/network/api_client.dart';
import 'package:mon_constat_digital/core/state/app_scope.dart';
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

  /// Document en cours de lecture : carte grise ou attestation.
  _Document? _scanning;

  String? _companyId;
  String? _companyName;

  /// Photo d'un document → l'IA du serveur le lit (plaque de la bande
  /// verticale comprise) et remplit le formulaire, à vérifier. Hors ligne,
  /// la carte grise est lue sur le téléphone (ML Kit), moins finement.
  Future<void> _scan(_Document document) async {
    final api = AppScope.of(context).api;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _scanning = document);
    try {
      final photo = await _media.capturePhoto(document.fileName);
      if (photo == null || !mounted) return;
      Map<String, dynamic> read;
      try {
        final body =
            await api.upload(
                  '/vehicles/scan',
                  method: 'POST',
                  field: 'photo',
                  bytes: await File(photo).readAsBytes(),
                  filename: '${document.fileName}.jpg',
                  fields: {'kind': document.apiValue},
                )
                as Map<String, dynamic>;
        read = body['extracted'] as Map<String, dynamic>;
      } on ApiException catch (error) {
        if (!error.isNetwork || document != _Document.registration) rethrow;
        final data = await _ocr.scan(photo);
        read = {'plate': data.plate, 'year': int.tryParse(data.year)};
      }
      if (!mounted) return;
      final filled = _apply(read);
      final estimated = read['expiresAtEstimated'] == true;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            filled.isEmpty
                ? 'Rien n’a pu être lu. Reprenez la photo à plat, bien éclairée.'
                : 'Lu par l’IA : ${filled.join(', ')}. Vérifiez avant d’enregistrer.'
                      '${estimated ? ' Fin de validité estimée à un an : vérifiez-la.' : ''}',
          ),
        ),
      );
    } on ApiException catch (error) {
      messenger.showSnackBar(SnackBar(content: Text(error.message)));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Lecture impossible : $e')));
    } finally {
      if (mounted) setState(() => _scanning = null);
    }
  }

  /// Bouton « photographier » d'un document ; la carte grise en plein, le
  /// reste en contour.
  Widget _scanButton(_Document document, {String? key}) {
    final busy = _scanning == document;
    final icon = busy
        ? const SizedBox.square(
            dimension: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Icon(document.icon);
    final label = Text(
      busy ? 'Lecture en cours… (jusqu’à 30 s)' : document.label,
    );
    final onPressed = _scanning != null ? null : () => _scan(document);
    final buttonKey = ValueKey(key ?? 'scan-${document.apiValue}');
    return SizedBox(
      width: double.infinity,
      child: document == _Document.registration
          ? FilledButton.icon(
              key: buttonKey,
              onPressed: onPressed,
              icon: icon,
              label: label,
            )
          : OutlinedButton.icon(
              key: buttonKey,
              onPressed: onPressed,
              icon: icon,
              label: label,
            ),
    );
  }

  /// Remplit les champs lus ; renvoie leurs noms pour le message.
  List<String> _apply(Map<String, dynamic> read) {
    final filled = <String>[];
    void put(TextEditingController field, Object? value, String label) {
      final text = value?.toString().trim() ?? '';
      if (text.isEmpty) return;
      field.text = text;
      filled.add(label);
    }

    String? displayDate(Object? iso) {
      final date = DateTime.tryParse(iso?.toString() ?? '');
      if (date == null) return null;
      String two(int n) => n.toString().padLeft(2, '0');
      return '${two(date.day)}/${two(date.month)}/${date.year}';
    }

    setState(() {
      put(_plate, read['plate'], 'immatriculation');
      put(_brand, read['brand'], 'marque');
      put(_model, read['model'], 'modèle');
      put(_year, read['year'], 'année');
      put(_policy, read['policy'], 'n° de contrat');
      put(_insuranceExpiry, displayDate(read['expiresAt']), 'fin de validité');
      final companyId = read['companyId'] as String?;
      if (companyId != null) {
        _companyId = companyId;
        _companyName = read['insurer'] as String?;
        _insurer.text = _companyName ?? '';
        filled.add('assureur');
      } else if (read['insurer'] != null) {
        // Assureur reconnu mais absent du référentiel : à choisir, ou à
        // faire ajouter par un administrateur.
        _insurer.text = read['insurer'] as String;
        filled.add('assureur (${read['insurer']}, à choisir dans la liste)');
      }
    });
    return filled;
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
                        const
                        SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Scanner vos documents avec l’IA',
                            style: TextStyle(fontWeight: FontWeight.w900),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Une photo de la carte grise ou de l’attestation d’assurance : l’IA remplit le formulaire, vous vérifiez.',
                      style: TextStyle(color: context.palette.textMuted),
                    ),
                    const SizedBox(height: 10),
                    for (final document in _Document.values) ...[
                      _scanButton(document),
                      const SizedBox(height: 8),
                    ],
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
              // Recréé quand une attestation lue choisit la compagnie.
              key: ValueKey(_companyId),
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

      try {
        if (_isEdit) {
          await store.updateVehicle(vehicle);
        } else {
          await store.addVehicle(vehicle);
        }
      } on ApiException catch (error) {
        // Refus du serveur (plaque déjà enregistrée…) : le formulaire reste
        // ouvert pour corriger.
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(error.message)));
        }
        return;
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
  /// UUID v4 : le même identifiant sur le téléphone et sur le serveur.
  String _uuid() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
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

/// Documents que l'IA sait lire pour remplir le formulaire.
enum _Document {
  registration('REGISTRATION', 'carte_grise', 'Photographier la carte grise', Icons.directions_car_outlined),
  insurance('INSURANCE', 'attestation_assurance', 'Photographier l’attestation d’assurance', Icons.verified_user_outlined);

  const _Document(this.apiValue, this.fileName, this.label, this.icon);
  final String apiValue, fileName, label;
  final IconData icon;
}
