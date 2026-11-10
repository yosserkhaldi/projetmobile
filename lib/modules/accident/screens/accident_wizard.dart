import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:mon_constat_digital/core/network/api_client.dart';
import 'package:mon_constat_digital/core/state/app_scope.dart';
import 'package:mon_constat_digital/core/theme/app_colors.dart';
import 'package:mon_constat_digital/modules/accident/models/accident_draft.dart';
import 'package:mon_constat_digital/modules/accident/services/accident_pdf_service.dart';
import 'package:mon_constat_digital/modules/accident/widgets/accident_steps.dart';
import 'package:mon_constat_digital/modules/accident/widgets/vehicle_choice.dart';
import 'package:mon_constat_digital/modules/claims/data/declaration_files.dart';
import 'package:mon_constat_digital/modules/claims/models/claim.dart';
import 'package:mon_constat_digital/modules/constat/models/constat.dart';
import 'package:mon_constat_digital/modules/constat/screens/constat_sealed_screen.dart';
import 'package:mon_constat_digital/modules/constat/widgets/constat_steps.dart';
import 'package:mon_constat_digital/modules/users/models/app_user.dart';
import 'package:mon_constat_digital/modules/users/screens/identity_screen.dart';
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
  int step = 0;
  bool _sending = false;

  /// Identifiant de la déclaration côté téléphone : un nouvel envoi (après
  /// une coupure) met à jour la même déclaration sur le serveur.
  final _clientId = 'acc-${DateTime.now().microsecondsSinceEpoch}';

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
      if (!mounted) return;
      VehicleChoice.preselect(draft, AppScope.of(context).vehicles.vehicles);
      _persistDraft();
      setState(() {});
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

  Widget _content() => switch (step) {
    0 => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        VehicleChoice(draft: draft, onChanged: _touch),
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
    _ => SignatureStep(draft: draft, onChanged: _touch),
  };

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
    // Le scellement prend un instant : un second appui ne crée pas un doublon.
    if (_sending) return;
    final stores = AppScope.of(context);
    final navigator = Navigator.of(context);
    final user = stores.users.currentUser;
    // Signer engage : identité vérifiée obligatoire (le serveur le vérifie
    // aussi). On le dit avant le scellement plutôt qu'après.
    if (user?.identity.status != IdentityStatus.verified) {
      await _askIdentity();
      return;
    }
    final vehicle = _vehicle(stores.vehicles.vehicles);
    if (vehicle == null) {
      _showError('Choisissez votre véhicule à la première étape.');
      return;
    }
    _sending = true;
    // Conducteur A : le profil et le véhicule choisi, pas des valeurs fictives.
    draft
      ..driverAName = user!.name
      ..driverALicense = user.licenseNumber ?? ''
      ..driverAPlate = vehicle.plate
      ..driverAVehicle = '${vehicle.brand} ${vehicle.model}'
      ..driverAInsurer = vehicle.companyName ?? vehicle.insurerName
      ..driverAPolicy = vehicle.policy
      ..driverACompanyId = vehicle.companyId;

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

    // Module 4 : le PDF scellé sur le serveur fait foi. Hors ligne, il est
    // scellé localement et le sinistre reste en attente de synchronisation.
    Constat constat;
    Uint8List pdfBytes;
    bool sealedOnline;
    try {
      // Module 3 : la déclaration rejoint le serveur, liée au constat.
      final accidentId = await stores.accidents.submitToServer(
        stores.api,
        draft,
        clientId: _clientId,
      );
      constat = await stores.constats.sealAndSubmit(
        draft: draft,
        accidentId: accidentId,
        driverAPolicy: vehicle.policy,
        companyAId: vehicle.companyId,
        companyBId: draft.driverBCompanyId,
      );
      pdfBytes = stores.constats.lastSealedPdfBytes!;
      sealedOnline = true;
    } on ApiException catch (error) {
      if (!error.isNetwork) {
        // Refus du serveur (identité, données) : rien n'est scellé, le
        // brouillon reste pour corriger et réessayer.
        _sending = false;
        if (mounted) {
          navigator.pop(); // ferme le dialog
          _showError(error.message);
        }
        return;
      }
      // Hors ligne : scellé sur le téléphone, envoyé plus tard.
      pdfBytes = await AccidentPdfService().build(draft);
      final hash = stores.constats.crypto.computeSha256(pdfBytes);
      constat = _localConstat(stores, hash);
      sealedOnline = false;
    } catch (_) {
      pdfBytes = await AccidentPdfService().build(draft);
      final hash = stores.constats.crypto.computeSha256(pdfBytes);
      constat = Constat(
        id: 'local-${DateTime.now().millisecondsSinceEpoch}',
        userId: stores.users.currentUser?.id ?? '',
        status: 'SIGNED',
        sha256Hash: hash,
        pdfUrl: '',
        driverAName: draft.driverAName,
        driverAPlate: draft.driverAPlate,
        driverAInsurer: draft.driverAInsurer,
        driverBName: draft.driverBName.isNotEmpty
            ? draft.driverBName
            : 'Conducteur B',
        driverBPlate: draft.driverBPlate.isNotEmpty
            ? draft.driverBPlate
            : 'Véhicule B',
        driverBInsurer: draft.driverBInsurer.isNotEmpty
            ? draft.driverBInsurer
            : 'Assureur B',
        place: draft.place,
        occurredAt: draft.occurredAt,
        circumstancesA: draft.circumstancesA.toList(),
        circumstancesB: draft.circumstancesB.toList(),
        impactZones: draft.impactZones.toList(),
        observations: draft.observations,
      );
      sealedOnline = false;
    }

    final claim = Claim(
      id: 'SIN-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      type: draft.type,
      place: draft.place,
      date: draft.occurredAt.toString().substring(0, 16),
      severity: draft.severity,
      status: 'Transmis',
      observations: draft.observations,
    );
    // Module 5 : la proposition de responsabilité lit les cases du déclarant (A).
    claim.circumstances.addAll(draft.circumstancesA);
    claim.circumstancesB.addAll(draft.circumstancesB);
    // Module 5 : le sinistre va aux agents de l'assureur du véhicule choisi.
    claim.companyId =
        vehicle.companyId ?? declarationCompany(stores.vehicles.vehicles);
    // Module 5 : le constat scellé sur le serveur ; hors ligne, pas encore.
    if (sealedOnline) claim.constatId = constat.id;
    claim.impactZones.addAll(draft.impactZones);
    final shortHash = constat.sha256Hash.substring(0, 8);
    claim.timeline.addAll([
      'Déclaration complétée',
      '${draft.evidenceCount} preuves ajoutées',
      'Double signature bilatérale',
      if (sealedOnline) ...[
        'Scellement SHA-256 ($shortHash...)',
        'Transmis aux assureurs',
      ] else ...[
        'Scellement local SHA-256 ($shortHash...)',
        'En attente de synchronisation réseau',
      ],
    ]);
    stores.claims.addClaim(claim);
    // Module 5 : photos, vidéo, note vocale et le PDF scellé (le même octet
    // pour octet, pour que son SHA-256 corresponde) rejoignent le dossier.
    // Lus avant d'effacer le brouillon.
    stores.claims.attachDeclaration(
      claim,
      await declarationFiles(draft, buildPdf: (_) async => pdfBytes),
    );
    stores.accidents.clearDraft();

    if (!mounted) return;
    navigator.pop(); // ferme le dialog
    await navigator.pushReplacement(
      MaterialPageRoute(
        builder: (_) => ConstatSealedScreen(
          constat: constat,
          draft: draft,
          pdfBytes: pdfBytes,
        ),
      ),
    );
  }

  Vehicle? _vehicle(List<Vehicle> vehicles) =>
      vehicles.where((v) => v.id == draft.vehicleId).firstOrNull;

  /// Constat scellé sur le téléphone (hors ligne), envoyé plus tard.
  Constat _localConstat(AppStores stores, String hash) => Constat(
    id: 'local-${DateTime.now().millisecondsSinceEpoch}',
    userId: stores.users.currentUser?.id ?? '',
    status: 'SIGNED',
    sha256Hash: hash,
    pdfUrl: '',
    driverAName: draft.driverAName,
    driverAPlate: draft.driverAPlate,
    driverAInsurer: draft.driverAInsurer,
    driverBName: draft.driverBName.isNotEmpty ? draft.driverBName : 'Conducteur B',
    driverBPlate: draft.driverBPlate.isNotEmpty ? draft.driverBPlate : 'Véhicule B',
    driverBInsurer: draft.driverBInsurer.isNotEmpty
        ? draft.driverBInsurer
        : 'Assureur B',
    place: draft.place,
    occurredAt: draft.occurredAt,
    circumstancesA: draft.circumstancesA.toList(),
    circumstancesB: draft.circumstancesB.toList(),
    impactZones: draft.impactZones.toList(),
    observations: draft.observations,
  );

  /// Identité pas encore vérifiée : on propose de le faire tout de suite.
  Future<void> _askIdentity() async {
    final verify = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.verified_user_outlined),
        title: const Text('Vérifiez votre identité pour signer'),
        content: const Text(
          'Le constat engage les deux conducteurs : votre identité doit être '
          'vérifiée avant la signature. Votre brouillon reste enregistré.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Plus tard'),
          ),
          FilledButton(
            key: const ValueKey('verify-identity-to-sign'),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Vérifier mon identité'),
          ),
        ],
      ),
    );
    if (verify == true && mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const IdentityScreen()),
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
    if (step == 0) {
      final problem = VehicleChoice.problem(
        draft,
        AppScope.of(context).vehicles.vehicles,
      );
      if (problem != null) {
        _showError(problem);
        return false;
      }
    }
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
    if (step == 4 &&
        draft.circumstancesA.isEmpty &&
        draft.circumstancesB.isEmpty) {
      _showError(
        'Sélectionnez au moins une circonstance pour le véhicule A ou B.',
      );
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
