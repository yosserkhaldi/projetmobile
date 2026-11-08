import 'package:flutter/material.dart';

import 'package:mon_constat_digital/core/theme/app_palette.dart';

import 'package:mon_constat_digital/core/state/app_scope.dart';
import 'package:mon_constat_digital/modules/claims/models/claim.dart';
import 'package:mon_constat_digital/modules/claims/models/claim_insight.dart';
import 'package:mon_constat_digital/modules/claims/models/claim_status.dart';
import 'package:mon_constat_digital/l10n/l10n.dart';
import 'package:mon_constat_digital/modules/claims/l10n/claims_text.dart';

const _heading = TextStyle(fontWeight: FontWeight.w800);
TextStyle _muted(BuildContext context) =>
    TextStyle(color: context.palette.textMuted, fontSize: 13);

/// Aide à la décision de l'agent : rien ne s'applique sans son action.
class AnalysisCard extends StatefulWidget {
  const AnalysisCard(this.claim, this.insight, {super.key});
  final Claim claim;
  final ClaimInsight insight;

  @override
  State<AnalysisCard> createState() => _AnalysisCardState();
}

class _AnalysisCardState extends State<AnalysisCard> {
  AiAnswer? summary;
  bool loading = false;

  Future<void> _summarize() async {
    final sync = AppScope.of(context).claimsSync;
    if (sync == null) return;
    final messenger = ScaffoldMessenger.of(context);
    final unavailable = context.t.claimsSummaryOffline;
    setState(() => loading = true);
    try {
      final answer = await sync.api.summarize(widget.claim.id);
      if (mounted) setState(() => summary = answer);
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(unavailable)));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final insight = widget.insight;
    final canRequest =
        widget.claim.status == ClaimStatus.inReview ||
        widget.claim.status == ClaimStatus.documentRequested;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    t.claimsDecisionHelp,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ),
                if (insight.overdueDays > 0)
                  _Tag(
                    t.claimsOverdue('${insight.overdueDays}'),
                    context.palette.errorBg,
                    context.palette.errorText,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (insight.nextAction != null)
              Text(insight.nextAction!, style: _heading),
            if (insight.reasons.isNotEmpty)
              Text(insight.reasons.join(' • '), style: _muted(context)),
            const Divider(height: 24),
            if (insight.estimateLow != null)
              _Fact(
                t.claimsEstimate,
                t.claimsRange(
                  '${insight.estimateLow!.round()}',
                  '${insight.estimateHigh!.round()}',
                ),
              ),
            if (insight.totalDays != null)
              _Fact(
                t.claimsUsualDuration,
                t.claimsDays('${insight.totalDays}'),
              ),
            if (insight.riskLevel != null)
              _Fact(
                t.claimsRejectionRisk,
                insight.riskFactors.isEmpty
                    ? t.claimRisk(insight.riskLevel!)
                    : t.claimsRiskWithFactors(
                        t.claimRisk(insight.riskLevel!),
                        insight.riskFactors.join(', '),
                      ),
              ),
            if (insight.recommendExpert)
              _Fact(t.claimsExpertiseTitle, t.claimsRecommended),
            if (insight.signals.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(t.claimsToCheck, style: _heading),
              const SizedBox(height: 4),
              for (final signal in insight.signals)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.flag_outlined,
                        size: 18,
                        color: context.palette.warningText,
                      ),
                      const SizedBox(width: 6),
                      Expanded(child: Text(signal)),
                    ],
                  ),
                ),
            ],
            if (insight.missing.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(t.claimsMissingDocuments, style: _heading),
              for (final document in insight.missing)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(t.claimValue(document.label)),
                  subtitle: Text(document.reason),
                  trailing: canRequest
                      ? TextButton(
                          onPressed: () => AppScope.of(context).claims
                              .requestDocument(widget.claim, document.label),
                          child: Text(t.claimsRequest),
                        )
                      : null,
                ),
            ],
            if (insight.similar.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(t.claimsSimilar, style: _heading),
              const SizedBox(height: 4),
              for (final past in insight.similar)
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    '${past.id} (${past.similarity} %) : ${_outcome(t, past)}',
                    style: _muted(context),
                  ),
                ),
            ],
            const SizedBox(height: 12),
            if (summary != null) ...[
              Text(summary!.text),
              const SizedBox(height: 4),
              Text(
                summary!.by != null
                    ? t.claimsSummaryBy(summary!.by!)
                    : t.claimsSummaryRules,
                style: _muted(context),
              ),
            ] else
              OutlinedButton.icon(
                onPressed: loading ? null : _summarize,
                icon: const Icon(Icons.summarize_outlined),
                label: Text(loading ? t.claimsSummarizing : t.claimsSummarize),
              ),
            const SizedBox(height: 8),
            Text(t.claimsModelDisclaimer, style: _muted(context)),
          ],
        ),
      ),
    );
  }

  String _outcome(AppLocalizations t, SimilarCase past) {
    final parts = [
      t.claimValue(past.outcome),
      if (past.responsibility != null) 'A ${past.responsibility} %',
      if (past.indemnity != null) '${past.indemnity!.round()} TND',
    ];
    return parts.join(', ');
  }
}

class _Fact extends StatelessWidget {
  const _Fact(this.label, this.value);
  final String label, value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 120, child: Text(label, style: _muted(context))),
        Expanded(child: Text(value)),
      ],
    ),
  );
}

class _Tag extends StatelessWidget {
  const _Tag(this.text, this.background, this.foreground);
  final String text;
  final Color background, foreground;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      text,
      style: TextStyle(
        color: foreground,
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

/// Suivi du conducteur : où en est le dossier et ce qu'il doit faire.
class GuidanceCard extends StatelessWidget {
  const GuidanceCard(this.insight, {super.key});
  final ClaimInsight insight;

  @override
  Widget build(BuildContext context) => Card(
    color: context.palette.primaryTint,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(insight.headline ?? '', style: _heading),
          for (final task in insight.todo)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.chevron_right, size: 20),
                  Expanded(child: Text(task)),
                ],
              ),
            ),
          if (insight.remainingDays != null) ...[
            const SizedBox(height: 8),
            Text(
              context.t.claimsRemaining('${insight.remainingDays}'),
              style: _muted(context),
            ),
          ],
        ],
      ),
    ),
  );
}
