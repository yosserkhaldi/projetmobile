import 'package:mon_constat_digital/l10n/app_localizations.dart';
import 'package:mon_constat_digital/modules/vehicles/models/vehicle.dart';

/// Résultat du score de risque IA.
class RiskScore {
  const RiskScore({
    required this.score,
    required this.level,
    required this.factors,
    required this.recommendations,
  });

  /// Score de 0 (très faible) à 100 (critique).
  final int score;
  final RiskLevel level;

  /// Liste des facteurs qui ont contribué au score.
  final List<RiskFactor> factors;

  /// Conseils personnalisés générés pour ce véhicule.
  final List<String> recommendations;

  bool get isHigh => level == RiskLevel.high || level == RiskLevel.critical;
}

enum RiskLevel { low, moderate, high, critical }

/// Un facteur de risque avec sa contribution et sa description.
class RiskFactor {
  const RiskFactor({
    required this.label,
    required this.contribution,
    required this.description,
  });

  final String label;

  /// Points ajoutés au score total (0–100).
  final int contribution;
  final String description;
}

/// Service d'analyse de risque basé sur des règles métier.
///
/// Pas d'appel réseau : fonctionne entièrement hors-ligne.
/// Algorithme basé sur des règles pondérées de l'assurance automobile
/// tunisienne (FTUSA — Fédération Tunisienne des Sociétés d'Assurance).
///
/// L'amélioration future peut remplacer le calcul par un modèle ML on-device
/// (TFLite) tout en gardant la même interface publique.
class VehicleAiService {
  const VehicleAiService._();

  static const _instance = VehicleAiService._();
  static VehicleAiService get instance => _instance;

  /// Calcule le score de risque pour un véhicule donné ; libellés et
  /// conseils dans la langue [t].
  RiskScore analyze(Vehicle v, AppLocalizations t) {
    final factors = <RiskFactor>[];
    var score = 0;

    // ── 1. Ancienneté du véhicule (max 25 pts) ─────────────────────────────
    final age = v.vehicleAge;
    if (age >= 20) {
      factors.add(RiskFactor(
        label: t.vehRiskVeryOld,
        contribution: 25,
        description: t.vehRiskVeryOldDesc,
      ));
      score += 25;
    } else if (age >= 15) {
      factors.add(RiskFactor(
        label: t.vehRiskOld,
        contribution: 18,
        description: t.vehRiskOldDesc(age),
      ));
      score += 18;
    } else if (age >= 10) {
      factors.add(RiskFactor(
        label: t.vehRiskMidAge,
        contribution: 10,
        description: t.vehRiskMidAgeDesc(age),
      ));
      score += 10;
    }

    // ── 2. Expiration de l'assurance (max 30 pts) ──────────────────────────
    final insExpi = v.daysUntilInsuranceExpiry;
    if (insExpi < 0) {
      factors.add(RiskFactor(
        label: t.vehAlertInsuranceExpired,
        contribution: 30,
        description: t.vehRiskInsExpiredDesc(-insExpi),
      ));
      score += 30;
    } else if (insExpi <= 7) {
      factors.add(RiskFactor(
        label: t.vehRiskInsCritical,
        contribution: 22,
        description: t.vehRiskInsCriticalDesc(insExpi),
      ));
      score += 22;
    } else if (insExpi <= 30) {
      factors.add(RiskFactor(
        label: t.vehRiskInsSoon,
        contribution: 12,
        description: t.vehRiskExpiresIn(insExpi),
      ));
      score += 12;
    }

    // ── 3. Visite technique (max 20 pts) ───────────────────────────────────
    final techDays = v.daysUntilTechnicalExpiry;
    if (techDays != null) {
      if (techDays < 0) {
        factors.add(RiskFactor(
          label: t.vehRiskTechExpired,
          contribution: 20,
          description: t.vehRiskExpiredSince(-techDays),
        ));
        score += 20;
      } else if (techDays <= 15) {
        factors.add(RiskFactor(
          label: t.vehRiskTechImminent,
          contribution: 14,
          description: t.vehRiskInDays(techDays),
        ));
        score += 14;
      } else if (techDays <= 30) {
        factors.add(RiskFactor(
          label: t.vehRiskTechNear,
          contribution: 8,
          description: t.vehRiskInDays(techDays),
        ));
        score += 8;
      }
    } else {
      // Date inconnue = risque modéré
      factors.add(RiskFactor(
        label: t.vehRiskTechUnknown,
        contribution: 6,
        description: t.vehRiskTechUnknownDesc,
      ));
      score += 6;
    }

    // ── 4. Kilométrage (max 15 pts) ────────────────────────────────────────
    final km = v.mileage;
    if (km != null) {
      if (km > 200000) {
        factors.add(RiskFactor(
          label: t.vehRiskKmVeryHigh,
          contribution: 15,
          description: t.vehRiskKmVeryHighDesc(km ~/ 1000),
        ));
        score += 15;
      } else if (km > 150000) {
        factors.add(RiskFactor(
          label: t.vehRiskKmHigh,
          contribution: 9,
          description: t.vehRiskKmDesc(km ~/ 1000),
        ));
        score += 9;
      } else if (km > 100000) {
        factors.add(RiskFactor(
          label: t.vehRiskKmModerate,
          contribution: 4,
          description: t.vehRiskKmDesc(km ~/ 1000),
        ));
        score += 4;
      }
    }

    // ── 5. Sinistres passés (max 15 pts) ───────────────────────────────────
    final claims = v.claimCount;
    if (claims >= 3) {
      factors.add(RiskFactor(
        label: t.vehRiskClaimsHigh,
        contribution: 15,
        description: t.vehRiskClaimsHighDesc(claims),
      ));
      score += 15;
    } else if (claims == 2) {
      factors.add(RiskFactor(
        label: t.vehRiskClaimsMulti,
        contribution: 8,
        description: t.vehRiskClaimsMultiDesc,
      ));
      score += 8;
    } else if (claims == 1) {
      factors.add(RiskFactor(
        label: t.vehRiskClaimsOne,
        contribution: 3,
        description: t.vehRiskClaimsOneDesc,
      ));
      score += 3;
    }

    // ── 6. Type de carburant (max 5 pts) ───────────────────────────────────
    if (v.fuel == FuelType.diesel && age >= 10) {
      factors.add(RiskFactor(
        label: t.vehRiskOldDiesel,
        contribution: 5,
        description: t.vehRiskOldDieselDesc,
      ));
      score += 5;
    }

    // Plafonner à 100
    final finalScore = score.clamp(0, 100);

    return RiskScore(
      score: finalScore,
      level: _level(finalScore),
      factors: factors,
      recommendations: _recommendations(v, factors, t),
    );
  }

