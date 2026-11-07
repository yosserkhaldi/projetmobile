import 'package:flutter/material.dart';

import 'package:mon_constat_digital/core/state/app_scope.dart';
import 'package:mon_constat_digital/core/theme/app_colors.dart';
import 'package:mon_constat_digital/core/theme/app_palette.dart';
import 'package:mon_constat_digital/modules/vehicles/screens/vehicle_detail_screen.dart';
import 'package:mon_constat_digital/modules/vehicles/state/vehicle_store.dart';
import 'package:mon_constat_digital/shared/navigation.dart';

/// Écran des alertes d'échéance — assurance et visite technique.
///
/// Les alertes sont calculées dynamiquement depuis les données des véhicules,
/// pas hardcodées. Chaque alerte ouvre la fiche du véhicule concerné.
class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context).vehicles;
    final alerts = store.alerts;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alertes d\'échéance'),
        actions: [
          if (alerts.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Badge(
                label: Text('${alerts.length}'),
                child: const Icon(Icons.notifications_active_outlined),
              ),
            ),
        ],
      ),
      body: alerts.isEmpty ? _EmptyState() : _AlertList(alerts: alerts),
    );
  }
}

// ── État vide ──────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 72,
            color: AppColors.successText,
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune alerte active',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: p.text,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tous vos contrats et visites techniques\nsont à jour.',
            textAlign: TextAlign.center,
            style: TextStyle(color: p.textMuted),
          ),
        ],
      ),
    );
  }
}

// ── Liste des alertes ──────────────────────────────────────────────────────────

class _AlertList extends StatelessWidget {
  const _AlertList({required this.alerts});
  final List<VehicleAlert> alerts;

  @override
  Widget build(BuildContext context) {
    // Séparer expirés et expirants
    final expired = alerts.where((a) => a.isExpired).toList();
    final expiring = alerts.where((a) => !a.isExpired).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (expired.isNotEmpty) ...[
          _GroupHeader(
            label: 'Expiré(s)',
            icon: Icons.dangerous_outlined,
            color: AppColors.errorText,
          ),
          ...expired.map((a) => _AlertCard(alert: a)),
          const SizedBox(height: 16),
        ],
        if (expiring.isNotEmpty) ...[
          _GroupHeader(
            label: 'Expire bientôt',
            icon: Icons.warning_amber_rounded,
            color: AppColors.accent,
          ),
          ...expiring.map((a) => _AlertCard(alert: a)),
        ],

        // Résumé en bas
        const SizedBox(height: 8),
        _SummaryBanner(alerts: alerts),
      ],
    );
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({
    required this.label,
    required this.icon,
    required this.color,
  });
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8, top: 4),
    child: Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: color,
          ),
        ),
      ],
    ),
  );
}

class _AlertCard extends StatelessWidget {
  const _AlertCard({required this.alert});
  final VehicleAlert alert;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final (bg, fg, icon) = _style(alert, p);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => open(
          context,
          VehicleDetailScreen(vehicle: alert.vehicle),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icône
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: fg, size: 22),
              ),
              const SizedBox(width: 14),

              // Texte
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alert.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: fg,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      alert.subtitle,
                      style: TextStyle(fontSize: 12, color: p.textMuted),
                    ),
                  ],
                ),
              ),

              // Jours restants
              _DaysChip(days: alert.daysRemaining, color: fg, bg: bg),

              const SizedBox(width: 4),
              Icon(Icons.chevron_right, size: 18, color: p.textMuted),
            ],
          ),
        ),
      ),
    );
  }

  (Color bg, Color fg, IconData icon) _style(
    VehicleAlert a,
    AppPalette p,
  ) {
    if (a.isExpired) {
      return (AppColors.errorBg, AppColors.errorText, Icons.dangerous_outlined);
    }
    if (a.daysRemaining <= 7) {
      return (AppColors.errorBg, AppColors.errorText, Icons.warning_rounded);
    }
    return (p.warningBg, p.warningText, Icons.warning_amber_rounded);
  }
}

class _DaysChip extends StatelessWidget {
  const _DaysChip({
    required this.days,
    required this.color,
    required this.bg,
  });
  final int days;
  final Color color, bg;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      days < 0 ? '${-days}j\ndépassé' : '${days}j',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        height: 1.2,
        color: color,
      ),
    ),
  );
}

class _SummaryBanner extends StatelessWidget {
  const _SummaryBanner({required this.alerts});
  final List<VehicleAlert> alerts;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final expired = alerts.where((a) => a.isExpired).length;
    final expiring = alerts.where((a) => !a.isExpired).length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: p.surfaceAlt,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _SummaryItem(
            count: expired,
            label: 'Expirés',
            color: AppColors.errorText,
          ),
          Container(width: 1, height: 32, color: p.border),
          _SummaryItem(
            count: expiring,
            label: 'Proches',
            color: p.warningText,
          ),
          Container(width: 1, height: 32, color: p.border),
          _SummaryItem(
            count: alerts.length,
            label: 'Total',
            color: p.text,
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.count,
    required this.label,
    required this.color,
  });
  final int count;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        '$count',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
      Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: context.palette.textMuted,
        ),
      ),
    ],
  );
}
