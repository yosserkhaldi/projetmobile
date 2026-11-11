import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:mon_constat_digital/core/network/api_client.dart';
import 'package:mon_constat_digital/core/state/app_scope.dart';
import 'package:mon_constat_digital/core/theme/app_colors.dart';
import 'package:mon_constat_digital/core/theme/app_palette.dart';
import 'package:mon_constat_digital/l10n/l10n.dart';
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
    final t = context.t;
    final risk = store.riskScoreFor(current, t);

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
                tooltip: t.vehEdit,
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
                    title: t.vehSectionInfo,
                    items: [
                      _InfoItem(
                        icon: Icons.directions_car_outlined,
                        label: t.vehType,
                        value: _typeLabel(t, current.type),
                      ),
                      _InfoItem(
                        icon: Icons.local_gas_station_outlined,
                        label: t.vehFuel,
                        value: _fuelLabel(t, current.fuel),
                      ),
                      _InfoItem(
                        icon: Icons.calendar_today_outlined,
                        label: t.vehYear,
                        value: current.year,
                      ),
                      if (current.color != null)
                        _InfoItem(
                          icon: Icons.palette_outlined,
                          label: t.vehColor,
                          value: current.color!,
                        ),
                      if (current.mileage != null)
                        _InfoItem(
                          icon: Icons.speed_outlined,
                          label: t.vehMileage,
                          value: t.vehMileageValue(current.mileage! ~/ 1000),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Contrat d'assurance ───────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        t.vehInsuranceContract,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: context.palette.primaryText,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => _showRenewDialog(context, current),
                        icon: const Icon(Icons.refresh, size: 16),
                        label: Text(t.vehRenew),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  _InfoSection(
                    title: '',
                    items: [
                      if (current.insurerName.isNotEmpty)
                        _InfoItem(
                          icon: Icons.business_outlined,
                          label: t.vehInsurer,
                          value: current.insurerName,
                        ),
                      _InfoItem(
                        icon: Icons.article_outlined,
                        label: t.vehPolicyNumber,
                        value: current.policy,
                      ),
                      _InfoItem(
                        icon: Icons.event_outlined,
                        label: t.vehExpiry,
                        value: _fmtDate(current.insuranceExpiry),
                        statusDays: current.daysUntilInsuranceExpiry,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.successBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.successText.withAlpha(50)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.shield_outlined, color: AppColors.successText, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                t.vehPremiumTitle,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.successText,
                                ),
                              ),
                              Text(
                                t.vehPremiumValue(
                                  VehicleAiService.instance
                                      .estimateAnnualPremium(current, risk)
                                      .toStringAsFixed(0),
                                ),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.successText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (current.technicalExpiry != null) ...[
                    const SizedBox(height: 20),
                    _InfoSection(
                      title: t.vehTechnicalInspection,
                      items: [
                        _InfoItem(
                          icon: Icons.build_outlined,
                          label: t.vehNextInspection,
                          value: _fmtDate(current.technicalExpiry!),
                          statusDays: current.daysUntilTechnicalExpiry,
                        ),
                      ],
                    ),
                  ],

                  if (current.claimCount > 0) ...[
                    const SizedBox(height: 20),
                    _InfoSection(
                      title: t.vehClaimsHistory,
                      items: [
                        _InfoItem(
                          icon: Icons.report_outlined,
                          label: t.vehClaimsDeclared,
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

  Future<void> _showRenewDialog(BuildContext context, Vehicle vehicle) async {
    final store = AppScope.of(context).vehicles;
    final t = context.t;
    final policyController = TextEditingController(text: vehicle.policy);
    final expiryController = TextEditingController(
      text: _fmtDate(vehicle.insuranceExpiry),
    );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.vehRenewTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: policyController,
              decoration: InputDecoration(labelText: t.vehPolicyNumber),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: expiryController,
              keyboardType: TextInputType.datetime,
              decoration: InputDecoration(
                labelText: t.vehExpiryDate,
                hintText: t.vehDateHint,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(t.vehCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(t.vehRenew),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final messenger = ScaffoldMessenger.of(context);
      // Une date illisible faisait passer un contrat expiré pour valide.
      final expiry = _isoDate(expiryController.text);
      if (expiry == null || policyController.text.trim().isEmpty) {
        messenger.showSnackBar(
          SnackBar(content: Text(t.vehRenewInvalid)),
        );
        return;
      }
      final updated = vehicle.copyWith(
        policy: policyController.text.trim(),
        insuranceExpiry: expiry,
      );
      try {
        await store.updateVehicle(updated);
      } on ApiException catch (error) {
        messenger.showSnackBar(SnackBar(content: Text(error.message)));
        return;
      }
      messenger.showSnackBar(
        SnackBar(content: Text(t.vehRenewSuccess)),
      );
    }
  }

  /// JJ/MM/AAAA ou AAAA-MM-JJ → AAAA-MM-JJ ; null si la date n'existe pas.
  static String? _isoDate(String input) {
    final text = input.trim();
    final fr = RegExp(r'^(\d{1,2})[/.-](\d{1,2})[/.-](\d{4})$').firstMatch(text);
    final iso = RegExp(r'^(\d{4})-(\d{1,2})-(\d{1,2})$').firstMatch(text);
    final (int? y, int? m, int? d) = fr != null
        ? (int.parse(fr[3]!), int.parse(fr[2]!), int.parse(fr[1]!))
        : iso != null
        ? (int.parse(iso[1]!), int.parse(iso[2]!), int.parse(iso[3]!))
        : (null, null, null);
    if (y == null || m == null || d == null) return null;
    final date = DateTime(y, m, d);
    if (date.year != y || date.month != m || date.day != d) return null;
    String two(int n) => n.toString().padLeft(2, '0');
    return '$y-${two(m)}-${two(d)}';
  }

  String _typeLabel(AppLocalizations t, VehicleType type) => switch (type) {
    VehicleType.car => t.vehTypeCar,
    VehicleType.moto => t.vehTypeMoto,
    VehicleType.truck => t.vehTypeTruck,
    VehicleType.van => t.vehTypeVan,
    VehicleType.other => t.vehOther,
  };

  String _fuelLabel(AppLocalizations t, FuelType f) => switch (f) {
    FuelType.petrol => t.vehFuelPetrol,
    FuelType.diesel => t.vehFuelDiesel,
    FuelType.electric => t.vehFuelElectric,
    FuelType.hybrid => t.vehFuelHybrid,
    FuelType.other => t.vehOther,
  };
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
                    Text(
                      context.t.vehRiskTitle,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      context.t.vehRiskSubtitle,
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
              context.t.vehRiskFactors,
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
        badgeText = context.t.vehExpiredBadge;
      } else if (d <= 7) {
        badgeColor = AppColors.errorText;
        badgeText = context.t.vehDaysShort(d);
      } else if (d <= 30) {
        badgeColor = p.warningText;
        badgeText = context.t.vehDaysShort(d);
      } else {
        badgeColor = AppColors.successText;
        badgeText = context.t.vehStatusOk;
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
          context.t.vehRecommendations,
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
          context.t.vehPhotoTitle,
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
      label: Text(context.t.vehAddPhoto),
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
              title: Text(context.t.vehTakePhoto),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(context.t.vehPickFromGallery),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }
}
