// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

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
}
