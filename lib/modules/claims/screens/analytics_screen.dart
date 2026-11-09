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
  Widget build(BuildContext context) => Scaffold(
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

    final statuses = [
      for (final (i, status) in ClaimStatus.all.indexed)
        if (byStatus[status] case final count? when count > 0)
          (
            label: t.claimValue(status),
            value: count,
            color: ClaimsColors.series[i % ClaimsColors.series.length],
          ),
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            _Tile(
              t.claimsTotal,
              json['total'] as int,
              ClaimsColors.violet,
              Icons.folder_copy_outlined,
            ),
            _Tile(
              t.claimsLate,
              json['overdue'] as int,
              ClaimsColors.coral,
              Icons.alarm,
            ),
          ],
        ),
        Row(
          children: [
            _Tile(
              t.claimsAverageDuration,
              days?.round() ?? 0,
              ClaimsColors.sky,
              Icons.timelapse,
              format: (v) =>
                  days == null ? '—' : t.claimsDaysShort('${v.round()}'),
            ),
            _Tile(
              t.claimsIndemnified,
              (json['totalIndemnity'] as num).round(),
              ClaimsColors.teal,
              Icons.payments_outlined,
            ),
          ],
        ),
        _Title(t.claimsByStatus),
        _Donut(statuses),
        _Title(t.claimsBySeverity),
        _Bars([
          for (final (i, severity) in ['Matériel', 'Léger', 'Grave'].indexed)
            if (bySeverity[severity] case final count?)
              (
                label: t.claimValue(severity),
                value: count,
                color: [
                  ClaimsColors.teal,
                  ClaimsColors.amber,
                  ClaimsColors.coral,
                ][i],
              ),
        ]),
        if (byType.isNotEmpty) ...[
          _Title(t.claimsByType),
          _Bars([
            for (final (i, entry) in byType.entries.indexed)
              (
                label: t.claimValue(entry.key),
                value: entry.value,
                color:
                    ClaimsColors.series[(i + 4) % ClaimsColors.series.length],
              ),
          ]),
        ],
        _Title(t.claimsSystemVsAgents),
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
                  ),
                  if (gap != null) ...[
                    const SizedBox(height: 4),
                    Text(t.claimsAverageGap('${gap.round()}')),
                  ],
                ],
              ),
            ),
          ],
        ),
        if (providers.isNotEmpty) ...[
          _Title(t.claimsAnswersBySource),
          _Bars([
            for (final (i, entry) in providers.entries.indexed)
              (
                label: entry.key,
                value: entry.value,
                color: [
                  ClaimsColors.violet,
                  ClaimsColors.pink,
                  ClaimsColors.sky,
                  ClaimsColors.lime,
                ][i % 4],
              ),
          ]),
        ],
        _Title(t.claimsModel),
        Text(t.claimsModelVersion('${model['version']}')),
        Text(
          t.claimsTrainedOn('${trained['synthetic']}', '${trained['real']}'),
        ),
        Text(
          t.claimsModelTest(
            '${metrics['indemnityMaeTnd']}',
            '${metrics['rejectionAuc']}',
          ),
        ),
        const SizedBox(height: 6),
        Text(
          t.claimsSimulatedWarning,
          style: TextStyle(color: context.palette.textMuted, fontSize: 13),
        ),
      ],
    );
  }
}

typedef _Slice = ({String label, int value, Color color});

class _Tile extends StatelessWidget {
  const _Tile(this.label, this.value, this.color, this.icon, {this.format});
  final String label;
  final int value;
  final Color color;
  final IconData icon;
  final String Function(num value)? format;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Card(
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: AlignmentDirectional.topStart,
            end: AlignmentDirectional.bottomEnd,
            colors: [
              color.withValues(alpha: .25),
              color.withValues(alpha: .05),
            ],
          ),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 4),
            CountUp(
              value,
              format: format,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            Text(label, textAlign: TextAlign.center),
          ],
        ),
      ),
    ),
  );
}

