import 'package:flutter/material.dart';

import 'package:mon_constat_digital/core/theme/app_colors.dart';
import 'package:mon_constat_digital/core/theme/app_palette.dart';

import 'package:mon_constat_digital/core/state/app_scope.dart';
import 'package:mon_constat_digital/modules/claims/models/claim.dart';
import 'package:mon_constat_digital/modules/claims/models/claim_insight.dart';
import 'package:mon_constat_digital/modules/claims/models/claim_status.dart';
import 'package:mon_constat_digital/modules/claims/widgets/motion.dart';
import 'package:mon_constat_digital/l10n/l10n.dart';
import 'package:mon_constat_digital/modules/claims/l10n/claims_text.dart';

const _heading = TextStyle(fontWeight: FontWeight.w600);
TextStyle _muted(BuildContext context) =>
    TextStyle(color: context.palette.textMuted, fontSize: 13);

/// Aide à la décision de l'agent : rien ne s'applique sans son action.
class AnalysisCard extends StatefulWidget {
  const AnalysisCard(this.claim, this.insight, {this.titled = true, super.key});
  final Claim claim;
  final ClaimInsight insight;

  /// Faux dans le panneau latéral, qui porte déjà le titre : la carte
  /// affiche alors le numéro du dossier.
  final bool titled;

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
    final p = context.palette;
    return InkPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (widget.titled) ...[
                Icon(Icons.insights, size: 18, color: p.textMuted),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: widget.titled
                    ? Text(
                        t.claimsDecisionHelp,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    : Text(
                        widget.claim.id,
                        style: TextStyle(
                          fontFamily: 'JetBrainsMono',
                          fontSize: 13,
                          color: p.textMuted,
                        ),
                      ),
              ),
              if (insight.overdueDays > 0)
                QuietTag(
                  t.claimsOverdue('${insight.overdueDays}'),
                  color: p.errorText,
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (insight.nextAction != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              decoration: BoxDecoration(
                color: p.primaryTint,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.arrow_forward, color: p.primaryText, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      insight.nextAction!,
                      style: _heading.copyWith(color: p.primaryText),
                    ),
                  ),
                ],
              ),
            ),
          if (insight.reasons.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(insight.reasons.join(' • '), style: _muted(context)),
          ],
          const SizedBox(height: 12),
          // Les chiffres côte à côte, en bande horizontale : la carte
          // reste courte même quand tout est rempli.
          XStrip(
            children: [
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
                  t.claimRisk(insight.riskLevel!),
                  dot: switch (insight.riskLevel) {
                    'élevé' => ClaimsColors.critical,
                    'moyen' => ClaimsColors.warn,
                    _ => ClaimsColors.ok,
                  },
                ),
              if (insight.recommendExpert)
                _Fact(t.claimsExpertiseTitle, t.claimsRecommended),
            ],
          ),
          if (insight.riskFactors.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '${t.claimsLabelColon(t.claimsRejectionRisk)}'
              '${insight.riskFactors.join(', ')}',
              style: _muted(context),
            ),
          ],
          if (insight.signals.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(t.claimsToCheck, style: _heading),
            const SizedBox(height: 4),
            for (final signal in insight.signals)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: SeriesDot(ClaimsColors.warn, size: 6),
                    ),
                    const SizedBox(width: 4),
                    const SizedBox(width: 6),
                    Expanded(child: Text(signal)),
                  ],
                ),
              ),
          ],
          if (insight.missing.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(t.claimsMissingDocuments, style: _heading),
            for (final document in insight.missing)
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(t.claimValue(document.label)),
                subtitle: Text(document.reason),
                trailing: canRequest
                    ? FilledButton.tonalIcon(
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(40, 36),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          textStyle: const TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onPressed: () => AppScope.of(
                          context,
                        ).claims.requestDocument(widget.claim, document.label),
                        icon: const Icon(Icons.send, size: 16),
                        label: Text(t.claimsRequest),
                      )
                    : null,
              ),
          ],
          if (insight.similar.isNotEmpty) ...[
            const SizedBox(height: 16),
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
          const SizedBox(height: 16),
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
                  : const Icon(Icons.notes, size: 18),
              label: Text(loading ? t.claimsSummarizing : t.claimsSummarize),
            ),
          const SizedBox(height: 8),
          Text(t.claimsModelDisclaimer, style: _muted(context)),
        ],
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

