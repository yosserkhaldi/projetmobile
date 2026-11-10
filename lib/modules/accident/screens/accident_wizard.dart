import 'package:flutter/material.dart';

import 'package:mon_constat_digital/core/state/app_scope.dart';
import 'package:mon_constat_digital/core/theme/app_colors.dart';
import 'package:mon_constat_digital/modules/accident/models/accident_draft.dart';
import 'package:mon_constat_digital/modules/accident/services/accident_pdf_service.dart';
import 'package:mon_constat_digital/modules/accident/widgets/accident_steps.dart';
import 'package:mon_constat_digital/modules/claims/models/claim.dart';
import 'package:mon_constat_digital/modules/constat/models/constat.dart';
import 'package:mon_constat_digital/modules/constat/screens/constat_sealed_screen.dart';
import 'package:mon_constat_digital/modules/constat/widgets/constat_steps.dart';
import 'package:mon_constat_digital/modules/vehicles/models/vehicle.dart';

/// Parcours en 7 étapes : les 3 premières relèvent du module 3 (déclaration),
/// les 4 suivantes du module 4 (constat).
class AccidentWizard extends StatefulWidget {
  const AccidentWizard({this.initialDraft, this.initialStep = 0, super.key});
  final AccidentDraft? initialDraft;
  final int initialStep;
  @override
  State<AccidentWizard> createState() => _AccidentWizardState();
}

class _AccidentWizardState extends State<AccidentWizard> {
  final _contextForm = GlobalKey<FormState>();
  late final AccidentDraft draft;
  late final TextEditingController place;
  final witnessName = TextEditingController();
  final witnessPhone = TextEditingController();
  final observations = TextEditingController();
  String? _selectedVehicleAId;
  int step = 0;

  static const steps = [
    ('Contexte', 'Lieu, heure et conditions'),
    ('Description', 'Type, gravité et témoins'),
    ('Preuves', 'Photos, vidéo et note vocale'),
    ('Conducteur B', 'Identité et assurance'),
    ('Circonstances', 'Cases et observations'),
    ('Croquis', 'Choc et schéma'),
    ('Signatures', 'Validation et transmission'),
  ];

