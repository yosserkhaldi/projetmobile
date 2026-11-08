import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:mon_constat_digital/core/state/app_scope.dart';
import 'package:mon_constat_digital/core/theme/app_colors.dart';
import 'package:mon_constat_digital/core/theme/app_palette.dart';
import 'package:mon_constat_digital/modules/vehicles/models/vehicle.dart';
import 'package:mon_constat_digital/modules/vehicles/screens/vehicle_form_screen.dart';
import 'package:mon_constat_digital/modules/vehicles/services/vehicle_ai_service.dart';
import 'package:mon_constat_digital/shared/navigation.dart';

/// Fiche détaillée d'un véhicule avec analyse de risque IA.
class VehicleDetailScreen extends StatelessWidget {
  const VehicleDetailScreen({required this.vehicle, super.key});
  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context).vehicles;
    // Recharger depuis le store pour avoir la version à jour
    final current = store.all.firstWhere(
      (v) => v.id == vehicle.id,
      orElse: () => vehicle,
    );
    final risk = store.riskScoreFor(current);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── En-tête avec photo ────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                '${current.brand} ${current.model}',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              background: _VehicleHero(vehicle: current),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Modifier',
                onPressed: () {
                  open(context, VehicleFormScreen(existing: current));
                },
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Plaque ───────────────────────────────────────────────
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.ink,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.primaryRaised, width: 2),
                      ),
                      child: Text(
                        current.plate,
                        style: const TextStyle(
                          fontFamily: 'JetBrainsMono',
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Score IA ─────────────────────────────────────────────
                  _RiskScoreCard(risk: risk),
                  const SizedBox(height: 24),

                  // ── Informations véhicule ────────────────────────────────
                  _InfoSection(
                    title: 'Informations',
                    items: [
                      _InfoItem(
                        icon: Icons.directions_car_outlined,
                        label: 'Type',
                        value: _typeLabel(current.type),
                      ),
                      _InfoItem(
                        icon: Icons.local_gas_station_outlined,
                        label: 'Carburant',
                        value: _fuelLabel(current.fuel),
                      ),
                      _InfoItem(
                        icon: Icons.calendar_today_outlined,
                        label: 'Année',
                        value: current.year,
                      ),
                      if (current.color != null)
                        _InfoItem(
                          icon: Icons.palette_outlined,
                          label: 'Couleur',
                          value: current.color!,
                        ),
                      if (current.mileage != null)
                        _InfoItem(
                          icon: Icons.speed_outlined,
                          label: 'Kilométrage',
                          value: '${current.mileage! ~/ 1000} 000 km',
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Contrat d'assurance ───────────────────────────────────
                  _InfoSection(
                    title: 'Contrat d\'assurance',
                    items: [
                      if (current.insurerName.isNotEmpty)
                        _InfoItem(
                          icon: Icons.business_outlined,
                          label: 'Assureur',
                          value: current.insurerName,
                        ),
                      _InfoItem(
                        icon: Icons.article_outlined,
                        label: 'N° de police',
                        value: current.policy,
                      ),
                      _InfoItem(
                        icon: Icons.event_outlined,
                        label: 'Expiration',
                        value: _fmtDate(current.insuranceExpiry),
                        statusDays: current.daysUntilInsuranceExpiry,
                      ),
                    ],
                  ),

                  if (current.technicalExpiry != null) ...[
                    const SizedBox(height: 20),
                    _InfoSection(
                      title: 'Visite technique',
                      items: [
                        _InfoItem(
                          icon: Icons.build_outlined,
                          label: 'Prochaine visite',
                          value: _fmtDate(current.technicalExpiry!),
                          statusDays: current.daysUntilTechnicalExpiry,
                        ),
                      ],
                    ),
                  ],

                  if (current.claimCount > 0) ...[
                    const SizedBox(height: 20),
                    _InfoSection(
                      title: 'Historique sinistres',
                      items: [
                        _InfoItem(
                          icon: Icons.report_outlined,
                          label: 'Sinistres déclarés',
                          value: '${current.claimCount}',
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 24),

                  // ── Recommandations IA ────────────────────────────────────
                  _RecommendationsList(recommendations: risk.recommendations),
                  const SizedBox(height: 24),

                  // ── Photo véhicule ────────────────────────────────────────
                  _PhotoSection(vehicle: current),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _fmtDate(String iso) {
    final dt = DateTime.tryParse(iso);
    if (dt == null) return iso;
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  String _typeLabel(VehicleType t) => const {
    VehicleType.car: 'Voiture',
    VehicleType.moto: 'Moto',
    VehicleType.truck: 'Camion',
    VehicleType.van: 'Camionnette',
    VehicleType.other: 'Autre',
  }[t]!;

  String _fuelLabel(FuelType f) => const {
    FuelType.petrol: 'Essence',
    FuelType.diesel: 'Diesel',
    FuelType.electric: 'Électrique',
    FuelType.hybrid: 'Hybride',
    FuelType.other: 'Autre',
  }[f]!;
}

// ── Hero avec photo ────────────────────────────────────────────────────────────

class _VehicleHero extends StatelessWidget {
  const _VehicleHero({required this.vehicle});
  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    if (vehicle.photoPath != null) {
      return Image.file(
        File(vehicle.photoPath!),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _defaultHero(),
      );
    }
    return _defaultHero();
  }

  Widget _defaultHero() => Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.primary, AppColors.primaryDark],
      ),
    ),
    child: const Center(
      child: Icon(Icons.directions_car, size: 80, color: Colors.white24),
    ),
  );
}

// ── Score IA ──────────────────────────────────────────────────────────────────

class _RiskScoreCard extends StatelessWidget {
  const _RiskScoreCard({required this.risk});
  final RiskScore risk;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final (color, label, bg) = switch (risk.level) {
      RiskLevel.low => (AppColors.successText, 'Faible', AppColors.successBg),
      RiskLevel.moderate => (p.warningText, 'Modéré', p.warningBg),
      RiskLevel.high => (AppColors.accent, 'Élevé', AppColors.warningBg),
      RiskLevel.critical => (
        AppColors.errorText,
        'Critique',
        AppColors.errorBg,
      ),
    };

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(80), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.psychology_outlined, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Analyse de risque IA',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Calculé depuis vos données locales',
                      style: TextStyle(fontSize: 11, color: p.textMuted),
                    ),
                  ],
                ),
              ),
              // Score en anneau
              _ScoreRing(score: risk.score, color: color),
            ],
          ),

          if (risk.factors.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Facteurs détectés',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: p.textMuted,
              ),
            ),
            const SizedBox(height: 8),
            ...risk.factors.map(
              (f) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '+${f.contribution}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            f.label,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            f.description,
                            style: TextStyle(
                              fontSize: 11,
                              color: p.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ScoreRing extends StatelessWidget {
  const _ScoreRing({required this.score, required this.color});
  final int score;
  final Color color;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 64,
    height: 64,
    child: Stack(
      alignment: Alignment.center,
      children: [
        CircularProgressIndicator(
          value: score / 100,
          strokeWidth: 6,
          backgroundColor: Colors.black12,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$score',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            Text(
              '/100',
              style: TextStyle(
                fontSize: 9,
                color: context.palette.textMuted,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

// ── Section info ──────────────────────────────────────────────────────────────

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.title, required this.items});
  final String title;
  final List<_InfoItem> items;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: p.primaryText,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: p.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: p.borderSoft),
          ),
          child: Column(
            children: items.asMap().entries.map((e) {
              final isLast = e.key == items.length - 1;
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: e.value,
                  ),
                  if (!isLast) Divider(height: 1, color: p.borderSoft),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _InfoItem extends StatelessWidget {
  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
    this.statusDays,
  });

  final IconData icon;
  final String label, value;
  final int? statusDays;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    Color? badgeColor;
    String? badgeText;

    if (statusDays != null) {
      final d = statusDays!;
      if (d < 0) {
        badgeColor = AppColors.errorText;
        badgeText = 'EXPIRÉ';
      } else if (d <= 7) {
        badgeColor = AppColors.errorText;
        badgeText = '${d}j';
      } else if (d <= 30) {
        badgeColor = p.warningText;
        badgeText = '${d}j';
      } else {
        badgeColor = AppColors.successText;
        badgeText = 'OK';
      }
    }

    return Row(
      children: [
        Icon(icon, size: 18, color: p.primaryText),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 11, color: p.textMuted)),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: p.text,
                ),
              ),
            ],
          ),
        ),
        if (badgeText != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: badgeColor!.withAlpha(25),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              badgeText,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: badgeColor,
              ),
            ),
          ),
      ],
    );
  }
}

