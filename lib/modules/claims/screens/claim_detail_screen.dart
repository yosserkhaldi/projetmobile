import 'package:flutter/material.dart';

import 'package:mon_constat_digital/core/state/app_scope.dart';
import 'package:mon_constat_digital/core/theme/app_colors.dart';
import 'package:mon_constat_digital/modules/claims/models/claim.dart';
import 'package:mon_constat_digital/modules/claims/models/claim_status.dart';
import 'package:mon_constat_digital/modules/claims/screens/assistant_screen.dart';
import 'package:mon_constat_digital/modules/claims/screens/chat_screen.dart';
import 'package:mon_constat_digital/modules/claims/widgets/agent_panel.dart';
import 'package:mon_constat_digital/modules/claims/widgets/analysis_card.dart';
import 'package:mon_constat_digital/modules/claims/widgets/claim_card.dart';
import 'package:mon_constat_digital/modules/claims/widgets/claim_timeline.dart';
import 'package:mon_constat_digital/modules/claims/widgets/document_picker.dart';
import 'package:mon_constat_digital/modules/claims/widgets/format.dart';
import 'package:mon_constat_digital/shared/navigation.dart';

class ClaimDetail extends StatelessWidget {
  const ClaimDetail(this.claim, {this.agentMode = false, super.key});
  final Claim claim;
  final bool agentMode;

  Future<void> _upload(BuildContext context, {DocumentRequest? request}) async {
    final store = AppScope.of(context).claims;
    final file = await pickDocument();
    if (file == null) return;
    store.addDocument(
      claim,
      file.name,
      path: file.path,
      bytes: file.bytes,
      request: request,
    );
  }

  @override
  Widget build(BuildContext context) {
    final stores = AppScope.of(context);
    final online = stores.claimsSync != null;
    final insight = stores.claims.insightFor(claim.id);
    final requests = claim.openRequests.toList();
    return Scaffold(
      appBar: AppBar(
        title: Text(claim.id),
        actions: [
          if (online)
            IconButton(
              tooltip: 'Assistant',
              onPressed: () => open(context, AssistantScreen(claim)),
              icon: const Icon(Icons.support_agent),
            ),
          IconButton(
            tooltip: 'Messagerie',
            onPressed: () => open(context, ChatScreen(claim)),
            icon: const Icon(Icons.chat_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClaimCard(claim),
          if (insight != null && agentMode && insight.isForAgent) ...[
            const SizedBox(height: 12),
            AnalysisCard(claim, insight),
          ],
          if (insight?.headline != null && !agentMode) ...[
            const SizedBox(height: 12),
            GuidanceCard(insight!),
          ],
          if (claim.status == ClaimStatus.closed ||
              claim.status == ClaimStatus.rejected) ...[
            const SizedBox(height: 12),
            _DecisionSummary(claim),
          ],
          if (requests.isNotEmpty) ...[
            const _Title('Pièces demandées'),
            ...requests.map(
              (request) => Card(
                color: AppColors.warningBg,
                child: ListTile(
                  leading: const Icon(
                    Icons.priority_high,
                    color: AppColors.warningText,
                  ),
                  title: Text(request.label),
                  subtitle: request.note.isEmpty ? null : Text(request.note),
                  trailing: agentMode
                      ? null
                      : TextButton(
                          onPressed: () => _upload(context, request: request),
                          child: const Text('Déposer'),
                        ),
                ),
              ),
            ),
          ],
          if (claim.expertName != null) ...[
            const _Title('Expertise'),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.engineering),
              title: Text(claim.expertName!),
              subtitle: claim.expertAppointment == null
                  ? null
                  : Text(
                      'Rendez-vous le ${formatDay(claim.expertAppointment!)}',
                    ),
            ),
          ],
          const _Title('Chronologie'),
          ClaimTimeline(claim),
          const _Title('Constat'),
          _ConstatSummary(claim),
          const _Title('Pièces du dossier'),
          ...claim.documents.map(
            (document) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.attach_file),
              title: Text(document.name),
              subtitle: Text(_describe(document)),
              trailing: online
                  ? IconButton(
                      tooltip: 'Télécharger',
                      onPressed: () => saveFromServer(
                        context,
                        kind: 'document',
                        id: document.id,
                        name: document.name,
                      ),
                      icon: const Icon(Icons.download),
                    )
                  : null,
            ),
          ),
          if (claim.documents.isEmpty && agentMode)
            const Text(
              'Aucune pièce déposée.',
              style: TextStyle(color: AppColors.textMuted),
            ),
          if (!ClaimStatus.isFinal(claim.status) && !agentMode)
            OutlinedButton.icon(
              onPressed: () => _upload(context),
              icon: const Icon(Icons.upload_file),
              label: const Text('Déposer une pièce'),
            ),
          if (agentMode && !ClaimStatus.isFinal(claim.status)) ...[
            const _Title('Instruction'),
            AgentPanel(claim),
          ],
        ],
      ),
    );
  }
}

String _describe(ClaimDocument document) {
  final analysis = document.analysis;
  if (analysis == null) return document.kind;
  final amount = analysis.amount == null
      ? ''
      : ', ${analysis.amount!.round()} TND';
  final warning = analysis.matches ? '' : ' Ne correspond pas à la demande.';
  return '${analysis.type}$amount. ${analysis.summary}$warning';
}

class _Title extends StatelessWidget {
  const _Title(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 20, bottom: 10),
    child: Text(
      text,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
    ),
  );
}

class _DecisionSummary extends StatelessWidget {
  const _DecisionSummary(this.claim);
  final Claim claim;

  @override
  Widget build(BuildContext context) {
    final rejected = claim.status == ClaimStatus.rejected;
    final share = claim.responsibility;
    return Card(
      color: rejected ? AppColors.errorBg : AppColors.successBg,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              rejected ? 'Dossier rejeté' : 'Dossier clôturé',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            if (claim.decisionReason != null)
              Text('Motif : ${claim.decisionReason}'),
            if (share != null)
              Text('Responsabilité : A $share %, B ${100 - share} %'),
            if (claim.indemnity != null)
              Text(
                'Indemnisation : ${claim.indemnity!.toStringAsFixed(3)} TND',
              ),
          ],
        ),
      ),
    );
  }
}

class _ConstatSummary extends StatelessWidget {
  const _ConstatSummary(this.claim);
  final Claim claim;

  @override
  Widget build(BuildContext context) {
    final rows = [
      if (claim.circumstances.isNotEmpty)
        ('Circonstances', claim.circumstances.join(', ')),
      if (claim.impactZones.isNotEmpty)
        ('Point de choc', claim.impactZones.join(', ')),
      if (claim.observations.isNotEmpty) ('Observations', claim.observations),
    ];
    if (rows.isEmpty) {
      return const Text(
        'Aucune information de constat.',
        style: TextStyle(color: AppColors.textMuted),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (label, value) in rows)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '$label : ',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