  @override
  void initState() {
    super.initState();
    draft = widget.initialDraft ?? AccidentDraft();
    step = widget.initialStep.clamp(0, steps.length - 1);
    place = TextEditingController(text: draft.place);
    witnessName.text = draft.witnessName;
    witnessPhone.text = draft.witnessPhone;
    observations.text = draft.observations;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _persistDraft();
    });
  }

  @override
  void dispose() {
    place.dispose();
    witnessName.dispose();
    witnessPhone.dispose();
    observations.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Nouvelle déclaration'),
      actions: [
        TextButton.icon(
          onPressed: _saveDraft,
          icon: const Icon(Icons.bookmark_border),
          label: const Text('Brouillon'),
        ),
      ],
    ),
    body: SafeArea(
      child: Column(
        children: [
          _OfflineBanner(savedAt: draft.lastSavedAt),
          _ProgressHeader(step: step, steps: steps),
          Expanded(
            child: Form(
              key: step == 0 ? _contextForm : null,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                children: [_content()],
              ),
            ),
          ),
          _BottomActions(
            canGoBack: step > 0,
            finalStep: step == steps.length - 1,
            continueLabel: step == 2
                ? 'Continuer vers le constat'
                : step == steps.length - 1
                ? 'Signer et transmettre'
                : 'Continuer',
            onBack: _goBack,
            onContinue: _next,
          ),
        ],
      ),
    ),
  );

  Vehicle? _resolveVehicleA(AppStores stores) {
    final active = stores.vehicles.vehicles;
    if (active.isEmpty) return null;
    if (_selectedVehicleAId != null) {
      for (final v in active) {
        if (v.id == _selectedVehicleAId) return v;
      }
    }
    return active.first;
  }

  ConstatDriverAData _buildDriverA(AppStores stores) =>
      ConstatDriverAData.fromUserAndVehicle(
        user: stores.users.currentUser,
        vehicle: _resolveVehicleA(stores),
      );

  Widget _content() {
    final stores = AppScope.of(context);
    final driverA = _buildDriverA(stores);
    return switch (step) {
      0 => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _VehicleASelectorCard(
            vehicles: stores.vehicles.vehicles,
            selected: _resolveVehicleA(stores),
            driverName: stores.users.userName,
            onChanged: (vehicleId) =>
                setState(() => _selectedVehicleAId = vehicleId),
          ),
          const SizedBox(height: 14),
          ContextStep(draft: draft, place: place, onChanged: _touch),
        ],
      ),
      1 => DescriptionStep(
        draft: draft,
        witnessName: witnessName,
        witnessPhone: witnessPhone,
        onChanged: _touch,
      ),
      2 => EvidenceStep(draft: draft, onChanged: _touch),
      3 => GuestDriverStep(draft: draft, onChanged: _touch),
      4 => CircumstancesStep(
        draft: draft,
        observations: observations,
        onChanged: _touch,
      ),
      5 => SketchStep(draft: draft, onChanged: _touch),
      _ => SignatureStep(
        draft: draft,
        driverA: driverA,
        onChanged: _touch,
      ),
    };
  }

  void _touch() {
    draft.touch();
    _persistDraft();
    setState(() {});
  }

  void _saveDraft() {
    draft.touch();
    _persistDraft();
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Brouillon enregistré sur cet appareil')),
    );
  }

  Future<void> _next() async {
    FocusScope.of(context).unfocus();
    if (!_isCurrentStepValid()) return;
    draft.touch();
    if (step < steps.length - 1) {
      setState(() => step++);
      _persistDraft();
      return;
    }

    final stores = AppScope.of(context);

    // Dialogue d'attente pendant la génération et le scellement
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(
                  'Scellement cryptographique du constat…',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  'Calcul du hash SHA-256 et transmission',
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final vehicleA = _resolveVehicleA(stores);
    final driverA = _buildDriverA(stores);
    final resolvedDriverAName =
        driverA.fullName.isNotEmpty ? driverA.fullName : stores.users.userName;
    final resolvedDriverAPlate =
        driverA.plate.isNotEmpty ? driverA.plate : 'Véhicule A';
    final resolvedDriverAInsurer =
        driverA.insurerName.isNotEmpty ? driverA.insurerName : 'Assureur A';
    final resolvedDriverAPolicy =
        driverA.policyNumber.isNotEmpty ? driverA.policyNumber : null;
    final resolvedCompanyAId =
        vehicleA?.companyId ?? stores.users.currentUser?.companyId;

    try {
      final sealed = await stores.constats.sealAndSubmit(
        draft: draft,
        driverAName: resolvedDriverAName,
        driverAPlate: resolvedDriverAPlate,
        driverAInsurer: resolvedDriverAInsurer,
        driverAPolicy: resolvedDriverAPolicy,
        companyAId: resolvedCompanyAId,
        companyBId: draft.driverBCompanyId,
        driverA: driverA,
      );

      final claim = Claim(
        id: 'SIN-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
        type: draft.type,
        place: draft.place,
        date: draft.occurredAt.toString().substring(0, 16),
        severity: draft.severity,
        status: 'Transmis',
      );
      claim.timeline.addAll([
        'Déclaration complétée',
        '${draft.evidenceCount} preuves ajoutées',
        'Double signature bilatérale',
        'Scellement SHA-256 (${sealed.sha256Hash.substring(0, 8)}...)',
        'Transmis aux assureurs',
      ]);
      claim.documents.add('Constat amiable scellé.pdf');
      stores.claims.addClaim(claim);
      stores.accidents.clearDraft();

      if (!mounted) return;
      Navigator.pop(context); // ferme le dialog

      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ConstatSealedScreen(
            constat: sealed,
            draft: draft,
            pdfBytes: stores.constats.lastSealedPdfBytes,
            driverA: driverA,
          ),
        ),
      );
    } catch (e, st) {
      debugPrint('[ConstatWizard] Scellement serveur échoué, bascule hors-ligne : $e\n$st');
      // En cas de mode déconnecté (hors-ligne), scellement local garanti
      final offlineAt = DateTime.now().toUtc();
      final pdfBytes = await AccidentPdfService().build(
        draft,
        driverA: driverA,
        generatedAt: offlineAt,
      );
      final hash = stores.constats.crypto.computeSha256(pdfBytes);
      final localConstat = Constat(
        id: 'local-${DateTime.now().millisecondsSinceEpoch}',
        userId: stores.users.currentUser?.id ?? '',
        status: 'SIGNED',
        sha256Hash: hash,
        pdfUrl: '',
        driverAName: resolvedDriverAName,
        driverAPlate: resolvedDriverAPlate,
        driverAInsurer: resolvedDriverAInsurer,
        driverAPolicy: resolvedDriverAPolicy,
        driverBName: draft.driverBName.isNotEmpty ? draft.driverBName : 'Conducteur B',
        driverBPlate: draft.driverBPlate.isNotEmpty ? draft.driverBPlate : 'Véhicule B',
        driverBInsurer: draft.driverBInsurer.isNotEmpty ? draft.driverBInsurer : 'Assureur B',
        driverBPolicy: draft.driverBPolicy.isNotEmpty ? draft.driverBPolicy : null,
        place: draft.place,
        occurredAt: draft.occurredAt,
        circumstancesA: draft.circumstancesA.toList(),
        circumstancesB: draft.circumstancesB.toList(),
        impactZones: draft.impactZones.toList(),
        observations: draft.observations,
      );

      final claim = Claim(
        id: 'SIN-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
        type: draft.type,
        place: draft.place,
        date: draft.occurredAt.toString().substring(0, 16),
        severity: draft.severity,
        status: 'Transmis',
      );
      claim.timeline.addAll([
        'Déclaration complétée',
        'Double signature bilatérale',
        'Scellement local SHA-256 (${hash.substring(0, 8)}...)',
        'En attente de synchronisation réseau',
      ]);
      claim.documents.add('Constat amiable scellé.pdf');
      stores.claims.addClaim(claim);
      stores.accidents.clearDraft();

      if (!mounted) return;
      Navigator.pop(context); // ferme le dialog

      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ConstatSealedScreen(
            constat: localConstat,
            draft: draft,
            pdfBytes: pdfBytes,
            driverA: driverA,
          ),
        ),
      );
    }
  }

  void _goBack() {
    setState(() => step--);
    _persistDraft();
  }

  void _persistDraft() {
    AppScope.of(context).accidents.saveDraft(draft, step);
  }

  bool _isCurrentStepValid() {
    if (step == 0 && !(_contextForm.currentState?.validate() ?? false)) {
      _showError('Vérifiez le lieu de l’accident.');
      return false;
    }
    if (step == 1 &&
        witnessName.text.trim().isNotEmpty &&
        witnessPhone.text.trim().length < 8) {
      _showError('Ajoutez un numéro valide pour le témoin.');
      return false;
    }
    if (step == 2 && draft.evidenceCount < 2) {
      _showError('Ajoutez au moins 2 photos avant de continuer.');
      return false;
    }
    if (step == 3 &&
        (draft.driverBName.trim().length < 2 ||
            draft.driverBPlate.trim().length < 3 ||
            draft.driverBInsurer.trim().length < 2)) {
      _showError(
        'Complétez le nom, l’immatriculation et l’assurance du conducteur B.',
      );
      return false;
    }
    if (step == 4 && draft.circumstancesA.isEmpty && draft.circumstancesB.isEmpty) {
      _showError('Sélectionnez au moins une circonstance pour le véhicule A ou B.');
      return false;
    }
    if (step == 5 && (!draft.sketchConfirmed || draft.impactZones.isEmpty)) {
      _showError('Confirmez le croquis et une zone de choc.');
      return false;
    }
    if (step == 6 && (!draft.driverASigned || !draft.driverBSigned)) {
      _showError('Les deux conducteurs doivent signer le constat.');
      return false;
    }
    return true;
  }

  void _showError(String message) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(backgroundColor: AppColors.errorSolid, content: Text(message)),
    );
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner({required this.savedAt});
  final DateTime savedAt;
  @override
  Widget build(BuildContext context) {
    String two(int number) => number.toString().padLeft(2, '0');
    return Container(
      width: double.infinity,
      color: AppColors.ink,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      child: Row(
        children: [
          const Icon(
            Icons.cloud_done_outlined,
            color: Color(0xFF7FE0CC),
            size: 17,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Brouillon local • sauvegardé à ${two(savedAt.hour)}:${two(savedAt.minute)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader({required this.step, required this.steps});
  final int step;
  final List<(String, String)> steps;
  @override
  Widget build(BuildContext context) => Container(
    color: AppColors.surface,
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Étape ${step + 1} sur ${steps.length}',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const Icon(Icons.timer_outlined, size: 17),
            const SizedBox(width: 5),
            Text(
              '~${9 - step} min',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text(steps[step].$1, style: Theme.of(context).textTheme.headlineSmall),
        Text(
          steps[step].$2,
          style: const TextStyle(color: AppColors.textMuted),
        ),
        const SizedBox(height: 14),
        Row(
          children: List.generate(
            steps.length,
            (index) => Expanded(
              child: Container(
                height: 5,
                margin: EdgeInsets.only(
                  right: index == steps.length - 1 ? 0 : 6,
                ),
                decoration: BoxDecoration(
                  color: index < step
                      ? AppColors.primary
                      : index == step
                      ? AppColors.accent
                      : AppColors.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class _BottomActions extends StatelessWidget {
  const _BottomActions({
    required this.canGoBack,
    required this.finalStep,
    required this.continueLabel,
    required this.onBack,
    required this.onContinue,
  });
  final bool canGoBack, finalStep;
  final String continueLabel;
  final VoidCallback onBack, onContinue;
  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      color: AppColors.surface,
      border: Border(top: BorderSide(color: AppColors.borderSoft)),
    ),
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
    child: Row(
      children: [
        if (canGoBack) ...[
          Expanded(
            child: OutlinedButton(
              onPressed: onBack,
              child: const Text('Retour'),
            ),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          flex: canGoBack ? 2 : 1,
          child: FilledButton.icon(
            onPressed: onContinue,
            icon: Icon(finalStep ? Icons.lock_outline : Icons.arrow_forward),
            label: Text(continueLabel),
          ),
        ),
      ],
    ),
  );
}

class _VehicleASelectorCard extends StatelessWidget {
  const _VehicleASelectorCard({
    required this.vehicles,
    required this.selected,
    required this.driverName,
    required this.onChanged,
  });

  final List<Vehicle> vehicles;
  final Vehicle? selected;
  final String driverName;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    if (vehicles.isEmpty) {
      return Card(
        color: AppColors.primaryTint,
        child: ListTile(
          leading: const Icon(Icons.directions_car_outlined, color: AppColors.primary),
          title: const Text(
            'Véhicule A — Profil conducteur',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
          ),
          subtitle: Text(
            '$driverName • Enregistrez un véhicule dans Mes véhicules pour pré-remplir plaque et N° police.',
            style: const TextStyle(fontSize: 12),
          ),
        ),
      );
    }

    if (vehicles.length == 1 && selected != null) {
      final v = selected!;
      final insurer = (v.companyName ?? '').isNotEmpty
          ? v.companyName!
          : v.insurerName;
      return Card(
        color: AppColors.primaryTint,
        child: ListTile(
          leading: const CircleAvatar(
            backgroundColor: AppColors.primary,
            child: Text(
              'A',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
            ),
          ),
          title: Text(
            '${v.brand} ${v.model} • ${v.plate}',
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
          ),
          subtitle: Text(
            '${insurer.isNotEmpty ? insurer : 'Assurance'} • Police ${v.policy.isNotEmpty ? v.policy : 'non renseignée'}',
            style: const TextStyle(fontSize: 12),
          ),
        ),
      );
    }

    return DropdownButtonFormField<String>(
      initialValue: selected?.id,
      decoration: const InputDecoration(
        labelText: 'Votre véhicule impliqué (Véhicule A)',
        prefixIcon: Icon(Icons.directions_car_outlined),
      ),
      items: vehicles
          .map(
            (v) => DropdownMenuItem<String>(
              value: v.id,
              child: Text('${v.brand} ${v.model} • ${v.plate}'),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
}
