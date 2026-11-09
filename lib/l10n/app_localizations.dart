import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mon Constat Digital'**
  String get appTitle;

  /// No description provided for @brand.
  ///
  /// In fr, this message translates to:
  /// **'Mon Constat'**
  String get brand;

  /// No description provided for @save.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In fr, this message translates to:
  /// **'Modifier'**
  String get edit;

  /// No description provided for @retry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get retry;

  /// No description provided for @later.
  ///
  /// In fr, this message translates to:
  /// **'Plus tard'**
  String get later;

  /// No description provided for @or.
  ///
  /// In fr, this message translates to:
  /// **'ou'**
  String get or;

  /// No description provided for @validate.
  ///
  /// In fr, this message translates to:
  /// **'Valider'**
  String get validate;

  /// No description provided for @notProvided.
  ///
  /// In fr, this message translates to:
  /// **'Non renseigné'**
  String get notProvided;

  /// No description provided for @requiredField.
  ///
  /// In fr, this message translates to:
  /// **'Champ obligatoire.'**
  String get requiredField;

  /// No description provided for @invalidEmail.
  ///
  /// In fr, this message translates to:
  /// **'Adresse e-mail invalide.'**
  String get invalidEmail;

  /// No description provided for @invalidPhone.
  ///
  /// In fr, this message translates to:
  /// **'Numéro de téléphone invalide.'**
  String get invalidPhone;

  /// No description provided for @passwordTooShort.
  ///
  /// In fr, this message translates to:
  /// **'Le mot de passe doit contenir au moins 8 caractères.'**
  String get passwordTooShort;

  /// No description provided for @codeFormat.
  ///
  /// In fr, this message translates to:
  /// **'Le code contient 6 chiffres.'**
  String get codeFormat;

  /// No description provided for @passwordsDontMatch.
  ///
  /// In fr, this message translates to:
  /// **'Les mots de passe ne correspondent pas.'**
  String get passwordsDontMatch;

  /// No description provided for @roleDriver.
  ///
  /// In fr, this message translates to:
  /// **'Conducteur'**
  String get roleDriver;

  /// No description provided for @roleAgent.
  ///
  /// In fr, this message translates to:
  /// **'Agent d\'assurance'**
  String get roleAgent;

  /// No description provided for @roleAdmin.
  ///
  /// In fr, this message translates to:
  /// **'Administrateur'**
  String get roleAdmin;

  /// No description provided for @heroTitleLine1.
  ///
  /// In fr, this message translates to:
  /// **'Le constat,'**
  String get heroTitleLine1;

  /// No description provided for @heroTitleLine2.
  ///
  /// In fr, this message translates to:
  /// **'sans papier.'**
  String get heroTitleLine2;

  /// No description provided for @heroSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Déclarez, signez et suivez votre sinistre depuis votre téléphone.'**
  String get heroSubtitle;

  /// No description provided for @loginTitle.
  ///
  /// In fr, this message translates to:
  /// **'Connexion'**
  String get loginTitle;

  /// No description provided for @identifierLabel.
  ///
  /// In fr, this message translates to:
  /// **'E-mail ou téléphone'**
  String get identifierLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get passwordLabel;

  /// No description provided for @forgotPasswordLink.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe oublié ?'**
  String get forgotPasswordLink;

  /// No description provided for @signIn.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get signIn;

  /// No description provided for @biometricButton.
  ///
  /// In fr, this message translates to:
  /// **'Empreinte ou Face ID'**
  String get biometricButton;

  /// No description provided for @noAccount.
  ///
  /// In fr, this message translates to:
  /// **'Pas encore de compte ?'**
  String get noAccount;

  /// No description provided for @createAccountLink.
  ///
  /// In fr, this message translates to:
  /// **'Créer un compte'**
  String get createAccountLink;

  /// No description provided for @showPassword.
  ///
  /// In fr, this message translates to:
  /// **'Afficher le mot de passe'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In fr, this message translates to:
  /// **'Masquer le mot de passe'**
  String get hidePassword;

  /// No description provided for @biometricLoginReason.
  ///
  /// In fr, this message translates to:
  /// **'Connectez-vous à Mon Constat'**
  String get biometricLoginReason;

  /// No description provided for @biometricEnableReason.
  ///
  /// In fr, this message translates to:
  /// **'Confirmez pour activer la connexion biométrique'**
  String get biometricEnableReason;

  /// No description provided for @languageSwitcher.
  ///
  /// In fr, this message translates to:
  /// **'Langue de l\'application'**
  String get languageSwitcher;

  /// No description provided for @registerTitle.
  ///
  /// In fr, this message translates to:
  /// **'Créer un compte'**
  String get registerTitle;

  /// No description provided for @firstNameLabel.
  ///
  /// In fr, this message translates to:
  /// **'Prénom'**
  String get firstNameLabel;

  /// No description provided for @lastNameLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nom'**
  String get lastNameLabel;

  /// No description provided for @emailLabel.
  ///
  /// In fr, this message translates to:
  /// **'E-mail'**
  String get emailLabel;

  /// No description provided for @phoneLabel.
  ///
  /// In fr, this message translates to:
  /// **'Téléphone'**
  String get phoneLabel;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer le mot de passe'**
  String get confirmPasswordLabel;

  /// No description provided for @createMyAccount.
  ///
  /// In fr, this message translates to:
  /// **'Créer mon compte'**
  String get createMyAccount;

  /// No description provided for @otpTitle.
  ///
  /// In fr, this message translates to:
  /// **'Vérifier mon téléphone'**
  String get otpTitle;

  /// No description provided for @otpInstructions.
  ///
  /// In fr, this message translates to:
  /// **'Saisissez le code à 6 chiffres envoyé sur WhatsApp au {phone}.'**
  String otpInstructions(String phone);

  /// No description provided for @otpCodeLabel.
  ///
  /// In fr, this message translates to:
  /// **'Code de vérification'**
  String get otpCodeLabel;

  /// No description provided for @resendCode.
  ///
  /// In fr, this message translates to:
  /// **'Renvoyer le code'**
  String get resendCode;

  /// No description provided for @resendCodeIn.
  ///
  /// In fr, this message translates to:
  /// **'Renvoyer le code ({seconds} s)'**
  String resendCodeIn(int seconds);

  /// No description provided for @forgotTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe oublié'**
  String get forgotTitle;

  /// No description provided for @forgotIntro.
  ///
  /// In fr, this message translates to:
  /// **'Saisissez votre adresse e-mail pour recevoir un code de réinitialisation.'**
  String get forgotIntro;

  /// No description provided for @forgotCodeSent.
  ///
  /// In fr, this message translates to:
  /// **'Si un compte existe pour {email}, un code valable 15 minutes vient de lui être envoyé.'**
  String forgotCodeSent(String email);

  /// No description provided for @codeFromEmailLabel.
  ///
  /// In fr, this message translates to:
  /// **'Code reçu par e-mail'**
  String get codeFromEmailLabel;

  /// No description provided for @newPasswordLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau mot de passe'**
  String get newPasswordLabel;

  /// No description provided for @receiveCode.
  ///
  /// In fr, this message translates to:
  /// **'Recevoir un code'**
  String get receiveCode;

  /// No description provided for @changePassword.
  ///
  /// In fr, this message translates to:
  /// **'Changer le mot de passe'**
  String get changePassword;

  /// No description provided for @passwordChanged.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe modifié. Vous pouvez vous connecter.'**
  String get passwordChanged;

  /// No description provided for @profileTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mon profil'**
  String get profileTitle;

  /// No description provided for @profileSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Identité, permis et préférences'**
  String get profileSubtitle;

  /// No description provided for @profileCompletion.
  ///
  /// In fr, this message translates to:
  /// **'Profil complété à {percent} %'**
  String profileCompletion(int percent);

  /// No description provided for @profileCompleteHint.
  ///
  /// In fr, this message translates to:
  /// **'Complétez votre permis : il servira à remplir le constat.'**
  String get profileCompleteHint;

  /// No description provided for @profileComplete.
  ///
  /// In fr, this message translates to:
  /// **'Profil complet, prêt pour un constat.'**
  String get profileComplete;

  /// No description provided for @sectionIdentity.
  ///
  /// In fr, this message translates to:
  /// **'Identité'**
  String get sectionIdentity;

  /// No description provided for @sectionLicense.
  ///
  /// In fr, this message translates to:
  /// **'Permis de conduire'**
  String get sectionLicense;

  /// No description provided for @sectionSecurity.
  ///
  /// In fr, this message translates to:
  /// **'Sécurité'**
  String get sectionSecurity;

  /// No description provided for @sectionPreferences.
  ///
  /// In fr, this message translates to:
  /// **'Préférences'**
  String get sectionPreferences;

  /// No description provided for @fullNameLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nom complet'**
  String get fullNameLabel;

  /// No description provided for @emailNotEditable.
  ///
  /// In fr, this message translates to:
  /// **'L\'e-mail ne peut pas être modifié.'**
  String get emailNotEditable;

  /// No description provided for @phoneVerified.
  ///
  /// In fr, this message translates to:
  /// **'Numéro vérifié'**
  String get phoneVerified;

  /// No description provided for @phoneNotVerified.
  ///
  /// In fr, this message translates to:
  /// **'Numéro non vérifié'**
  String get phoneNotVerified;

  /// No description provided for @verify.
  ///
  /// In fr, this message translates to:
  /// **'Vérifier'**
  String get verify;

  /// No description provided for @licenseNumberLabel.
  ///
  /// In fr, this message translates to:
  /// **'N° de permis'**
  String get licenseNumberLabel;

  /// No description provided for @licenseCategoryLabel.
  ///
  /// In fr, this message translates to:
  /// **'Catégorie'**
  String get licenseCategoryLabel;

  /// No description provided for @licenseIssuedLabel.
  ///
  /// In fr, this message translates to:
  /// **'Date de délivrance'**
  String get licenseIssuedLabel;

  /// No description provided for @licenseEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun permis enregistré. Il sert à remplir votre partie du constat.'**
  String get licenseEmpty;

  /// No description provided for @addLicense.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter mon permis'**
  String get addLicense;

  /// No description provided for @licenseIssuedOn.
  ///
  /// In fr, this message translates to:
  /// **'Délivré le {date}'**
  String licenseIssuedOn(String date);

  /// No description provided for @licensePhotoAdd.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter la photo du permis'**
  String get licensePhotoAdd;

  /// No description provided for @replace.
  ///
  /// In fr, this message translates to:
  /// **'Remplacer'**
  String get replace;

  /// No description provided for @biometricTitle.
  ///
  /// In fr, this message translates to:
  /// **'Connexion par empreinte'**
  String get biometricTitle;

  /// No description provided for @biometricSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Empreinte ou reconnaissance faciale, 30 jours sur ce téléphone'**
  String get biometricSubtitle;

  /// No description provided for @biometricEnabled.
  ///
  /// In fr, this message translates to:
  /// **'Connexion biométrique activée'**
  String get biometricEnabled;

  /// No description provided for @languageLabel.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get languageLabel;

  /// No description provided for @logout.
  ///
  /// In fr, this message translates to:
  /// **'Se déconnecter'**
  String get logout;

  /// No description provided for @profileSaved.
  ///
  /// In fr, this message translates to:
  /// **'Profil enregistré'**
  String get profileSaved;

  /// No description provided for @editIdentityTitle.
  ///
  /// In fr, this message translates to:
  /// **'Modifier l\'identité'**
  String get editIdentityTitle;

  /// No description provided for @editLicenseTitle.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le permis'**
  String get editLicenseTitle;

  /// No description provided for @changeProfilePhoto.
  ///
  /// In fr, this message translates to:
  /// **'Changer la photo de profil'**
  String get changeProfilePhoto;

  /// No description provided for @phoneChangeNotice.
  ///
  /// In fr, this message translates to:
  /// **'Un nouveau numéro devra être vérifié par un code WhatsApp.'**
  String get phoneChangeNotice;

  /// No description provided for @takePhoto.
  ///
  /// In fr, this message translates to:
  /// **'Prendre une photo'**
  String get takePhoto;

  /// No description provided for @chooseFromGallery.
  ///
  /// In fr, this message translates to:
  /// **'Choisir dans la galerie'**
  String get chooseFromGallery;

  /// No description provided for @deletePhoto.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer la photo'**
  String get deletePhoto;

  /// No description provided for @photoSaved.
  ///
  /// In fr, this message translates to:
  /// **'Photo enregistrée'**
  String get photoSaved;

  /// No description provided for @accountsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Gestion des comptes'**
  String get accountsTitle;

  /// No description provided for @accountsSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Rôles, agents et suspensions'**
  String get accountsSubtitle;

  /// No description provided for @createAgentTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Créer un agent'**
  String get createAgentTooltip;

  /// No description provided for @searchHint.
  ///
  /// In fr, this message translates to:
  /// **'Nom, e-mail ou téléphone'**
  String get searchHint;

  /// No description provided for @noAccounts.
  ///
  /// In fr, this message translates to:
  /// **'Aucun compte trouvé.'**
  String get noAccounts;

  /// No description provided for @roleLabel.
  ///
  /// In fr, this message translates to:
  /// **'Rôle'**
  String get roleLabel;

  /// No description provided for @companyLabel.
  ///
  /// In fr, this message translates to:
  /// **'Compagnie'**
  String get companyLabel;

  /// No description provided for @createAgentTitle.
  ///
  /// In fr, this message translates to:
  /// **'Créer un agent'**
  String get createAgentTitle;

  /// No description provided for @tempPasswordLabel.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe provisoire'**
  String get tempPasswordLabel;

  /// No description provided for @createAccountButton.
  ///
  /// In fr, this message translates to:
  /// **'Créer le compte'**
  String get createAccountButton;

  /// No description provided for @companiesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Compagnies d\'assurance'**
  String get companiesTitle;

  /// No description provided for @companiesSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Compagnies et agences'**
  String get companiesSubtitle;

  /// No description provided for @addCompany.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une compagnie'**
  String get addCompany;

  /// No description provided for @noCompanies.
  ///
  /// In fr, this message translates to:
  /// **'Aucune compagnie enregistrée.'**
  String get noCompanies;

  /// No description provided for @agencyCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucune agence} =1{1 agence} other{{count} agences}}'**
  String agencyCount(int count);

  /// No description provided for @addAgency.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une agence'**
  String get addAgency;

  /// No description provided for @rename.
  ///
  /// In fr, this message translates to:
  /// **'Renommer'**
  String get rename;

  /// No description provided for @newCompany.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle compagnie'**
  String get newCompany;

  /// No description provided for @renameCompany.
  ///
  /// In fr, this message translates to:
  /// **'Renommer la compagnie'**
  String get renameCompany;

  /// No description provided for @companyNameLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nom de la compagnie'**
  String get companyNameLabel;

  /// No description provided for @newAgency.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle agence'**
  String get newAgency;

  /// No description provided for @editAgency.
  ///
  /// In fr, this message translates to:
  /// **'Modifier l\'agence'**
  String get editAgency;

  /// No description provided for @agencyNameLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nom de l\'agence'**
  String get agencyNameLabel;

  /// No description provided for @cityLabel.
  ///
  /// In fr, this message translates to:
  /// **'Ville'**
  String get cityLabel;

  /// No description provided for @deleteCompanyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer {name} ?'**
  String deleteCompanyTitle(String name);

  /// No description provided for @deleteCompanyBody.
  ///
  /// In fr, this message translates to:
  /// **'Ses agences seront aussi supprimées.'**
  String get deleteCompanyBody;

  /// No description provided for @deleteAgencyTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer l\'agence'**
  String get deleteAgencyTooltip;

  /// No description provided for @adminTitle.
  ///
  /// In fr, this message translates to:
  /// **'Administration'**
  String get adminTitle;

  /// No description provided for @adminSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Vue globale de la plateforme'**
  String get adminSubtitle;

  /// No description provided for @demoData.
  ///
  /// In fr, this message translates to:
  /// **'Données de démonstration'**
  String get demoData;

  /// No description provided for @statAccidents.
  ///
  /// In fr, this message translates to:
  /// **'Accidents'**
  String get statAccidents;

  /// No description provided for @statOpen.
  ///
  /// In fr, this message translates to:
  /// **'Ouverts'**
  String get statOpen;

  /// No description provided for @statClosed.
  ///
  /// In fr, this message translates to:
  /// **'Clôturés'**
  String get statClosed;

  /// No description provided for @statAvgDelay.
  ///
  /// In fr, this message translates to:
  /// **'Délai moyen'**
  String get statAvgDelay;

  /// No description provided for @heatmapTitle.
  ///
  /// In fr, this message translates to:
  /// **'Carte des zones à forte accidentalité'**
  String get heatmapTitle;

  /// No description provided for @severityTitle.
  ///
  /// In fr, this message translates to:
  /// **'Répartition par gravité'**
  String get severityTitle;

  /// No description provided for @severityMaterial.
  ///
  /// In fr, this message translates to:
  /// **'{percent} % matériel'**
  String severityMaterial(int percent);

  /// No description provided for @navHome.
  ///
  /// In fr, this message translates to:
  /// **'Accueil'**
  String get navHome;

  /// No description provided for @navVehicles.
  ///
  /// In fr, this message translates to:
  /// **'Véhicules'**
  String get navVehicles;

  /// No description provided for @navClaims.
  ///
  /// In fr, this message translates to:
  /// **'Dossiers'**
  String get navClaims;

  /// No description provided for @navMessages.
  ///
  /// In fr, this message translates to:
  /// **'Messages'**
  String get navMessages;

  /// No description provided for @navProfile.
  ///
  /// In fr, this message translates to:
  /// **'Profil'**
  String get navProfile;

  /// No description provided for @navDashboard.
  ///
  /// In fr, this message translates to:
  /// **'Tableau'**
  String get navDashboard;

  /// No description provided for @navCases.
  ///
  /// In fr, this message translates to:
  /// **'Sinistres'**
  String get navCases;

  /// No description provided for @navAccounts.
  ///
  /// In fr, this message translates to:
  /// **'Comptes'**
  String get navAccounts;

  /// No description provided for @navCompanies.
  ///
  /// In fr, this message translates to:
  /// **'Compagnies'**
  String get navCompanies;

  /// No description provided for @errorGeneric.
  ///
  /// In fr, this message translates to:
  /// **'Une erreur est survenue. Réessayez.'**
  String get errorGeneric;

  /// No description provided for @errorNetwork.
  ///
  /// In fr, this message translates to:
  /// **'Connexion au serveur impossible. Vérifiez votre réseau.'**
  String get errorNetwork;

  /// No description provided for @errorInvalidCredentials.
  ///
  /// In fr, this message translates to:
  /// **'Identifiant ou mot de passe incorrect.'**
  String get errorInvalidCredentials;

  /// No description provided for @errorAccountLocked.
  ///
  /// In fr, this message translates to:
  /// **'Compte bloqué pendant 15 minutes après 5 échecs. Réessayez plus tard.'**
  String get errorAccountLocked;

  /// No description provided for @errorAccountSuspended.
  ///
  /// In fr, this message translates to:
  /// **'Ce compte est suspendu.'**
  String get errorAccountSuspended;

  /// No description provided for @errorAlreadyExists.
  ///
  /// In fr, this message translates to:
  /// **'Cette valeur est déjà utilisée.'**
  String get errorAlreadyExists;

  /// No description provided for @errorInvalidCode.
  ///
  /// In fr, this message translates to:
  /// **'Code incorrect ou expiré.'**
  String get errorInvalidCode;

  /// No description provided for @errorCodeCooldown.
  ///
  /// In fr, this message translates to:
  /// **'Attendez une minute avant de redemander un code.'**
  String get errorCodeCooldown;

  /// No description provided for @errorSessionExpired.
  ///
  /// In fr, this message translates to:
  /// **'Session expirée. Reconnectez-vous.'**
  String get errorSessionExpired;

  /// No description provided for @errorBiometricInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Connexion biométrique expirée. Connectez-vous avec votre mot de passe.'**
  String get errorBiometricInvalid;

  /// No description provided for @errorBiometricUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Empreinte ou reconnaissance faciale indisponible. Vérifiez les réglages de sécurité du téléphone.'**
  String get errorBiometricUnavailable;

  /// No description provided for @errorFileTooLarge.
  ///
  /// In fr, this message translates to:
  /// **'Image trop lourde : 5 Mo maximum.'**
  String get errorFileTooLarge;

  /// No description provided for @errorUnsupportedImage.
  ///
  /// In fr, this message translates to:
  /// **'Format accepté : JPEG, PNG ou WebP.'**
  String get errorUnsupportedImage;

  /// No description provided for @errorCompanyInUse.
  ///
  /// In fr, this message translates to:
  /// **'Cette compagnie a encore des agents rattachés.'**
  String get errorCompanyInUse;

  /// No description provided for @errorSelfChange.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de modifier votre propre rôle ou statut.'**
  String get errorSelfChange;

  /// No description provided for @errorInvalidData.
  ///
  /// In fr, this message translates to:
  /// **'Certaines données sont invalides.'**
  String get errorInvalidData;

  /// No description provided for @appearanceLabel.
  ///
  /// In fr, this message translates to:
  /// **'Apparence'**
  String get appearanceLabel;

  /// No description provided for @themeSystem.
  ///
  /// In fr, this message translates to:
  /// **'Comme le téléphone'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In fr, this message translates to:
  /// **'Clair'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In fr, this message translates to:
  /// **'Sombre'**
  String get themeDark;

  /// No description provided for @navDeclarations.
  ///
  /// In fr, this message translates to:
  /// **'Déclarations'**
  String get navDeclarations;

  /// No description provided for @securityDevicesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Appareils connectés'**
  String get securityDevicesTitle;

  /// No description provided for @securityDevicesSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Où votre compte est ouvert'**
  String get securityDevicesSubtitle;

  /// No description provided for @thisDevice.
  ///
  /// In fr, this message translates to:
  /// **'Cet appareil'**
  String get thisDevice;

  /// No description provided for @lastActive.
  ///
  /// In fr, this message translates to:
  /// **'Actif le {when}'**
  String lastActive(String when);

  /// No description provided for @signOutDevice.
  ///
  /// In fr, this message translates to:
  /// **'Déconnecter'**
  String get signOutDevice;

  /// No description provided for @signOutDeviceConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Déconnecter {name} ?'**
  String signOutDeviceConfirm(String name);

  /// No description provided for @signOutDeviceBody.
  ///
  /// In fr, this message translates to:
  /// **'Cet appareil devra se reconnecter avec le mot de passe.'**
  String get signOutDeviceBody;

  /// No description provided for @signOutOthers.
  ///
  /// In fr, this message translates to:
  /// **'Déconnecter les autres appareils'**
  String get signOutOthers;

  /// No description provided for @signedOutOthers.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucun autre appareil connecté} =1{1 appareil déconnecté} other{{count} appareils déconnectés}}'**
  String signedOutOthers(int count);

  /// No description provided for @unknownDevice.
  ///
  /// In fr, this message translates to:
  /// **'Appareil inconnu'**
  String get unknownDevice;

  /// No description provided for @securityAlertNote.
  ///
  /// In fr, this message translates to:
  /// **'Une connexion depuis un nouvel appareil vous est signalée sur WhatsApp et par e-mail.'**
  String get securityAlertNote;

  /// No description provided for @loginHistoryTitle.
  ///
  /// In fr, this message translates to:
  /// **'Historique des connexions'**
  String get loginHistoryTitle;

  /// No description provided for @noHistory.
  ///
  /// In fr, this message translates to:
  /// **'Aucune connexion enregistrée.'**
  String get noHistory;

  /// No description provided for @loginSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Connexion réussie'**
  String get loginSuccess;

  /// No description provided for @loginMethodPassword.
  ///
  /// In fr, this message translates to:
  /// **'mot de passe'**
  String get loginMethodPassword;

  /// No description provided for @loginMethodBiometric.
  ///
  /// In fr, this message translates to:
  /// **'empreinte'**
  String get loginMethodBiometric;

  /// No description provided for @loginMethodRegister.
  ///
  /// In fr, this message translates to:
  /// **'création du compte'**
  String get loginMethodRegister;

  /// No description provided for @loginFailedWrongPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe incorrect'**
  String get loginFailedWrongPassword;

  /// No description provided for @loginFailedLocked.
  ///
  /// In fr, this message translates to:
  /// **'Tentative sur compte bloqué'**
  String get loginFailedLocked;

  /// No description provided for @loginFailedSuspended.
  ///
  /// In fr, this message translates to:
  /// **'Tentative sur compte suspendu'**
  String get loginFailedSuspended;

  /// No description provided for @identityTitle.
  ///
  /// In fr, this message translates to:
  /// **'Vérification d\'identité'**
  String get identityTitle;

  /// No description provided for @identityStatusUnverified.
  ///
  /// In fr, this message translates to:
  /// **'Identité non vérifiée'**
  String get identityStatusUnverified;

  /// No description provided for @identityStatusPending.
  ///
  /// In fr, this message translates to:
  /// **'Vérification en cours'**
  String get identityStatusPending;

  /// No description provided for @identityStatusVerified.
  ///
  /// In fr, this message translates to:
  /// **'Identité vérifiée'**
  String get identityStatusVerified;

  /// No description provided for @identityStatusRejected.
  ///
  /// In fr, this message translates to:
  /// **'Vérification refusée'**
  String get identityStatusRejected;

  /// No description provided for @identityIntro.
  ///
  /// In fr, this message translates to:
  /// **'Un administrateur vérifie votre CIN. Elle est exigée pour signer un constat.'**
  String get identityIntro;

  /// No description provided for @identityPendingNote.
  ///
  /// In fr, this message translates to:
  /// **'Un administrateur vérifie vos documents. Vous serez prévenu sur WhatsApp et par e-mail.'**
  String get identityPendingNote;

  /// No description provided for @identityVerifiedNote.
  ///
  /// In fr, this message translates to:
  /// **'Vous pouvez signer vos constats.'**
  String get identityVerifiedNote;

  /// No description provided for @identityRejectedReason.
  ///
  /// In fr, this message translates to:
  /// **'Motif : {reason}'**
  String identityRejectedReason(String reason);

  /// No description provided for @cinNumberLabel.
  ///
  /// In fr, this message translates to:
  /// **'N° de CIN'**
  String get cinNumberLabel;

  /// No description provided for @cinInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Le numéro de CIN contient 8 chiffres.'**
  String get cinInvalid;

  /// No description provided for @cinFront.
  ///
  /// In fr, this message translates to:
  /// **'Recto de la CIN'**
  String get cinFront;

  /// No description provided for @cinBack.
  ///
  /// In fr, this message translates to:
  /// **'Verso de la CIN'**
  String get cinBack;

  /// No description provided for @addPhoto.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter la photo'**
  String get addPhoto;

  /// No description provided for @identityPhotosRequired.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez le recto et le verso de votre CIN.'**
  String get identityPhotosRequired;

  /// No description provided for @submitIdentity.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer pour vérification'**
  String get submitIdentity;

  /// No description provided for @identitySent.
  ///
  /// In fr, this message translates to:
  /// **'Demande envoyée. Vous serez prévenu sur WhatsApp.'**
  String get identitySent;

  /// No description provided for @navIdentities.
  ///
  /// In fr, this message translates to:
  /// **'Identités'**
  String get navIdentities;

  /// No description provided for @reviewTitle.
  ///
  /// In fr, this message translates to:
  /// **'Vérifications d\'identité'**
  String get reviewTitle;

  /// No description provided for @reviewSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Demandes en attente, les plus anciennes en premier'**
  String get reviewSubtitle;

  /// No description provided for @noPendingReviews.
  ///
  /// In fr, this message translates to:
  /// **'Aucune demande en attente.'**
  String get noPendingReviews;

  /// No description provided for @submittedOn.
  ///
  /// In fr, this message translates to:
  /// **'Envoyée le {date}'**
  String submittedOn(String date);

  /// No description provided for @approve.
  ///
  /// In fr, this message translates to:
  /// **'Valider'**
  String get approve;

  /// No description provided for @reject.
  ///
  /// In fr, this message translates to:
  /// **'Refuser'**
  String get reject;

  /// No description provided for @rejectTitle.
  ///
  /// In fr, this message translates to:
  /// **'Motif du refus'**
  String get rejectTitle;

  /// No description provided for @rejectReasonBlurry.
  ///
  /// In fr, this message translates to:
  /// **'Photo floue'**
  String get rejectReasonBlurry;

  /// No description provided for @rejectReasonUnreadable.
  ///
  /// In fr, this message translates to:
  /// **'Document illisible'**
  String get rejectReasonUnreadable;

  /// No description provided for @rejectReasonNameMismatch.
  ///
  /// In fr, this message translates to:
  /// **'Nom différent du compte'**
  String get rejectReasonNameMismatch;

  /// No description provided for @rejectReasonNotCin.
  ///
  /// In fr, this message translates to:
  /// **'Ce n\'est pas une CIN'**
  String get rejectReasonNotCin;

  /// No description provided for @otherReason.
  ///
  /// In fr, this message translates to:
  /// **'Autre motif'**
  String get otherReason;

  /// No description provided for @identityApproved.
  ///
  /// In fr, this message translates to:
  /// **'Identité validée, le titulaire est prévenu'**
  String get identityApproved;

  /// No description provided for @identityRejected.
  ///
  /// In fr, this message translates to:
  /// **'Demande refusée, le titulaire est prévenu'**
  String get identityRejected;

  /// No description provided for @errorIdentityLocked.
  ///
  /// In fr, this message translates to:
  /// **'Votre identité est en cours de vérification ou déjà vérifiée.'**
  String get errorIdentityLocked;

  /// No description provided for @errorCinInUse.
  ///
  /// In fr, this message translates to:
  /// **'Ce numéro de CIN est déjà utilisé.'**
  String get errorCinInUse;

  /// No description provided for @errorIdentityNotVerified.
  ///
  /// In fr, this message translates to:
  /// **'Votre identité doit être vérifiée avant cette action.'**
  String get errorIdentityNotVerified;

  /// No description provided for @errorIdentityNotPending.
  ///
  /// In fr, this message translates to:
  /// **'Cette demande n\'est plus en attente.'**
  String get errorIdentityNotPending;

  /// No description provided for @consentLabel.
  ///
  /// In fr, this message translates to:
  /// **'J\'accepte que mes données soient traitées pour la gestion de mes constats, conformément à la loi n° 2004-63.'**
  String get consentLabel;

  /// No description provided for @consentRequired.
  ///
  /// In fr, this message translates to:
  /// **'Votre accord est nécessaire pour créer un compte.'**
  String get consentRequired;

  /// No description provided for @sectionPrivacy.
  ///
  /// In fr, this message translates to:
  /// **'Données personnelles'**
  String get sectionPrivacy;

  /// No description provided for @exportData.
  ///
  /// In fr, this message translates to:
  /// **'Télécharger mes données'**
  String get exportData;

  /// No description provided for @exportDataSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'PDF de tout ce que Mon Constat garde sur vous'**
  String get exportDataSubtitle;

  /// No description provided for @deleteAccount.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer mon compte'**
  String get deleteAccount;

  /// No description provided for @deleteAccountSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Définitif. Vos constats restent, sans votre nom.'**
  String get deleteAccountSubtitle;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer votre compte ?'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountBody.
  ///
  /// In fr, this message translates to:
  /// **'Votre nom, vos coordonnées, votre permis, votre CIN et vos photos seront effacés. Les accidents et sinistres déjà déclarés restent, anonymes, comme l\'exige l\'assurance. Cette action est définitive.'**
  String get deleteAccountBody;

  /// No description provided for @deleteAccountConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer définitivement'**
  String get deleteAccountConfirm;

  /// No description provided for @accountDeleted.
  ///
  /// In fr, this message translates to:
  /// **'Votre compte a été supprimé.'**
  String get accountDeleted;

  /// No description provided for @errorAdminCannotDelete.
  ///
  /// In fr, this message translates to:
  /// **'Un administrateur ne peut pas supprimer son compte ici.'**
  String get errorAdminCannotDelete;

  /// No description provided for @dashUsers.
  ///
  /// In fr, this message translates to:
  /// **'Utilisateurs'**
  String get dashUsers;

  /// No description provided for @dashActive.
  ///
  /// In fr, this message translates to:
  /// **'{count} actifs'**
  String dashActive(int count);

  /// No description provided for @dashPendingIds.
  ///
  /// In fr, this message translates to:
  /// **'À vérifier'**
  String get dashPendingIds;

  /// No description provided for @dashVerifiedIds.
  ///
  /// In fr, this message translates to:
  /// **'{count} identités vérifiées'**
  String dashVerifiedIds(int count);

  /// No description provided for @dashPhones.
  ///
  /// In fr, this message translates to:
  /// **'Téléphones vérifiés'**
  String get dashPhones;

  /// No description provided for @dashSignIns.
  ///
  /// In fr, this message translates to:
  /// **'Connexions 7 j'**
  String get dashSignIns;

  /// No description provided for @dashFailed.
  ///
  /// In fr, this message translates to:
  /// **'{count} échecs'**
  String dashFailed(int count);

  /// No description provided for @dashSignupsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Inscriptions, 30 derniers jours'**
  String get dashSignupsTitle;

  /// No description provided for @dashRolesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Comptes par rôle'**
  String get dashRolesTitle;

  /// No description provided for @dashIdentityTitle.
  ///
  /// In fr, this message translates to:
  /// **'Vérification d\'identité des conducteurs'**
  String get dashIdentityTitle;

  /// No description provided for @dashNetwork.
  ///
  /// In fr, this message translates to:
  /// **'{companies} compagnies · {agencies} agences'**
  String dashNetwork(int companies, int agencies);

  /// No description provided for @dashAccidentsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Accidents et sinistres'**
  String get dashAccidentsTitle;

  /// No description provided for @dashAccidentsPending.
  ///
  /// In fr, this message translates to:
  /// **'Indicateurs, répartition et carte des zones à risque : disponibles dès que les modules 3 et 5 envoient leurs données au serveur.'**
  String get dashAccidentsPending;

  /// No description provided for @agencyLabel.
  ///
  /// In fr, this message translates to:
  /// **'Agence'**
  String get agencyLabel;

  /// No description provided for @companiesOffline.
  ///
  /// In fr, this message translates to:
  /// **'Hors ligne : liste enregistrée le {date}'**
  String companiesOffline(String date);

  /// No description provided for @pendingSyncTitle.
  ///
  /// In fr, this message translates to:
  /// **'Modifications en attente'**
  String get pendingSyncTitle;

  /// No description provided for @pendingSyncBody.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrées sur le téléphone. Elles seront envoyées dès le retour du réseau.'**
  String get pendingSyncBody;

  /// No description provided for @syncFailed.
  ///
  /// In fr, this message translates to:
  /// **'Le serveur a refusé la modification : {reason}'**
  String syncFailed(String reason);

  /// No description provided for @syncNow.
  ///
  /// In fr, this message translates to:
  /// **'Synchroniser'**
  String get syncNow;

  /// No description provided for @retrySync.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get retrySync;

  /// No description provided for @discardChanges.
  ///
  /// In fr, this message translates to:
  /// **'Annuler les modifications'**
  String get discardChanges;

  /// No description provided for @savedOffline.
  ///
  /// In fr, this message translates to:
  /// **'Enregistré sur le téléphone. Envoi dès le retour du réseau.'**
  String get savedOffline;

  /// No description provided for @syncing.
  ///
  /// In fr, this message translates to:
  /// **'Synchronisation…'**
  String get syncing;

  /// No description provided for @consoleDashboard.
  ///
  /// In fr, this message translates to:
  /// **'Tableau de bord'**
  String get consoleDashboard;

  /// No description provided for @consoleToHandle.
  ///
  /// In fr, this message translates to:
  /// **'À traiter'**
  String get consoleToHandle;

  /// No description provided for @consoleReview.
  ///
  /// In fr, this message translates to:
  /// **'Examiner'**
  String get consoleReview;

  /// No description provided for @consoleSeeAll.
  ///
  /// In fr, this message translates to:
  /// **'Tout voir'**
  String get consoleSeeAll;

  /// No description provided for @consoleNothingToHandle.
  ///
  /// In fr, this message translates to:
  /// **'Rien à traiter pour le moment.'**
  String get consoleNothingToHandle;

  /// No description provided for @refresh.
  ///
  /// In fr, this message translates to:
  /// **'Actualiser'**
  String get refresh;

  /// No description provided for @signedInAs.
  ///
  /// In fr, this message translates to:
  /// **'Connecté'**
  String get signedInAs;

  /// No description provided for @colUser.
  ///
  /// In fr, this message translates to:
  /// **'Utilisateur'**
  String get colUser;

  /// No description provided for @colStatus.
  ///
  /// In fr, this message translates to:
  /// **'Statut'**
  String get colStatus;

  /// No description provided for @filterAll.
  ///
  /// In fr, this message translates to:
  /// **'Tous'**
  String get filterAll;

  /// No description provided for @filterDrivers.
  ///
  /// In fr, this message translates to:
  /// **'Conducteurs'**
  String get filterDrivers;

  /// No description provided for @filterAgents.
  ///
  /// In fr, this message translates to:
  /// **'Agents'**
  String get filterAgents;

  /// No description provided for @filterAdmins.
  ///
  /// In fr, this message translates to:
  /// **'Administrateurs'**
  String get filterAdmins;

  /// No description provided for @accountsCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucun compte} =1{1 compte} other{{count} comptes}}'**
  String accountsCount(int count);

  /// No description provided for @statusActive.
  ///
  /// In fr, this message translates to:
  /// **'Actif'**
  String get statusActive;

  /// No description provided for @statusSuspended.
  ///
  /// In fr, this message translates to:
  /// **'Suspendu'**
  String get statusSuspended;

  /// No description provided for @changeRole.
  ///
  /// In fr, this message translates to:
  /// **'Changer le rôle'**
  String get changeRole;

  /// No description provided for @suspendAccount.
  ///
  /// In fr, this message translates to:
  /// **'Suspendre'**
  String get suspendAccount;

  /// No description provided for @reactivateAccount.
  ///
  /// In fr, this message translates to:
  /// **'Réactiver'**
  String get reactivateAccount;

  /// No description provided for @selectRequest.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionnez une demande pour voir la CIN.'**
  String get selectRequest;

  /// No description provided for @pendingCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucune demande} =1{1 demande} other{{count} demandes}}'**
  String pendingCount(int count);

  /// No description provided for @selectCompany.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionnez une compagnie pour gérer ses agences.'**
  String get selectCompany;

  /// No description provided for @agenciesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Agences'**
  String get agenciesTitle;

  /// No description provided for @noAgencies.
  ///
  /// In fr, this message translates to:
  /// **'Aucune agence pour le moment.'**
  String get noAgencies;

  /// No description provided for @heroPoint1.
  ///
  /// In fr, this message translates to:
  /// **'Un constat complet en moins de 10 minutes, même hors ligne'**
  String get heroPoint1;

  /// No description provided for @heroPoint2.
  ///
  /// In fr, this message translates to:
  /// **'Signature des deux conducteurs et PDF infalsifiable'**
  String get heroPoint2;

  /// No description provided for @heroPoint3.
  ///
  /// In fr, this message translates to:
  /// **'Suivi du dossier en temps réel jusqu’à l’indemnisation'**
  String get heroPoint3;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
