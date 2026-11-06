import 'package:flutter/material.dart';

import 'package:mon_constat_digital/core/state/app_scope.dart';
import 'package:mon_constat_digital/modules/accident/widgets/accident_steps.dart';
import 'package:mon_constat_digital/modules/claims/models/claim.dart';
import 'package:mon_constat_digital/modules/constat/widgets/constat_steps.dart';

/// Parcours en 7 étapes : les 3 premières relèvent du module 3 (déclaration),
/// les 4 suivantes du module 4 (constat).
class AccidentWizard extends StatefulWidget {
  const AccidentWizard({this.startAtConstat = false, super.key});
  final bool startAtConstat;
  @override
  State<AccidentWizard> createState() => _AccidentWizardState();
}

class _AccidentWizardState extends State<AccidentWizard> {
  int step = 0;
  String type = 'Collision', severity = 'Matériel';
  bool injured = false;
  final place = TextEditingController(text: 'Position GPS détectée — Tunis');
  final guest = TextEditingController();
  final observations = TextEditingController();
  final steps = [
    'Contexte',
    'Description',
    'Preuves',
    'Conducteur B',
    'Circonstances',
    'Croquis',
    'Signatures',
  ];
  @override
  void initState() {
    super.initState();
    if (widget.startAtConstat) step = 3;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('Constat • ${step + 1}/${steps.length}')),
    body: SafeArea(
      child: Column(
        children: [
          LinearProgressIndicator(value: (step + 1) / steps.length),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  steps[step],
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Brouillon enregistré localement • synchronisation automatique',
                ),
                const SizedBox(height: 22),
                _content(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (step > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => step--),
                      child: const Text('Retour'),
                    ),
                  ),
                if (step > 0) const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _next,
                    child: Text(
                      step == steps.length - 1
                          ? 'Signer et transmettre'
                          : 'Continuer',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Widget _content() => switch (step) {
    0 => ContextStep(place: place),
    1 => DescriptionStep(
      type: type,
      severity: severity,
      injured: injured,
      onTypeChanged: (v) => setState(() => type = v),
      onSeverityChanged: (v) => setState(() => severity = v),
      onInjuredChanged: (v) => setState(() => injured = v),
    ),
    2 => const EvidenceStep(),
    3 => GuestDriverStep(guest: guest),
    4 => CircumstancesStep(observations: observations),
    5 => const SketchStep(),
    _ => const SignatureStep(),
  };

  void _next() {
    if (step < steps.length - 1) {
      setState(() => step++);
      return;
    }
    final s = AppScope.of(context).claims;
    final c = Claim(
      id: 'SIN-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      type: type,
      place: place.text,
      date: DateTime.now().toString().substring(0, 16),
      severity: severity,
      status: 'Transmis',
    );
    c.timeline.addAll([
      'Double signature',
      'PDF verrouillé',
      'Transmis aux assureurs',
    ]);
    s.addClaim(c);
    Navigator.pop(context);
  }
}