class _Title extends StatelessWidget {
  const _Title(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 22, bottom: 10),
    child: Text(
      text,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
    ),
  );
}

/// Une barre par valeur, de sa couleur, qui pousse depuis le début.
class _Bars extends StatelessWidget {
  const _Bars(this.items);
  final List<_Slice> items;

  @override
  Widget build(BuildContext context) {
    final largest = items.fold(1, (a, b) => a > b.value ? a : b.value);
    return Column(
      children: [
        for (final (i, item) in items.indexed)
          Appear(
            index: i,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(item.label)),
                      Text(
                        '${item.value}',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: item.color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  GrowingBar(
                    value: item.value / largest,
                    color: item.color,
                    height: 12,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Anneau par statut, qui se dessine en tournant ; légende à côté.
class _Donut extends StatelessWidget {
  const _Donut(this.slices);
  final List<_Slice> slices;

  @override
  Widget build(BuildContext context) {
    final total = slices.fold(0, (sum, s) => sum + s.value);
    Widget ring(double progress) => SizedBox.square(
      dimension: 150,
      child: CustomPaint(
        painter: _DonutPainter(slices, progress),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$total',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                context.t.claimsTotal,
                style: TextStyle(color: context.palette.textMuted),
              ),
            ],
          ),
        ),
      ),
    );
    return Wrap(
      spacing: 20,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (reduceMotion(context))
          ring(1)
        else
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 1100),
            curve: Curves.easeOutCubic,
            builder: (_, v, _) => ring(v),
          ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final slice in slices)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: slice.color,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(slice.label),
                    const SizedBox(width: 8),
                    Text(
                      '${slice.value}',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter(this.slices, this.progress);
  final List<_Slice> slices;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final total = slices.fold(0, (sum, s) => sum + s.value);
    if (total == 0) return;
    const stroke = 22.0;
    final rect = Rect.fromLTWH(
      stroke / 2,
      stroke / 2,
      size.width - stroke,
      size.height - stroke,
    );
    const gap = 0.04;
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
            ..strokeWidth = stroke
            ..strokeCap = StrokeCap.round,
        );
      }
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) =>
      old.progress != progress || old.slices != slices;
}

/// Jauge en demi-cercle : part des décisions où l'agent a suivi le système.
class _Gauge extends StatelessWidget {
  const _Gauge(this.value);
  final double? value;

  @override
  Widget build(BuildContext context) {
    Widget gauge(double v) => SizedBox(
      width: 120,
      height: 70,
      child: CustomPaint(
        painter: _GaugePainter(v, context.palette.surfaceAlt),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Text(
            value == null ? '—' : '${(v * 100).round()} %',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
        ),
      ),
    );
    if (reduceMotion(context) || value == null) return gauge(value ?? 0);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: const Duration(milliseconds: 1100),
      curve: Curves.easeOutBack,
      builder: (_, v, _) => gauge(v.clamp(0, 1)),
    );
  }
}

class _GaugePainter extends CustomPainter {
  _GaugePainter(this.value, this.track);
  final double value;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 12.0;
    final rect = Rect.fromLTWH(
      stroke / 2,
      stroke / 2,
      size.width - stroke,
      (size.height - stroke / 2) * 2 - stroke,
    );
    Paint paint(Shader? shader, Color color) => Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = color
      ..shader = shader;
    canvas.drawArc(rect, math.pi, math.pi, false, paint(null, track));
    if (value <= 0) return;
    final shader = const SweepGradient(
      startAngle: math.pi,
      endAngle: 2 * math.pi,
      colors: [ClaimsColors.coral, ClaimsColors.amber, ClaimsColors.teal],
    ).createShader(rect);
    canvas.drawArc(
      rect,
      math.pi,
      math.pi * value,
      false,
      paint(shader, Colors.white),
    );
  }

  @override
  bool shouldRepaint(_GaugePainter old) => old.value != value;
}
