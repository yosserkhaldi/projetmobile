import 'package:flutter/material.dart';

import 'package:mon_constat_digital/core/theme/app_palette.dart';

import 'package:mon_constat_digital/core/state/app_scope.dart';
import 'package:mon_constat_digital/modules/claims/models/claim.dart';
import 'package:mon_constat_digital/modules/claims/models/claim_insight.dart';
import 'package:mon_constat_digital/modules/claims/models/claim_status.dart';
import 'package:mon_constat_digital/modules/claims/widgets/motion.dart';
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
  bool loading = false;

  /// Gardé dans le store : le résumé survit au défilement et au retour
  /// sur le dossier.
  AiAnswer? get summary =>
      AppScope.of(context).claims.summaries[widget.claim.id];

  Future<void> _summarize() async {
    final sync = AppScope.of(context).claimsSync;
    if (sync == null) return;
    final messenger = ScaffoldMessenger.of(context);
    final unavailable = context.t.claimsSummaryOffline;
    setState(() => loading = true);
    try {
      final store = AppScope.of(context).claims;
      final answer = await sync.api.summarize(widget.claim.id);
      store.summaries[widget.claim.id] = answer;
      if (mounted) setState(() {});
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
                const Icon(Icons.insights, color: ClaimsColors.violet),
                const SizedBox(width: 8),
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
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: ClaimsColors.indigo.withValues(alpha: .14),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.arrow_circle_right,
                      color: ClaimsColors.indigo,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(insight.nextAction!, style: _heading)),
                  ],
                ),
              ),
            const SizedBox(height: 6),
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
                      ? FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: ClaimsColors.amber,
                            foregroundColor: Colors.black,
                            visualDensity: VisualDensity.compact,
                          ),
                          onPressed: () => AppScope.of(context).claims
                              .requestDocument(widget.claim, document.label),
                          icon: const Icon(Icons.send, size: 16),
                          label: Text(t.claimsRequest),
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
            if (summary case final answer?)
              _SummaryBox(answer, onRefresh: loading ? null : _summarize)
            else
              FilledButton.tonalIcon(
                onPressed: loading ? null : _summarize,
                icon: loading
                    ? const SizedBox.square(
                        dimension: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.auto_awesome),
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

/// Le résumé écrit par le modèle, à part du reste : bordure dégradée violet
/// vers rose, icône étincelle et nom du modèle qui l'a écrit.
class _SummaryBox extends StatelessWidget {
  const _SummaryBox(this.answer, {this.onRefresh});
  final AiAnswer answer;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return Appear(
      child: Container(
        padding: const EdgeInsets.all(1.5),
        decoration: BoxDecoration(
          gradient: ClaimsColors.ai,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Color.alphaBlend(
              ClaimsColors.violet.withValues(alpha: .10),
              context.palette.surface,
            ),
            borderRadius: BorderRadius.circular(12.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.auto_awesome,
                    size: 18,
                    color: ClaimsColors.violet,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      t.claimsSummaryTitle,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: ClaimsColors.violet,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: t.claimsSummarize,
                    visualDensity: VisualDensity.compact,
                    onPressed: onRefresh,
                    icon: const Icon(Icons.refresh, size: 18),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(answer.text, style: const TextStyle(height: 1.4)),
              const SizedBox(height: 8),
              Text(
                answer.by != null
                    ? t.claimsSummaryBy(answer.by!)
                    : t.claimsSummaryRules,
                style: _muted(context).copyWith(fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
      ),
    );
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
///
/// Le texte vient du serveur, dans la langue du profil : une phrase par
/// statut, la liste des pièces demandées et le délai restant estimé.
class GuidanceCard extends StatelessWidget {
  const GuidanceCard(this.insight, {required this.status, super.key});
  final ClaimInsight insight;
  final String status;

  /// Étape atteinte : reçu, étude, expertise, décision.
  int get _step => switch (status) {
    ClaimStatus.transmitted => 0,
    ClaimStatus.inReview || ClaimStatus.documentRequested => 1,
    ClaimStatus.expertise => 2,
    ClaimStatus.closed || ClaimStatus.rejected => 3,
    _ => -1,
  };

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    const white = Colors.white;
    final soft = Colors.white.withValues(alpha: .82);
    final steps = [
      t.claimsStepReceived,
      t.claimsStepReview,
      t.claimsStepExpertise,
      t.claimsStepDecision,
    ];
    return Appear(
      child: Container(
        decoration: BoxDecoration(
          gradient: ClaimsColors.guidance,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: ClaimsColors.violet.withValues(alpha: .35),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Floating(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .18),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.route, color: white, size: 22),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    insight.headline ?? '',
                    style: const TextStyle(
                      color: white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _Progress(steps: steps, reached: _step),
            if (insight.todo.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(
                t.claimsYourTodo,
                style: const TextStyle(
                  color: white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              for (final (i, task) in insight.todo.indexed)
                Appear(
                  index: i + 1,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.radio_button_unchecked,
                          size: 18,
                          color: ClaimsColors.amber,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            task,
                            style: const TextStyle(color: white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
            if (insight.remainingDays != null) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: .18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.hourglass_bottom, size: 16, color: white),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        t.claimsRemainingDays(insight.remainingDays!),
                        style: const TextStyle(
                          color: white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                t.claimsEstimateNote,
                style: TextStyle(color: soft, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Quatre pastilles reliées ; le trait se remplit jusqu'à l'étape atteinte.
class _Progress extends StatelessWidget {
  const _Progress({required this.steps, required this.reached});
  final List<String> steps;
  final int reached;

  @override
  Widget build(BuildContext context) {
    Widget dot(int i) {
      final done = i <= reached;
      final current = i == reached;
      final circle = Container(
        width: current ? 26 : 22,
        height: current ? 26 : 22,
        decoration: BoxDecoration(
          color: done ? Colors.white : Colors.white.withValues(alpha: .2),
          shape: BoxShape.circle,
          border: current
              ? Border.all(color: ClaimsColors.amber, width: 3)
              : null,
        ),
        child: done && !current
            ? const Icon(Icons.check, size: 14, color: ClaimsColors.violet)
            : null,
      );
      return current ? Breathing(child: circle) : circle;
    }

    return Column(
      children: [
        Row(
          children: [
            for (var i = 0; i < steps.length; i++) ...[
              dot(i),
              if (i < steps.length - 1)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: GrowingBar(
                      value: i < reached ? 1 : 0,
                      color: Colors.white,
                      track: Colors.white.withValues(alpha: .2),
                      height: 4,
                    ),
                  ),
                ),
            ],
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            for (final (i, label) in steps.indexed)
              Expanded(
                child: Text(
                  label,
                  textAlign: i == 0
                      ? TextAlign.start
                      : i == steps.length - 1
                      ? TextAlign.end
                      : TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(
                      alpha: i <= reached ? 1 : .6,
                    ),
                    fontSize: 11,
                    fontWeight: i == reached ? FontWeight.w800 : null,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