  static RiskLevel _level(int s) {
    if (s >= 70) return RiskLevel.critical;
    if (s >= 45) return RiskLevel.high;
    if (s >= 20) return RiskLevel.moderate;
    return RiskLevel.low;
  }

  static List<String> _recommendations(
    Vehicle v,
    List<RiskFactor> factors,
    AppLocalizations t,
  ) {
    final recs = <String>[];

    if (v.isInsuranceExpired || v.daysUntilInsuranceExpiry <= 7) {
      recs.add(t.vehRecRenewNow);
    } else if (v.isInsuranceUrgent) {
      recs.add(t.vehRecSeeInsurer);
    }

    if (v.isTechnicalExpired) {
      recs.add(t.vehRecTechNow);
    } else if (v.isTechnicalUrgent) {
      recs.add(t.vehRecTechSchedule);
    } else if (v.technicalExpiry == null) {
      recs.add(t.vehRecTechAddDate);
    }

    if (v.vehicleAge >= 15) {
      recs.add(t.vehRecFullCheck);
    }

    if (v.mileage != null && v.mileage! > 150000) {
      recs.add(t.vehRecBeltBrakes);
    }

    if (v.claimCount >= 2) {
      recs.add(t.vehRecDefensive);
    }

    if (v.mileage == null) {
      recs.add(t.vehRecAddMileage);
    }

    if (recs.isEmpty) {
      recs.add(t.vehRecAllGood);
    }

    return recs;
  }

  /// Estime la prime d'assurance annuelle en fonction du type de véhicule et du score de risque IA (en TND).
  double estimateAnnualPremium(Vehicle v, RiskScore risk) {
    var base = switch (v.type) {
      VehicleType.car => 650.0,
      VehicleType.moto => 300.0,
      VehicleType.truck => 1400.0,
      VehicleType.van => 950.0,
      VehicleType.other => 700.0,
    };

    final multiplier = 1.0 + (risk.score - 20) / 100.0;
    final estimated = base * multiplier.clamp(0.8, 1.8);
    return estimated.roundToDouble();
  }
}
