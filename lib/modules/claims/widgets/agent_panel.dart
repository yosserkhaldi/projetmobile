import 'package:flutter/material.dart';

import 'package:mon_constat_digital/core/theme/app_palette.dart';

import 'package:mon_constat_digital/core/state/app_scope.dart';
import 'package:mon_constat_digital/core/theme/app_colors.dart';
import 'package:mon_constat_digital/modules/claims/models/claim.dart';
import 'package:mon_constat_digital/modules/claims/models/claim_status.dart';
import 'package:mon_constat_digital/modules/claims/models/responsibility.dart';
import 'package:mon_constat_digital/modules/claims/widgets/document_picker.dart';
import 'package:mon_constat_digital/modules/claims/widgets/expertise_card.dart';
import 'package:mon_constat_digital/l10n/l10n.dart';
import 'package:mon_constat_digital/modules/claims/l10n/claims_text.dart';

/// Actions de l'agent : seules celles permises par le statut sont proposées.
class AgentPanel extends StatelessWidget {
  const AgentPanel(this.claim, {super.key});
  final Claim claim;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final stores = AppScope.of(context);
    final store = stores.claims;
    final next = ClaimStatus.nextOf(claim.status);
    if (claim.status == ClaimStatus.transmitted) {
      return FilledButton.icon(
        onPressed: () => store.takeCharge(claim, stores.users.userName),
        icon: const Icon(Icons.assignment_ind),
        label: Text(t.claimsTakeCharge),
      );
    }
    if (ClaimStatus.isFinal(claim.status)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            t.claimsReopenHelp,
            style: TextStyle(color: context.palette.textMuted),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => _reopen(context),
            icon: const Icon(Icons.restart_alt),
            label: Text(t.claimsReopen),
          ),
        ],
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
            label: Text(t.claimsRequestDocument),
          ),
          const SizedBox(height: 8),
        ],
        if (inReview || inExpertise) ...[
          OutlinedButton.icon(
            onPressed: () => _appointExpert(context),
            icon: const Icon(Icons.event),
            label: Text(
              inExpertise ? t.claimsMoveAppointment : t.claimsAppointExpert,
            ),
          ),
          const SizedBox(height: 8),
        ],
        if (inExpertise) ...[
          OutlinedButton.icon(
            onPressed: () async {
              final file = await pickDocument();
              if (file == null) return;
              store.addExpertReport(
                claim,
                file.name,
                path: file.path,
                bytes: file.bytes,
              );
            },
            icon: const Icon(Icons.upload_file),
            label: Text(t.claimsAttachReport),
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
            style: TextButton.styleFrom(
              foregroundColor: context.palette.errorText,
            ),
            onPressed: () => _reject(context),
            icon: const Icon(Icons.block),
            label: Text(t.claimsReject),
          ),
      ],
    );
  }

  Future<void> _requestDocument(BuildContext context) async {
    final t = context.t;
    final store = AppScope.of(context).claims;
    var label = DocumentRequest.labels.first;
    final note = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(t.claimsRequestDocument),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: label,
              items: DocumentRequest.labels
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(t.claimValue(e)),
                    ),
                  )
                  .toList(),
              onChanged: (value) => label = value ?? label,
              decoration: InputDecoration(labelText: t.claimsDocument),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: note,
              decoration: InputDecoration(labelText: t.claimsDetail),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(t.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(t.claimsSendRequest),
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
    final t = context.t;
    final store = AppScope.of(context).claims;
    final expert = TextEditingController(text: claim.expertName);
    final phone = TextEditingController(text: claim.expertPhone);
    final place = TextEditingController(text: claim.expertPlace);
    final note = TextEditingController();
    var kind = claim.expertKind ?? defaultExpertKind(claim);
    final suggestions = suggestedSlots(avoid: claim.expertAppointment);
    var appointment = claim.expertAppointment ?? suggestions.first;
    String? error;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
          title: Text(
            claim.status == ClaimStatus.expertise
                ? t.claimsMoveAppointment
                : t.claimsAppointExpert,
          ),
          scrollable: true,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SegmentedButton<String>(
                segments: [
                  for (final (value, icon) in [
                    (vehicleExpertise, Icons.directions_car),
                    (bodilyExpertise, Icons.healing_outlined),
                  ])
                    ButtonSegment(
                      value: value,
                      icon: Icon(icon),
                      label: Text(t.claimValue(value)),
                    ),
                ],
                selected: {kind},
                onSelectionChanged: (value) =>
                    setState(() => kind = value.first),
              ),
              const SizedBox(height: 6),
              Text(
                t.claimsKindHelp,
                style: TextStyle(
                  fontSize: 12,
                  color: dialogContext.palette.textMuted,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: expert,
                decoration: InputDecoration(
                  labelText: t.claimsExpert,
                  errorText: error,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: phone,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(labelText: t.claimsExpertPhone),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: place,
                decoration: InputDecoration(
                  labelText: t.claimsExpertPlace,
                  hintText: kind == bodilyExpertise
                      ? t.claimsPlaceHintBody
                      : t.claimsPlaceHintVehicle,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                t.claimsSuggestedSlots,
                style: TextStyle(color: dialogContext.palette.textMuted),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final slot in suggestions)
                    ChoiceChip(
                      label: Text(formatSlot(dialogContext, slot)),
                      selected: appointment == slot,
                      onSelected: (_) => setState(() => appointment = slot),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () async {
                  final day = await showDatePicker(
                    context: dialogContext,
                    initialDate: appointment.isBefore(DateTime.now())
                        ? DateTime.now()
                        : appointment,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (day == null || !dialogContext.mounted) return;
                  final time = await showTimePicker(
                    context: dialogContext,
                    initialTime: TimeOfDay.fromDateTime(appointment),
                  );
                  if (time == null) return;
                  setState(
                    () => appointment = DateTime(
                      day.year,
                      day.month,
                      day.day,
                      time.hour,
                      time.minute,
                    ),
                  );
                },
                icon: const Icon(Icons.edit_calendar),
                label: Text(formatSlot(dialogContext, appointment)),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: note,
                decoration: InputDecoration(labelText: t.claimsNoteOptional),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(t.cancel),
            ),
            FilledButton(
              onPressed: () {
                if (expert.text.trim().isEmpty) {
                  setState(() => error = t.claimsExpertRequired);
                  return;
                }
                Navigator.pop(dialogContext, true);
              },
              child: Text(t.claimsSchedule),
            ),
          ],
        ),
      ),
    );
    if (confirmed ?? false) {
      store.scheduleExpertise(
        claim,
        expert: expert.text,
        appointment: appointment,
        kind: kind,
        phone: phone.text,
        place: place.text,
        note: note.text,
      );
    }
  }

  Future<void> _reopen(BuildContext context) async {
    final t = context.t;
    final store = AppScope.of(context).claims;
    final reason = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(t.claimsReopen),
        content: TextField(
          controller: reason,
          autofocus: true,
          decoration: InputDecoration(labelText: t.claimsReasonLabel),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(t.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(t.claimsReopenAction),
          ),
        ],
      ),
    );
    if ((confirmed ?? false) && reason.text.trim().isNotEmpty) {
      store.reopenClaim(claim, reason.text);
    }
  }

  Future<void> _reject(BuildContext context) async {
    final t = context.t;
    final store = AppScope.of(context).claims;
    final reason = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(t.claimsReject),
        content: TextField(
          controller: reason,
          decoration: InputDecoration(labelText: t.claimsReasonLabel),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(t.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(t.claimsRejectAction),
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
  late final proposal = ResponsibilityProposal.fromBoxes(
    widget.claim.circumstances,
    widget.claim.circumstancesB,
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
      setState(() => error = context.t.claimsInvalidAmount);
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
          Text(
            context.t.claimsDecision,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            context.t.claimsProposal(
              '${proposal.driverA}',
              '${proposal.driverB}',
              context.t.claimProposalReason(proposal),
            ),
            style: TextStyle(color: context.palette.textMuted),
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
              labelText: context.t.claimsIndemnityAmount,
              errorText: error,
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _close,
            icon: const Icon(Icons.gavel),
            label: Text(context.t.claimsCloseClaim),
          ),
        ],
      ),
    ),
  );
}
