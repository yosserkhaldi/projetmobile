import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:mon_constat_digital/core/theme/app_colors.dart';
import 'package:mon_constat_digital/core/theme/app_theme.dart';
import 'package:mon_constat_digital/l10n/l10n.dart';
import 'package:mon_constat_digital/modules/claims/l10n/claims_text.dart';
import 'package:mon_constat_digital/modules/users/widgets/dashboard_widgets.dart';

/// Tableau de bord administrateur, accidents et sinistres (modules 3 et 5) :
/// chiffres clés, répartitions, évolution sur six mois et carte des lieux
/// d'accident déclarés.
class ActivityPanel extends StatelessWidget {
  const ActivityPanel({required this.activity, super.key});

  /// `activity` de GET /users/stats.
  final Map<String, dynamic>? activity;

  static const _palette = [
    AppColors.primary,
    AppColors.accent,
    Color(0xFF0EA5A4),
    Color(0xFF8B5CF6),
    Color(0xFFE11D48),
    Color(0xFF64748B),
  ];

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final p = context.palette;
    final a = activity;
    if (a == null) {
      return DashPanel(title: t.dashAccidentsTitle, child: const SizedBox());
    }
    final total = a['claims'] as int;
    final average = a['averageDaysToClose'] as num?;
    final indemnity = (a['indemnityTotal'] as num).round();

    List<(String, int, Color)> parts(
      Map<String, dynamic> counts, {
      String Function(String)? label,
    }) {
      final entries = counts.entries.toList()
        ..sort((x, y) => (y.value as int).compareTo(x.value as int));
      return [
        for (final (i, e) in entries.indexed)
          (
            label?.call(e.key) ?? e.key,
            e.value as int,
            _palette[i % _palette.length],
          ),
      ];
    }

    Widget figure(String value, String caption, {Color? color}) => Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: color ?? p.text,
            ),
          ),
          Text(caption, style: TextStyle(fontSize: 12, color: p.textMuted)),
        ],
      ),
    );

    Widget section(String title, Widget child) => Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: .3,
              color: p.textMuted,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );

    final months = (a['byMonth'] as List).cast<Map<String, dynamic>>();
    final points = (a['points'] as List).cast<Map<String, dynamic>>();
    final companies = (a['byCompany'] as Map<String, dynamic>).map(
      (name, count) => MapEntry(
        name == 'Sans compagnie' ? t.dashNoCompany : name,
        count,
      ),
    );

    return DashPanel(
      title: t.dashAccidentsTitle,
      footer: t.dashIndemnities('$indemnity'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              figure('$total', t.dashClaimsTotal),
              figure(
                '${a['open']}',
                t.dashClaimsOpen,
                color: p.primaryText,
              ),
              figure(
                '${a['closed']}',
                t.dashClaimsClosed,
                color: p.successText,
              ),
              figure(
                average == null ? '—' : t.dashDays('$average'),
                t.dashAvgClose,
              ),
            ],
          ),
          section(
            t.dashByStatus,
            SplitBar(
              total: total,
              parts: parts(
                a['byStatus'] as Map<String, dynamic>,
                label: t.claimValue,
              ),
            ),
          ),
          section(
            t.dashBySeverity,
            SplitBar(
              total: total,
              parts: parts(
                a['bySeverity'] as Map<String, dynamic>,
                label: t.claimValue,
              ),
            ),
          ),
          section(
            t.dashByCompany,
            SplitBar(total: total, parts: parts(companies)),
          ),
          section(
            t.dashByMonth,
            SizedBox(
              height: 110,
              child: SignupBars(
                values: [for (final m in months) m['count'] as int],
              ),
            ),
          ),
          section(
            t.dashHotspots(points.length),
            points.isEmpty
                ? Text(
                    t.dashNoPoints,
                    style: TextStyle(color: p.textMuted),
                  )
                : _HotspotMap(points: points),
          ),
        ],
      ),
    );
  }
}

/// Carte des accidents déclarés : un point par déclaration localisée.
class _HotspotMap extends StatelessWidget {
  const _HotspotMap({required this.points});
  final List<Map<String, dynamic>> points;

  @override
  Widget build(BuildContext context) {
    final coordinates = [
      for (final point in points)
        LatLng(
          (point['lat'] as num).toDouble(),
          (point['lng'] as num).toDouble(),
        ),
    ];
    final fit = coordinates.length == 1
        ? null
        : CameraFit.coordinates(
            coordinates: coordinates,
            padding: const EdgeInsets.all(28),
            maxZoom: 14,
          );
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 220,
        child: FlutterMap(
          options: MapOptions(
            initialCenter: coordinates.first,
            initialZoom: 13,
            initialCameraFit: fit,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'tn.monconstat.app',
            ),
            CircleLayer(
              circles: [
                for (final c in coordinates)
                  CircleMarker(
                    point: c,
                    radius: 9,
                    color: AppColors.accent.withValues(alpha: .75),
                    borderColor: AppColors.ink,
                    borderStrokeWidth: 2,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
