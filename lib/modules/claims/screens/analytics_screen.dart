import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:mon_constat_digital/core/theme/app_palette.dart';

import 'package:mon_constat_digital/core/state/app_scope.dart';
import 'package:mon_constat_digital/modules/claims/models/claim_status.dart';
import 'package:mon_constat_digital/modules/claims/widgets/motion.dart';
import 'package:mon_constat_digital/l10n/l10n.dart';
import 'package:mon_constat_digital/modules/claims/l10n/claims_text.dart';

typedef LoadAnalytics = Future<Map<String, dynamic>> Function();

/// Activité de l'équipe et mesure du système face aux décisions réelles.
class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({this.load, super.key});

  /// Remplace l'appel au serveur dans les tests.
  final LoadAnalytics? load;

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  Future<Map<String, dynamic>>? data;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final sync = AppScope.of(context).claimsSync;
    data ??=
        widget.load?.call() ??
        sync?.api.analytics() ??
        Future.error(StateError('Application locale'));
  }

  @override
  Widget build(BuildContext context) => ClaimsStyle(
    child: Scaffold(
      appBar: AppBar(title: Text(context.t.claimsStatistics)),
      body: FutureBuilder(
        future: data,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                context.t.claimsStatsServerOnly,
                style: TextStyle(color: context.palette.textMuted),
              ),
            );
          }
          final json = snapshot.data;
          if (json == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return _Report(json);
        },
      ),
    ),
  );
}

class _Report extends StatelessWidget {
  const _Report(this.json);
  final Map<String, dynamic> json;

  Map<String, int> _counts(String key) =>
      ((json[key] as Map?) ?? const {}).cast<String, int>();

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final p = context.palette;
    final byStatus = _counts('byStatus');
    final bySeverity = _counts('bySeverity');
    final byType = _counts('byType');
    final ai = (json['ai'] as Map).cast<String, dynamic>();
    final providers = ((ai['byProvider'] as Map?) ?? const {})
        .cast<String, int>();
    final model = (json['model'] as Map).cast<String, dynamic>();
    final metrics = (model['metrics'] as Map).cast<String, dynamic>();
    final trained = (model['trainedOn'] as Map).cast<String, dynamic>();
    final days = (json['averageDays'] as num?)?.toDouble();
    final agreement = (ai['agreement'] as num?)?.toDouble();
    final gap = (ai['estimateErrorTnd'] as num?)?.toDouble();
    final compared = ai['decisionsCompared'] as int;
    final overdue = json['overdue'] as int;

    final statuses = [
      for (final (i, status) in ClaimStatus.all.indexed)
        if (byStatus[status] case final count? when count > 0)
          (
            label: t.claimValue(status),
            value: count,
            color: ClaimsColors.series[i % ClaimsColors.series.length],
          ),
    ];
    const severityColors = {
      'Matériel': ClaimsColors.ok,
      'Léger': ClaimsColors.warn,
      'Grave': ClaimsColors.critical,
    };

    // Les panneaux de répartition, côte à côte : on les fait défiler au
    // lieu de les empiler.
    final breakdowns = [
      _Panel(
        title: t.claimsBySeverity,
        width: 280,
        child: _BarGauges([
          for (final MapEntry(key: severity, value: color)
              in severityColors.entries)
            if (bySeverity[severity] case final count?)
              (label: t.claimValue(severity), value: count, color: color),
        ]),
      ),
      if (byType.isNotEmpty)
        _Panel(
          title: t.claimsByType,
          width: 280,
          child: _BarGauges([
            for (final (i, entry) in byType.entries.indexed)
              (
                label: t.claimValue(entry.key),
                value: entry.value,
                color:
                    ClaimsColors.series[(i + 5) % ClaimsColors.series.length],
              ),
          ]),
        ),
      if (providers.isNotEmpty)
        _Panel(
          title: t.claimsAnswersBySource,
          width: 280,
          child: _BarGauges([
            for (final (i, entry) in providers.entries.indexed)
              (
                label: entry.key,
                value: entry.value,
                color:
                    ClaimsColors.series[(i + 2) % ClaimsColors.series.length],
              ),
          ]),
        ),
    ];

    final mono = TextStyle(fontSize: 13, color: p.textMuted, height: 1.4);