// ── Recommandations ────────────────────────────────────────────────────────────

class _RecommendationsList extends StatelessWidget {
  const _RecommendationsList({required this.recommendations});
  final List<String> recommendations;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recommandations',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: p.primaryText,
          ),
        ),
        const SizedBox(height: 10),
        ...recommendations.asMap().entries.map(
          (e) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 22,
                  height: 22,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.primaryTint,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${e.key + 1}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    e.value,
                    style: TextStyle(fontSize: 14, color: p.text),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Section photo ──────────────────────────────────────────────────────────────

class _PhotoSection extends StatelessWidget {
  const _PhotoSection({required this.vehicle});
  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context).vehicles;
    final p = context.palette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Photo du véhicule',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: p.primaryText,
          ),
        ),
        const SizedBox(height: 10),
        if (vehicle.photoPath != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              File(vehicle.photoPath!),
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _AddPhotoButton(
                vehicle: vehicle,
                store: store,
              ),
            ),
          )
        else
          _AddPhotoButton(vehicle: vehicle, store: store),
      ],
    );
  }
}

class _AddPhotoButton extends StatelessWidget {
  const _AddPhotoButton({required this.vehicle, required this.store});
  final Vehicle vehicle;
  final dynamic store;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () async {
        final picker = ImagePicker();
        final source = await _pickSource(context);
        if (source == null) return;
        final file = await picker.pickImage(source: source, imageQuality: 80);
        if (file != null) {
          final updated = vehicle.copyWith(photoPath: file.path);
          await store.updateVehicle(updated);
        }
      },
      icon: const Icon(Icons.add_a_photo_outlined),
      label: const Text('Ajouter une photo'),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
      ),
    );
  }

  Future<ImageSource?> _pickSource(BuildContext context) async {
    return showModalBottomSheet<ImageSource>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Prendre une photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choisir depuis la galerie'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }
}
