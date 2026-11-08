import 'package:mon_constat_digital/l10n/l10n.dart';
import 'package:mon_constat_digital/modules/claims/models/responsibility.dart';

/// Traductions du module 5 qui ne sont pas de simples textes d'écran.
///
/// Les valeurs enregistrées (statut, type, gravité, cases, pièces) et les
/// textes de la chronologie et des notifications restent en français dans
/// SQLite et sur le serveur : ce sont des données, partagées entre un
/// conducteur et un agent qui n'ont pas forcément la même langue. On les
/// traduit seulement à l'affichage. Une valeur inconnue, comme un texte
/// saisi par l'agent, s'affiche telle quelle.
extension ClaimsText on AppLocalizations {
  /// Statut, type, gravité, circonstance, point de choc ou nature de pièce.
  String claimValue(String value) => switch (value) {
    'Brouillon' => claimsValueDraft,
    'Déclaré' => claimsValueDeclared,
    'Constat signé' => claimsValueSigned,
    'Transmis' => claimsValueTransmitted,
    'En instruction' => claimsValueInReview,
    'Pièce demandée' => claimsValueDocumentRequested,
    'Expertise' => claimsValueExpertise,
    'Clôturé' => claimsValueClosed,
    'Rejeté' => claimsValueRejected,
    'Collision' => claimsValueCollision,
    'Sortie de route' => claimsValueOffRoad,
    'Piéton' => claimsValuePedestrian,
    'Accident matériel' => claimsValueMaterialAccident,
    'Autre' => claimsValueOther,
    'Matériel' => claimsValueMaterial,
    'Léger' => claimsValueLight,
    'Grave' => claimsValueSerious,
    'En stationnement' => claimsValueParked,
    'Quittait un stationnement' => claimsValueLeavingParking,
    'Changeait de file' => claimsValueChangingLane,
    'Doublait' => claimsValueOvertaking,
    'Virait à droite' => claimsValueTurningRight,
    'Virait à gauche' => claimsValueTurningLeft,
    'Reculait' => claimsValueReversing,
    'Avant' => claimsValueFront,
    'Arrière' => claimsValueRear,
    'Côté gauche' => claimsValueLeftSide,
    'Côté droit' => claimsValueRightSide,
    'Devis' => claimsValueQuote,
    'Facture' => claimsValueInvoice,
    'PV de police' => claimsValuePoliceReport,
    "Rapport d'expertise" || 'Rapport d’expertise' => claimsValueExpertReport,
    'Pièce' => claimsValueSupporting,
    'Photo' => claimsValuePhoto,
    'Vidéo' => claimsValueVideo,
    'Note vocale' => claimsValueVoiceNote,
    'Constat amiable' => claimsValueAccidentReport,
    'Véhicule' => claimsValueVehicle,
    'Corporelle' => claimsValueBodily,
    'Rouvert' => claimsValueReopened,
    _ => value,
  };

  String claimValues(Iterable<String> values) =>
      values.map(claimValue).join(', ');

  /// Niveau de risque envoyé par le serveur : faible, moyen ou élevé.
  String claimRisk(String level) => switch (level) {
    'faible' => claimsRiskLow,
    'moyen' => claimsRiskMedium,
    'élevé' => claimsRiskHigh,
    _ => level,
  };

  /// Une étape de la chronologie.
  String claimEvent(String label) {
    final known = switch (label) {
      'Brouillon créé' => claimsEventDraftCreated,
      'Déclaration complétée' => claimsEventDeclared,
      'Double signature' => claimsEventSigned,
      'PDF verrouillé' => claimsEventPdfLocked,
      'Transmis aux assureurs' => claimsEventSent,
      'Rendez-vous déplacé' => claimsEventMoved,
      'Rapport d’expertise joint' => claimsEventReport,
      'Rendez-vous confirmé' => claimsEventConfirmed,
      'Autre créneau proposé' => claimsEventOtherSlot,
      _ => null,
    };
    if (known != null) return known;
    if (RegExp(r'^(\d+) preuves ajoutées$').firstMatch(label) case final m?) {
      return claimsEventEvidence(m[1]!);
    }
    // « Statut : précision », par exemple « Pièce demandée : Devis ».
    if (RegExp(r'^(.+?) : (.+)$').firstMatch(label) case final m?) {
      return claimsEventDetail(claimValue(m[1]!), claimValue(m[2]!));
    }
    return claimValue(label);
  }

  /// Le texte d'une notification, tel que le serveur ou l'appareil l'a écrit.
  String claimNotification(String body) {
    RegExpMatch? match(String pattern) => RegExp(pattern).firstMatch(body);
    if (match(r'^Nouveau sinistre reçu : (\S+)$') case final m?) {
      return claimsNotifNew(ltr(m[1]!));
    }
    if (match(r'^Votre dossier (\S+) est en instruction\.$') case final m?) {
      return claimsNotifInReview(ltr(m[1]!));
    }
    if (match(r'^Votre contrat expire dans (\d+) jours\.$') case final m?) {
      return claimsNotifContract(m[1]!);
    }
    if (match(r'^(\S+) : pièce demandée \((.+)\)$') case final m?) {
      return claimsNotifRequested(ltr(m[1]!), claimValue(m[2]!));
    }
    if (match(r'^(\S+) : pièce déposée \((.+)\)$') case final m?) {
      return claimsNotifUploaded(ltr(m[1]!), m[2]!);
    }
    if (match(r'^(\S+) : rendez-vous d’expertise déplacé$') case final m?) {
      return claimsNotifMoved(ltr(m[1]!));
    }
    if (match(r'^(\S+) : rendez-vous d’expertise confirmé$') case final m?) {
      return claimsNotifConfirmed(ltr(m[1]!));
    }
    if (match(r'^(\S+) : autre créneau proposé pour l’expertise$')
        case final m?) {
      return claimsNotifOtherSlot(ltr(m[1]!));
    }
    if (match(r'^(SIN-\S+) : (.+)$') case final m?) {
      return claimsNotifEvent(ltr(m[1]!), claimEvent(m[2]!));
    }
    return body;
  }

  /// Raison de la proposition de responsabilité, dans la langue de l'écran.
  String claimProposalReason(ResponsibilityProposal proposal) {
    final box = claimValue(proposal.box ?? '');
    return switch (proposal.basis) {
      ProposalBasis.fault => claimsProposalFault(box),
      ProposalBasis.parked => claimsProposalParked,
      ProposalBasis.turn => claimsProposalTurn(box),
      ProposalBasis.unknown => claimsProposalUnknown,
    };
  }
}