    return ListView(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 32),
      children: [
        XStrip(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            _Stat(t.claimsTotal, json['total'] as int, ClaimsColors.info),
            _Stat(
              t.claimsLate,
              overdue,
              overdue > 0 ? ClaimsColors.critical : ClaimsColors.ok,
            ),
            _Stat(
              t.claimsAverageDuration,
              days?.round() ?? 0,
              ClaimsColors.info,
              format: (v) =>
                  days == null ? '—' : t.claimsDaysShort('${v.round()}'),
            ),
            _Stat(
              t.claimsIndemnified,
              (json['totalIndemnity'] as num).round(),
              ClaimsColors.ok,
              unit: 'TND',
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: _Panel(title: t.claimsByStatus, child: _Donut(statuses)),
        ),
        const SizedBox(height: 12),
        XStrip(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: breakdowns,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: _Panel(
            title: t.claimsSystemVsAgents,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _Gauge(compared == 0 ? null : agreement ?? 0),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            compared == 0
                                ? t.claimsNoDecisionYet
                                : t.claimsAgreement(
                                    '$compared',
                                    '${((agreement ?? 0) * 100).round()}',
                                  ),
                            style: const TextStyle(height: 1.4),
                          ),
                          if (gap != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              t.claimsAverageGap('${gap.round()}'),
                              style: TextStyle(color: p.textMuted),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                Divider(height: 24, color: p.borderSoft),
                Text(
                  '${t.claimsModel} · '
                  '${t.claimsModelVersion('${model['version']}')}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  t.claimsTrainedOn(
                    '${trained['synthetic']}',
                    '${trained['real']}',
                  ),
                  style: mono,
                ),
                Text(
                  t.claimsModelTest(
                    '${metrics['indemnityMaeTnd']}',
                    '${metrics['rejectionAuc']}',
                  ),
                  style: mono,
                ),
                const SizedBox(height: 8),
                Text(
                  t.claimsSimulatedWarning,
                  style: TextStyle(color: p.textMuted, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

typedef _Slice = ({String label, int value, Color color});

/// Panneau à la Grafana : titre discret en haut, contenu dessous.
class _Panel extends StatelessWidget {
  const _Panel({required this.title, required this.child, this.width});
  final String title;
  final Widget child;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final panel = InkPanel(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: context.palette.textMuted,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
    return width == null ? panel : SizedBox(width: width, child: panel);
  }
}

/// Panneau « stat » : libellé, valeur en chiffres tabulaires, seuil.
class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value, this.color, {this.format, this.unit});
  final String label;
  final int value;
  final Color color;
  final String Function(num value)? format;
  final String? unit;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return SizedBox(
      width: 152,
      child: InkPanel(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SeriesDot(color),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: p.textMuted),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: AlignmentDirectional.centerStart,
                    child: CountUp(
                      value,
                      format: format,
                      style: TextStyle(
                        fontFamily: 'JetBrainsMono',
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        color: p.text,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                ),
                if (unit != null) ...[
                  const SizedBox(width: 4),
                  Text(
                    unit!,
                    style: TextStyle(fontSize: 12, color: p.textMuted),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Jauges en barres, mode simple de Grafana : libellé, barre fine, valeur.
class _BarGauges extends StatelessWidget {
  const _BarGauges(this.items);
  final List<_Slice> items;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final largest = items.fold(1, (a, b) => a > b.value ? a : b.value);
    return Column(
      children: [
        for (final (i, item) in items.indexed)
          Appear(
            index: i,
            child: Padding(
              padding: EdgeInsets.only(top: i == 0 ? 0 : 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                      Text(
                        '${item.value}',
                        style: TextStyle(
                          fontFamily: 'JetBrainsMono',
                          fontSize: 13,
                          color: p.text,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  GrowingBar(
                    value: item.value / largest,
                    color: item.color,
                    height: 6,
                    track: p.surfaceAlt,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Anneau fin par statut, légende en tableau : valeur et part.
class _Donut extends StatelessWidget {
  const _Donut(this.slices);
  final List<_Slice> slices;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final total = slices.fold(0, (sum, s) => sum + s.value);
    final mono = TextStyle(
      fontFamily: 'JetBrainsMono',
      fontSize: 12,
      color: p.textMuted,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    Widget ring(double progress) => SizedBox.square(
      dimension: 128,
      child: CustomPaint(
        painter: _DonutPainter(slices, progress, p.surfaceAlt),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$total',
                style: TextStyle(
                  fontFamily: 'JetBrainsMono',
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: p.text,
                ),
              ),
              Text(
                t(context),
                style: TextStyle(fontSize: 11, color: p.textMuted),
              ),
            ],
          ),
        ),
      ),
    );
    final legend = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final slice in slices)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                SeriesDot(slice.color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    slice.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
                SizedBox(
                  width: 28,
                  child: Text(
                    '${slice.value}',
                    textAlign: TextAlign.end,
                    style: mono.copyWith(color: p.text),
                  ),
                ),
                SizedBox(
                  width: 44,
                  child: Text(
                    '${(100 * slice.value / (total == 0 ? 1 : total)).round()}%',
                    textAlign: TextAlign.end,
                    style: mono,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
    return Row(
      children: [
        if (reduceMotion(context))
          ring(1)
        else
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (_, v, _) => ring(v),
          ),
        const SizedBox(width: 16),
        Expanded(child: legend),
      ],
    );
  }

  String t(BuildContext context) => context.t.claimsTotal;
}

class _DonutPainter extends CustomPainter {
  _DonutPainter(this.slices, this.progress, this.track);
  final List<_Slice> slices;
  final double progress;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 12.0;
    final rect = Rect.fromLTWH(
      stroke / 2,
      stroke / 2,
      size.width - stroke,
      size.height - stroke,
    );
    canvas.drawArc(
      rect,
      0,
      2 * math.pi,
      false,
      Paint()
        ..color = track
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke,
    );
    final total = slices.fold(0, (sum, s) => sum + s.value);
    if (total == 0) return;
    const gap = 0.02;
    var start = -math.pi / 2;
    final sweepTotal = 2 * math.pi * progress;
    for (final slice in slices) {
      final sweep = sweepTotal * slice.value / total;
      if (sweep > gap) {
        canvas.drawArc(
          rect,
          start + gap / 2,
          sweep - gap,
          false,
          Paint()
            ..color = slice.color
            ..style = PaintingStyle.stroke
            ..strokeWidth = stroke,
        );
      }
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) =>
      old.progress != progress || old.slices != slices || old.track != track;
}

/// Jauge Grafana : arc coloré par seuil, et la bande des seuils en
/// liseré extérieur (rouge sous 50 %, jaune jusqu'à 75 %, vert au-delà).
class _Gauge extends StatelessWidget {
  const _Gauge(this.value);
  final double? value;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    Widget gauge(double v) => SizedBox(
      width: 120,
      height: 72,
      child: CustomPaint(
        painter: _GaugePainter(v, p.surfaceAlt),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: value == null ? '—' : '${(v * 100).round()}',
                  style: TextStyle(
                    fontFamily: 'JetBrainsMono',
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    color: p.text,
                  ),
                ),
                if (value != null)
                  TextSpan(
                    text: '%',
                    style: TextStyle(fontSize: 12, color: p.textMuted),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
    if (reduceMotion(context) || value == null) return gauge(value ?? 0);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (_, v, _) => gauge(v.clamp(0, 1)),
    );
  }
}

class _GaugePainter extends CustomPainter {
  _GaugePainter(this.value, this.track);
  final double value;
  final Color track;

  static Color colorFor(double v) => v >= .75
      ? ClaimsColors.ok
      : v >= .5
      ? ClaimsColors.warn
      : ClaimsColors.critical;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 10.0;
    const band = 3.0;
    // Arc principal, un peu en retrait pour laisser la bande des seuils.
    final outer = Rect.fromLTWH(
      band / 2,
      band / 2,
      size.width - band,
      (size.height - band / 2) * 2 - band,
    );
    final inner = outer.deflate(band + 3 + stroke / 2);
    Paint line(Color color, double width) => Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..color = color;
    for (final (from, to) in [(0.0, .5), (.5, .75), (.75, 1.0)]) {
      canvas.drawArc(
        outer,
        math.pi + math.pi * from,
        math.pi * (to - from) - .02,
        false,
        line(colorFor(from), band),
      );
    }
    canvas.drawArc(inner, math.pi, math.pi, false, line(track, stroke));
    if (value <= 0) return;
    canvas.drawArc(
      inner,
      math.pi,
      math.pi * value,
      false,
      line(colorFor(value), stroke),
    );
  }

  @override
  bool shouldRepaint(_GaugePainter old) =>
      old.value != value || old.track != track;
}
