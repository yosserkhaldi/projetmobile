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

  /// Calcule le score de risque pour un véhicule donné.
  RiskScore analyze(Vehicle v) {
    final factors = <RiskFactor>[];
    var score = 0;

    // ── 1. Ancienneté du véhicule (max 25 pts) ─────────────────────────────
    final age = v.vehicleAge;
    if (age >= 20) {
      factors.add(const RiskFactor(
        label: 'Véhicule très ancien',
        contribution: 25,
        description: 'Plus de 20 ans — risque mécanique élevé.',
      ));
      score += 25;
    } else if (age >= 15) {
      factors.add(RiskFactor(
        label: 'Véhicule ancien',
        contribution: 18,
        description: '$age ans — entretien régulier recommandé.',
      ));
      score += 18;
    } else if (age >= 10) {
      factors.add(RiskFactor(
        label: 'Véhicule d\'âge moyen',
        contribution: 10,
        description: '$age ans — vérifier la carte grise.',
      ));
      score += 10;
    }

    // ── 2. Expiration de l'assurance (max 30 pts) ──────────────────────────
    final insExpi = v.daysUntilInsuranceExpiry;
    if (insExpi < 0) {
      factors.add(RiskFactor(
        label: 'Assurance EXPIRÉE',
        contribution: 30,
        description:
            'Expirée depuis ${-insExpi} jour(s) — circuler est illégal.',
      ));
      score += 30;
    } else if (insExpi <= 7) {
      factors.add(RiskFactor(
        label: 'Assurance critique',
        contribution: 22,
        description: 'Expire dans $insExpi jour(s) — renouvelez d\'urgence.',
      ));
      score += 22;
    } else if (insExpi <= 30) {
      factors.add(RiskFactor(
        label: 'Assurance bientôt expirée',
        contribution: 12,
        description: 'Expire dans $insExpi jour(s).',
      ));
      score += 12;
    }

    // ── 3. Visite technique (max 20 pts) ───────────────────────────────────
    final techDays = v.daysUntilTechnicalExpiry;
    if (techDays != null) {
      if (techDays < 0) {
        factors.add(RiskFactor(
          label: 'Visite technique expirée',
          contribution: 20,
          description: 'Expirée depuis ${-techDays} jour(s).',
        ));
        score += 20;
      } else if (techDays <= 15) {
        factors.add(RiskFactor(
          label: 'Visite technique imminente',
          contribution: 14,
          description: 'Dans $techDays jour(s).',
        ));
        score += 14;
      } else if (techDays <= 30) {
        factors.add(RiskFactor(
          label: 'Visite technique proche',
          contribution: 8,
          description: 'Dans $techDays jour(s).',
        ));
        score += 8;
      }
    } else {
      // Date inconnue = risque modéré
      factors.add(const RiskFactor(
        label: 'Visite technique inconnue',
        contribution: 6,
        description: 'Ajoutez la date pour un suivi précis.',
      ));
      score += 6;
    }

    // ── 4. Kilométrage (max 15 pts) ────────────────────────────────────────
    final km = v.mileage;
    if (km != null) {
      if (km > 200000) {
        factors.add(RiskFactor(
          label: 'Kilométrage très élevé',
          contribution: 15,
          description: '${km ~/ 1000} 000 km — usure importante.',
        ));
        score += 15;
      } else if (km > 150000) {
        factors.add(RiskFactor(
          label: 'Kilométrage élevé',
          contribution: 9,
          description: '${km ~/ 1000} 000 km.',
        ));
        score += 9;
      } else if (km > 100000) {
        factors.add(RiskFactor(
          label: 'Kilométrage modéré',
          contribution: 4,
          description: '${km ~/ 1000} 000 km.',
        ));
        score += 4;
      }
    }

    // ── 5. Sinistres passés (max 15 pts) ───────────────────────────────────
    final claims = v.claimCount;
    if (claims >= 3) {
      factors.add(RiskFactor(
        label: 'Historique sinistres élevé',
        contribution: 15,
        description: '$claims sinistre(s) enregistré(s).',
      ));
      score += 15;
    } else if (claims == 2) {
      factors.add(const RiskFactor(
        label: 'Sinistres multiples',
        contribution: 8,
        description: '2 sinistres enregistrés.',
      ));
      score += 8;
    } else if (claims == 1) {
      factors.add(const RiskFactor(
        label: 'Sinistre précédent',
        contribution: 3,
        description: '1 sinistre enregistré.',
      ));
      score += 3;
    }

    // ── 6. Type de carburant (max 5 pts) ───────────────────────────────────
    if (v.fuel == FuelType.diesel && age >= 10) {
      factors.add(const RiskFactor(
        label: 'Diesel ancien',
        contribution: 5,
        description: 'Risque de particules et usure moteur accrue.',
      ));
      score += 5;
    }

    // Plafonner à 100
    final finalScore = score.clamp(0, 100);

    return RiskScore(
      score: finalScore,
      level: _level(finalScore),
      factors: factors,
      recommendations: _recommendations(v, factors),
    );
  }

  static RiskLevel _level(int s) {
    if (s >= 70) return RiskLevel.critical;
    if (s >= 45) return RiskLevel.high;
    if (s >= 20) return RiskLevel.moderate;
    return RiskLevel.low;
  }

  static List<String> _recommendations(Vehicle v, List<RiskFactor> factors) {
    final recs = <String>[];

    if (v.isInsuranceExpired || v.daysUntilInsuranceExpiry <= 7) {
      recs.add('Renouvelez votre assurance immédiatement.');
    } else if (v.isInsuranceUrgent) {
      recs.add('Prenez rendez-vous avec votre assureur dans les prochains jours.');
    }

    if (v.isTechnicalExpired) {
      recs.add('Effectuez votre visite technique au plus tôt.');
    } else if (v.isTechnicalUrgent) {
      recs.add('Programmez votre visite technique prochainement.');
    } else if (v.technicalExpiry == null) {
      recs.add('Ajoutez la date de votre prochaine visite technique.');
    }

    if (v.vehicleAge >= 15) {
      recs.add('Faites une vérification complète chez un garagiste agréé.');
    }

    if (v.mileage != null && v.mileage! > 150000) {
      recs.add('Vérifiez la courroie de distribution et les plaquettes de frein.');
    }

    if (v.claimCount >= 2) {
      recs.add('Envisagez une conduite défensive pour réduire les sinistres.');
    }

    if (v.mileage == null) {
      recs.add('Renseignez le kilométrage pour une analyse plus précise.');
    }

    if (recs.isEmpty) {
      recs.add('Votre véhicule est en règle. Continuez l\'entretien régulier.');
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
