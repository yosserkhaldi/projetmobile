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
import 'package:mon_constat_digital/modules/claims/widgets/expertise_card.dart';
import 'package:mon_constat_digital/modules/claims/widgets/motion.dart';
import 'package:mon_constat_digital/modules/users/models/app_user.dart';
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
    final reports = claim.documents
        .where((d) => d.kind == ClaimDocument.expertReport)
        .toList();
    final files = claim.documents
        .where((d) => d.kind != ClaimDocument.expertReport)
        .toList();
    return ClaimsStyle(
      child: Scaffold(
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
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            ClaimCard(claim),
            if (insight != null && agentMode && insight.isForAgent) ...[
              const SizedBox(height: 12),
              AnalysisCard(claim, insight),
            ],
            if (insight?.headline != null && !agentMode) ...[
              const SizedBox(height: 12),
              GuidanceCard(insight!, status: claim.status),
            ],
            if (claim.status == ClaimStatus.closed ||
                claim.status == ClaimStatus.rejected) ...[
              const SizedBox(height: 12),
              _DecisionSummary(claim),
              if (!agentMode)
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: TextButton.icon(
                    onPressed: () => open(context, ChatScreen(claim)),
                    icon: const Icon(Icons.forum_outlined),
                    label: Text(t.claimsQuestionOnDecision),
                  ),
                ),
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
              ExpertiseCard(
                claim,
                role: agentMode ? UserRole.agent : UserRole.driver,
              ),
            ],
            if (reports.isNotEmpty ||
                (claim.status == ClaimStatus.expertise && !agentMode)) ...[
              _Title(t.claimValue(ClaimDocument.expertReport)),
              _ReportSection(reports, online: online),
            ],
            _Title(t.claimsTimeline),
            ClaimTimeline(claim),
            _Title(t.claimsConstat),
            _ConstatSummary(claim),
            _Title(t.claimsDocuments),
            // Les pièces en bande horizontale : une ligne, quel que soit
            // leur nombre.
            if (files.isNotEmpty)
              XStrip(
                children: [
                  for (final document in files)
                    _DocumentTile(document, online: online),
                ],
              ),
            if (files.isEmpty && agentMode)
              Text(
                t.claimsNoDocument,
                style: TextStyle(color: context.palette.textMuted),
              ),
            if (!ClaimStatus.isFinal(claim.status) && !agentMode) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => _upload(context),
                icon: const Icon(Icons.upload_file),
                label: Text(t.claimsUploadDocument),
              ),
            ],
            if (agentMode) ...[_Title(t.claimsHandling), AgentPanel(claim)],
          ],
        ),
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

/// Le rapport de l'expert, à part : c'est la pièce qui décide du dossier.
/// L'expert n'utilise pas l'application ; il envoie son rapport à
/// l'assureur, et l'agent le joint au dossier.
class _ReportSection extends StatelessWidget {
  const _ReportSection(this.reports, {required this.online});
  final List<ClaimDocument> reports;
  final bool online;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    if (reports.isEmpty) {
      return Text(
        t.claimsReportPending,
        style: TextStyle(color: context.palette.textMuted),
      );
    }
    final p = context.palette;
    return Appear(
      child: InkPanel(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          children: [
            for (final report in reports)
              ListTile(
                leading: Icon(Icons.verified_outlined, color: p.successText),
                title: Text(report.name),
                subtitle: Text(
                  report.analysis == null
                      ? t.claimsReportReceived
                      : _describe(t, report),
                ),
                trailing: online
                    ? IconButton(
                        tooltip: t.claimsDownload,
                        onPressed: () => saveFromServer(
                          context,
                          kind: 'document',
                          id: report.id,
                          name: report.name,
                        ),
                        icon: const Icon(Icons.download, size: 20),
                      )
                    : null,
              ),
          ],
        ),
      ),
    );
  }
}

/// Une pièce : icône, nom, ce que le modèle y a lu, téléchargement.
class _DocumentTile extends StatelessWidget {
  const _DocumentTile(this.document, {required this.online});
  final ClaimDocument document;
  final bool online;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final p = context.palette;
    return SizedBox(
      width: 232,
      child: InkPanel(
        padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(_iconOf(document.kind), size: 20, color: p.textMuted),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    document.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _describe(t, document),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: p.textMuted),
                  ),
                ],
              ),
            ),
            if (online)
              IconButton(
                tooltip: t.claimsDownload,
                visualDensity: VisualDensity.compact,
                onPressed: () => saveFromServer(
                  context,
                  kind: 'document',
                  id: document.id,
                  name: document.name,
                ),
                icon: Icon(Icons.download, size: 18, color: p.textMuted),
              ),
          ],
        ),
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => SectionTitle(text);
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
              style: const TextStyle(fontWeight: FontWeight.w600),
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
        (t.claimsCircumstancesA, t.claimValues(claim.circumstances)),
      if (claim.circumstancesB.isNotEmpty)
        (t.claimsCircumstancesB, t.claimValues(claim.circumstancesB)),
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
                    style: TextStyle(color: context.palette.textMuted),
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
