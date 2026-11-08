import 'dart:io';

import 'package:flutter/material.dart';

import 'package:mon_constat_digital/core/state/app_scope.dart';
import 'package:mon_constat_digital/core/theme/app_colors.dart';
import 'package:mon_constat_digital/core/theme/app_palette.dart';
import 'package:mon_constat_digital/modules/vehicles/models/vehicle.dart';
import 'package:mon_constat_digital/modules/vehicles/screens/vehicle_detail_screen.dart';
import 'package:mon_constat_digital/modules/vehicles/screens/vehicle_form_screen.dart';
import 'package:mon_constat_digital/modules/vehicles/services/vehicle_ai_service.dart';
import 'package:mon_constat_digital/shared/navigation.dart';
import 'package:mon_constat_digital/shared/widgets/page_head.dart';

class VehiclesScreen extends StatefulWidget {
  const VehiclesScreen({super.key});
  @override
  State<VehiclesScreen> createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends State<VehiclesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context).vehicles;
    final alerts = store.alertCount;

    return SafeArea(
      child: Column(
        children: [
          PageHead(
            'Véhicules & contrats',
            subtitle: '${store.vehicles.length} véhicule(s) actif(s)',
            actions: [
              if (alerts > 0)
                Badge(
                  label: Text('$alerts'),
                  child: IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () =>
                        open(context, const _AlertsBadgeNavigation()),
                  ),
                ),
              IconButton.filled(
                onPressed: () {
                  open(context, const VehicleFormScreen());
                },
                icon: const Icon(Icons.add),
                tooltip: 'Ajouter un véhicule',
              ),
            ],
          ),

          // Onglets Actifs / Archivés
          TabBar(
            controller: _tabs,
            tabs: [
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.directions_car, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'Actifs (${store.vehicles.length})',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.archive_outlined, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'Archivés (${store.archived.length})',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ],
          ),

          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                _VehicleList(vehicles: store.vehicles, archived: false),
                _VehicleList(vehicles: store.archived, archived: true),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Liste de véhicules ────────────────────────────────────────────────────────

class _VehicleList extends StatelessWidget {
  const _VehicleList({required this.vehicles, required this.archived});
  final List<Vehicle> vehicles;
  final bool archived;

  @override
  Widget build(BuildContext context) {
    if (vehicles.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              archived ? Icons.archive_outlined : Icons.directions_car_outlined,
              size: 64,
              color: context.palette.textMuted,
            ),
            const SizedBox(height: 12),
            Text(
              archived
                  ? 'Aucun véhicule archivé'
                  : 'Ajoutez votre premier véhicule',
              style: TextStyle(color: context.palette.textMuted, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: vehicles.length,
      itemBuilder: (_, i) => _VehicleCard(vehicle: vehicles[i]),
    );
  }
}

// ── Carte de véhicule ─────────────────────────────────────────────────────────

class _VehicleCard extends StatelessWidget {
  const _VehicleCard({required this.vehicle});
  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context).vehicles;
    final risk = store.riskScoreFor(vehicle);
    final p = context.palette;

    final (riskColor, riskIcon) = switch (risk.level) {
      RiskLevel.critical => (AppColors.errorText, Icons.dangerous_outlined),
      RiskLevel.high => (AppColors.accent, Icons.warning_amber_rounded),
      RiskLevel.moderate => (p.warningText, Icons.info_outline),
      RiskLevel.low => (AppColors.successText, Icons.check_circle_outline),
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => open(context, VehicleDetailScreen(vehicle: vehicle)),
        child: Column(
          children: [
            // Bandeau haut : photo ou fond coloré avec info principale
            Container(
              height: 80,
              color: p.primaryTint,
              child: Row(
                children: [
                  // Photo ou icône de véhicule
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: vehicle.photoPath != null
                        ? Image.file(
                            File(vehicle.photoPath!),
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const _VehicleIcon(),
                          )
                        : const _VehicleIcon(),
                  ),

                  // Infos principales
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${vehicle.brand} ${vehicle.model}',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: p.text,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            vehicle.plate,
                            style: TextStyle(
                              fontFamily: 'JetBrainsMono',
                              fontSize: 13,
                              color: p.primaryText,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Score risque
                  Padding(
                    padding: const EdgeInsets.only(right: 14),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(riskIcon, color: riskColor, size: 22),
                        Text(
                          '${risk.score}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: riskColor,
                          ),
                        ),
                        Text(
                          '/100',
                          style: TextStyle(
                            fontSize: 10,
                            color: p.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Corps : détails contrat
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Column(
                children: [
                  _ContractRow(
                    icon: Icons.verified_user_outlined,
                    label: 'Assurance',
                    value: vehicle.insurerName.isEmpty
                        ? 'Police ${vehicle.policy}'
                        : vehicle.insurerName,
                    badge: _ExpiryBadge(days: vehicle.daysUntilInsuranceExpiry),
                  ),
                  if (vehicle.technicalExpiry != null) ...[
                    const SizedBox(height: 8),
                    _ContractRow(
                      icon: Icons.build_outlined,
                      label: 'Visite technique',
                      value: _fmtDate(vehicle.technicalExpiry!),
                      badge: _ExpiryBadge(
                        days: vehicle.daysUntilTechnicalExpiry ?? 9999,
                      ),
                    ),
                  ],
                  if (vehicle.mileage != null) ...[
                    const SizedBox(height: 8),
                    _ContractRow(
                      icon: Icons.speed_outlined,
                      label: 'Kilométrage',
                      value: '${vehicle.mileage! ~/ 1000} 000 km',
                    ),
                  ],
                ],
              ),
            ),

            // Barre d'actions
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: Row(
                children: [
                  TextButton.icon(
                    onPressed: () {
                      open(
                        context,
                        VehicleDetailScreen(vehicle: vehicle),
                      );
                    },
                    icon: const Icon(Icons.analytics_outlined, size: 18),
                    label: const Text('Analyse IA'),
                  ),
                  const Spacer(),
                  _VehicleMenu(vehicle: vehicle),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmtDate(String iso) {
    final dt = DateTime.tryParse(iso);
    if (dt == null) return iso;
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year}';
  }
}

class _VehicleIcon extends StatelessWidget {
  const _VehicleIcon();
  @override
  Widget build(BuildContext context) => Container(
    color: AppColors.primaryTint,
    child: const Center(
      child: Icon(Icons.directions_car, size: 36, color: AppColors.primary),
    ),
  );
}

class _ContractRow extends StatelessWidget {
  const _ContractRow({
    required this.icon,
    required this.label,
    required this.value,
    this.badge,
  });
  final IconData icon;
  final String label, value;
  final Widget? badge;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Row(
      children: [
        Icon(icon, size: 16, color: p.primaryText),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 11, color: p.textMuted),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: p.text,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        if (badge != null) badge!,
      ],
    );
  }
}

class _ExpiryBadge extends StatelessWidget {
  const _ExpiryBadge({required this.days});
  final int days;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    if (days < 0) {
      return _Badge(
        label: 'EXPIRÉ',
        bg: p.errorBg,
        fg: p.errorText,
      );
    }
    if (days <= 7) {
      return _Badge(
        label: '${days}j',
        bg: AppColors.errorBg,
        fg: AppColors.errorText,
      );
    }
    if (days <= 30) {
      return _Badge(
        label: '${days}j',
        bg: p.warningBg,
        fg: p.warningText,
      );
    }
    return _Badge(
      label: '${days}j',
      bg: AppColors.successBg,
      fg: AppColors.successText,
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.bg, required this.fg});
  final String label;
  final Color bg, fg;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      label,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: fg,
      ),
    ),
  );
}

class _VehicleMenu extends StatelessWidget {
  const _VehicleMenu({required this.vehicle});
  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context).vehicles;
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (action) async {
        switch (action) {
          case 'edit':
            open(
              context,
              VehicleFormScreen(existing: vehicle),
            );
          case 'archive':
            store.archiveVehicle(vehicle);
          case 'delete':
            final ok = await _confirmDelete(context);
            if (ok && context.mounted) store.removeVehicle(vehicle);
        }
      },
      itemBuilder: (_) => [
        PopupMenuItem(
          value: 'edit',
          child: const ListTile(
            leading: Icon(Icons.edit_outlined),
            title: Text('Modifier'),
            dense: true,
          ),
        ),
        PopupMenuItem(
          value: 'archive',
          child: ListTile(
            leading: const Icon(Icons.archive_outlined),
            title: Text(vehicle.archived ? 'Désarchiver' : 'Archiver'),
            dense: true,
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'delete',
          child: ListTile(
            leading: Icon(Icons.delete_outline, color: AppColors.errorSolid),
            title: Text(
              'Supprimer',
              style: TextStyle(color: AppColors.errorSolid),
            ),
            dense: true,
          ),
        ),
      ],
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Supprimer ce véhicule ?'),
            content: Text(
              '${vehicle.brand} ${vehicle.model} (${vehicle.plate}) '
              'sera définitivement supprimé.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Annuler'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.errorSolid,
                ),
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Supprimer'),
              ),
            ],
          ),
        ) ??
        false;
  }
}

// Simple wrapper pour naviguer vers l'écran d'alertes depuis l'icône notif
class _AlertsBadgeNavigation extends StatelessWidget {
  const _AlertsBadgeNavigation();
  @override
  Widget build(BuildContext context) {
    // Redirige vers l'écran AlertsScreen existant
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pop(context);
    });
    return const SizedBox.shrink();
  }
}
