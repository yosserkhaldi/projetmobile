import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:mon_constat_digital/core/theme/app_palette.dart';

import 'package:mon_constat_digital/core/network/api_client.dart';
import 'package:mon_constat_digital/modules/constat/services/pending_seals.dart';
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

  /// Le téléphone est entre les mains du conducteur B (étape 4) : retour
  /// impossible vers les étapes de A, jusqu'à ce qu'il le rende.
  bool _guestMode = false;

  /// Étape du conducteur B, avant la remise du téléphone.
  bool get _handoverPending => step == 3 && !_guestMode;

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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final vehicles = AppScope.of(context).vehicles;
      _persistDraft();
      // Véhicules à jour avant de choisir (ajoutés ailleurs, par exemple).
      await vehicles.syncWithServer();
      if (!mounted) return;
      VehicleChoice.preselect(draft, vehicles.vehicles);
      _fillDriverA();
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
  Widget build(BuildContext context) => PopScope(
    canPop: !_guestMode,
    onPopInvokedWithResult: (didPop, _) {
      if (!didPop) {
        _showError('Terminez d’abord la saisie du conducteur B.');
      }
    },
    child: _scaffold(context),
  );

  Widget _scaffold(BuildContext context) => Scaffold(
    appBar: AppBar(
      automaticallyImplyLeading: !_guestMode,
      title: Text(_guestMode ? 'Conducteur B' : 'Nouvelle déclaration'),
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
            canGoBack: step > 0 && !_guestMode,
            finalStep: step == steps.length - 1,
            continueLabel: step == 2
                ? 'Continuer vers le constat'
                : _handoverPending
                ? 'Je suis le conducteur B'
                : _guestMode
                ? 'Terminer et rendre le téléphone'
                : step == steps.length - 1
                ? 'Signer et transmettre'
                : 'Continuer',
            onBack: _goBack,
            onContinue: _handoverPending
                ? () => setState(() => _guestMode = true)
                : _next,
          ),
        ],
      ),
    ),
  );

  ConstatDriverAData _buildDriverA(AppStores stores) =>
      ConstatDriverAData.fromUserAndVehicle(
        user: stores.users.currentUser,
        vehicle:
            _vehicle(stores.vehicles.vehicles) ??
            stores.vehicles.vehicles.firstOrNull,
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
    3 =>
      _guestMode
          ? GuestDriverStep(draft: draft, onChanged: _touch)
          : const _HandoverIntro(),
    4 => CircumstancesStep(
      draft: draft,
      observations: observations,
      onChanged: _touch,
    ),
    5 => SketchStep(draft: draft, onChanged: _touch),
    _ => SignatureStep(
      draft: draft,
      driverA: _buildDriverA(AppScope.of(context)),
      onChanged: _touch,
    ),
  };

  void _touch() {
    _fillDriverA();
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
    if (_guestMode) {
      // Le conducteur B a terminé : il rend le téléphone au conducteur A.
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          icon: const Icon(Icons.swap_horiz_rounded),
          title: const Text('Merci !'),
          content: const Text(
            'Rendez maintenant le téléphone au conducteur A. Les deux '
            'conducteurs signeront ensemble à la fin du constat.',
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Je suis le conducteur A'),
            ),
          ],
        ),
      );
      if (!mounted) return;
      _guestMode = false;
    }
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
    if (user == null || user.identity.status != IdentityStatus.verified) {
      await _askIdentity();
      return;
    }
    final vehicle = _vehicle(stores.vehicles.vehicles);
    if (vehicle == null) {
      _showError('Choisissez votre véhicule à la première étape.');
      return;
    }
    _sending = true;
    _fillDriverA();

    // Dialogue d'attente pendant la génération et le scellement
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
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
                  style: TextStyle(fontSize: 12, color: context.palette.textMuted),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final driverA = _buildDriverA(stores);
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
        clientId: draft.clientId,
      );
      constat = await stores.constats.sealAndSubmit(
        draft: draft,
        accidentId: accidentId,
        driverAName: driverA.fullName.isNotEmpty
            ? driverA.fullName
            : user.name,
        driverAPlate: driverA.plate.isNotEmpty
            ? driverA.plate
            : vehicle.plate,
        driverAInsurer: driverA.insurerName.isNotEmpty
            ? driverA.insurerName
            : (vehicle.companyName ?? vehicle.insurerName),
        driverAPolicy: vehicle.policy,
        companyAId: vehicle.companyId ?? user.companyId,
        companyBId: draft.driverBCompanyId,
        driverA: driverA,
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
      final offlineAt = DateTime.now();
      pdfBytes = await AccidentPdfService().build(
        draft,
        driverA: driverA,
        generatedAt: offlineAt,
      );
      final hash = stores.constats.crypto.computeSha256(pdfBytes);
      constat = _localConstat(stores, hash);
      sealedOnline = false;
    } catch (error) {
      _sending = false;
      if (mounted) {
        navigator.pop(); // ferme le dialog
        _showError('Le constat n’a pas pu être scellé : $error');
      }
      return;
    }

    final claim = Claim(
      id: _claimId(),
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
    // Hors ligne : scellé sur le serveur et rattaché au sinistre au retour
    // du réseau (PendingSeals).
    if (!sealedOnline) {
      await PendingSeals.add(
        userId: user.id,
        claimId: claim.id,
        draft: draft,
        driverA: driverA,
        companyAId: vehicle.companyId ?? user.companyId,
        companyBId: draft.driverBCompanyId,
      );
    }
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
          driverA: driverA,
        ),
      ),
    );
  }

  /// Conducteur A : le profil et le véhicule choisi, pas des valeurs fictives.
  /// Rempli dès que possible, pour que l'aperçu du PDF (avant la signature)
  /// les montre aussi.
  void _fillDriverA() {
    final stores = AppScope.of(context);
    final user = stores.users.currentUser;
    if (user != null) {
      draft
        ..driverAName = user.name
        ..driverALicense = user.licenseNumber ?? '';
    }
    final vehicle = _vehicle(stores.vehicles.vehicles);
    if (vehicle != null) {
      draft
        ..driverAPlate = vehicle.plate
        ..driverAVehicle = '${vehicle.brand} ${vehicle.model}'
        ..driverAInsurer = vehicle.companyName ?? vehicle.insurerName
        ..driverAPolicy = vehicle.policy
        ..driverACompanyId = vehicle.companyId;
    }
  }

  /// Numéro de dossier : date du jour et 6 caractères aléatoires. L'ancien
  /// (6 chiffres de l'horloge) revenait toutes les 16 minutes, et le serveur
  /// refusait alors le dossier.
  static String _claimId() {
    final now = DateTime.now();
    String two(int n) => n.toString().padLeft(2, '0');
    final random = Random.secure();
    const alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final suffix = List.generate(
      6,
      (_) => alphabet[random.nextInt(alphabet.length)],
    ).join();
    return 'SIN-${two(now.year % 100)}${two(now.month)}${two(now.day)}-$suffix';
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
    driverAPolicy: draft.driverAPolicy.isNotEmpty ? draft.driverAPolicy : null,
    driverBName: draft.driverBName.isNotEmpty ? draft.driverBName : 'Conducteur B',
    driverBPlate: draft.driverBPlate.isNotEmpty ? draft.driverBPlate : 'Véhicule B',
    driverBInsurer: draft.driverBInsurer.isNotEmpty
        ? draft.driverBInsurer
        : 'Assureur B',
    driverBPolicy: draft.driverBPolicy.isNotEmpty ? draft.driverBPolicy : null,
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
    color: context.palette.surface,
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Étape ${step + 1} sur ${steps.length}',
                style: TextStyle(
                  color: context.palette.primaryText,
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
          style: TextStyle(color: context.palette.textMuted),
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
                      ? context.palette.primaryText
                      : index == step
                      ? AppColors.accent
                      : context.palette.border,
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

/// Remise du téléphone au conducteur B : il ne voit que sa propre saisie.
class _HandoverIntro extends StatelessWidget {
  const _HandoverIntro();

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    Widget point(IconData icon, String text) => Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: p.primaryText),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: TextStyle(color: p.text, height: 1.35)),
          ),
        ],
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 12),
        Container(
          width: 96,
          height: 96,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: p.primaryTint,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.phonelink_ring_rounded,
            size: 46,
            color: p.primaryText,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'Passez le téléphone au conducteur B',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: p.text,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Il remplit lui-même son identité, son permis, son véhicule et son '
          'assurance.',
          textAlign: TextAlign.center,
          style: TextStyle(color: p.textMuted, height: 1.4),
        ),
        const SizedBox(height: 10),
        Card(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
            child: Column(
              children: [
                point(
                  Icons.visibility_off_outlined,
                  'Vos informations restent masquées : le retour aux étapes '
                  'précédentes est bloqué pendant sa saisie.',
                ),
                point(
                  Icons.document_scanner_outlined,
                  'Il peut photographier son permis : l’IA remplit les champs.',
                ),
                point(
                  Icons.swap_horiz_rounded,
                  'À la fin, il vous rend le téléphone.',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
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
    decoration: BoxDecoration(
      color: context.palette.surface,
      border: Border(top: BorderSide(color: context.palette.borderSoft)),
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
