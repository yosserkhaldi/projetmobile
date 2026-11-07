import 'package:flutter/material.dart';

import 'package:mon_constat_digital/core/state/app_scope.dart';
import 'package:mon_constat_digital/core/theme/app_colors.dart';
import 'package:mon_constat_digital/modules/claims/models/claim.dart';
import 'package:mon_constat_digital/modules/claims/models/claim_status.dart';
import 'package:mon_constat_digital/modules/claims/models/responsibility.dart';
import 'package:mon_constat_digital/modules/claims/widgets/document_picker.dart';
import 'package:mon_constat_digital/modules/claims/widgets/format.dart';

/// Actions de l'agent : seules celles permises par le statut sont proposées.
class AgentPanel extends StatelessWidget {
  const AgentPanel(this.claim, {super.key});
  final Claim claim;

  @override
  Widget build(BuildContext context) {
    final stores = AppScope.of(context);
    final store = stores.claims;
    final next = ClaimStatus.nextOf(claim.status);
    if (claim.status == ClaimStatus.transmitted) {
      return FilledButton.icon(
        onPressed: () => store.takeCharge(claim, stores.users.userName),
        icon: const Icon(Icons.assignment_ind),
        label: const Text('Prendre en charge'),
      );
    }
    if (next.isEmpty) return const SizedBox.shrink();
    final inReview = claim.status == ClaimStatus.inReview;
    final inExpertise = claim.status == ClaimStatus.expertise;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (inReview || claim.status == ClaimStatus.documentRequested) ...[
          OutlinedButton.icon(
            onPressed: () => _requestDocument(context),
            icon: const Icon(Icons.post_add),
            label: const Text('Demander une pièce'),
          ),
          const SizedBox(height: 8),
        ],
        if (inReview || inExpertise) ...[
          OutlinedButton.icon(
            onPressed: () => _appointExpert(context),
            icon: const Icon(Icons.event),
            label: Text(
              inExpertise ? 'Déplacer le rendez-vous' : 'Désigner un expert',
            ),
          ),
          const SizedBox(height: 8),
        ],
        if (inExpertise) ...[
          OutlinedButton.icon(
            onPressed: () async {
              final file = await pickDocument();
              if (file == null) return;
              store.addExpertReport(claim, file.name, path: file.path);
            },
            icon: const Icon(Icons.upload_file),
            label: const Text('Joindre le rapport d’expertise'),
          ),
          const SizedBox(height: 8),
        ],
        if (next.contains(ClaimStatus.closed)) ...[
          const SizedBox(height: 8),
          _DecisionCard(claim),
          const SizedBox(height: 8),
        ],
        if (next.contains(ClaimStatus.rejected))
          TextButton.icon(
            style: TextButton.styleFrom(foregroundColor: AppColors.errorText),
            onPressed: () => _reject(context),
            icon: const Icon(Icons.block),
            label: const Text('Rejeter le dossier'),
          ),
      ],
    );
  }

  Future<void> _requestDocument(BuildContext context) async {
    final store = AppScope.of(context).claims;
    var label = DocumentRequest.labels.first;
    final note = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Demander une pièce'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: label,
              items: DocumentRequest.labels
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (value) => label = value ?? label,
              decoration: const InputDecoration(labelText: 'Pièce'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: note,
              decoration: const InputDecoration(labelText: 'Précision'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Envoyer la demande'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {
      store.requestDocument(claim, label, note: note.text);
    }
    note.dispose();
  }

  Future<void> _appointExpert(BuildContext context) async {
    final store = AppScope.of(context).claims;
    final expert = TextEditingController(text: claim.expertName);
    var appointment =
        claim.expertAppointment ?? DateTime.now().add(const Duration(days: 2));
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
          title: const Text('Expertise'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: expert,
                decoration: const InputDecoration(labelText: 'Expert'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  final day = await showDatePicker(
                    context: dialogContext,
                    initialDate: appointment,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (day != null) setState(() => appointment = day);
                },
                icon: const Icon(Icons.calendar_month),
                label: Text(formatDay(appointment)),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Planifier'),
            ),
          ],
        ),
      ),
    );
    if ((confirmed ?? false) && expert.text.trim().isNotEmpty) {
      store.scheduleExpertise(claim, expert.text, appointment);
    }
    expert.dispose();
  }

  Future<void> _reject(BuildContext context) async {
    final store = AppScope.of(context).claims;
    final reason = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Rejeter le dossier'),
        content: TextField(
          controller: reason,
          decoration: const InputDecoration(labelText: 'Motif'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Rejeter'),
          ),
        ],
      ),
    );
    if ((confirmed ?? false) && reason.text.trim().isNotEmpty) {
      store.rejectClaim(claim, reason.text);
    }
    reason.dispose();
  }
}

class _DecisionCard extends StatefulWidget {
  const _DecisionCard(this.claim);
  final Claim claim;

  @override
  State<_DecisionCard> createState() => _DecisionCardState();
}

class _DecisionCardState extends State<_DecisionCard> {
  late final proposal = ResponsibilityProposal.fromCircumstances(
    widget.claim.circumstances,
  );
  late int share = widget.claim.responsibility ?? proposal.driverA;
  final amount = TextEditingController();
  String? error;

  @override
  void dispose() {
    amount.dispose();
    super.dispose();
  }

  void _close() {
    final value = double.tryParse(amount.text.trim().replaceAll(',', '.'));
    if (value == null || value < 0) {
      setState(() => error = 'Saisissez un montant valide.');
      return;
    }
    AppScope.of(context).claims.closeClaim(widget.claim, share, value);
  }

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Décision',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            'Proposition : A ${proposal.driverA} %, B ${proposal.driverB} %. '
            '${proposal.reason}',
            style: const TextStyle(color: AppColors.textMuted),
          ),
          const SizedBox(height: 12),
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 0, label: Text('0 %')),
              ButtonSegment(value: 50, label: Text('50 %')),
              ButtonSegment(value: 100, label: Text('100 %')),
            ],
            selected: {share},
            onSelectionChanged: (value) => setState(() => share = value.first),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: SizedBox(
              height: 8,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (share > 0)
                    Expanded(
                      flex: share,
                      child: const ColoredBox(color: AppColors.driverA),
                    ),
                  if (share < 100)
                    Expanded(
                      flex: 100 - share,
                      child: const ColoredBox(color: AppColors.driverB),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: amount,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: "Montant d'indemnisation (TND)",
              errorText: error,
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _close,
            icon: const Icon(Icons.gavel),
            label: const Text('Clôturer le dossier'),
          ),
        ],
      ),
    ),
  );
}
