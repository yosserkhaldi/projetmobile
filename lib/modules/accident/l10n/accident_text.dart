import 'package:mon_constat_digital/l10n/l10n.dart';
import 'package:mon_constat_digital/modules/claims/l10n/claims_text.dart';

/// Traductions du module 3 qui ne sont pas de simples textes d'écran.
///
/// Les valeurs du brouillon (météo, chaussée, luminosité, type, gravité,
/// vues photo, zones de choc, cases) restent en français dans SQLite, sur le
/// serveur et dans le PDF du constat : on les traduit seulement à
/// l'affichage. Une valeur inconnue s'affiche telle quelle.
extension AccidentText on AppLocalizations {
  /// Valeur enregistrée du brouillon, dans la langue de l'écran.
  String accidentValue(String value) => switch (value) {
    'Ensoleillé' => accValueSunny,
    'Pluie' => accValueRain,
    'Brouillard' => accValueFog,
    'Sèche' => accValueDry,
    'Mouillée' => accValueWet,
    'Glissante' => accValueSlippery,
    'Jour' => accValueDay,
    'Crépuscule' => accValueDusk,
    'Nuit éclairée' => accValueNightLit,
    'Nuit sombre' => accValueNightDark,
    'Vue d’ensemble' || "Vue d'ensemble" => accEvidenceOverview,
    'Dégâts véhicule A' => accEvidenceDamageA,
    'Dégâts véhicule B' => accEvidenceDamageB,
    'Plaques' => accEvidencePlates,
    _ => claimValue(value),
  };

  String accidentValues(Iterable<String> values) =>
      values.map(accidentValue).join(', ');

  /// Message d'une AccidentLocationException (écrit en français par le
  /// service), dans la langue de l'écran.
  String accidentLocationError(String message) => switch (message) {
    'Activez la localisation GPS de l’appareil.' => accLocationDisabled,
    'La permission de localisation a été refusée.' => accLocationDenied,
    'Autorisez la localisation dans les paramètres de l’application.' =>
      accLocationDeniedForever,
    'Adresse introuvable.' => accAddressNotFound,
    _ => message,
  };
}