/// Le résumé écrit par le modèle, à part du reste : fond un cran plus
/// marqué, filet, et le nom du modèle qui l'a écrit.
class _SummaryBox extends StatelessWidget {
  const _SummaryBox(this.answer, {this.onRefresh});
  final AiAnswer answer;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final p = context.palette;
    return Appear(
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 4, 12),
        decoration: BoxDecoration(
          color: p.surfaceAlt,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: p.borderSoft),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.notes, size: 16, color: p.textMuted),
                const SizedBox(width: 8),
                Expanded(child: Text(t.claimsSummaryTitle, style: _heading)),
                IconButton(
                  tooltip: t.claimsSummarize,
                  visualDensity: VisualDensity.compact,
                  onPressed: onRefresh,
                  icon: Icon(Icons.refresh, size: 18, color: p.textMuted),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: Text(answer.text, style: const TextStyle(height: 1.45)),
            ),
            const SizedBox(height: 8),
            Text(
              answer.by != null
                  ? t.claimsSummaryBy(answer.by!)
                  : t.claimsSummaryRules,
              style: TextStyle(
                color: p.textMuted,
                fontSize: 12,
                fontFamily: 'JetBrainsMono',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Un chiffre de l'analyse : libellé discret au-dessus, valeur dessous.
class _Fact extends StatelessWidget {
  const _Fact(this.label, this.value, {this.dot});
  final String label, value;
  final Color? dot;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minWidth: 120, maxWidth: 220),
    padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
    decoration: BoxDecoration(
      color: context.palette.surfaceAlt,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _muted(context).copyWith(fontSize: 12)),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (dot != null) ...[SeriesDot(dot!), const SizedBox(width: 6)],
            Flexible(
              child: Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ],
        ),
      ],
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
    final soft = Colors.white.withValues(alpha: .72);
    final faint = Colors.white.withValues(alpha: .56);
    final steps = [
      t.claimsStepReceived,
      t.claimsStepReview,
      t.claimsStepExpertise,
      t.claimsStepDecision,
    ];
    return Appear(
      child: InkPanel(
        ink: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(Icons.route, color: soft, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    insight.headline ?? '',
                    style: const TextStyle(
                      color: white,
                      fontSize: 16,
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _Progress(steps: steps, reached: _step),
            if (insight.todo.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                t.claimsYourTodo,
                style: TextStyle(color: soft, fontSize: 13),
              ),
              for (final (i, task) in insight.todo.indexed)
                Appear(
                  index: i + 1,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 7),
                          child: SeriesDot(AppColors.accent, size: 6),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            task,
                            style: const TextStyle(color: white, height: 1.35),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
            if (insight.late) ...[
              const SizedBox(height: 16),
              Text(
                t.claimsTakingLonger,
                style: const TextStyle(
                  color: white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            if (insight.remainingDays != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .06),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: .10),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.schedule, size: 16, color: soft),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        t.claimsRemainingDays(insight.remainingDays!),
                        style: const TextStyle(
                          color: white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                t.claimsEstimateNote,
                style: TextStyle(color: faint, fontSize: 12),
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
    // Étapes franchies pleines, l'étape en cours en ambre, les suivantes en
    // creux. Rien ne clignote.
    Widget dot(int i) {
      final done = i < reached;
      final current = i == reached;
      return Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          color: done
              ? Colors.white
              : current
              ? AppColors.accent
              : Colors.transparent,
          shape: BoxShape.circle,
          border: done || current
              ? null
              : Border.all(
                  color: Colors.white.withValues(alpha: .28),
                  width: 1.5,
                ),
        ),
        child: done
            ? const Icon(Icons.check, size: 11, color: AppColors.ink)
            : null,
      );
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
                      track: Colors.white.withValues(alpha: .14),
                      height: 2,
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
                      alpha: i <= reached ? .92 : .5,
                    ),
                    fontSize: 11,
                    fontWeight: i == reached ? FontWeight.w600 : null,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
