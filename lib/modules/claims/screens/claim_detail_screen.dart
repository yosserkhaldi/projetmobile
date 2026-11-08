import 'package:flutter/material.dart';

import 'package:mon_constat_digital/core/theme/app_palette.dart';

import 'package:mon_constat_digital/core/state/app_scope.dart';
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
import 'package:mon_constat_digital/l10n/l10n.dart';
import 'package:mon_constat_digital/modules/claims/l10n/claims_text.dart';

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
    final t = context.t;
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
              tooltip: t.claimsAssistant,
              onPressed: () => open(context, AssistantScreen(claim)),
              icon: const Icon(Icons.support_agent),
            ),
          IconButton(
            tooltip: t.claimsMessaging,
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
            _Title(t.claimsRequestedDocuments),
            ...requests.map(
              (request) => Card(
                color: context.palette.warningBg,
                child: ListTile(
                  leading: Icon(
                    Icons.priority_high,
                    color: context.palette.warningText,
                  ),
                  title: Text(t.claimValue(request.label)),
                  subtitle: request.note.isEmpty ? null : Text(request.note),
                  trailing: agentMode
                      ? null
                      : TextButton(
                          onPressed: () => _upload(context, request: request),
                          child: Text(t.claimsUpload),
                        ),
                ),
              ),
            ),
          ],
          if (claim.expertName != null) ...[
            _Title(t.claimsExpertiseTitle),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.engineering),
              title: Text(claim.expertName!),
              subtitle: claim.expertAppointment == null
                  ? null
                  : Text(
                      t.claimsAppointmentOn(
                        formatDay(claim.expertAppointment!),
                      ),
                    ),
            ),
          ],
          _Title(t.claimsTimeline),
          ClaimTimeline(claim),
          _Title(t.claimsConstat),
          _ConstatSummary(claim),
          _Title(t.claimsDocuments),
          ...claim.documents.map(
            (document) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(_iconOf(document.kind)),
              title: Text(document.name),
              subtitle: Text(_describe(t, document)),
              trailing: online
                  ? IconButton(
                      tooltip: t.claimsDownload,
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
            Text(
              t.claimsNoDocument,
              style: TextStyle(color: context.palette.textMuted),
            ),
          if (!ClaimStatus.isFinal(claim.status) && !agentMode)
            OutlinedButton.icon(
              onPressed: () => _upload(context),
              icon: const Icon(Icons.upload_file),
              label: Text(t.claimsUploadDocument),
            ),
          if (agentMode && !ClaimStatus.isFinal(claim.status)) ...[
            _Title(t.claimsHandling),
            AgentPanel(claim),
          ],
        ],
      ),
    );
  }
}

IconData _iconOf(String kind) => switch (kind) {
  ClaimDocument.photo => Icons.photo_outlined,
  ClaimDocument.video => Icons.videocam_outlined,
  ClaimDocument.voiceNote => Icons.mic_none,
  ClaimDocument.accidentReport => Icons.picture_as_pdf_outlined,
  _ => Icons.attach_file,
};

/// Le résumé de la pièce vient du modèle de langage, en français : la pièce
/// est lue en arrière-plan, sans utilisateur.
String _describe(AppLocalizations t, ClaimDocument document) {
  final analysis = document.analysis;
  if (analysis == null) return t.claimValue(document.kind);
  final amount = analysis.amount == null
      ? ''
      : ', ${analysis.amount!.round()} TND';
  final warning = analysis.matches ? '' : ' ${t.claimsDocMismatch}';
  return '${t.claimValue(analysis.type)}$amount. ${analysis.summary}$warning';
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
    final t = context.t;
    final rejected = claim.status == ClaimStatus.rejected;
    final share = claim.responsibility;
    return Card(
      color: rejected ? context.palette.errorBg : context.palette.successBg,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              rejected ? t.claimsRejectedTitle : t.claimsClosedTitle,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            if (claim.decisionReason != null)
              Text(t.claimsReason(claim.decisionReason!)),
            if (share != null)
              Text(t.claimsResponsibilitySplit('$share', '${100 - share}')),
            if (claim.indemnity != null)
              Text(t.claimsIndemnity(claim.indemnity!.toStringAsFixed(3))),
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
    final t = context.t;
    final rows = [
      if (claim.circumstances.isNotEmpty)
        (t.claimsCircumstances, t.claimValues(claim.circumstances)),
      if (claim.impactZones.isNotEmpty)
        (t.claimsImpactPoint, t.claimValues(claim.impactZones)),
      if (claim.observations.isNotEmpty)
        (t.claimsObservations, claim.observations),
    ];
    if (rows.isEmpty) {
      return Text(
        t.claimsNoConstat,
        style: TextStyle(color: context.palette.textMuted),
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
                    text: t.claimsLabelColon(label),
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
