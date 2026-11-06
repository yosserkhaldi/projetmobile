import 'package:flutter/material.dart';

import 'package:mon_constat_digital/core/state/app_scope.dart';
import 'package:mon_constat_digital/core/theme/app_colors.dart';
import 'package:mon_constat_digital/modules/accident/models/accident_draft.dart';
import 'package:mon_constat_digital/modules/accident/widgets/accident_steps.dart';
import 'package:mon_constat_digital/modules/claims/models/claim.dart';
import 'package:mon_constat_digital/modules/constat/widgets/constat_steps.dart';

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
  final guest = TextEditingController();
  final observations = TextEditingController();
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
    guest.dispose();
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
    0 => ContextStep(draft: draft, place: place, onChanged: _touch),
    1 => DescriptionStep(
      draft: draft,
      witnessName: witnessName,
      witnessPhone: witnessPhone,
      onChanged: _touch,
    ),
    2 => EvidenceStep(draft: draft, onChanged: _touch),
    3 => GuestDriverStep(guest: guest),
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

  void _next() {
    FocusScope.of(context).unfocus();
    if (!_isCurrentStepValid()) return;
    draft.touch();
    if (step < steps.length - 1) {
      setState(() => step++);
      _persistDraft();
      return;
    }
    final claims = AppScope.of(context).claims;
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
      'Double signature',
      'PDF verrouillé',
      'Transmis aux assureurs',
    ]);
    claims.addClaim(claim);
    AppScope.of(context).accidents.clearDraft();
    Navigator.pop(context);
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
    if (step == 4 && draft.circumstances.isEmpty) {
      _showError('Sélectionnez au moins une circonstance.');
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
