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
  String get navDeclarations => 'Constats';

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
      'Choisissez une pièce, photographiez-la, puis vérifiez votre visage. Notre IA compare votre visage à la photo de la pièce, sur nos serveurs, sans aucun service extérieur.';

  @override
  String get identityPendingNote =>
      'L\'IA n\'a pas pu conclure : un administrateur compare vos photos. Vous serez prévenu sur WhatsApp et par e-mail.';

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
  String get identityPhotosRequired => 'Ajoutez les photos de la pièce.';

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
  String get rejectReasonNotCin => 'Pièce non valable';

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
  String get errorCinInUse => 'Ce numéro de pièce est déjà utilisé.';

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
  String get selectRequest => 'Sélectionnez une demande pour voir la pièce.';

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

  @override
  String get identityVerifiedAutoNote =>
      'Vérifiée automatiquement par reconnaissance faciale. Vous pouvez signer vos constats.';

  @override
  String get documentTypeLabel => 'Pièce d\'identité';

  @override
  String get documentCin => 'CIN';

  @override
  String get documentLicense => 'Permis';

  @override
  String get documentPassport => 'Passeport';

  @override
  String get passportNumberLabel => 'N° du passeport';

  @override
  String get licenseNumberInvalid =>
      'Numéro de permis invalide (ex. 12/345678).';

  @override
  String get passportNumberInvalid =>
      'Numéro de passeport invalide (ex. X1234567).';

  @override
  String get licenseFront => 'Recto du permis';

  @override
  String get licenseBack => 'Verso du permis';

  @override
  String get passportPage => 'Page photo du passeport';

  @override
  String get faceCheckTitle => 'Vérification du visage';

  @override
  String get faceCheckIntro =>
      'Trois photos rapides : de face, puis la tête tournée de chaque côté. Une photo imprimée ou un écran ne passe pas.';

  @override
  String get faceCheckDone => 'Visage vérifié';

  @override
  String get faceCheckStart => 'Vérifier mon visage';

  @override
  String get faceCheckRedo => 'Recommencer';

  @override
  String get faceCheckRequired => 'Faites d\'abord la vérification du visage.';

  @override
  String get livenessCenter => 'Regardez la caméra, bien de face';

  @override
  String get livenessLeft => 'Tournez la tête vers la gauche';

  @override
  String get livenessRight => 'Tournez la tête vers la droite';

  @override
  String livenessStepOf(int current, int total) {
    return 'Photo $current sur $total';
  }

  @override
  String get livenessAnalyzing => 'Analyse par l\'IA…';

  @override
  String get livenessNoCamera =>
      'Caméra indisponible. Autorisez l\'accès à la caméra, puis réessayez.';

  @override
  String get livenessPrivacy =>
      'La photo de face sert uniquement à cette vérification. Elle est effacée dès la décision.';

  @override
  String get livenessSuccess =>
      'Visage vérifié. Vous pouvez envoyer la demande.';

  @override
  String get identityVerifiedByAi => 'Identité vérifiée par l\'IA';

  @override
  String get errorNoFaceOnDocument =>
      'Aucun visage détecté sur la pièce. Reprenez la photo à plat, bien éclairée et sans reflet.';

  @override
  String get errorLivenessNoFace =>
      'Visage introuvable. Placez votre visage dans l\'ovale, bien éclairé.';

  @override
  String get errorLivenessManyFaces =>
      'Une seule personne doit être devant la caméra.';

  @override
  String get errorLivenessNotCentered =>
      'Regardez la caméra bien de face pour la première photo.';

  @override
  String get errorLivenessNoTurn =>
      'Tournez davantage la tête quand la consigne le demande.';

  @override
  String get errorLivenessDifferentFaces =>
      'Les photos ne montrent pas la même personne.';

  @override
  String get errorLivenessExpired =>
      'Le défi a expiré. Recommencez la vérification du visage.';

  @override
  String get errorFaceEngine =>
      'L\'analyse du visage est indisponible. Réessayez dans un instant.';

  @override
  String aiMatch(int percent) {
    return 'Ressemblance IA : $percent %';
  }

  @override
  String get aiNoConclusion => 'IA : pas de conclusion';

  @override
  String get livenessPassed => 'Visage vivant vérifié';

  @override
  String get selfieLabel => 'Photo du visage';

  @override
  String get documentNumberLabel => 'N° de la pièce';

  @override
  String get rejectReasonFaceMismatch =>
      'Le visage ne correspond pas à la pièce';

  @override
  String dashVerifiedIdsAi(int count, int ai) {
    return '$count vérifiées, dont $ai par l\'IA';
  }

  @override
  String get readingDocument => 'Lecture de la pièce par l\'IA…';

  @override
  String get readOnCard => 'Lu sur la pièce par l\'IA';

  @override
  String get readNumber => 'Numéro';

  @override
  String get readName => 'Nom';

  @override
  String get readParents => 'Filiation';

  @override
  String get readBirth => 'Naissance';

  @override
  String get readExpiry => 'Valable jusqu\'au';

  @override
  String get readConfirm =>
      'Vérifiez ces informations. Le numéro saisi doit être celui de la pièce.';

  @override
  String get readNothing =>
      'L\'IA n\'a pas pu lire la pièce. Saisissez le numéro : un administrateur vérifiera.';

  @override
  String get useNumberRead => 'Utiliser ce numéro';

  @override
  String get useLicensePhoto => 'Utiliser la photo du permis de mon profil';

  @override
  String get errorBackHasFace =>
      'Cette photo montre un recto. Photographiez le verso de la même pièce.';

  @override
  String get errorLicensePhotoMissing =>
      'Aucune photo de permis dans votre profil.';

  @override
  String get checksTitle => 'Contrôles de l\'IA';

  @override
  String get checkLiveness => 'Visage vivant';

  @override
  String get checkFace => 'Visage identique à la photo de la pièce';

  @override
  String checkNumber(String number) {
    return 'Numéro saisi = numéro lu ($number)';
  }

  @override
  String get checkNumberUnread => 'Numéro illisible sur la pièce';

  @override
  String get checkName => 'Nom du compte sur la pièce';

  @override
  String get checkExpiry => 'Pièce en cours de validité';

  @override
  String get scanLicense => 'Scanner mon permis';

  @override
  String get scanLicenseHint =>
      'Prenez votre permis en photo : l\'IA remplit le numéro, les catégories et la date.';

  @override
  String get licenseFilledByAi =>
      'Rempli par l\'IA à partir de la photo. Vérifiez avant d\'enregistrer.';

  @override
  String get licenseNotRead =>
      'Photo enregistrée, mais l\'IA n\'a pas pu lire le permis. Complétez les champs.';

  @override
  String get errorBackNotRecognized =>
      'Ce n\'est pas le verso de la pièce. Sur une CIN, le code-barres doit être net et entier sur la photo.';

  @override
  String get checkBack => 'Verso reconnu';

  @override
  String get rejectSevere => 'Refus définitif : bloquer les nouvelles demandes';

  @override
  String get rejectSevereHint =>
      'Pour une fraude probable : visage différent, fausse pièce.';

  @override
  String get identityBlockedNote =>
      'La vérification de votre identité est bloquée. Contactez le support.';

  @override
  String identityRetryOn(String date) {
    return 'Nouvelle demande possible le $date.';
  }

  @override
  String identityAttemptsLeft(int count) {
    return 'Essais restants : $count.';
  }

  @override
  String get errorIdentityBlocked =>
      'La vérification de votre identité est bloquée. Contactez le support.';

  @override
  String get errorIdentityRetryLater =>
      'Attendez 24 h après un refus avant une nouvelle demande.';

  @override
  String get unblockIdentity => 'Débloquer la vérification';

  @override
  String get identityUnblocked => 'Vérification débloquée';

  @override
  String get identityBlockedChip => 'Vérification bloquée';

  @override
  String get attemptsTitle => 'Demandes de ce compte';

  @override
  String refusalsCount(int count) {
    return 'Refus : $count';
  }

  @override
  String get outcomeAuto => 'Validée par l\'IA';

  @override
  String get outcomeVerified => 'Validée';

  @override
  String get outcomeRejected => 'Refusée';

  @override
  String get outcomePending => 'En attente';

  @override
  String get biometricConsentLabel =>
      'J\'accepte que mon visage soit analysé pour vérifier mon identité. Analyse faite sur les serveurs de Mon Constat, photo effacée dès la décision (loi n° 2004-63).';

  @override
  String get errorAiQuota =>
      'Trop d\'analyses en peu de temps. Réessayez dans un moment.';

  @override
  String get livenessHintNoFace => 'Placez votre visage dans l\'ovale';

  @override
  String get livenessHintLookStraight => 'Regardez la caméra bien en face';

  @override
  String get livenessHintTurnMore => 'Tournez davantage la tête';

  @override
  String get dashAiTitle => 'Vérification par l\'IA';

  @override
  String get dashAiFooter =>
      'Sur la période affichée. Analyse sur nos serveurs, sans service extérieur.';

  @override
  String get dashAiRequests => 'demandes';

  @override
  String get dashAiAutoRate => 'validées par l\'IA seule';

  @override
  String get dashAiAverageMatch => 'ressemblance moyenne';

  @override
  String get dashAiBlocked => 'comptes bloqués';

  @override
  String get checkBirthDate => 'Même date de naissance que le permis';

  @override
  String get licenseBirthMismatch =>
      'Attention : la date de naissance du permis ne correspond pas à votre pièce d\'identité.';

  @override
  String get licenseNameMismatch =>
      'Attention : ce permis n\'est pas à votre nom. Ajoutez votre propre permis.';

  @override
  String get licenseCinMismatch =>
      'Attention : le numéro de CIN du permis ne correspond pas à votre pièce d\'identité.';

  @override
  String get errorWrongDocument =>
      'La photo ne montre pas la pièce choisie. Changez de pièce ou de photo.';

  @override
  String get errorNotALicense =>
      'Cette photo n\'est pas un permis de conduire.';

  @override
  String get registerIntro =>
      'Un e-mail et un mot de passe. Le reste se fait juste après, en quelques étapes.';

  @override
  String get registerStepYou => 'Vous';

  @override
  String get registerStepContact => 'Vos coordonnées';

  @override
  String get registerStepSecurity => 'Sécurité';

  @override
  String get registerPhoneHint =>
      'Un code de vérification vous sera envoyé sur WhatsApp.';

  @override
  String get passwordWeak => 'Faible';

  @override
  String get passwordFair => 'Moyen';

  @override
  String get passwordGood => 'Bon';

  @override
  String get passwordStrong => 'Excellent';

  @override
  String get passwordRuleLength => '8 caractères';

  @override
  String get passwordRuleUpper => 'Une majuscule';

  @override
  String get passwordRuleDigit => 'Un chiffre';

  @override
  String get passwordRuleSymbol => 'Un symbole';

  @override
  String get identityStepDocument => 'Pièce';

  @override
  String get identityStepReading => 'Lecture';

  @override
  String get identityStepFace => 'Visage';

  @override
  String get identityStepSend => 'Envoi';

  @override
  String get profileIdentityVerified => 'Identité vérifiée';

  @override
  String get profileIdentityPending => 'Identité en cours';

  @override
  String get profileIdentityTodo => 'Identité à vérifier';

  @override
  String get licenseStatusVerified => 'Permis vérifié';

  @override
  String get licenseStatusToReview => 'Permis en cours de vérification';

  @override
  String get licenseStatusRejected => 'Permis refusé';

  @override
  String get licenseToReviewNote =>
      'Une information du permis ne correspond pas à votre compte : un administrateur le vérifie.';

  @override
  String licenseRejectedNote(String reason) {
    return 'Votre permis a été refusé. Motif : $reason. Ajoutez votre propre permis.';
  }

  @override
  String get errorLicenseNotYours =>
      'Ce permis ne semble pas être le vôtre : le nom, la date de naissance ou le numéro de CIN ne correspondent pas à votre compte. Il n\'a pas été enregistré.';

  @override
  String get accountFileTitle => 'Dossier du compte';

  @override
  String get openAccountFile => 'Voir le dossier';

  @override
  String get sectionAccount => 'Compte';

  @override
  String get licenseReviewTitle => 'Permis à vérifier';

  @override
  String get licenseReviewSubtitle =>
      'Un contrôle de l\'IA a échoué, ou la photo était illisible';

  @override
  String get noLicenseReviews => 'Aucun permis à vérifier.';

  @override
  String licensesToReviewCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count permis à vérifier',
      one: '1 permis à vérifier',
    );
    return '$_temp0';
  }

  @override
  String get approveLicense => 'Valider le permis';

  @override
  String get rejectLicense => 'Refuser le permis';

  @override
  String get deleteLicense => 'Supprimer le permis';

  @override
  String deleteLicenseBody(String name) {
    return 'La photo et les informations du permis de $name seront effacées.';
  }

  @override
  String get licenseApproved => 'Permis validé';

  @override
  String get licenseRejected => 'Permis refusé, le conducteur voit le motif';

  @override
  String get licenseDeleted => 'Permis supprimé';

  @override
  String get licenseUpdated => 'Permis modifié';

  @override
  String get noLicense => 'Aucun permis enregistré.';

  @override
  String get noIdentityDocuments => 'Aucune pièce enregistrée.';

  @override
  String get aiChecksTitle => 'Contrôles de l\'IA';

  @override
  String get checkLicenseName => 'Nom du titulaire = nom du compte';

  @override
  String get checkLicenseBirth => 'Date de naissance = pièce d\'identité';

  @override
  String get checkLicenseCin => 'N° de CIN = pièce d\'identité';

  @override
  String get checkLicenseNumber => 'Numéro saisi = numéro lu sur la photo';

  @override
  String get checkNotCompared => 'non comparable';

  @override
  String get licenseRejectReasonNotOwner => 'Permis d\'une autre personne';

  @override
  String get licenseRejectReasonExpired => 'Permis expiré';

  @override
  String get revokeIdentity => 'Annuler la vérification';

  @override
  String get revokeIdentityTitle => 'Annuler la vérification d\'identité ?';

  @override
  String get revokeIdentityBody =>
      'Les photos de la pièce seront effacées. Le conducteur voit le motif et peut refaire une demande tout de suite.';

  @override
  String get identityRevoked => 'Vérification annulée';

  @override
  String get reasonLabel => 'Motif';

  @override
  String get onbSkip => 'Passer';

  @override
  String get onbLater => 'Plus tard';

  @override
  String get onbContinue => 'Continuer';

  @override
  String get onbBack => 'Étape précédente';

  @override
  String onbProgress(int current, int total) {
    return 'Étape $current sur $total';
  }

  @override
  String get onbWelcomeEyebrow => 'Compte créé';

  @override
  String onbWelcomeTitle(String name) {
    return 'Bienvenue,\n$name';
  }

  @override
  String get onbWelcomeBody =>
      'Deux minutes pour préparer votre compte, et vous serez prêt le jour où vous en aurez besoin.';

  @override
  String get onbWelcomeStart => 'Préparer mon compte';

  @override
  String get onbWelcomeSkip => 'Je le ferai plus tard';

  @override
  String get onbLicenseTitle => 'Ajoutez votre permis';

  @override
  String get onbLicenseBody =>
      'Une photo suffit : l\'IA lit le numéro, les catégories et la date. Il servira à remplir vos constats.';

  @override
  String get onbLicenseScan => 'Photographier mon permis';

  @override
  String get onbLicenseRescan => 'Reprendre la photo';

  @override
  String get onbLicenseReading => 'Lecture du permis…';

  @override
  String get onbLicenseRead => 'Lu par l\'IA';

  @override
  String get onbLicenseUnread =>
      'La carte n\'a pas pu être lue. Vous compléterez les informations depuis votre profil.';

  @override
  String get onbLicenseTip => 'À plat, bien éclairé, sans reflet.';

  @override
  String get onbIdentityTitle => 'Vérifiez votre identité';

  @override
  String get onbIdentityBody =>
      'Pour signer vos constats en toute confiance. Comptez deux minutes.';

  @override
  String get onbIdentityStep1 => 'Une pièce : CIN, permis ou passeport';

  @override
  String get onbIdentityStep2 => 'Votre visage, en tournant la tête';

  @override
  String get onbIdentityStep3 => 'L\'IA compare, en quelques secondes';

  @override
  String get onbIdentityStart => 'Vérifier maintenant';

  @override
  String get onbIdentityLicenseHint =>
      'Votre permis peut servir de pièce : inutile de le reprendre en photo.';

  @override
  String get onbIdentityPrivacy =>
      'Vos photos sont analysées sur nos serveurs, sans service extérieur.';

  @override
  String get onbBiometricTitle => 'Connexion en un geste';

  @override
  String get onbBiometricBody =>
      'Ouvrez l\'application avec votre empreinte ou votre visage, sans retaper votre mot de passe.';

  @override
  String get onbBiometricEnable => 'Activer';

  @override
  String onbDoneTitle(String name) {
    return 'Tout est prêt,\n$name';
  }

  @override
  String get onbDoneBody =>
      'Vous pouvez déclarer un accident à tout moment, même sans réseau.';

  @override
  String get onbDoneLater =>
      'Le reste se termine depuis votre profil, quand vous voulez.';

  @override
  String get onbDoneStart => 'Accéder à l\'application';

  @override
  String get onbItemPhone => 'Téléphone';

  @override
  String get onbItemLicense => 'Permis de conduire';

  @override
  String get onbItemIdentity => 'Identité';

  @override
  String get onbItemBiometric => 'Connexion biométrique';

  @override
  String get onbStateDone => 'Fait';

  @override
  String get onbStatePending => 'En vérification';

  @override
  String get onbStateTodo => 'À faire';

  @override
  String get registerStepAccount => 'Votre compte';

  @override
  String get onbWelcomeNewTitle => 'Bienvenue sur\nMon Constat';

  @override
  String get onbProfileTitle => 'Faisons connaissance';

  @override
  String get onbProfileBody =>
      'Votre nom figure sur vos constats. Votre numéro sert à vous connecter et à suivre vos dossiers.';

  @override
  String get onbPhoneTitle => 'Confirmez votre numéro';

  @override
  String get onbCodeSent => 'Nouveau code envoyé.';

  @override
  String get onbReadingTitle => 'Lu sur la pièce';

  @override
  String get correctReading => 'Corriger';

  @override
  String get correctReadingTitle => 'Corriger la lecture de la pièce';

  @override
  String get correctReadingHint =>
      'Corrigez ce que l\'IA a mal lu, en recopiant la pièce. Dates au format AAAA-MM-JJ.';

  @override
  String get readingCorrected => 'Lecture corrigée';

  @override
  String get readLastName => 'Nom';

  @override
  String get readFirstName => 'Prénom';

  @override
  String get readBirthDate => 'Date de naissance';

  @override
  String get readBirthPlace => 'Lieu de naissance';

  @override
  String get claimsDecisionHelpGuide =>
      'Aide à la décision : priorité, estimation, risque et pièces manquantes de ce dossier. Touchez l’icône pour l’ouvrir.';

  @override
  String claimsTimelineEarlier(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count étapes précédentes',
      one: '1 étape précédente',
    );
    return '$_temp0';
  }

  @override
  String get claimsAlertOpen => 'Voir';

  @override
  String get claimsTimelineCollapse => 'Afficher moins';

  @override
  String get dashClaimsTotal => 'Sinistres';

  @override
  String get dashClaimsOpen => 'En cours';

  @override
  String get dashClaimsClosed => 'Clôturés';

  @override
  String get dashAvgClose => 'Délai moyen de clôture';

  @override
  String dashDays(String days) {
    return '$days j';
  }

  @override
  String dashIndemnities(String amount) {
    return 'Indemnisations versées : $amount TND';
  }

  @override
  String get dashByStatus => 'Par statut';

  @override
  String get dashBySeverity => 'Par gravité';

  @override
  String get dashByCompany => 'Par compagnie';

  @override
  String get dashByMonth => 'Sinistres des 6 derniers mois';

  @override
  String dashHotspots(int count) {
    return 'Lieux des accidents déclarés ($count)';
  }

  @override
  String get dashNoPoints => 'Aucune déclaration localisée pour l’instant.';

  @override
  String get dashNoCompany => 'Sans compagnie';

  @override
  String get vehAddVehicle => 'Ajouter un véhicule';

  @override
  String get vehEditVehicle => 'Modifier le véhicule';

  @override
  String get vehEdit => 'Modifier';

  @override
  String get vehArchive => 'Archiver';

  @override
  String get vehUnarchive => 'Désarchiver';

  @override
  String get vehDelete => 'Supprimer';

  @override
  String get vehCancel => 'Annuler';

  @override
  String get vehInsurance => 'Assurance';

  @override
  String get vehInsuranceContract => 'Contrat d\'assurance';

  @override
  String get vehTechnicalInspection => 'Visite technique';

  @override
  String get vehMileage => 'Kilométrage';

  @override
  String vehMileageValue(int thousands) {
    return '$thousands 000 km';
  }

  @override
  String get vehType => 'Type';

  @override
  String get vehFuel => 'Carburant';

  @override
  String get vehYear => 'Année';

  @override
  String get vehColor => 'Couleur';

  @override
  String get vehPolicyNumber => 'N° de police';

  @override
  String get vehExpiredBadge => 'EXPIRÉ';

  @override
  String get vehStatusOk => 'OK';

  @override
  String vehDaysShort(int days) {
    return '${days}j';
  }

  @override
  String vehDaysOverdue(int days) {
    return '${days}j\ndépassé';
  }

  @override
  String get vehDateHint => 'JJ/MM/AAAA';

  @override
  String get vehTypeCar => 'Voiture';

  @override
  String get vehTypeMoto => 'Moto';

  @override
  String get vehTypeTruck => 'Camion';

  @override
  String get vehTypeVan => 'Camionnette';

  @override
  String get vehOther => 'Autre';

  @override
  String get vehFuelPetrol => 'Essence';

  @override
  String get vehFuelDiesel => 'Diesel';

  @override
  String get vehFuelElectric => 'Électrique';

  @override
  String get vehFuelHybrid => 'Hybride';

  @override
  String get vehAlertsTitle => 'Alertes d\'échéance';

  @override
  String get vehAlertsEmptyTitle => 'Aucune alerte active';

  @override
  String get vehAlertsEmptyBody =>
      'Tous vos contrats et visites techniques\nsont à jour.';

  @override
  String get vehAlertsGroupExpired => 'Expiré(s)';

  @override
  String get vehAlertsGroupExpiring => 'Expire bientôt';

  @override
  String get vehAlertsSummaryExpired => 'Expirés';

  @override
  String get vehAlertsSummaryNear => 'Proches';

  @override
  String get vehAlertsSummaryTotal => 'Total';

  @override
  String get vehAlertInsuranceExpired => 'Assurance EXPIRÉE';

  @override
  String vehAlertInsuranceExpiring(int days) {
    return 'Assurance expire dans $days j.';
  }

  @override
  String get vehAlertTechnicalExpired => 'Visite technique EXPIRÉE';

  @override
  String vehAlertTechnicalExpiring(int days) {
    return 'Visite technique dans $days j.';
  }

  @override
  String get vehListTitle => 'Véhicules & contrats';

  @override
  String vehListActiveCount(int count) {
    return '$count véhicule(s) actif(s)';
  }

  @override
  String vehTabActive(int count) {
    return 'Actifs ($count)';
  }

  @override
  String vehTabArchived(int count) {
    return 'Archivés ($count)';
  }

  @override
  String get vehEmptyArchived => 'Aucun véhicule archivé';

  @override
  String get vehEmptyActive => 'Ajoutez votre premier véhicule';

  @override
  String vehPolicyValue(String policy) {
    return 'Police $policy';
  }

  @override
  String get vehAiAnalysis => 'Analyse IA';

  @override
  String get vehDeleteTitle => 'Supprimer ce véhicule ?';

  @override
  String vehDeleteBody(String name, String plate) {
    return '$name ($plate) sera définitivement supprimé.';
  }

  @override
  String get vehSectionInfo => 'Informations';

  @override
  String get vehRenew => 'Renouveler';

  @override
  String get vehInsurer => 'Assureur';

  @override
  String get vehExpiry => 'Expiration';

  @override
  String get vehPremiumTitle => 'Prime d’assurance estimée (IA)';

  @override
  String vehPremiumValue(String amount) {
    return '$amount TND / an';
  }

  @override
  String get vehNextInspection => 'Prochaine visite';

  @override
  String get vehClaimsHistory => 'Historique sinistres';

  @override
  String get vehClaimsDeclared => 'Sinistres déclarés';

  @override
  String get vehRenewTitle => 'Renouveler le contrat d’assurance';

  @override
  String get vehExpiryDate => 'Date d’expiration';

  @override
  String get vehRenewInvalid =>
      'Date invalide (JJ/MM/AAAA) ou n° de police manquant.';

  @override
  String get vehRenewSuccess => 'Contrat d’assurance renouvelé avec succès !';

  @override
  String get vehRiskTitle => 'Analyse de risque IA';

  @override
  String get vehRiskSubtitle => 'Calculé depuis vos données locales';

  @override
  String get vehRiskFactors => 'Facteurs détectés';

  @override
  String get vehRecommendations => 'Recommandations';

  @override
  String get vehPhotoTitle => 'Photo du véhicule';

  @override
  String get vehAddPhoto => 'Ajouter une photo';

  @override
  String get vehTakePhoto => 'Prendre une photo';

  @override
  String get vehPickFromGallery => 'Choisir depuis la galerie';

  @override
  String get vehRiskVeryOld => 'Véhicule très ancien';

  @override
  String get vehRiskVeryOldDesc => 'Plus de 20 ans — risque mécanique élevé.';

  @override
  String get vehRiskOld => 'Véhicule ancien';

  @override
  String vehRiskOldDesc(int age) {
    return '$age ans — entretien régulier recommandé.';
  }

  @override
  String get vehRiskMidAge => 'Véhicule d\'âge moyen';

  @override
  String vehRiskMidAgeDesc(int age) {
    return '$age ans — vérifier la carte grise.';
  }

  @override
  String vehRiskInsExpiredDesc(int days) {
    return 'Expirée depuis $days jour(s) — circuler est illégal.';
  }

  @override
  String get vehRiskInsCritical => 'Assurance critique';

  @override
  String vehRiskInsCriticalDesc(int days) {
    return 'Expire dans $days jour(s) — renouvelez d\'urgence.';
  }

  @override
  String get vehRiskInsSoon => 'Assurance bientôt expirée';

  @override
  String vehRiskExpiresIn(int days) {
    return 'Expire dans $days jour(s).';
  }

  @override
  String get vehRiskTechExpired => 'Visite technique expirée';

  @override
  String vehRiskExpiredSince(int days) {
    return 'Expirée depuis $days jour(s).';
  }

  @override
  String get vehRiskTechImminent => 'Visite technique imminente';

  @override
  String vehRiskInDays(int days) {
    return 'Dans $days jour(s).';
  }

  @override
  String get vehRiskTechNear => 'Visite technique proche';

  @override
  String get vehRiskTechUnknown => 'Visite technique inconnue';

  @override
  String get vehRiskTechUnknownDesc => 'Ajoutez la date pour un suivi précis.';

  @override
  String get vehRiskKmVeryHigh => 'Kilométrage très élevé';

  @override
  String vehRiskKmVeryHighDesc(int thousands) {
    return '$thousands 000 km — usure importante.';
  }

  @override
  String get vehRiskKmHigh => 'Kilométrage élevé';

  @override
  String get vehRiskKmModerate => 'Kilométrage modéré';

  @override
  String vehRiskKmDesc(int thousands) {
    return '$thousands 000 km.';
  }

  @override
  String get vehRiskClaimsHigh => 'Historique sinistres élevé';

  @override
  String vehRiskClaimsHighDesc(int count) {
    return '$count sinistre(s) enregistré(s).';
  }

  @override
  String get vehRiskClaimsMulti => 'Sinistres multiples';

  @override
  String get vehRiskClaimsMultiDesc => '2 sinistres enregistrés.';

  @override
  String get vehRiskClaimsOne => 'Sinistre précédent';

  @override
  String get vehRiskClaimsOneDesc => '1 sinistre enregistré.';

  @override
  String get vehRiskOldDiesel => 'Diesel ancien';

  @override
  String get vehRiskOldDieselDesc =>
      'Risque de particules et usure moteur accrue.';

  @override
  String get vehRecRenewNow => 'Renouvelez votre assurance immédiatement.';

  @override
  String get vehRecSeeInsurer =>
      'Prenez rendez-vous avec votre assureur dans les prochains jours.';

  @override
  String get vehRecTechNow => 'Effectuez votre visite technique au plus tôt.';

  @override
  String get vehRecTechSchedule =>
      'Programmez votre visite technique prochainement.';

  @override
  String get vehRecTechAddDate =>
      'Ajoutez la date de votre prochaine visite technique.';

  @override
  String get vehRecFullCheck =>
      'Faites une vérification complète chez un garagiste agréé.';

  @override
  String get vehRecBeltBrakes =>
      'Vérifiez la courroie de distribution et les plaquettes de frein.';

  @override
  String get vehRecDefensive =>
      'Envisagez une conduite défensive pour réduire les sinistres.';

  @override
  String get vehRecAddMileage =>
      'Renseignez le kilométrage pour une analyse plus précise.';

  @override
  String get vehRecAllGood =>
      'Votre véhicule est en règle. Continuez l\'entretien régulier.';

  @override
  String get vehScanNothing =>
      'Rien n’a pu être lu. Reprenez la photo à plat, bien éclairée.';

  @override
  String vehScanRead(String fields) {
    return 'Lu par l’IA : $fields. Vérifiez avant d’enregistrer.';
  }

  @override
  String get vehScanEstimated =>
      'Fin de validité estimée à un an : vérifiez-la.';

  @override
  String vehScanFailed(String error) {
    return 'Lecture impossible : $error';
  }

  @override
  String get vehScanBusy => 'Lecture en cours… (jusqu’à 30 s)';

  @override
  String get vehScanRegistration => 'Photographier la carte grise';

  @override
  String get vehScanInsurance => 'Photographier l’attestation d’assurance';

  @override
  String get vehReadPlate => 'immatriculation';

  @override
  String get vehReadBrand => 'marque';

  @override
  String get vehReadModel => 'modèle';

  @override
  String get vehReadYear => 'année';

  @override
  String get vehReadPolicy => 'n° de contrat';

  @override
  String get vehReadExpiry => 'fin de validité';

  @override
  String get vehReadInsurer => 'assureur';

  @override
  String vehReadInsurerToPick(String insurer) {
    return 'assureur ($insurer, à choisir dans la liste)';
  }

  @override
  String get vehScanTitle => 'Scanner vos documents avec l’IA';

  @override
  String get vehScanBody =>
      'Une photo de la carte grise ou de l’attestation d’assurance : l’IA remplit le formulaire, vous vérifiez.';

  @override
  String get vehSectionIdentification => 'Identification du véhicule';

  @override
  String get vehPlateRequired => 'Immatriculation *';

  @override
  String get vehPlateHint => 'Ex : 215 تونس 4521';

  @override
  String get vehBrandRequired => 'Marque *';

  @override
  String get vehModelRequired => 'Modèle *';

  @override
  String get vehYearRequired => 'Année *';

  @override
  String get vehColorHint => 'Blanc';

  @override
  String get vehKmUnit => 'km';

  @override
  String get vehPolicyNumberRequired => 'N° de police *';

  @override
  String get vehInsuranceExpiryRequired => 'Date d\'expiration assurance *';

  @override
  String get vehNextInspectionField => 'Prochaine visite technique';

  @override
  String get vehSaveChanges => 'Enregistrer les modifications';

  @override
  String get vehAddVehicleButton => 'Ajouter le véhicule';

  @override
  String get vehFieldRequired => 'Champ obligatoire.';

  @override
  String get vehYearInvalid => 'Année invalide.';

  @override
  String get vehDateFormat => 'Format JJ/MM/AAAA.';

  @override
  String get accStepContext => 'Contexte';

  @override
  String get accStepContextHint => 'Lieu, heure et conditions';

  @override
  String get accStepDescription => 'Description';

  @override
  String get accStepDescriptionHint => 'Type, gravité et témoins';

  @override
  String get accStepEvidence => 'Preuves';

  @override
  String get accStepEvidenceHint => 'Photos, vidéo et note vocale';

  @override
  String get accStepDriverBHint => 'Identité et assurance';

  @override
  String get accStepCircumstances => 'Circonstances';

  @override
  String get accStepCircumstancesHint => 'Cases et observations';

  @override
  String get accStepSketch => 'Croquis';

  @override
  String get accStepSketchHint => 'Choc et schéma';

  @override
  String get accStepSignatures => 'Signatures';

  @override
  String get accStepSignaturesHint => 'Validation et transmission';

  @override
  String accStepOf(int step, int total) {
    return 'Étape $step sur $total';
  }

  @override
  String accMinutesLeft(int minutes) {
    return '~$minutes min';
  }

  @override
  String get accDriverA => 'Conducteur A';

  @override
  String get accDriverB => 'Conducteur B';

  @override
  String get accNewDeclaration => 'Nouvelle déclaration';

  @override
  String get accDraft => 'Brouillon';

  @override
  String get accFinishDriverBFirst =>
      'Terminez d’abord la saisie du conducteur B.';

  @override
  String get accContinue => 'Continuer';

  @override
  String get accContinueToReport => 'Continuer vers le constat';

  @override
  String get accIAmDriverB => 'Je suis le conducteur B';

  @override
  String get accFinishAndReturnPhone => 'Terminer et rendre le téléphone';

  @override
  String get accSignAndSend => 'Signer et transmettre';

  @override
  String get accIAmDriverA => 'Je suis le conducteur A';

  @override
  String get accBack => 'Retour';

  @override
  String get accDraftSaved => 'Brouillon enregistré sur cet appareil';

  @override
  String get accThanks => 'Merci !';

  @override
  String get accReturnPhoneText =>
      'Rendez maintenant le téléphone au conducteur A. Les deux conducteurs signeront ensemble à la fin du constat.';

  @override
  String get accChooseVehicleFirst =>
      'Choisissez votre véhicule à la première étape.';

  @override
  String get accSealingTitle => 'Scellement cryptographique du constat…';

  @override
  String get accSealingHint => 'Calcul du hash SHA-256 et transmission';

  @override
  String accSealFailed(String error) {
    return 'Le constat n’a pas pu être scellé : $error';
  }

  @override
  String get accVerifyIdentityTitle => 'Vérifiez votre identité pour signer';

  @override
  String get accVerifyIdentityText =>
      'Le constat engage les deux conducteurs : votre identité doit être vérifiée avant la signature. Votre brouillon reste enregistré.';

  @override
  String get accLater => 'Plus tard';

  @override
  String get accVerifyIdentity => 'Vérifier mon identité';

  @override
  String get accCheckPlace => 'Vérifiez le lieu de l’accident.';

  @override
  String get accWitnessPhoneInvalid =>
      'Ajoutez un numéro valide pour le témoin.';

  @override
  String get accMinPhotos => 'Ajoutez au moins 2 photos avant de continuer.';

  @override
  String get accDriverBIncomplete =>
      'Complétez le nom, l’immatriculation et l’assurance du conducteur B.';

  @override
  String get accCircumstanceRequired =>
      'Sélectionnez au moins une circonstance pour le véhicule A ou B.';

  @override
  String get accSketchRequired => 'Confirmez le croquis et une zone de choc.';

  @override
  String get accSignaturesRequired =>
      'Les deux conducteurs doivent signer le constat.';

  @override
  String accLocalDraftSaved(String time) {
    return 'Brouillon local • sauvegardé à $time';
  }

  @override
  String get accHandoverTitle => 'Passez le téléphone au conducteur B';

  @override
  String get accHandoverText =>
      'Il remplit lui-même son identité, son permis, son véhicule et son assurance.';

  @override
  String get accHandoverHidden =>
      'Vos informations restent masquées : le retour aux étapes précédentes est bloqué pendant sa saisie.';

  @override
  String get accHandoverScan =>
      'Il peut photographier son permis : l’IA remplit les champs.';

  @override
  String get accHandoverReturn => 'À la fin, il vous rend le téléphone.';

  @override
  String get accChooseVehicle =>
      'Choisissez votre véhicule : son assureur reçoit le constat.';

  @override
  String accInsuranceExpired(String vehicle, String date) {
    return 'Le contrat d’assurance de $vehicle a expiré le $date. Renouvelez-le dans Véhicules avant de déclarer.';
  }

  @override
  String get accYourVehicle => 'VOTRE VÉHICULE';

  @override
  String get accAddVehicleHint =>
      'Ajoutez votre véhicule et son assureur : c’est à lui que le constat est transmis.';

  @override
  String get accAddMyVehicle => 'Ajouter mon véhicule';

  @override
  String accContractExpiredOn(String date) {
    return 'Contrat expiré le $date';
  }

  @override
  String get accInsurerMissing => 'Assureur non renseigné';

  @override
  String accInsuredUntil(String insurer, String date) {
    return '$insurer · jusqu’au $date';
  }

  @override
  String get accWhereWhen => 'Où et quand ?';

  @override
  String get accWhereWhenHint =>
      'Vérifiez les informations détectées automatiquement.';

  @override
  String get accPlaceRequired => 'Indiquez le lieu de l’accident';

  @override
  String get accAccidentPlace => 'Lieu de l’accident';

  @override
  String get accChooseOnMap => 'Choisir sur la carte';

  @override
  String accGpsLine(String coords, int accuracy) {
    return 'GPS $coords • précision ±$accuracy m';
  }

  @override
  String get accDateTime => 'Date et heure';

  @override
  String get accWeather => 'Météo';

  @override
  String get accRoad => 'Chaussée';

  @override
  String get accLight => 'Luminosité';

  @override
  String get accPlaceConfirmed => 'Lieu de l’accident confirmé et sauvegardé.';

  @override
  String get accPositionUnavailable =>
      'Position indisponible. Réessayez dans un instant.';

  @override
  String get accPositionDetected => 'Position détectée';

  @override
  String accUseDetectedQuestion(String place) {
    return '$place\n\nVoulez-vous utiliser cette localisation ?';
  }

  @override
  String get accChooseAnother => 'Choisir une autre';

  @override
  String get accUsePosition => 'Utiliser cette position';

  @override
  String get accAutoLocationFailed => 'Localisation automatique impossible.';

  @override
  String get accLocationDisabled =>
      'Activez la localisation GPS de l’appareil.';

  @override
  String get accLocationDenied =>
      'La permission de localisation a été refusée.';

  @override
  String get accLocationDeniedForever =>
      'Autorisez la localisation dans les paramètres de l’application.';

  @override
  String get accAddressNotFound => 'Adresse introuvable.';

  @override
  String get accValueSunny => 'Ensoleillé';

  @override
  String get accValueRain => 'Pluie';

  @override
  String get accValueFog => 'Brouillard';

  @override
  String get accValueDry => 'Sèche';

  @override
  String get accValueWet => 'Mouillée';

  @override
  String get accValueSlippery => 'Glissante';

  @override
  String get accValueDay => 'Jour';

  @override
  String get accValueDusk => 'Crépuscule';

  @override
  String get accValueNightLit => 'Nuit éclairée';

  @override
  String get accValueNightDark => 'Nuit sombre';

  @override
  String get accEvidenceOverview => 'Vue d’ensemble';

  @override
  String get accEvidenceDamageA => 'Dégâts véhicule A';

  @override
  String get accEvidenceDamageB => 'Dégâts véhicule B';

  @override
  String get accEvidencePlates => 'Plaques';

  @override
  String get accWhatHappened => 'Que s’est-il passé ?';

  @override
  String get accWhatHappenedHint =>
      'Ces informations permettent de prioriser votre dossier.';

  @override
  String get accAccidentType => 'Type d\'accident';

  @override
  String get accSeverity => 'Gravité';

  @override
  String get accVehicles => 'Véhicules';

  @override
  String get accInjured => 'Blessés';

  @override
  String get accSecureArea => 'Sécurisez la zone et appelez les secours';

  @override
  String get accSamu => 'SAMU';

  @override
  String get accPolice => 'Police';

  @override
  String get accCivilProtection => 'Protection civile';

  @override
  String accCalling(String number) {
    return 'Appel du $number';
  }

  @override
  String get accWitnessOptional => 'Témoin (optionnel)';

  @override
  String get accWitnessName => 'Nom du témoin';

  @override
  String get accPhone => 'Téléphone';

  @override
  String get accGuidedPhotos => 'Photos guidées';

  @override
  String accPhotosProgress(int count) {
    return '$count/4 vues ajoutées • 2 minimum requises';
  }

  @override
  String get accPhotoSaved => 'Photo enregistrée • touchez pour reprendre';

  @override
  String get accTapToOpenCamera => 'Touchez pour ouvrir la caméra';

  @override
  String get accSceneVideo => 'Vidéo de la scène';

  @override
  String get accOpeningCamera => 'Ouverture de la caméra…';

  @override
  String get accVideoSaved => 'Vidéo enregistrée • touchez pour la lire';

  @override
  String get accFilmScene => 'Filmez la scène • 30 secondes maximum';

  @override
  String get accStopRecording => 'Arrêter l’enregistrement';

  @override
  String get accVoiceNote => 'Note vocale';

  @override
  String get accRecordingInProgress =>
      'Enregistrement en cours… touchez pour arrêter';

  @override
  String get accVoiceNoteSaved => 'Note enregistrée • touchez pour écouter';

  @override
  String get accDescribeByVoice => 'Décrivez la scène avec votre voix';

  @override
  String get accVideoSaveFailed => 'Impossible d’enregistrer la vidéo.';

  @override
  String get accMicPermission =>
      'Autorisez le microphone pour enregistrer une note vocale.';

  @override
  String get accMicFailed => 'Impossible de démarrer le microphone.';

  @override
  String get accVideoMissing =>
      'La vidéo n’existe plus. Vous pouvez la reprendre.';

  @override
  String get accVoiceNoteMissing =>
      'La note vocale n’existe plus. Vous pouvez la refaire.';

  @override
  String get accListen => 'Écouter';

  @override
  String get accRedoRecording => 'Refaire l’enregistrement';

  @override
  String get accDelete => 'Supprimer';

  @override
  String get accPause => 'Pause';

  @override
  String get accPlay => 'Lire';

  @override
  String get accSummary => 'RÉCAPITULATIF';

  @override
  String accSummaryCounts(int vehicles, int injured, int photos) {
    return '$vehicles véhicule(s) • $injured blessé(s) • $photos photo(s)';
  }

  @override
  String get accReportCompleted => 'Constat complété';

  @override
  String get accReviewHint =>
      'Vérifiez toutes les informations avant la transmission.';

  @override
  String get accSectionAccident => 'Accident';

  @override
  String get accPlace => 'Lieu';

  @override
  String get accType => 'Type';

  @override
  String get accConditions => 'Conditions';

  @override
  String get accVehiclesInjured => 'Véhicules / blessés';

  @override
  String accVehiclesInjuredValue(int vehicles, int injured) {
    return '$vehicles véhicule(s) • $injured blessé(s)';
  }

  @override
  String get accWitness => 'Témoin';

  @override
  String get accSectionDriverA => 'Conducteur & Véhicule A';

  @override
  String get accName => 'Nom';

  @override
  String get accLicense => 'Permis';

  @override
  String get accVehicle => 'Véhicule';

  @override
  String get accPlate => 'Immatriculation';

  @override
  String get accInsurance => 'Assurance';

  @override
  String get accPolicyNumber => 'N° de police';

  @override
  String get accLicenseExpiry => 'Validité du permis';

  @override
  String get accObservations => 'Observations';

  @override
  String get accImpactZones => 'Zones de choc';

  @override
  String get accPhotos => 'Photos';

  @override
  String get accSketchMissing => 'Croquis manquant';

  @override
  String get accPdfFailed => 'Impossible de générer le PDF. Réessayez.';

  @override
  String get accPdfTitle => 'Constat PDF';

  @override
  String get accPdfHint =>
      'Le document reprend les informations officielles, photos, croquis et signatures.';

  @override
  String get accPreview => 'Aperçu';

  @override
  String get accShare => 'Partager';

  @override
  String get accNotProvided => 'Non renseigné';

  @override
  String get accNoPhotos => 'Aucune photo enregistrée.';

  @override
  String get accMyDeclarations => 'Mes déclarations';

  @override
  String get accMyDeclarationsHint => 'Brouillons et dossiers transmis';

  @override
  String get accDraftInProgress => 'BROUILLON EN COURS';

  @override
  String get accResume => 'Reprendre';

  @override
  String get accSentDeclarations => 'DÉCLARATIONS TRANSMISES';

  @override
  String get accNoSentDeclarations => 'Aucune déclaration transmise.';

  @override
  String get accDeleteDraftTitle => 'Supprimer le brouillon ?';

  @override
  String get accDeleteDraftText =>
      'Les informations non transmises seront perdues.';

  @override
  String get accCancel => 'Annuler';

  @override
  String get accEmergencyNumbers => 'Numéros d’urgence';

  @override
  String get accSearchAddress => 'Rechercher une adresse';

  @override
  String get accSearch => 'Rechercher';

  @override
  String get accMyPosition => 'Ma position';

  @override
  String get accSelectedPlace => 'LIEU SÉLECTIONNÉ';

  @override
  String get accConfirmPlace => 'Confirmer ce lieu';

  @override
  String get accMinChars => 'Saisissez au moins 3 caractères.';

  @override
  String get accPlaceFetchFailed => 'Impossible de récupérer ce lieu.';

  @override
  String get cstNotProvided => 'Non renseigné';

  @override
  String get cstClear => 'Effacer';

  @override
  String get cstEdit => 'Modifier';

  @override
  String get cstTapToDrawFullscreen => 'Touchez pour dessiner en plein écran';

  @override
  String get cstCloseWithoutSaving => 'Fermer sans enregistrer';

  @override
  String get cstUndoLastStroke => 'Annuler le dernier trait';

  @override
  String get cstClearAll => 'Tout effacer';

  @override
  String get cstDone => 'Terminé';

  @override
  String get cstSignHint => 'Signez avec votre doigt ou le curseur';

  @override
  String get cstGuestModeTitle => 'Mode invité — Conducteur B';

  @override
  String get cstShareWithDriverB => 'Partage avec le conducteur B';

  @override
  String get cstGuestQrInstructions =>
      'Faites scanner ce QR code au conducteur B avec son smartphone pour qu’il vérifie ses informations et suive la déclaration en direct.';

  @override
  String get cstNoInstallRequired =>
      'Aucune installation d’application requise pour le conducteur B.';

  @override
  String get cstGuestLinkCopied => 'Lien invité copié dans le presse-papier !';

  @override
  String get cstCopyGuestLink => 'Copier le lien d’accès invité';

  @override
  String get cstContinueOnThisDevice => 'Continuer la saisie sur cet appareil';

  @override
  String get cstSealedTitle => 'Constat scellé';

  @override
  String get cstSealedOnPhone => 'Constat scellé sur le téléphone';

  @override
  String get cstSealedAndSent => 'Constat scellé et transmis';

  @override
  String get cstSealedOfflineHint =>
      'Pas de réseau : il sera transmis et signé par le serveur dès le retour de la connexion.';

  @override
  String get cstSealedOnlineHint =>
      'Document officiel inaltérable signé bilatéralement.';

  @override
  String get cstOfflineCertification => 'CERTIFICATION HORS-LIGNE (JWS)';

  @override
  String get cstScanQrToVerify =>
      'Scannez ce QR Code pour certifier l’authenticité et l’intégrité du constat sans connexion au serveur.';

  @override
  String get cstCertifiedQr => 'QR Code Certifié';

  @override
  String get cstEcdsaCertified =>
      'Signature ECDSA P-256 certifiée — Zero-Dependency Verification';

  @override
  String get cstVehicleA => 'Véhicule A';

  @override
  String get cstVehicleB => 'Véhicule B';

  @override
  String get cstDriverA => 'Conducteur A';

  @override
  String get cstDriverB => 'Conducteur B';

  @override
  String get cstPlateA => 'Immatriculation A';

  @override
  String get cstPlateB => 'Immatriculation B';

  @override
  String get cstInsurerA => 'Assurance A';

  @override
  String get cstInsurerB => 'Assurance B';

  @override
  String cstPolicyLine(String policy) {
    return 'Police : $policy';
  }

  @override
  String get cstViewOfficialPdf => 'Consulter l’exemplaire officiel (PDF)';

  @override
  String get cstShareSealed => 'Partager le constat scellé';

  @override
  String get cstBackToHome => 'Retour à l’accueil';

  @override
  String cstPdfPreviewError(String error) {
    return 'Erreur aperçu PDF : $error';
  }

  @override
  String cstPdfShareError(String error) {
    return 'Erreur partage PDF : $error';
  }

  @override
  String get cstDriverBTitle => 'Informations du conducteur B';

  @override
  String get cstDriverBSubtitle =>
      'Données nécessaires au constat, isolées de votre profil.';

  @override
  String get cstScanLicenseAi => 'Scanner le permis avec l’IA';

  @override
  String get cstScanLicenseHint =>
      'La photo est analysée localement. Vérifiez toujours les données détectées.';

  @override
  String get cstScanning => 'Analyse en cours…';

  @override
  String get cstTakeLicensePhoto => 'Photographier le permis';

  @override
  String get cstFullNameRequired => 'Nom complet *';

  @override
  String get cstLicenseNumber => 'Numéro de permis';

  @override
  String get cstLicenseExpiry => 'Date de validité du permis';

  @override
  String get cstPlateRequired => 'Immatriculation *';

  @override
  String get cstInsuranceSection => 'ASSURANCE';

  @override
  String get cstPolicyNumber => 'N° de police / attestation d’assurance';

  @override
  String get cstNoTextDetected =>
      'Aucun texte détecté. Reprenez la photo avec plus de lumière.';

  @override
  String get cstLicenseScanned =>
      'Permis analysé. Vérifiez les champs avant de continuer.';

  @override
  String get cstScanFailed =>
      'Analyse impossible. Vérifiez la photo et réessayez.';

  @override
  String get cstReviewDetectedData => 'Vérifier les données détectées';

  @override
  String get cstOcrWarning =>
      'L’OCR peut faire des erreurs. Corrigez les champs avant confirmation.';

  @override
  String get cstFullName => 'Nom complet';

  @override
  String get cstLicenseNumberDialog => 'Numéro du permis';

  @override
  String get cstExpiryDate => 'Date de validité';

  @override
  String get cstRecognizedText => 'Texte reconnu par ML Kit';

  @override
  String get cstCancel => 'Annuler';

  @override
  String get cstUseThisData => 'Utiliser ces données';

  @override
  String get cstClearDate => 'Effacer la date';

  @override
  String get cstCircumstancesTitle => 'Circonstances de l’accident (FTUSA)';

  @override
  String get cstCircumstancesHint =>
      'Cochez la ou les cases utiles pour le véhicule A (bleu) et le véhicule B (ambre).';

  @override
  String cstBoxesA(int count) {
    return 'Véhicule A : $count case(s)';
  }

  @override
  String cstBoxesB(int count) {
    return 'Véhicule B : $count case(s)';
  }

  @override
  String get cstCircumstancesHeader => '12. Circonstances';

  @override
  String get cstCircumstance1 => 'En stationnement / À l’arrêt';

  @override
  String get cstCircumstance2 =>
      'Quittait un stationnement / ouvrait une portière';

  @override
  String get cstCircumstance3 => 'Prenait un stationnement';

  @override
  String get cstCircumstance4 => 'Sortait d’un parking, lieu privé ou chemin';

  @override
  String get cstCircumstance5 =>
      'S’engageait dans un parking, lieu privé ou chemin';

  @override
  String get cstCircumstance6 => 'S’engageait sur une place à sens giratoire';

  @override
  String get cstCircumstance7 => 'Circulait sur une place à sens giratoire';

  @override
  String get cstCircumstance8 => 'Heurtait à l’arrière (même sens, même file)';

  @override
  String get cstCircumstance9 =>
      'Roulait dans le même sens sur une file différente';

  @override
  String get cstCircumstance10 => 'Changeait de file';

  @override
  String get cstCircumstance11 => 'Doublait';

  @override
  String get cstCircumstance12 => 'Virait à droite';

  @override
  String get cstCircumstance13 => 'Virait à gauche';

  @override
  String get cstCircumstance14 => 'Reculait';

  @override
  String get cstCircumstance15 => 'Empiétait sur la chaussée en sens inverse';

  @override
  String get cstCircumstance16 => 'Venait de droite (dans un carrefour)';

  @override
  String get cstCircumstance17 => 'N’avait pas observé un signal de priorité';

  @override
  String get cstObservations => 'Observations complémentaires';

  @override
  String get cstSketchTitle => 'Croquis et point de choc';

  @override
  String get cstSketchFieldTitle => 'Croquis de l’accident';

  @override
  String get cstSketchHint =>
      'Dessinez les voies, les véhicules et leur direction';

  @override
  String get cstImpactZoneTitle => 'Zone de choc sur votre véhicule';

  @override
  String get cstSignInstructions =>
      'Relisez les informations puis signez dans les deux zones.';

  @override
  String get cstSignatureA => 'Signature conducteur A';

  @override
  String get cstSignatureB => 'Signature conducteur B';

  @override
  String get cstShaLock => 'Verrouillage SHA-256';

  @override
  String get cstShaLockHint =>
      'Le constat sera rendu infalsifiable après la double signature.';
}
