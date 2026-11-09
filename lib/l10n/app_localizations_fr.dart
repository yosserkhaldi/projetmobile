// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get claimsMyClaims => 'Mes dossiers';

  @override
  String get claimsReceived => 'Sinistres reçus';

  @override
  String claimsCount(String shown, String total) {
    return '$shown sur $total dossiers';
  }

  @override
  String get claimsFilterHint => 'Filtrer par numéro, statut ou gravité';

  @override
  String get claimsStatus => 'Statut';

  @override
  String get claimsSeverity => 'Gravité';

  @override
  String get claimsDate => 'Date';

  @override
  String claimsAllOf(String label) {
    return 'Tous : $label';
  }

  @override
  String get claimsNoMatch => 'Aucun dossier ne correspond.';

  @override
  String get claimsAgentSpace => 'Espace agent';

  @override
  String get claimsAgentSubtitle => 'Instruction des sinistres';

  @override
  String get claimsStatistics => 'Statistiques';

  @override
  String get claimsNotifications => 'Notifications';

  @override
  String get claimsToHandle => 'À traiter';

  @override
  String get claimsExpertises => 'Expertises';

  @override
  String get claimsClosedCount => 'Clôturés';

  @override
  String get claimsPriority => 'Dossiers prioritaires';

  @override
  String get claimsNothingToHandle => 'Aucun dossier à traiter.';

  @override
  String get claimsAssistant => 'Assistant';

  @override
  String get claimsMessaging => 'Messagerie';

  @override
  String get claimsRequestedDocuments => 'Pièces demandées';

  @override
  String get claimsUpload => 'Déposer';

  @override
  String get claimsExpertiseTitle => 'Expertise';

  @override
  String claimsAppointmentOn(String date) {
    return 'Rendez-vous le $date';
  }

  @override
  String get claimsTimeline => 'Chronologie';

  @override
  String get claimsConstat => 'Constat';

  @override
  String get claimsDocuments => 'Pièces du dossier';

  @override
  String get claimsDownload => 'Télécharger';

  @override
  String get claimsNoDocument => 'Aucune pièce déposée.';

  @override
  String get claimsUploadDocument => 'Déposer une pièce';

  @override
  String get claimsHandling => 'Instruction';

  @override
  String get claimsDocMismatch => 'Ne correspond pas à la demande.';

  @override
  String get claimsRejectedTitle => 'Dossier rejeté';

  @override
  String get claimsClosedTitle => 'Dossier clôturé';

  @override
  String claimsReason(String reason) {
    return 'Motif : $reason';
  }

  @override
  String claimsResponsibilitySplit(String a, String b) {
    return 'Responsabilité : A $a %, B $b %';
  }

  @override
  String claimsIndemnity(String amount) {
    return 'Indemnisation : $amount TND';
  }

  @override
  String get claimsCircumstances => 'Circonstances';

  @override
  String get claimsImpactPoint => 'Point de choc';

  @override
  String get claimsObservations => 'Observations';

  @override
  String get claimsNoConstat => 'Aucune information de constat.';

  @override
  String claimsLabelColon(String label) {
    return '$label : ';
  }

  @override
  String get claimsTakeCharge => 'Prendre en charge';

  @override
  String get claimsRequestDocument => 'Demander une pièce';

  @override
  String get claimsMoveAppointment => 'Déplacer le rendez-vous';

  @override
  String get claimsAppointExpert => 'Désigner un expert';

  @override
  String get claimsAttachReport => 'Joindre le rapport d’expertise';

  @override
  String get claimsReject => 'Rejeter le dossier';

  @override
  String get claimsDocument => 'Pièce';

  @override
  String get claimsDetail => 'Précision';

  @override
  String get claimsSendRequest => 'Envoyer la demande';

  @override
  String get claimsExpert => 'Expert';

  @override
  String get claimsSchedule => 'Planifier';

  @override
  String get claimsReasonLabel => 'Motif';

  @override
  String get claimsRejectAction => 'Rejeter';

  @override
  String get claimsInvalidAmount => 'Saisissez un montant valide.';

  @override
  String get claimsDecision => 'Décision';

  @override
  String claimsProposal(String a, String b, String reason) {
    return 'Proposition : A $a %, B $b %. $reason';
  }

  @override
  String get claimsIndemnityAmount => 'Montant d\'indemnisation (TND)';

  @override
  String get claimsCloseClaim => 'Clôturer le dossier';

  @override
  String claimsProposalFault(String box) {
    return '$box : manœuvre à risque de A.';
  }

  @override
  String get claimsProposalParked => 'A était en stationnement.';

  @override
  String claimsProposalTurn(String box) {
    return '$box : partage par défaut.';
  }

  @override
  String get claimsProposalUnknown =>
      'Cases insuffisantes : partage par défaut.';

  @override
  String get claimsSummaryOffline => 'Synthèse indisponible hors connexion.';

  @override
  String get claimsDecisionHelp => 'Aide à la décision';

  @override
  String claimsOverdue(String days) {
    return 'Retard $days j';
  }

  @override
  String get claimsEstimate => 'Estimation';

  @override
  String claimsRange(String low, String high) {
    return '$low à $high TND';
  }

  @override
  String get claimsUsualDuration => 'Durée habituelle';

  @override
  String claimsDays(String days) {
    return '$days jours';
  }

  @override
  String get claimsRejectionRisk => 'Risque de rejet';

  @override
  String get claimsRiskLow => 'faible';

  @override
  String get claimsRiskMedium => 'moyen';

  @override
  String get claimsRiskHigh => 'élevé';

  @override
  String claimsRiskWithFactors(String level, String factors) {
    return '$level : $factors';
  }

  @override
  String get claimsRecommended => 'Recommandée pour ce dossier';

  @override
  String get claimsToCheck => 'À vérifier';

  @override
  String get claimsMissingDocuments => 'Pièces manquantes';

  @override
  String get claimsRequest => 'Demander';

  @override
  String get claimsSimilar => 'Dossiers similaires';

  @override
  String claimsSummaryBy(String by) {
    return 'Synthèse rédigée par $by';
  }

  @override
  String get claimsSummaryRules => 'Synthèse automatique, sans IA générative';

  @override
  String get claimsSummarizing => 'Synthèse en cours';

  @override
  String get claimsSummarize => 'Résumer le dossier';

  @override
  String get claimsModelDisclaimer =>
      'Estimations issues d’un modèle entraîné sur des données simulées. La décision appartient à l’agent.';

  @override
  String get claimsDriverIdea1 => 'Où en est mon dossier ?';

  @override
  String get claimsDriverIdea2 => 'Quelles pièces dois-je déposer ?';

  @override
  String get claimsDriverIdea3 => 'Combien de temps ça va prendre ?';

  @override
  String get claimsAgentIdea1 => 'Que dois-je faire ensuite ?';

  @override
  String get claimsAgentIdea2 => 'Quels points vérifier ?';

  @override
  String get claimsAgentIdea3 => 'Quelle responsabilité proposes-tu ?';

  @override
  String get claimsAssistantUnavailable =>
      'Assistant indisponible pour le moment. Réessayez plus tard.';

  @override
  String claimsAssistantTitle(String id) {
    return 'Assistant $id';
  }

  @override
  String get claimsAssistantIntro =>
      'Posez une question sur ce dossier. L’assistant informe, il ne prend aucune décision.';

  @override
  String get claimsAssistantReading => 'L’assistant lit le dossier…';

  @override
  String get claimsYourQuestion => 'Votre question';

  @override
  String get claimsSend => 'Envoyer';

  @override
  String get claimsAutomaticAnswer => 'Réponse automatique';

  @override
  String get claimsStatsServerOnly =>
      'Statistiques disponibles avec le serveur.';

  @override
  String get claimsTotal => 'Dossiers';

  @override
  String get claimsLate => 'En retard';

  @override
  String get claimsAverageDuration => 'Durée moyenne';

  @override
  String claimsDaysShort(String days) {
    return '$days j';
  }

  @override
  String get claimsIndemnified => 'Indemnisé (TND)';

  @override
  String get claimsByStatus => 'Dossiers par statut';

  @override
  String get claimsSystemVsAgents => 'Le système face aux agents';

  @override
  String get claimsNoDecisionYet => 'Pas encore de décision à comparer.';

  @override
  String claimsAgreement(String count, String percent) {
    return 'Sur $count décision(s), la responsabilité proposée a été retenue dans $percent % des cas.';
  }

  @override
  String claimsAverageGap(String gap) {
    return 'Écart moyen avec le montant décidé : $gap TND.';
  }

  @override
  String get claimsModel => 'Modèle';

  @override
  String claimsModelVersion(String version) {
    return 'Version $version';
  }

  @override
  String claimsTrainedOn(String synthetic, String real) {
    return 'Entraîné sur $synthetic cas simulés et $real dossiers réels.';
  }

  @override
  String claimsModelTest(String mae, String auc) {
    return 'Test : erreur moyenne $mae TND, AUC rejet $auc.';
  }

  @override
  String get claimsSimulatedWarning =>
      'Ces mesures portent sur des données simulées : elles ne disent pas encore si le modèle est juste sur de vrais sinistres.';

  @override
  String get claimsSuggestionsUnavailable => 'Suggestions indisponibles.';

  @override
  String get claimsNoMessages => 'Aucun message sur ce dossier.';

  @override
  String get claimsSuggestReply => 'Suggérer une réponse';

  @override
  String get claimsAttachFile => 'Joindre un fichier';

  @override
  String get claimsYourMessage => 'Votre message';

  @override
  String get claimsOneConversation => 'Une conversation par dossier';

  @override
  String get claimsNoClaims => 'Aucun dossier.';

  @override
  String get claimsNoMessage => 'Aucun message';

  @override
  String get claimsMarkAllRead => 'Tout marquer lu';

  @override
  String get claimsNoNotification => 'Aucune notification.';

  @override
  String get claimsOffline =>
      'Hors ligne : vos changements partiront au retour du réseau';

  @override
  String get claimsFileUnavailable => 'Fichier indisponible pour le moment.';

  @override
  String get claimsValueDraft => 'Brouillon';

  @override
  String get claimsValueDeclared => 'Déclaré';

  @override
  String get claimsValueSigned => 'Constat signé';

  @override
  String get claimsValueTransmitted => 'Transmis';

  @override
  String get claimsValueInReview => 'En instruction';

  @override
  String get claimsValueDocumentRequested => 'Pièce demandée';

  @override
  String get claimsValueExpertise => 'Expertise';

  @override
  String get claimsValueClosed => 'Clôturé';

  @override
  String get claimsValueRejected => 'Rejeté';

  @override
  String get claimsValueCollision => 'Collision';

  @override
  String get claimsValueOffRoad => 'Sortie de route';

  @override
  String get claimsValuePedestrian => 'Piéton';

  @override
  String get claimsValueMaterialAccident => 'Accident matériel';

  @override
  String get claimsValueOther => 'Autre';

  @override
  String get claimsValueMaterial => 'Matériel';

  @override
  String get claimsValueLight => 'Léger';

  @override
  String get claimsValueSerious => 'Grave';

  @override
  String get claimsValueParked => 'En stationnement';

  @override
  String get claimsValueLeavingParking => 'Quittait un stationnement';

  @override
  String get claimsValueChangingLane => 'Changeait de file';

  @override
  String get claimsValueOvertaking => 'Doublait';

  @override
  String get claimsValueTurningRight => 'Virait à droite';

  @override
  String get claimsValueTurningLeft => 'Virait à gauche';

  @override
  String get claimsValueReversing => 'Reculait';

  @override
  String get claimsValueFront => 'Avant';

  @override
  String get claimsValueRear => 'Arrière';

  @override
  String get claimsValueLeftSide => 'Côté gauche';

  @override
  String get claimsValueRightSide => 'Côté droit';

  @override
  String get claimsValueQuote => 'Devis';

  @override
  String get claimsValueInvoice => 'Facture';

  @override
  String get claimsValuePoliceReport => 'PV de police';

  @override
  String get claimsValueExpertReport => 'Rapport d\'expertise';

  @override
  String get claimsValueSupporting => 'Pièce';

  @override
  String get claimsValuePhoto => 'Photo';

  @override
  String get claimsValueVideo => 'Vidéo';

  @override
  String get claimsValueVoiceNote => 'Note vocale';

  @override
  String get claimsValueAccidentReport => 'Constat amiable';

  @override
  String get claimsEventDraftCreated => 'Brouillon créé';

  @override
  String get claimsEventDeclared => 'Déclaration complétée';

  @override
  String claimsEventEvidence(String count) {
    return '$count preuves ajoutées';
  }

  @override
  String get claimsEventSigned => 'Double signature';

  @override
  String get claimsEventPdfLocked => 'PDF verrouillé';

  @override
  String get claimsEventSent => 'Transmis aux assureurs';

  @override
  String get claimsEventMoved => 'Rendez-vous déplacé';

  @override
  String get claimsEventReport => 'Rapport d’expertise joint';

  @override
  String claimsEventDetail(String status, String detail) {
    return '$status : $detail';
  }

  @override
  String claimsNotifNew(String id) {
    return 'Nouveau sinistre reçu : $id';
  }

  @override
  String claimsNotifRequested(String id, String document) {
    return '$id : pièce demandée ($document)';
  }

  @override
  String claimsNotifUploaded(String id, String name) {
    return '$id : pièce déposée ($name)';
  }

  @override
  String claimsNotifMoved(String id) {
    return '$id : rendez-vous d’expertise déplacé';
  }

  @override
  String claimsNotifEvent(String id, String event) {
    return '$id : $event';
  }

  @override
  String claimsNotifInReview(String id) {
    return 'Votre dossier $id est en instruction.';
  }

  @override
  String claimsNotifContract(String days) {
    return 'Votre contrat expire dans $days jours.';
  }

  @override
  String get claimsValueVehicle => 'Véhicule';

  @override
  String get claimsValueBodily => 'Corporelle';

  @override
  String get claimsValueReopened => 'Rouvert';

  @override
  String get claimsEventConfirmed => 'Rendez-vous confirmé';

  @override
  String get claimsEventOtherSlot => 'Autre créneau proposé';

  @override
  String claimsNotifConfirmed(String id) {
    return '$id : rendez-vous d’expertise confirmé';
  }

  @override
  String claimsNotifOtherSlot(String id) {
    return '$id : autre créneau proposé pour l’expertise';
  }

  @override
  String get claimsQuestionOnDecision =>
      'Une question sur la décision ? Écrire à l’agent';

  @override
  String get claimsReportPending =>
      'L’expert envoie son rapport à l’assureur après le rendez-vous. Il apparaîtra ici.';

  @override
  String get claimsReportReceived => 'Rapport de l’expert, joint par l’agent';

  @override
  String get claimsReopen => 'Rouvrir le dossier';

  @override
  String get claimsReopenHelp =>
      'En cas d’erreur, rouvrez le dossier : il revient en instruction et la décision précédente reste dans la chronologie.';

  @override
  String get claimsReopenAction => 'Rouvrir';

  @override
  String get claimsKindHelp =>
      'Corporelle : examen médical d’une personne blessée, un piéton par exemple. Aucun véhicule à présenter.';

  @override
  String get claimsExpertPhone => 'Téléphone de l’expert';

  @override
  String get claimsExpertPlace => 'Lieu du rendez-vous';

  @override
  String get claimsPlaceHintBody => 'Cabinet médical, clinique…';

  @override
  String get claimsPlaceHintVehicle => 'Garage, agence, domicile…';

  @override
  String get claimsSuggestedSlots => 'Créneaux suggérés';

  @override
  String get claimsNoteOptional => 'Message (facultatif)';

  @override
  String get claimsExpertRequired => 'Indiquez le nom de l’expert.';

  @override
  String get claimsSlotConfirmed => 'Confirmé';

  @override
  String get claimsSlotYourTurn => 'À confirmer';

  @override
  String get claimsSlotWaitingAgent => 'En attente de l’agent';

  @override
  String get claimsSlotWaitingDriver => 'En attente du conducteur';

  @override
  String get claimsExpertiseBody => 'Expertise médicale';

  @override
  String get claimsExpertiseVehicle => 'Expertise du véhicule';

  @override
  String get claimsPlaceFromExpert => 'Lieu communiqué par l’expert';

  @override
  String get claimsFromDriver => 'Du conducteur';

  @override
  String get claimsFromAgent => 'De l’agent';

  @override
  String get claimsToBring => 'À apporter';

  @override
  String get claimsBringId => 'Votre pièce d’identité';

  @override
  String get claimsBringCertificates => 'Les certificats médicaux';

  @override
  String get claimsBringPrescriptions => 'Les ordonnances et factures de soins';

  @override
  String get claimsBringVehicle => 'Le véhicule, non réparé';

  @override
  String get claimsBringRegistration => 'La carte grise';

  @override
  String get claimsBringLicence => 'Le permis de conduire';

  @override
  String get claimsBringInsurance => 'L’attestation d’assurance';

  @override
  String get claimsAccept => 'Accepter';

  @override
  String get claimsProposeOther => 'Proposer un autre créneau';

  @override
  String get claimsCannotCome => 'Je ne peux plus venir';

  @override
  String get claimsOtherDateTime => 'Autre date et heure';

  @override
  String get claimsSendProposal => 'Envoyer la proposition';

  @override
  String get claimsStepReceived => 'Reçu';

  @override
  String get claimsStepReview => 'Étude';

  @override
  String get claimsStepExpertise => 'Expertise';

  @override
  String get claimsStepDecision => 'Décision';

  @override
  String get claimsYourTodo => 'À faire';

  @override
  String claimsRemainingDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Encore environ $days jours',
      one: 'Encore environ 1 jour',
    );
    return '$_temp0';
  }

  @override
  String get claimsEstimateNote => 'Estimation, pas un engagement.';

  @override
  String get claimsTakingLonger =>
      'Votre dossier prend plus de temps que d’habitude. Vous pouvez écrire à votre agent.';

  @override
  String get claimsCircumstancesA => 'Circonstances de A';

  @override
  String get claimsCircumstancesB => 'Circonstances de B';

  @override
  String claimsProposalFaultB(String box) {
    return '$box : manœuvre à risque de B.';
  }

  @override
  String claimsProposalBoth(String a, String b) {
    return 'A : $a, B : $b. Manœuvres à risque des deux côtés : partage.';
  }

  @override
  String get claimsProposalParkedB => 'B était en stationnement.';

  @override
  String get claimsNoCompany => 'Compagnie non renseignée';

  @override
  String claimsEventSealed(String hash) {
    return 'Constat scellé (SHA-256 $hash)';
  }

  @override
  String claimsEventSealedLocal(String hash) {
    return 'Constat scellé sur le téléphone (SHA-256 $hash)';
  }

  @override
  String get claimsEventWaitingSync => 'En attente de connexion pour l’envoi';

  @override
  String get claimsSummaryTitle => 'Résumé du dossier';

  @override
  String claimsPriorityScore(String score) {
    return 'Priorité $score';
  }

  @override
  String get claimsSearchMine => 'Rechercher dans mes dossiers';

  @override
  String get claimsBySeverity => 'Par gravité';

  @override
  String get claimsByType => 'Par type d’accident';

  @override
  String get claimsAnswersBySource => 'Réponses par source';

  @override
  String get appTitle => 'Mon Constat Digital';

  @override
  String get brand => 'Mon Constat';

  @override
  String get save => 'Enregistrer';

  @override
  String get cancel => 'Annuler';

  @override
  String get delete => 'Supprimer';

  @override
  String get edit => 'Modifier';

  @override
  String get retry => 'Réessayer';

  @override
  String get later => 'Plus tard';

  @override
  String get or => 'ou';

  @override
  String get validate => 'Valider';

  @override
  String get notProvided => 'Non renseigné';

  @override
  String get requiredField => 'Champ obligatoire.';

  @override
  String get invalidEmail => 'Adresse e-mail invalide.';

  @override
  String get invalidPhone => 'Numéro de téléphone invalide.';

  @override
  String get passwordTooShort =>
      'Le mot de passe doit contenir au moins 8 caractères.';

  @override
  String get codeFormat => 'Le code contient 6 chiffres.';

  @override
  String get passwordsDontMatch => 'Les mots de passe ne correspondent pas.';

  @override
  String get roleDriver => 'Conducteur';

  @override
  String get roleAgent => 'Agent d\'assurance';

  @override
  String get roleAdmin => 'Administrateur';

  @override
  String get heroTitleLine1 => 'Le constat,';

  @override
  String get heroTitleLine2 => 'sans papier.';

  @override
  String get heroSubtitle =>
      'Déclarez, signez et suivez votre sinistre depuis votre téléphone.';

  @override
  String get loginTitle => 'Connexion';

  @override
  String get identifierLabel => 'E-mail ou téléphone';

  @override
  String get passwordLabel => 'Mot de passe';

  @override
  String get forgotPasswordLink => 'Mot de passe oublié ?';

  @override
  String get signIn => 'Se connecter';

  @override
  String get biometricButton => 'Empreinte ou Face ID';

  @override
  String get noAccount => 'Pas encore de compte ?';

  @override
  String get createAccountLink => 'Créer un compte';

  @override
  String get showPassword => 'Afficher le mot de passe';

  @override
  String get hidePassword => 'Masquer le mot de passe';

  @override
  String get biometricLoginReason => 'Connectez-vous à Mon Constat';

  @override
  String get biometricEnableReason =>
      'Confirmez pour activer la connexion biométrique';

  @override
  String get languageSwitcher => 'Langue de l\'application';

  @override
  String get registerTitle => 'Créer un compte';

  @override
  String get firstNameLabel => 'Prénom';

  @override
  String get lastNameLabel => 'Nom';

  @override
  String get emailLabel => 'E-mail';

  @override
  String get phoneLabel => 'Téléphone';

  @override
  String get confirmPasswordLabel => 'Confirmer le mot de passe';

  @override
  String get createMyAccount => 'Créer mon compte';

  @override
  String get otpTitle => 'Vérifier mon téléphone';

  @override
  String otpInstructions(String phone) {
    return 'Saisissez le code à 6 chiffres envoyé sur WhatsApp au $phone.';
  }

  @override
  String get otpCodeLabel => 'Code de vérification';

  @override
  String get resendCode => 'Renvoyer le code';

  @override
  String resendCodeIn(int seconds) {
    return 'Renvoyer le code ($seconds s)';
  }

  @override
  String get forgotTitle => 'Mot de passe oublié';

  @override
  String get forgotIntro =>
      'Saisissez votre adresse e-mail pour recevoir un code de réinitialisation.';

  @override
  String forgotCodeSent(String email) {
    return 'Si un compte existe pour $email, un code valable 15 minutes vient de lui être envoyé.';
  }

  @override
  String get codeFromEmailLabel => 'Code reçu par e-mail';

  @override
  String get newPasswordLabel => 'Nouveau mot de passe';

  @override
  String get receiveCode => 'Recevoir un code';

  @override
  String get changePassword => 'Changer le mot de passe';

  @override
  String get passwordChanged =>
      'Mot de passe modifié. Vous pouvez vous connecter.';

  @override
  String get profileTitle => 'Mon profil';

  @override
  String get profileSubtitle => 'Identité, permis et préférences';

  @override
  String profileCompletion(int percent) {
    return 'Profil complété à $percent %';
  }

  @override
  String get profileCompleteHint =>
      'Complétez votre permis : il servira à remplir le constat.';

  @override
  String get profileComplete => 'Profil complet, prêt pour un constat.';

  @override
  String get sectionIdentity => 'Identité';

  @override
  String get sectionLicense => 'Permis de conduire';

  @override
  String get sectionSecurity => 'Sécurité';

  @override
  String get sectionPreferences => 'Préférences';

  @override
  String get fullNameLabel => 'Nom complet';

  @override
  String get emailNotEditable => 'L\'e-mail ne peut pas être modifié.';

  @override
  String get phoneVerified => 'Numéro vérifié';

  @override
  String get phoneNotVerified => 'Numéro non vérifié';

  @override
  String get verify => 'Vérifier';

  @override
  String get licenseNumberLabel => 'N° de permis';

  @override
  String get licenseCategoryLabel => 'Catégorie';

  @override
  String get licenseIssuedLabel => 'Date de délivrance';

  @override
  String get licenseEmpty =>
      'Aucun permis enregistré. Il sert à remplir votre partie du constat.';

  @override
  String get addLicense => 'Ajouter mon permis';

  @override
  String licenseIssuedOn(String date) {
    return 'Délivré le $date';
  }

  @override
  String get licensePhotoAdd => 'Ajouter la photo du permis';

  @override
  String get replace => 'Remplacer';

  @override
  String get biometricTitle => 'Connexion par empreinte';

  @override
  String get biometricSubtitle =>
      'Empreinte ou reconnaissance faciale, 30 jours sur ce téléphone';

  @override
  String get biometricEnabled => 'Connexion biométrique activée';

  @override
  String get languageLabel => 'Langue';

  @override
  String get logout => 'Se déconnecter';

  @override
  String get profileSaved => 'Profil enregistré';

  @override
  String get editIdentityTitle => 'Modifier l\'identité';

  @override
  String get editLicenseTitle => 'Modifier le permis';

  @override
  String get changeProfilePhoto => 'Changer la photo de profil';

  @override
  String get phoneChangeNotice =>
      'Un nouveau numéro devra être vérifié par un code WhatsApp.';

  @override
  String get takePhoto => 'Prendre une photo';

  @override
  String get chooseFromGallery => 'Choisir dans la galerie';

  @override
  String get deletePhoto => 'Supprimer la photo';

  @override
  String get photoSaved => 'Photo enregistrée';

  @override
  String get accountsTitle => 'Gestion des comptes';

  @override
  String get accountsSubtitle => 'Rôles, agents et suspensions';

  @override
  String get createAgentTooltip => 'Créer un agent';

  @override
  String get searchHint => 'Nom, e-mail ou téléphone';

  @override
  String get noAccounts => 'Aucun compte trouvé.';

  @override
  String get roleLabel => 'Rôle';

  @override
  String get companyLabel => 'Compagnie';

  @override
  String get createAgentTitle => 'Créer un agent';

  @override
  String get tempPasswordLabel => 'Mot de passe provisoire';

  @override
  String get createAccountButton => 'Créer le compte';

  @override
  String get companiesTitle => 'Compagnies d\'assurance';

  @override
  String get companiesSubtitle => 'Compagnies et agences';

  @override
  String get addCompany => 'Ajouter une compagnie';

  @override
  String get noCompanies => 'Aucune compagnie enregistrée.';

  @override
  String agencyCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count agences',
      one: '1 agence',
      zero: 'Aucune agence',
    );
    return '$_temp0';
  }

  @override
  String get addAgency => 'Ajouter une agence';

  @override
  String get rename => 'Renommer';

  @override
  String get newCompany => 'Nouvelle compagnie';

  @override
  String get renameCompany => 'Renommer la compagnie';

  @override
  String get companyNameLabel => 'Nom de la compagnie';

  @override
  String get newAgency => 'Nouvelle agence';

  @override
  String get editAgency => 'Modifier l\'agence';

  @override
  String get agencyNameLabel => 'Nom de l\'agence';

  @override
  String get cityLabel => 'Ville';

  @override
  String deleteCompanyTitle(String name) {
    return 'Supprimer $name ?';
  }

  @override
  String get deleteCompanyBody => 'Ses agences seront aussi supprimées.';

  @override
  String get deleteAgencyTooltip => 'Supprimer l\'agence';

  @override
  String get adminTitle => 'Administration';

  @override
  String get adminSubtitle => 'Vue globale de la plateforme';

  @override
  String get demoData => 'Données de démonstration';

  @override
  String get statAccidents => 'Accidents';

  @override
  String get statOpen => 'Ouverts';

  @override
  String get statClosed => 'Clôturés';

  @override
  String get statAvgDelay => 'Délai moyen';

  @override
  String get heatmapTitle => 'Carte des zones à forte accidentalité';

  @override
  String get severityTitle => 'Répartition par gravité';

  @override
  String severityMaterial(int percent) {
    return '$percent % matériel';
  }

  @override
  String get navHome => 'Accueil';

  @override
  String get navVehicles => 'Véhicules';

  @override
  String get navClaims => 'Dossiers';

  @override
  String get navMessages => 'Messages';

  @override
  String get navProfile => 'Profil';

  @override
  String get navDashboard => 'Tableau';

  @override
  String get navCases => 'Sinistres';

  @override
  String get navAccounts => 'Comptes';

  @override
  String get navCompanies => 'Compagnies';

  @override
  String get errorGeneric => 'Une erreur est survenue. Réessayez.';

  @override
  String get errorNetwork =>
      'Connexion au serveur impossible. Vérifiez votre réseau.';

  @override
  String get errorInvalidCredentials =>
      'Identifiant ou mot de passe incorrect.';

  @override
  String get errorAccountLocked =>
      'Compte bloqué pendant 15 minutes après 5 échecs. Réessayez plus tard.';

  @override
  String get errorAccountSuspended => 'Ce compte est suspendu.';

  @override
  String get errorAlreadyExists => 'Cette valeur est déjà utilisée.';

  @override
  String get errorInvalidCode => 'Code incorrect ou expiré.';

  @override
  String get errorCodeCooldown =>
      'Attendez une minute avant de redemander un code.';

  @override
  String get errorSessionExpired => 'Session expirée. Reconnectez-vous.';

  @override
  String get errorBiometricInvalid =>
      'Connexion biométrique expirée. Connectez-vous avec votre mot de passe.';

  @override
  String get errorBiometricUnavailable =>
      'Empreinte ou reconnaissance faciale indisponible. Vérifiez les réglages de sécurité du téléphone.';

  @override
  String get errorFileTooLarge => 'Image trop lourde : 5 Mo maximum.';

  @override
  String get errorUnsupportedImage => 'Format accepté : JPEG, PNG ou WebP.';

  @override
  String get errorCompanyInUse =>
      'Cette compagnie a encore des agents rattachés.';

  @override
  String get errorSelfChange =>
      'Impossible de modifier votre propre rôle ou statut.';

  @override
  String get errorInvalidData => 'Certaines données sont invalides.';

  @override
  String get appearanceLabel => 'Apparence';

  @override
  String get themeSystem => 'Comme le téléphone';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

  @override
  String get navDeclarations => 'Déclarations';

  @override
  String get securityDevicesTitle => 'Appareils connectés';

  @override
  String get securityDevicesSubtitle => 'Où votre compte est ouvert';

  @override
  String get thisDevice => 'Cet appareil';

  @override
  String lastActive(String when) {
    return 'Actif le $when';
  }

  @override
  String get signOutDevice => 'Déconnecter';

  @override
  String signOutDeviceConfirm(String name) {
    return 'Déconnecter $name ?';
  }

  @override
  String get signOutDeviceBody =>
      'Cet appareil devra se reconnecter avec le mot de passe.';

  @override
  String get signOutOthers => 'Déconnecter les autres appareils';

  @override
  String signedOutOthers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count appareils déconnectés',
      one: '1 appareil déconnecté',
      zero: 'Aucun autre appareil connecté',
    );
    return '$_temp0';
  }

  @override
  String get unknownDevice => 'Appareil inconnu';

  @override
  String get securityAlertNote =>
      'Une connexion depuis un nouvel appareil vous est signalée sur WhatsApp et par e-mail.';

  @override
  String get loginHistoryTitle => 'Historique des connexions';

  @override
  String get noHistory => 'Aucune connexion enregistrée.';

  @override
  String get loginSuccess => 'Connexion réussie';

  @override
  String get loginMethodPassword => 'mot de passe';

  @override
  String get loginMethodBiometric => 'empreinte';

  @override
  String get loginMethodRegister => 'création du compte';

  @override
  String get loginFailedWrongPassword => 'Mot de passe incorrect';

  @override
  String get loginFailedLocked => 'Tentative sur compte bloqué';

  @override
  String get loginFailedSuspended => 'Tentative sur compte suspendu';

  @override
  String get identityTitle => 'Vérification d\'identité';

  @override
  String get identityStatusUnverified => 'Identité non vérifiée';

  @override
  String get identityStatusPending => 'Vérification en cours';

  @override
  String get identityStatusVerified => 'Identité vérifiée';

  @override
  String get identityStatusRejected => 'Vérification refusée';

  @override
  String get identityIntro =>
      'Un administrateur vérifie votre CIN. Elle est exigée pour signer un constat.';

  @override
  String get identityPendingNote =>
      'Un administrateur vérifie vos documents. Vous serez prévenu sur WhatsApp et par e-mail.';

  @override
  String get identityVerifiedNote => 'Vous pouvez signer vos constats.';

  @override
  String identityRejectedReason(String reason) {
    return 'Motif : $reason';
  }

  @override
  String get cinNumberLabel => 'N° de CIN';

  @override
  String get cinInvalid => 'Le numéro de CIN contient 8 chiffres.';

  @override
  String get cinFront => 'Recto de la CIN';

  @override
  String get cinBack => 'Verso de la CIN';

  @override
  String get addPhoto => 'Ajouter la photo';

  @override
  String get identityPhotosRequired =>
      'Ajoutez le recto et le verso de votre CIN.';

  @override
  String get submitIdentity => 'Envoyer pour vérification';

  @override
  String get identitySent =>
      'Demande envoyée. Vous serez prévenu sur WhatsApp.';

  @override
  String get navIdentities => 'Identités';

  @override
  String get reviewTitle => 'Vérifications d\'identité';

  @override
  String get reviewSubtitle =>
      'Demandes en attente, les plus anciennes en premier';

  @override
  String get noPendingReviews => 'Aucune demande en attente.';

  @override
  String submittedOn(String date) {
    return 'Envoyée le $date';
  }

  @override
  String get approve => 'Valider';

  @override
  String get reject => 'Refuser';

  @override
  String get rejectTitle => 'Motif du refus';

  @override
  String get rejectReasonBlurry => 'Photo floue';

  @override
  String get rejectReasonUnreadable => 'Document illisible';

  @override
  String get rejectReasonNameMismatch => 'Nom différent du compte';

  @override
  String get rejectReasonNotCin => 'Ce n\'est pas une CIN';

  @override
  String get otherReason => 'Autre motif';

  @override
  String get identityApproved => 'Identité validée, le titulaire est prévenu';

  @override
  String get identityRejected => 'Demande refusée, le titulaire est prévenu';

  @override
  String get errorIdentityLocked =>
      'Votre identité est en cours de vérification ou déjà vérifiée.';

  @override
  String get errorCinInUse => 'Ce numéro de CIN est déjà utilisé.';

  @override
  String get errorIdentityNotVerified =>
      'Votre identité doit être vérifiée avant cette action.';

  @override
  String get errorIdentityNotPending => 'Cette demande n\'est plus en attente.';

  @override
  String get consentLabel =>
      'J\'accepte que mes données soient traitées pour la gestion de mes constats, conformément à la loi n° 2004-63.';

  @override
  String get consentRequired =>
      'Votre accord est nécessaire pour créer un compte.';

  @override
  String get sectionPrivacy => 'Données personnelles';

  @override
  String get exportData => 'Télécharger mes données';

  @override
  String get exportDataSubtitle =>
      'PDF de tout ce que Mon Constat garde sur vous';

  @override
  String get deleteAccount => 'Supprimer mon compte';

  @override
  String get deleteAccountSubtitle =>
      'Définitif. Vos constats restent, sans votre nom.';

  @override
  String get deleteAccountTitle => 'Supprimer votre compte ?';

  @override
  String get deleteAccountBody =>
      'Votre nom, vos coordonnées, votre permis, votre CIN et vos photos seront effacés. Les accidents et sinistres déjà déclarés restent, anonymes, comme l\'exige l\'assurance. Cette action est définitive.';

  @override
  String get deleteAccountConfirm => 'Supprimer définitivement';

  @override
  String get accountDeleted => 'Votre compte a été supprimé.';

  @override
  String get errorAdminCannotDelete =>
      'Un administrateur ne peut pas supprimer son compte ici.';

  @override
  String get dashUsers => 'Utilisateurs';

  @override
  String dashActive(int count) {
    return '$count actifs';
  }

  @override
  String get dashPendingIds => 'À vérifier';

  @override
  String dashVerifiedIds(int count) {
    return '$count identités vérifiées';
  }

  @override
  String get dashPhones => 'Téléphones vérifiés';

  @override
  String get dashSignIns => 'Connexions 7 j';

  @override
  String dashFailed(int count) {
    return '$count échecs';
  }

  @override
  String get dashSignupsTitle => 'Inscriptions, 30 derniers jours';

  @override
  String get dashRolesTitle => 'Comptes par rôle';

  @override
  String get dashIdentityTitle => 'Vérification d\'identité des conducteurs';

  @override
  String dashNetwork(int companies, int agencies) {
    return '$companies compagnies · $agencies agences';
  }

  @override
  String get dashAccidentsTitle => 'Accidents et sinistres';

  @override
  String get dashAccidentsPending =>
      'Indicateurs, répartition et carte des zones à risque : disponibles dès que les modules 3 et 5 envoient leurs données au serveur.';

  @override
  String get agencyLabel => 'Agence';

  @override
  String companiesOffline(String date) {
    return 'Hors ligne : liste enregistrée le $date';
  }

  @override
  String get pendingSyncTitle => 'Modifications en attente';

  @override
  String get pendingSyncBody =>
      'Enregistrées sur le téléphone. Elles seront envoyées dès le retour du réseau.';

  @override
  String syncFailed(String reason) {
    return 'Le serveur a refusé la modification : $reason';
  }

  @override
  String get syncNow => 'Synchroniser';

  @override
  String get retrySync => 'Réessayer';

  @override
  String get discardChanges => 'Annuler les modifications';

  @override
  String get savedOffline =>
      'Enregistré sur le téléphone. Envoi dès le retour du réseau.';

  @override
  String get syncing => 'Synchronisation…';

  @override
  String get consoleDashboard => 'Tableau de bord';

  @override
  String get consoleToHandle => 'À traiter';

  @override
  String get consoleReview => 'Examiner';

  @override
  String get consoleSeeAll => 'Tout voir';

  @override
  String get consoleNothingToHandle => 'Rien à traiter pour le moment.';

  @override
  String get refresh => 'Actualiser';

  @override
  String get signedInAs => 'Connecté';

  @override
  String get colUser => 'Utilisateur';

  @override
  String get colStatus => 'Statut';

  @override
  String get filterAll => 'Tous';

  @override
  String get filterDrivers => 'Conducteurs';

  @override
  String get filterAgents => 'Agents';

  @override
  String get filterAdmins => 'Administrateurs';

  @override
  String accountsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count comptes',
      one: '1 compte',
      zero: 'Aucun compte',
    );
    return '$_temp0';
  }

  @override
  String get statusActive => 'Actif';

  @override
  String get statusSuspended => 'Suspendu';

  @override
  String get changeRole => 'Changer le rôle';

  @override
  String get suspendAccount => 'Suspendre';

  @override
  String get reactivateAccount => 'Réactiver';

  @override
  String get selectRequest => 'Sélectionnez une demande pour voir la CIN.';

  @override
  String pendingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count demandes',
      one: '1 demande',
      zero: 'Aucune demande',
    );
    return '$_temp0';
  }

  @override
  String get selectCompany =>
      'Sélectionnez une compagnie pour gérer ses agences.';

  @override
  String get agenciesTitle => 'Agences';

  @override
  String get noAgencies => 'Aucune agence pour le moment.';

  @override
  String get heroPoint1 =>
      'Un constat complet en moins de 10 minutes, même hors ligne';

  @override
  String get heroPoint2 =>
      'Signature des deux conducteurs et PDF infalsifiable';

  @override
  String get heroPoint3 =>
      'Suivi du dossier en temps réel jusqu’à l’indemnisation';
}
