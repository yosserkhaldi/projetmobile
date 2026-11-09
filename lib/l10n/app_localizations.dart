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

  /// No description provided for @claimsMyClaims.
  ///
  /// In fr, this message translates to:
  /// **'Mes dossiers'**
  String get claimsMyClaims;

  /// No description provided for @claimsReceived.
  ///
  /// In fr, this message translates to:
  /// **'Sinistres reçus'**
  String get claimsReceived;

  /// No description provided for @claimsCount.
  ///
  /// In fr, this message translates to:
  /// **'{shown} sur {total} dossiers'**
  String claimsCount(String shown, String total);

  /// No description provided for @claimsFilterHint.
  ///
  /// In fr, this message translates to:
  /// **'Filtrer par numéro, statut ou gravité'**
  String get claimsFilterHint;

  /// No description provided for @claimsStatus.
  ///
  /// In fr, this message translates to:
  /// **'Statut'**
  String get claimsStatus;

  /// No description provided for @claimsSeverity.
  ///
  /// In fr, this message translates to:
  /// **'Gravité'**
  String get claimsSeverity;

  /// No description provided for @claimsDate.
  ///
  /// In fr, this message translates to:
  /// **'Date'**
  String get claimsDate;

  /// No description provided for @claimsAllOf.
  ///
  /// In fr, this message translates to:
  /// **'Tous : {label}'**
  String claimsAllOf(String label);

  /// No description provided for @claimsNoMatch.
  ///
  /// In fr, this message translates to:
  /// **'Aucun dossier ne correspond.'**
  String get claimsNoMatch;

  /// No description provided for @claimsAgentSpace.
  ///
  /// In fr, this message translates to:
  /// **'Espace agent'**
  String get claimsAgentSpace;

  /// No description provided for @claimsAgentSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Instruction des sinistres'**
  String get claimsAgentSubtitle;

  /// No description provided for @claimsStatistics.
  ///
  /// In fr, this message translates to:
  /// **'Statistiques'**
  String get claimsStatistics;

  /// No description provided for @claimsNotifications.
  ///
  /// In fr, this message translates to:
  /// **'Notifications'**
  String get claimsNotifications;

  /// No description provided for @claimsToHandle.
  ///
  /// In fr, this message translates to:
  /// **'À traiter'**
  String get claimsToHandle;

  /// No description provided for @claimsExpertises.
  ///
  /// In fr, this message translates to:
  /// **'Expertises'**
  String get claimsExpertises;

  /// No description provided for @claimsClosedCount.
  ///
  /// In fr, this message translates to:
  /// **'Clôturés'**
  String get claimsClosedCount;

  /// No description provided for @claimsPriority.
  ///
  /// In fr, this message translates to:
  /// **'Dossiers prioritaires'**
  String get claimsPriority;

  /// No description provided for @claimsNothingToHandle.
  ///
  /// In fr, this message translates to:
  /// **'Aucun dossier à traiter.'**
  String get claimsNothingToHandle;

  /// No description provided for @claimsAssistant.
  ///
  /// In fr, this message translates to:
  /// **'Assistant'**
  String get claimsAssistant;

  /// No description provided for @claimsMessaging.
  ///
  /// In fr, this message translates to:
  /// **'Messagerie'**
  String get claimsMessaging;

  /// No description provided for @claimsRequestedDocuments.
  ///
  /// In fr, this message translates to:
  /// **'Pièces demandées'**
  String get claimsRequestedDocuments;

  /// No description provided for @claimsUpload.
  ///
  /// In fr, this message translates to:
  /// **'Déposer'**
  String get claimsUpload;

  /// No description provided for @claimsExpertiseTitle.
  ///
  /// In fr, this message translates to:
  /// **'Expertise'**
  String get claimsExpertiseTitle;

  /// No description provided for @claimsAppointmentOn.
  ///
  /// In fr, this message translates to:
  /// **'Rendez-vous le {date}'**
  String claimsAppointmentOn(String date);

  /// No description provided for @claimsTimeline.
  ///
  /// In fr, this message translates to:
  /// **'Chronologie'**
  String get claimsTimeline;

  /// No description provided for @claimsConstat.
  ///
  /// In fr, this message translates to:
  /// **'Constat'**
  String get claimsConstat;

  /// No description provided for @claimsDocuments.
  ///
  /// In fr, this message translates to:
  /// **'Pièces du dossier'**
  String get claimsDocuments;

  /// No description provided for @claimsDownload.
  ///
  /// In fr, this message translates to:
  /// **'Télécharger'**
  String get claimsDownload;

  /// No description provided for @claimsNoDocument.
  ///
  /// In fr, this message translates to:
  /// **'Aucune pièce déposée.'**
  String get claimsNoDocument;

  /// No description provided for @claimsUploadDocument.
  ///
  /// In fr, this message translates to:
  /// **'Déposer une pièce'**
  String get claimsUploadDocument;

  /// No description provided for @claimsHandling.
  ///
  /// In fr, this message translates to:
  /// **'Instruction'**
  String get claimsHandling;

  /// No description provided for @claimsDocMismatch.
  ///
  /// In fr, this message translates to:
  /// **'Ne correspond pas à la demande.'**
  String get claimsDocMismatch;

  /// No description provided for @claimsRejectedTitle.
  ///
  /// In fr, this message translates to:
  /// **'Dossier rejeté'**
  String get claimsRejectedTitle;

  /// No description provided for @claimsClosedTitle.
  ///
  /// In fr, this message translates to:
  /// **'Dossier clôturé'**
  String get claimsClosedTitle;

  /// No description provided for @claimsReason.
  ///
  /// In fr, this message translates to:
  /// **'Motif : {reason}'**
  String claimsReason(String reason);

  /// No description provided for @claimsResponsibilitySplit.
  ///
  /// In fr, this message translates to:
  /// **'Responsabilité : A {a} %, B {b} %'**
  String claimsResponsibilitySplit(String a, String b);

  /// No description provided for @claimsIndemnity.
  ///
  /// In fr, this message translates to:
  /// **'Indemnisation : {amount} TND'**
  String claimsIndemnity(String amount);

  /// No description provided for @claimsCircumstances.
  ///
  /// In fr, this message translates to:
  /// **'Circonstances'**
  String get claimsCircumstances;

  /// No description provided for @claimsImpactPoint.
  ///
  /// In fr, this message translates to:
  /// **'Point de choc'**
  String get claimsImpactPoint;

  /// No description provided for @claimsObservations.
  ///
  /// In fr, this message translates to:
  /// **'Observations'**
  String get claimsObservations;

  /// No description provided for @claimsNoConstat.
  ///
  /// In fr, this message translates to:
  /// **'Aucune information de constat.'**
  String get claimsNoConstat;

  /// No description provided for @claimsLabelColon.
  ///
  /// In fr, this message translates to:
  /// **'{label} : '**
  String claimsLabelColon(String label);

  /// No description provided for @claimsTakeCharge.
  ///
  /// In fr, this message translates to:
  /// **'Prendre en charge'**
  String get claimsTakeCharge;

  /// No description provided for @claimsRequestDocument.
  ///
  /// In fr, this message translates to:
  /// **'Demander une pièce'**
  String get claimsRequestDocument;

  /// No description provided for @claimsMoveAppointment.
  ///
  /// In fr, this message translates to:
  /// **'Déplacer le rendez-vous'**
  String get claimsMoveAppointment;

  /// No description provided for @claimsAppointExpert.
  ///
  /// In fr, this message translates to:
  /// **'Désigner un expert'**
  String get claimsAppointExpert;

  /// No description provided for @claimsAttachReport.
  ///
  /// In fr, this message translates to:
  /// **'Joindre le rapport d’expertise'**
  String get claimsAttachReport;

  /// No description provided for @claimsReject.
  ///
  /// In fr, this message translates to:
  /// **'Rejeter le dossier'**
  String get claimsReject;

  /// No description provided for @claimsDocument.
  ///
  /// In fr, this message translates to:
  /// **'Pièce'**
  String get claimsDocument;

  /// No description provided for @claimsDetail.
  ///
  /// In fr, this message translates to:
  /// **'Précision'**
  String get claimsDetail;

  /// No description provided for @claimsSendRequest.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer la demande'**
  String get claimsSendRequest;

  /// No description provided for @claimsExpert.
  ///
  /// In fr, this message translates to:
  /// **'Expert'**
  String get claimsExpert;

  /// No description provided for @claimsSchedule.
  ///
  /// In fr, this message translates to:
  /// **'Planifier'**
  String get claimsSchedule;

  /// No description provided for @claimsReasonLabel.
  ///
  /// In fr, this message translates to:
  /// **'Motif'**
  String get claimsReasonLabel;

  /// No description provided for @claimsRejectAction.
  ///
  /// In fr, this message translates to:
  /// **'Rejeter'**
  String get claimsRejectAction;

  /// No description provided for @claimsInvalidAmount.
  ///
  /// In fr, this message translates to:
  /// **'Saisissez un montant valide.'**
  String get claimsInvalidAmount;

  /// No description provided for @claimsDecision.
  ///
  /// In fr, this message translates to:
  /// **'Décision'**
  String get claimsDecision;

  /// No description provided for @claimsProposal.
  ///
  /// In fr, this message translates to:
  /// **'Proposition : A {a} %, B {b} %. {reason}'**
  String claimsProposal(String a, String b, String reason);

  /// No description provided for @claimsIndemnityAmount.
  ///
  /// In fr, this message translates to:
  /// **'Montant d\'indemnisation (TND)'**
  String get claimsIndemnityAmount;

  /// No description provided for @claimsCloseClaim.
  ///
  /// In fr, this message translates to:
  /// **'Clôturer le dossier'**
  String get claimsCloseClaim;

  /// No description provided for @claimsProposalFault.
  ///
  /// In fr, this message translates to:
  /// **'{box} : manœuvre à risque de A.'**
  String claimsProposalFault(String box);

  /// No description provided for @claimsProposalParked.
  ///
  /// In fr, this message translates to:
  /// **'A était en stationnement.'**
  String get claimsProposalParked;

  /// No description provided for @claimsProposalTurn.
  ///
  /// In fr, this message translates to:
  /// **'{box} : partage par défaut.'**
  String claimsProposalTurn(String box);

  /// No description provided for @claimsProposalUnknown.
  ///
  /// In fr, this message translates to:
  /// **'Cases insuffisantes : partage par défaut.'**
  String get claimsProposalUnknown;

  /// No description provided for @claimsSummaryOffline.
  ///
  /// In fr, this message translates to:
  /// **'Synthèse indisponible hors connexion.'**
  String get claimsSummaryOffline;

  /// No description provided for @claimsDecisionHelp.
  ///
  /// In fr, this message translates to:
  /// **'Aide à la décision'**
  String get claimsDecisionHelp;

  /// No description provided for @claimsOverdue.
  ///
  /// In fr, this message translates to:
  /// **'Retard {days} j'**
  String claimsOverdue(String days);

  /// No description provided for @claimsEstimate.
  ///
  /// In fr, this message translates to:
  /// **'Estimation'**
  String get claimsEstimate;

  /// No description provided for @claimsRange.
  ///
  /// In fr, this message translates to:
  /// **'{low} à {high} TND'**
  String claimsRange(String low, String high);

  /// No description provided for @claimsUsualDuration.
  ///
  /// In fr, this message translates to:
  /// **'Durée habituelle'**
  String get claimsUsualDuration;

  /// No description provided for @claimsDays.
  ///
  /// In fr, this message translates to:
  /// **'{days} jours'**
  String claimsDays(String days);

  /// No description provided for @claimsRejectionRisk.
  ///
  /// In fr, this message translates to:
  /// **'Risque de rejet'**
  String get claimsRejectionRisk;

  /// No description provided for @claimsRiskLow.
  ///
  /// In fr, this message translates to:
  /// **'faible'**
  String get claimsRiskLow;

  /// No description provided for @claimsRiskMedium.
  ///
  /// In fr, this message translates to:
  /// **'moyen'**
  String get claimsRiskMedium;

  /// No description provided for @claimsRiskHigh.
  ///
  /// In fr, this message translates to:
  /// **'élevé'**
  String get claimsRiskHigh;

  /// No description provided for @claimsRiskWithFactors.
  ///
  /// In fr, this message translates to:
  /// **'{level} : {factors}'**
  String claimsRiskWithFactors(String level, String factors);

  /// No description provided for @claimsRecommended.
  ///
  /// In fr, this message translates to:
  /// **'Recommandée pour ce dossier'**
  String get claimsRecommended;

  /// No description provided for @claimsToCheck.
  ///
  /// In fr, this message translates to:
  /// **'À vérifier'**
  String get claimsToCheck;

  /// No description provided for @claimsMissingDocuments.
  ///
  /// In fr, this message translates to:
  /// **'Pièces manquantes'**
  String get claimsMissingDocuments;

  /// No description provided for @claimsRequest.
  ///
  /// In fr, this message translates to:
  /// **'Demander'**
  String get claimsRequest;

  /// No description provided for @claimsSimilar.
  ///
  /// In fr, this message translates to:
  /// **'Dossiers similaires'**
  String get claimsSimilar;

  /// No description provided for @claimsSummaryBy.
  ///
  /// In fr, this message translates to:
  /// **'Synthèse rédigée par {by}'**
  String claimsSummaryBy(String by);

  /// No description provided for @claimsSummaryRules.
  ///
  /// In fr, this message translates to:
  /// **'Synthèse automatique, sans IA générative'**
  String get claimsSummaryRules;

  /// No description provided for @claimsSummarizing.
  ///
  /// In fr, this message translates to:
  /// **'Synthèse en cours'**
  String get claimsSummarizing;

  /// No description provided for @claimsSummarize.
  ///
  /// In fr, this message translates to:
  /// **'Résumer le dossier'**
  String get claimsSummarize;

  /// No description provided for @claimsModelDisclaimer.
  ///
  /// In fr, this message translates to:
  /// **'Estimations issues d’un modèle entraîné sur des données simulées. La décision appartient à l’agent.'**
  String get claimsModelDisclaimer;

  /// No description provided for @claimsDriverIdea1.
  ///
  /// In fr, this message translates to:
  /// **'Où en est mon dossier ?'**
  String get claimsDriverIdea1;

  /// No description provided for @claimsDriverIdea2.
  ///
  /// In fr, this message translates to:
  /// **'Quelles pièces dois-je déposer ?'**
  String get claimsDriverIdea2;

  /// No description provided for @claimsDriverIdea3.
  ///
  /// In fr, this message translates to:
  /// **'Combien de temps ça va prendre ?'**
  String get claimsDriverIdea3;

  /// No description provided for @claimsAgentIdea1.
  ///
  /// In fr, this message translates to:
  /// **'Que dois-je faire ensuite ?'**
  String get claimsAgentIdea1;

  /// No description provided for @claimsAgentIdea2.
  ///
  /// In fr, this message translates to:
  /// **'Quels points vérifier ?'**
  String get claimsAgentIdea2;

  /// No description provided for @claimsAgentIdea3.
  ///
  /// In fr, this message translates to:
  /// **'Quelle responsabilité proposes-tu ?'**
  String get claimsAgentIdea3;

  /// No description provided for @claimsAssistantUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Assistant indisponible pour le moment. Réessayez plus tard.'**
  String get claimsAssistantUnavailable;

  /// No description provided for @claimsAssistantTitle.
  ///
  /// In fr, this message translates to:
  /// **'Assistant {id}'**
  String claimsAssistantTitle(String id);

  /// No description provided for @claimsAssistantIntro.
  ///
  /// In fr, this message translates to:
  /// **'Posez une question sur ce dossier. L’assistant informe, il ne prend aucune décision.'**
  String get claimsAssistantIntro;

  /// No description provided for @claimsAssistantReading.
  ///
  /// In fr, this message translates to:
  /// **'L’assistant lit le dossier…'**
  String get claimsAssistantReading;

  /// No description provided for @claimsYourQuestion.
  ///
  /// In fr, this message translates to:
  /// **'Votre question'**
  String get claimsYourQuestion;

  /// No description provided for @claimsSend.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer'**
  String get claimsSend;

  /// No description provided for @claimsAutomaticAnswer.
  ///
  /// In fr, this message translates to:
  /// **'Réponse automatique'**
  String get claimsAutomaticAnswer;

  /// No description provided for @claimsStatsServerOnly.
  ///
  /// In fr, this message translates to:
  /// **'Statistiques disponibles avec le serveur.'**
  String get claimsStatsServerOnly;

  /// No description provided for @claimsTotal.
  ///
  /// In fr, this message translates to:
  /// **'Dossiers'**
  String get claimsTotal;

  /// No description provided for @claimsLate.
  ///
  /// In fr, this message translates to:
  /// **'En retard'**
  String get claimsLate;

  /// No description provided for @claimsAverageDuration.
  ///
  /// In fr, this message translates to:
  /// **'Durée moyenne'**
  String get claimsAverageDuration;

  /// No description provided for @claimsDaysShort.
  ///
  /// In fr, this message translates to:
  /// **'{days} j'**
  String claimsDaysShort(String days);

  /// No description provided for @claimsIndemnified.
  ///
  /// In fr, this message translates to:
  /// **'Indemnisé (TND)'**
  String get claimsIndemnified;

  /// No description provided for @claimsByStatus.
  ///
  /// In fr, this message translates to:
  /// **'Dossiers par statut'**
  String get claimsByStatus;

  /// No description provided for @claimsSystemVsAgents.
  ///
  /// In fr, this message translates to:
  /// **'Le système face aux agents'**
  String get claimsSystemVsAgents;

  /// No description provided for @claimsNoDecisionYet.
  ///
  /// In fr, this message translates to:
  /// **'Pas encore de décision à comparer.'**
  String get claimsNoDecisionYet;

  /// No description provided for @claimsAgreement.
  ///
  /// In fr, this message translates to:
  /// **'Sur {count} décision(s), la responsabilité proposée a été retenue dans {percent} % des cas.'**
  String claimsAgreement(String count, String percent);

  /// No description provided for @claimsAverageGap.
  ///
  /// In fr, this message translates to:
  /// **'Écart moyen avec le montant décidé : {gap} TND.'**
  String claimsAverageGap(String gap);

  /// No description provided for @claimsModel.
  ///
  /// In fr, this message translates to:
  /// **'Modèle'**
  String get claimsModel;

  /// No description provided for @claimsModelVersion.
  ///
  /// In fr, this message translates to:
  /// **'Version {version}'**
  String claimsModelVersion(String version);

  /// No description provided for @claimsTrainedOn.
  ///
  /// In fr, this message translates to:
  /// **'Entraîné sur {synthetic} cas simulés et {real} dossiers réels.'**
  String claimsTrainedOn(String synthetic, String real);

  /// No description provided for @claimsModelTest.
  ///
  /// In fr, this message translates to:
  /// **'Test : erreur moyenne {mae} TND, AUC rejet {auc}.'**
  String claimsModelTest(String mae, String auc);

  /// No description provided for @claimsSimulatedWarning.
  ///
  /// In fr, this message translates to:
  /// **'Ces mesures portent sur des données simulées : elles ne disent pas encore si le modèle est juste sur de vrais sinistres.'**
  String get claimsSimulatedWarning;

  /// No description provided for @claimsSuggestionsUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Suggestions indisponibles.'**
  String get claimsSuggestionsUnavailable;

  /// No description provided for @claimsNoMessages.
  ///
  /// In fr, this message translates to:
  /// **'Aucun message sur ce dossier.'**
  String get claimsNoMessages;

  /// No description provided for @claimsSuggestReply.
  ///
  /// In fr, this message translates to:
  /// **'Suggérer une réponse'**
  String get claimsSuggestReply;

  /// No description provided for @claimsAttachFile.
  ///
  /// In fr, this message translates to:
  /// **'Joindre un fichier'**
  String get claimsAttachFile;

  /// No description provided for @claimsYourMessage.
  ///
  /// In fr, this message translates to:
  /// **'Votre message'**
  String get claimsYourMessage;

  /// No description provided for @claimsOneConversation.
  ///
  /// In fr, this message translates to:
  /// **'Une conversation par dossier'**
  String get claimsOneConversation;

  /// No description provided for @claimsNoClaims.
  ///
  /// In fr, this message translates to:
  /// **'Aucun dossier.'**
  String get claimsNoClaims;

  /// No description provided for @claimsNoMessage.
  ///
  /// In fr, this message translates to:
  /// **'Aucun message'**
  String get claimsNoMessage;

  /// No description provided for @claimsMarkAllRead.
  ///
  /// In fr, this message translates to:
  /// **'Tout marquer lu'**
  String get claimsMarkAllRead;

  /// No description provided for @claimsNoNotification.
  ///
  /// In fr, this message translates to:
  /// **'Aucune notification.'**
  String get claimsNoNotification;

  /// No description provided for @claimsOffline.
  ///
  /// In fr, this message translates to:
  /// **'Hors ligne : vos changements partiront au retour du réseau'**
  String get claimsOffline;

  /// No description provided for @claimsFileUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Fichier indisponible pour le moment.'**
  String get claimsFileUnavailable;

  /// No description provided for @claimsValueDraft.
  ///
  /// In fr, this message translates to:
  /// **'Brouillon'**
  String get claimsValueDraft;

  /// No description provided for @claimsValueDeclared.
  ///
  /// In fr, this message translates to:
  /// **'Déclaré'**
  String get claimsValueDeclared;

  /// No description provided for @claimsValueSigned.
  ///
  /// In fr, this message translates to:
  /// **'Constat signé'**
  String get claimsValueSigned;

  /// No description provided for @claimsValueTransmitted.
  ///
  /// In fr, this message translates to:
  /// **'Transmis'**
  String get claimsValueTransmitted;

  /// No description provided for @claimsValueInReview.
  ///
  /// In fr, this message translates to:
  /// **'En instruction'**
  String get claimsValueInReview;

  /// No description provided for @claimsValueDocumentRequested.
  ///
  /// In fr, this message translates to:
  /// **'Pièce demandée'**
  String get claimsValueDocumentRequested;

  /// No description provided for @claimsValueExpertise.
  ///
  /// In fr, this message translates to:
  /// **'Expertise'**
  String get claimsValueExpertise;

  /// No description provided for @claimsValueClosed.
  ///
  /// In fr, this message translates to:
  /// **'Clôturé'**
  String get claimsValueClosed;

  /// No description provided for @claimsValueRejected.
  ///
  /// In fr, this message translates to:
  /// **'Rejeté'**
  String get claimsValueRejected;

  /// No description provided for @claimsValueCollision.
  ///
  /// In fr, this message translates to:
  /// **'Collision'**
  String get claimsValueCollision;

  /// No description provided for @claimsValueOffRoad.
  ///
  /// In fr, this message translates to:
  /// **'Sortie de route'**
  String get claimsValueOffRoad;

  /// No description provided for @claimsValuePedestrian.
  ///
  /// In fr, this message translates to:
  /// **'Piéton'**
  String get claimsValuePedestrian;

  /// No description provided for @claimsValueMaterialAccident.
  ///
  /// In fr, this message translates to:
  /// **'Accident matériel'**
  String get claimsValueMaterialAccident;

  /// No description provided for @claimsValueOther.
  ///
  /// In fr, this message translates to:
  /// **'Autre'**
  String get claimsValueOther;

  /// No description provided for @claimsValueMaterial.
  ///
  /// In fr, this message translates to:
  /// **'Matériel'**
  String get claimsValueMaterial;

  /// No description provided for @claimsValueLight.
  ///
  /// In fr, this message translates to:
  /// **'Léger'**
  String get claimsValueLight;

  /// No description provided for @claimsValueSerious.
  ///
  /// In fr, this message translates to:
  /// **'Grave'**
  String get claimsValueSerious;

  /// No description provided for @claimsValueParked.
  ///
  /// In fr, this message translates to:
  /// **'En stationnement'**
  String get claimsValueParked;

  /// No description provided for @claimsValueLeavingParking.
  ///
  /// In fr, this message translates to:
  /// **'Quittait un stationnement'**
  String get claimsValueLeavingParking;

  /// No description provided for @claimsValueChangingLane.
  ///
  /// In fr, this message translates to:
  /// **'Changeait de file'**
  String get claimsValueChangingLane;

  /// No description provided for @claimsValueOvertaking.
  ///
  /// In fr, this message translates to:
  /// **'Doublait'**
  String get claimsValueOvertaking;

  /// No description provided for @claimsValueTurningRight.
  ///
  /// In fr, this message translates to:
  /// **'Virait à droite'**
  String get claimsValueTurningRight;

  /// No description provided for @claimsValueTurningLeft.
  ///
  /// In fr, this message translates to:
  /// **'Virait à gauche'**
  String get claimsValueTurningLeft;

  /// No description provided for @claimsValueReversing.
  ///
  /// In fr, this message translates to:
  /// **'Reculait'**
  String get claimsValueReversing;

  /// No description provided for @claimsValueFront.
  ///
  /// In fr, this message translates to:
  /// **'Avant'**
  String get claimsValueFront;

  /// No description provided for @claimsValueRear.
  ///
  /// In fr, this message translates to:
  /// **'Arrière'**
  String get claimsValueRear;

  /// No description provided for @claimsValueLeftSide.
  ///
  /// In fr, this message translates to:
  /// **'Côté gauche'**
  String get claimsValueLeftSide;

  /// No description provided for @claimsValueRightSide.
  ///
  /// In fr, this message translates to:
  /// **'Côté droit'**
  String get claimsValueRightSide;

  /// No description provided for @claimsValueQuote.
  ///
  /// In fr, this message translates to:
  /// **'Devis'**
  String get claimsValueQuote;

  /// No description provided for @claimsValueInvoice.
  ///
  /// In fr, this message translates to:
  /// **'Facture'**
  String get claimsValueInvoice;

  /// No description provided for @claimsValuePoliceReport.
  ///
  /// In fr, this message translates to:
  /// **'PV de police'**
  String get claimsValuePoliceReport;

  /// No description provided for @claimsValueExpertReport.
  ///
  /// In fr, this message translates to:
  /// **'Rapport d\'expertise'**
  String get claimsValueExpertReport;

  /// No description provided for @claimsValueSupporting.
  ///
  /// In fr, this message translates to:
  /// **'Pièce'**
  String get claimsValueSupporting;

  /// No description provided for @claimsValuePhoto.
  ///
  /// In fr, this message translates to:
  /// **'Photo'**
  String get claimsValuePhoto;

  /// No description provided for @claimsValueVideo.
  ///
  /// In fr, this message translates to:
  /// **'Vidéo'**
  String get claimsValueVideo;

  /// No description provided for @claimsValueVoiceNote.
  ///
  /// In fr, this message translates to:
  /// **'Note vocale'**
  String get claimsValueVoiceNote;

  /// No description provided for @claimsValueAccidentReport.
  ///
  /// In fr, this message translates to:
  /// **'Constat amiable'**
  String get claimsValueAccidentReport;

  /// No description provided for @claimsEventDraftCreated.
  ///
  /// In fr, this message translates to:
  /// **'Brouillon créé'**
  String get claimsEventDraftCreated;

  /// No description provided for @claimsEventDeclared.
  ///
  /// In fr, this message translates to:
  /// **'Déclaration complétée'**
  String get claimsEventDeclared;

  /// No description provided for @claimsEventEvidence.
  ///
  /// In fr, this message translates to:
  /// **'{count} preuves ajoutées'**
  String claimsEventEvidence(String count);

  /// No description provided for @claimsEventSigned.
  ///
  /// In fr, this message translates to:
  /// **'Double signature'**
  String get claimsEventSigned;

  /// No description provided for @claimsEventPdfLocked.
  ///
  /// In fr, this message translates to:
  /// **'PDF verrouillé'**
  String get claimsEventPdfLocked;

  /// No description provided for @claimsEventSent.
  ///
  /// In fr, this message translates to:
  /// **'Transmis aux assureurs'**
  String get claimsEventSent;

  /// No description provided for @claimsEventMoved.
  ///
  /// In fr, this message translates to:
  /// **'Rendez-vous déplacé'**
  String get claimsEventMoved;

  /// No description provided for @claimsEventReport.
  ///
  /// In fr, this message translates to:
  /// **'Rapport d’expertise joint'**
  String get claimsEventReport;

  /// No description provided for @claimsEventDetail.
  ///
  /// In fr, this message translates to:
  /// **'{status} : {detail}'**
  String claimsEventDetail(String status, String detail);

  /// No description provided for @claimsNotifNew.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau sinistre reçu : {id}'**
  String claimsNotifNew(String id);

  /// No description provided for @claimsNotifRequested.
  ///
  /// In fr, this message translates to:
  /// **'{id} : pièce demandée ({document})'**
  String claimsNotifRequested(String id, String document);

  /// No description provided for @claimsNotifUploaded.
  ///
  /// In fr, this message translates to:
  /// **'{id} : pièce déposée ({name})'**
  String claimsNotifUploaded(String id, String name);

  /// No description provided for @claimsNotifMoved.
  ///
  /// In fr, this message translates to:
  /// **'{id} : rendez-vous d’expertise déplacé'**
  String claimsNotifMoved(String id);

  /// No description provided for @claimsNotifEvent.
  ///
  /// In fr, this message translates to:
  /// **'{id} : {event}'**
  String claimsNotifEvent(String id, String event);

  /// No description provided for @claimsNotifInReview.
  ///
  /// In fr, this message translates to:
  /// **'Votre dossier {id} est en instruction.'**
  String claimsNotifInReview(String id);

  /// No description provided for @claimsNotifContract.
  ///
  /// In fr, this message translates to:
  /// **'Votre contrat expire dans {days} jours.'**
  String claimsNotifContract(String days);

  /// No description provided for @claimsValueVehicle.
  ///
  /// In fr, this message translates to:
  /// **'Véhicule'**
  String get claimsValueVehicle;

  /// No description provided for @claimsValueBodily.
  ///
  /// In fr, this message translates to:
  /// **'Corporelle'**
  String get claimsValueBodily;

  /// No description provided for @claimsValueReopened.
  ///
  /// In fr, this message translates to:
  /// **'Rouvert'**
  String get claimsValueReopened;

  /// No description provided for @claimsEventConfirmed.
  ///
  /// In fr, this message translates to:
  /// **'Rendez-vous confirmé'**
  String get claimsEventConfirmed;

  /// No description provided for @claimsEventOtherSlot.
  ///
  /// In fr, this message translates to:
  /// **'Autre créneau proposé'**
  String get claimsEventOtherSlot;

  /// No description provided for @claimsNotifConfirmed.
  ///
  /// In fr, this message translates to:
  /// **'{id} : rendez-vous d’expertise confirmé'**
  String claimsNotifConfirmed(String id);

  /// No description provided for @claimsNotifOtherSlot.
  ///
  /// In fr, this message translates to:
  /// **'{id} : autre créneau proposé pour l’expertise'**
  String claimsNotifOtherSlot(String id);

  /// No description provided for @claimsQuestionOnDecision.
  ///
  /// In fr, this message translates to:
  /// **'Une question sur la décision ? Écrire à l’agent'**
  String get claimsQuestionOnDecision;

  /// No description provided for @claimsReportPending.
  ///
  /// In fr, this message translates to:
  /// **'L’expert envoie son rapport à l’assureur après le rendez-vous. Il apparaîtra ici.'**
  String get claimsReportPending;

  /// No description provided for @claimsReportReceived.
  ///
  /// In fr, this message translates to:
  /// **'Rapport de l’expert, joint par l’agent'**
  String get claimsReportReceived;

  /// No description provided for @claimsReopen.
  ///
  /// In fr, this message translates to:
  /// **'Rouvrir le dossier'**
  String get claimsReopen;

  /// No description provided for @claimsReopenHelp.
  ///
  /// In fr, this message translates to:
  /// **'En cas d’erreur, rouvrez le dossier : il revient en instruction et la décision précédente reste dans la chronologie.'**
  String get claimsReopenHelp;

  /// No description provided for @claimsReopenAction.
  ///
  /// In fr, this message translates to:
  /// **'Rouvrir'**
  String get claimsReopenAction;

  /// No description provided for @claimsKindHelp.
  ///
  /// In fr, this message translates to:
  /// **'Corporelle : examen médical d’une personne blessée, un piéton par exemple. Aucun véhicule à présenter.'**
  String get claimsKindHelp;

  /// No description provided for @claimsExpertPhone.
  ///
  /// In fr, this message translates to:
  /// **'Téléphone de l’expert'**
  String get claimsExpertPhone;

  /// No description provided for @claimsExpertPlace.
  ///
  /// In fr, this message translates to:
  /// **'Lieu du rendez-vous'**
  String get claimsExpertPlace;

  /// No description provided for @claimsPlaceHintBody.
  ///
  /// In fr, this message translates to:
  /// **'Cabinet médical, clinique…'**
  String get claimsPlaceHintBody;

  /// No description provided for @claimsPlaceHintVehicle.
  ///
  /// In fr, this message translates to:
  /// **'Garage, agence, domicile…'**
  String get claimsPlaceHintVehicle;

  /// No description provided for @claimsSuggestedSlots.
  ///
  /// In fr, this message translates to:
  /// **'Créneaux suggérés'**
  String get claimsSuggestedSlots;

  /// No description provided for @claimsNoteOptional.
  ///
  /// In fr, this message translates to:
  /// **'Message (facultatif)'**
  String get claimsNoteOptional;

  /// No description provided for @claimsExpertRequired.
  ///
  /// In fr, this message translates to:
  /// **'Indiquez le nom de l’expert.'**
  String get claimsExpertRequired;

  /// No description provided for @claimsSlotConfirmed.
  ///
  /// In fr, this message translates to:
  /// **'Confirmé'**
  String get claimsSlotConfirmed;

  /// No description provided for @claimsSlotYourTurn.
  ///
  /// In fr, this message translates to:
  /// **'À confirmer'**
  String get claimsSlotYourTurn;

  /// No description provided for @claimsSlotWaitingAgent.
  ///
  /// In fr, this message translates to:
  /// **'En attente de l’agent'**
  String get claimsSlotWaitingAgent;

  /// No description provided for @claimsSlotWaitingDriver.
  ///
  /// In fr, this message translates to:
  /// **'En attente du conducteur'**
  String get claimsSlotWaitingDriver;

  /// No description provided for @claimsExpertiseBody.
  ///
  /// In fr, this message translates to:
  /// **'Expertise médicale'**
  String get claimsExpertiseBody;

  /// No description provided for @claimsExpertiseVehicle.
  ///
  /// In fr, this message translates to:
  /// **'Expertise du véhicule'**
  String get claimsExpertiseVehicle;

  /// No description provided for @claimsPlaceFromExpert.
  ///
  /// In fr, this message translates to:
  /// **'Lieu communiqué par l’expert'**
  String get claimsPlaceFromExpert;

  /// No description provided for @claimsFromDriver.
  ///
  /// In fr, this message translates to:
  /// **'Du conducteur'**
  String get claimsFromDriver;

  /// No description provided for @claimsFromAgent.
  ///
  /// In fr, this message translates to:
  /// **'De l’agent'**
  String get claimsFromAgent;

  /// No description provided for @claimsToBring.
  ///
  /// In fr, this message translates to:
  /// **'À apporter'**
  String get claimsToBring;

  /// No description provided for @claimsBringId.
  ///
  /// In fr, this message translates to:
  /// **'Votre pièce d’identité'**
  String get claimsBringId;

  /// No description provided for @claimsBringCertificates.
  ///
  /// In fr, this message translates to:
  /// **'Les certificats médicaux'**
  String get claimsBringCertificates;

  /// No description provided for @claimsBringPrescriptions.
  ///
  /// In fr, this message translates to:
  /// **'Les ordonnances et factures de soins'**
  String get claimsBringPrescriptions;

  /// No description provided for @claimsBringVehicle.
  ///
  /// In fr, this message translates to:
  /// **'Le véhicule, non réparé'**
  String get claimsBringVehicle;

  /// No description provided for @claimsBringRegistration.
  ///
  /// In fr, this message translates to:
  /// **'La carte grise'**
  String get claimsBringRegistration;

  /// No description provided for @claimsBringLicence.
  ///
  /// In fr, this message translates to:
  /// **'Le permis de conduire'**
  String get claimsBringLicence;

  /// No description provided for @claimsBringInsurance.
  ///
  /// In fr, this message translates to:
  /// **'L’attestation d’assurance'**
  String get claimsBringInsurance;

  /// No description provided for @claimsAccept.
  ///
  /// In fr, this message translates to:
  /// **'Accepter'**
  String get claimsAccept;

  /// No description provided for @claimsProposeOther.
  ///
  /// In fr, this message translates to:
  /// **'Proposer un autre créneau'**
  String get claimsProposeOther;

  /// No description provided for @claimsCannotCome.
  ///
  /// In fr, this message translates to:
  /// **'Je ne peux plus venir'**
  String get claimsCannotCome;

  /// No description provided for @claimsOtherDateTime.
  ///
  /// In fr, this message translates to:
  /// **'Autre date et heure'**
  String get claimsOtherDateTime;

  /// No description provided for @claimsSendProposal.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer la proposition'**
  String get claimsSendProposal;

  /// No description provided for @claimsStepReceived.
  ///
  /// In fr, this message translates to:
  /// **'Reçu'**
  String get claimsStepReceived;

  /// No description provided for @claimsStepReview.
  ///
  /// In fr, this message translates to:
  /// **'Étude'**
  String get claimsStepReview;

  /// No description provided for @claimsStepExpertise.
  ///
  /// In fr, this message translates to:
  /// **'Expertise'**
  String get claimsStepExpertise;

  /// No description provided for @claimsStepDecision.
  ///
  /// In fr, this message translates to:
  /// **'Décision'**
  String get claimsStepDecision;

  /// No description provided for @claimsYourTodo.
  ///
  /// In fr, this message translates to:
  /// **'À faire'**
  String get claimsYourTodo;

  /// No description provided for @claimsRemainingDays.
  ///
  /// In fr, this message translates to:
  /// **'{days, plural, =1{Encore environ 1 jour} other{Encore environ {days} jours}}'**
  String claimsRemainingDays(int days);

  /// No description provided for @claimsEstimateNote.
  ///
  /// In fr, this message translates to:
  /// **'Estimation, pas un engagement.'**
  String get claimsEstimateNote;

  /// No description provided for @claimsTakingLonger.
  ///
  /// In fr, this message translates to:
  /// **'Votre dossier prend plus de temps que d’habitude. Vous pouvez écrire à votre agent.'**
  String get claimsTakingLonger;

  /// No description provided for @claimsCircumstancesA.
  ///
  /// In fr, this message translates to:
  /// **'Circonstances de A'**
  String get claimsCircumstancesA;

  /// No description provided for @claimsCircumstancesB.
  ///
  /// In fr, this message translates to:
  /// **'Circonstances de B'**
  String get claimsCircumstancesB;

  /// No description provided for @claimsProposalFaultB.
  ///
  /// In fr, this message translates to:
  /// **'{box} : manœuvre à risque de B.'**
  String claimsProposalFaultB(String box);

  /// No description provided for @claimsProposalBoth.
  ///
  /// In fr, this message translates to:
  /// **'A : {a}, B : {b}. Manœuvres à risque des deux côtés : partage.'**
  String claimsProposalBoth(String a, String b);

  /// No description provided for @claimsProposalParkedB.
  ///
  /// In fr, this message translates to:
  /// **'B était en stationnement.'**
  String get claimsProposalParkedB;

  /// No description provided for @claimsNoCompany.
  ///
  /// In fr, this message translates to:
  /// **'Compagnie non renseignée'**
  String get claimsNoCompany;

  /// No description provided for @claimsEventSealed.
  ///
  /// In fr, this message translates to:
  /// **'Constat scellé (SHA-256 {hash})'**
  String claimsEventSealed(String hash);

  /// No description provided for @claimsEventSealedLocal.
  ///
  /// In fr, this message translates to:
  /// **'Constat scellé sur le téléphone (SHA-256 {hash})'**
  String claimsEventSealedLocal(String hash);

  /// No description provided for @claimsEventWaitingSync.
  ///
  /// In fr, this message translates to:
  /// **'En attente de connexion pour l’envoi'**
  String get claimsEventWaitingSync;

  /// No description provided for @claimsSummaryTitle.
  ///
  /// In fr, this message translates to:
  /// **'Résumé du dossier'**
  String get claimsSummaryTitle;

  /// No description provided for @claimsPriorityScore.
  ///
  /// In fr, this message translates to:
  /// **'Priorité {score}'**
  String claimsPriorityScore(String score);

  /// No description provided for @claimsSearchMine.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher dans mes dossiers'**
  String get claimsSearchMine;

  /// No description provided for @claimsBySeverity.
  ///
  /// In fr, this message translates to:
  /// **'Par gravité'**
  String get claimsBySeverity;

  /// No description provided for @claimsByType.
  ///
  /// In fr, this message translates to:
  /// **'Par type d’accident'**
  String get claimsByType;

  /// No description provided for @claimsAnswersBySource.
  ///
  /// In fr, this message translates to:
  /// **'Réponses par source'**
  String get claimsAnswersBySource;

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
  /// **'Choisissez une pièce, photographiez-la, puis vérifiez votre visage. Notre IA compare votre visage à la photo de la pièce, sur nos serveurs, sans aucun service extérieur.'**
  String get identityIntro;

  /// No description provided for @identityPendingNote.
  ///
  /// In fr, this message translates to:
  /// **'L\'IA n\'a pas pu conclure : un administrateur compare vos photos. Vous serez prévenu sur WhatsApp et par e-mail.'**
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
  /// **'Ajoutez les photos de la pièce.'**
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
  /// **'Pièce non valable'**
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
  /// **'Ce numéro de pièce est déjà utilisé.'**
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
  /// **'Sélectionnez une demande pour voir la pièce.'**
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

  /// No description provided for @identityVerifiedAutoNote.
  ///
  /// In fr, this message translates to:
  /// **'Vérifiée automatiquement par reconnaissance faciale. Vous pouvez signer vos constats.'**
  String get identityVerifiedAutoNote;

  /// No description provided for @documentTypeLabel.
  ///
  /// In fr, this message translates to:
  /// **'Pièce d\'identité'**
  String get documentTypeLabel;

  /// No description provided for @documentCin.
  ///
  /// In fr, this message translates to:
  /// **'CIN'**
  String get documentCin;

  /// No description provided for @documentLicense.
  ///
  /// In fr, this message translates to:
  /// **'Permis'**
  String get documentLicense;

  /// No description provided for @documentPassport.
  ///
  /// In fr, this message translates to:
  /// **'Passeport'**
  String get documentPassport;

  /// No description provided for @passportNumberLabel.
  ///
  /// In fr, this message translates to:
  /// **'N° du passeport'**
  String get passportNumberLabel;

  /// No description provided for @licenseNumberInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Numéro de permis invalide (ex. 12/345678).'**
  String get licenseNumberInvalid;

  /// No description provided for @passportNumberInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Numéro de passeport invalide (ex. X1234567).'**
  String get passportNumberInvalid;

  /// No description provided for @licenseFront.
  ///
  /// In fr, this message translates to:
  /// **'Recto du permis'**
  String get licenseFront;

  /// No description provided for @licenseBack.
  ///
  /// In fr, this message translates to:
  /// **'Verso du permis'**
  String get licenseBack;

  /// No description provided for @passportPage.
  ///
  /// In fr, this message translates to:
  /// **'Page photo du passeport'**
  String get passportPage;

  /// No description provided for @faceCheckTitle.
  ///
  /// In fr, this message translates to:
  /// **'Vérification du visage'**
  String get faceCheckTitle;

  /// No description provided for @faceCheckIntro.
  ///
  /// In fr, this message translates to:
  /// **'Trois photos rapides : de face, puis la tête tournée de chaque côté. Une photo imprimée ou un écran ne passe pas.'**
  String get faceCheckIntro;

  /// No description provided for @faceCheckDone.
  ///
  /// In fr, this message translates to:
  /// **'Visage vérifié'**
  String get faceCheckDone;

  /// No description provided for @faceCheckStart.
  ///
  /// In fr, this message translates to:
  /// **'Vérifier mon visage'**
  String get faceCheckStart;

  /// No description provided for @faceCheckRedo.
  ///
  /// In fr, this message translates to:
  /// **'Recommencer'**
  String get faceCheckRedo;

  /// No description provided for @faceCheckRequired.
  ///
  /// In fr, this message translates to:
  /// **'Faites d\'abord la vérification du visage.'**
  String get faceCheckRequired;

  /// No description provided for @livenessCenter.
  ///
  /// In fr, this message translates to:
  /// **'Regardez la caméra, bien de face'**
  String get livenessCenter;

  /// No description provided for @livenessLeft.
  ///
  /// In fr, this message translates to:
  /// **'Tournez la tête vers la gauche'**
  String get livenessLeft;

  /// No description provided for @livenessRight.
  ///
  /// In fr, this message translates to:
  /// **'Tournez la tête vers la droite'**
  String get livenessRight;

  /// No description provided for @livenessStepOf.
  ///
  /// In fr, this message translates to:
  /// **'Photo {current} sur {total}'**
  String livenessStepOf(int current, int total);

  /// No description provided for @livenessAnalyzing.
  ///
  /// In fr, this message translates to:
  /// **'Analyse par l\'IA…'**
  String get livenessAnalyzing;

  /// No description provided for @livenessNoCamera.
  ///
  /// In fr, this message translates to:
  /// **'Caméra indisponible. Autorisez l\'accès à la caméra, puis réessayez.'**
  String get livenessNoCamera;

  /// No description provided for @livenessPrivacy.
  ///
  /// In fr, this message translates to:
  /// **'La photo de face sert uniquement à cette vérification. Elle est effacée dès la décision.'**
  String get livenessPrivacy;

  /// No description provided for @livenessSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Visage vérifié. Vous pouvez envoyer la demande.'**
  String get livenessSuccess;

  /// No description provided for @identityVerifiedByAi.
  ///
  /// In fr, this message translates to:
  /// **'Identité vérifiée par l\'IA'**
  String get identityVerifiedByAi;

  /// No description provided for @errorNoFaceOnDocument.
  ///
  /// In fr, this message translates to:
  /// **'Aucun visage détecté sur la pièce. Reprenez la photo à plat, bien éclairée et sans reflet.'**
  String get errorNoFaceOnDocument;

  /// No description provided for @errorLivenessNoFace.
  ///
  /// In fr, this message translates to:
  /// **'Visage introuvable. Placez votre visage dans l\'ovale, bien éclairé.'**
  String get errorLivenessNoFace;

  /// No description provided for @errorLivenessManyFaces.
  ///
  /// In fr, this message translates to:
  /// **'Une seule personne doit être devant la caméra.'**
  String get errorLivenessManyFaces;

  /// No description provided for @errorLivenessNotCentered.
  ///
  /// In fr, this message translates to:
  /// **'Regardez la caméra bien de face pour la première photo.'**
  String get errorLivenessNotCentered;

  /// No description provided for @errorLivenessNoTurn.
  ///
  /// In fr, this message translates to:
  /// **'Tournez davantage la tête quand la consigne le demande.'**
  String get errorLivenessNoTurn;

  /// No description provided for @errorLivenessDifferentFaces.
  ///
  /// In fr, this message translates to:
  /// **'Les photos ne montrent pas la même personne.'**
  String get errorLivenessDifferentFaces;

  /// No description provided for @errorLivenessExpired.
  ///
  /// In fr, this message translates to:
  /// **'Le défi a expiré. Recommencez la vérification du visage.'**
  String get errorLivenessExpired;

  /// No description provided for @errorFaceEngine.
  ///
  /// In fr, this message translates to:
  /// **'L\'analyse du visage est indisponible. Réessayez dans un instant.'**
  String get errorFaceEngine;

  /// No description provided for @aiMatch.
  ///
  /// In fr, this message translates to:
  /// **'Ressemblance IA : {percent} %'**
  String aiMatch(int percent);

  /// No description provided for @aiNoConclusion.
  ///
  /// In fr, this message translates to:
  /// **'IA : pas de conclusion'**
  String get aiNoConclusion;

  /// No description provided for @livenessPassed.
  ///
  /// In fr, this message translates to:
  /// **'Visage vivant vérifié'**
  String get livenessPassed;

  /// No description provided for @selfieLabel.
  ///
  /// In fr, this message translates to:
  /// **'Photo du visage'**
  String get selfieLabel;

  /// No description provided for @documentNumberLabel.
  ///
  /// In fr, this message translates to:
  /// **'N° de la pièce'**
  String get documentNumberLabel;

  /// No description provided for @rejectReasonFaceMismatch.
  ///
  /// In fr, this message translates to:
  /// **'Le visage ne correspond pas à la pièce'**
  String get rejectReasonFaceMismatch;

  /// No description provided for @dashVerifiedIdsAi.
  ///
  /// In fr, this message translates to:
  /// **'{count} vérifiées, dont {ai} par l\'IA'**
  String dashVerifiedIdsAi(int count, int ai);

  /// No description provided for @readingDocument.
  ///
  /// In fr, this message translates to:
  /// **'Lecture de la pièce par l\'IA…'**
  String get readingDocument;

  /// No description provided for @readOnCard.
  ///
  /// In fr, this message translates to:
  /// **'Lu sur la pièce par l\'IA'**
  String get readOnCard;

  /// No description provided for @readNumber.
  ///
  /// In fr, this message translates to:
  /// **'Numéro'**
  String get readNumber;

  /// No description provided for @readName.
  ///
  /// In fr, this message translates to:
  /// **'Nom'**
  String get readName;

  /// No description provided for @readParents.
  ///
  /// In fr, this message translates to:
  /// **'Filiation'**
  String get readParents;

  /// No description provided for @readBirth.
  ///
  /// In fr, this message translates to:
  /// **'Naissance'**
  String get readBirth;

  /// No description provided for @readExpiry.
  ///
  /// In fr, this message translates to:
  /// **'Valable jusqu\'au'**
  String get readExpiry;

  /// No description provided for @readConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Vérifiez ces informations. Le numéro saisi doit être celui de la pièce.'**
  String get readConfirm;

  /// No description provided for @readNothing.
  ///
  /// In fr, this message translates to:
  /// **'L\'IA n\'a pas pu lire la pièce. Saisissez le numéro : un administrateur vérifiera.'**
  String get readNothing;

  /// No description provided for @useNumberRead.
  ///
  /// In fr, this message translates to:
  /// **'Utiliser ce numéro'**
  String get useNumberRead;

  /// No description provided for @useLicensePhoto.
  ///
  /// In fr, this message translates to:
  /// **'Utiliser la photo du permis de mon profil'**
  String get useLicensePhoto;

  /// No description provided for @errorBackHasFace.
  ///
  /// In fr, this message translates to:
  /// **'Cette photo montre un recto. Photographiez le verso de la même pièce.'**
  String get errorBackHasFace;

  /// No description provided for @errorLicensePhotoMissing.
  ///
  /// In fr, this message translates to:
  /// **'Aucune photo de permis dans votre profil.'**
  String get errorLicensePhotoMissing;

  /// No description provided for @checksTitle.
  ///
  /// In fr, this message translates to:
  /// **'Contrôles de l\'IA'**
  String get checksTitle;

  /// No description provided for @checkLiveness.
  ///
  /// In fr, this message translates to:
  /// **'Visage vivant'**
  String get checkLiveness;

  /// No description provided for @checkFace.
  ///
  /// In fr, this message translates to:
  /// **'Visage identique à la photo de la pièce'**
  String get checkFace;

  /// No description provided for @checkNumber.
  ///
  /// In fr, this message translates to:
  /// **'Numéro saisi = numéro lu ({number})'**
  String checkNumber(String number);

  /// No description provided for @checkNumberUnread.
  ///
  /// In fr, this message translates to:
  /// **'Numéro illisible sur la pièce'**
  String get checkNumberUnread;

  /// No description provided for @checkName.
  ///
  /// In fr, this message translates to:
  /// **'Nom du compte sur la pièce'**
  String get checkName;

  /// No description provided for @checkExpiry.
  ///
  /// In fr, this message translates to:
  /// **'Pièce en cours de validité'**
  String get checkExpiry;

  /// No description provided for @scanLicense.
  ///
  /// In fr, this message translates to:
  /// **'Scanner mon permis'**
  String get scanLicense;

  /// No description provided for @scanLicenseHint.
  ///
  /// In fr, this message translates to:
  /// **'Prenez votre permis en photo : l\'IA remplit le numéro, les catégories et la date.'**
  String get scanLicenseHint;

  /// No description provided for @licenseFilledByAi.
  ///
  /// In fr, this message translates to:
  /// **'Rempli par l\'IA à partir de la photo. Vérifiez avant d\'enregistrer.'**
  String get licenseFilledByAi;

  /// No description provided for @licenseNotRead.
  ///
  /// In fr, this message translates to:
  /// **'Photo enregistrée, mais l\'IA n\'a pas pu lire le permis. Complétez les champs.'**
  String get licenseNotRead;

  /// No description provided for @errorBackNotRecognized.
  ///
  /// In fr, this message translates to:
  /// **'Ce n\'est pas le verso de la pièce. Sur une CIN, le code-barres doit être net et entier sur la photo.'**
  String get errorBackNotRecognized;

  /// No description provided for @checkBack.
  ///
  /// In fr, this message translates to:
  /// **'Verso reconnu'**
  String get checkBack;

  /// No description provided for @rejectSevere.
  ///
  /// In fr, this message translates to:
  /// **'Refus définitif : bloquer les nouvelles demandes'**
  String get rejectSevere;

  /// No description provided for @rejectSevereHint.
  ///
  /// In fr, this message translates to:
  /// **'Pour une fraude probable : visage différent, fausse pièce.'**
  String get rejectSevereHint;

  /// No description provided for @identityBlockedNote.
  ///
  /// In fr, this message translates to:
  /// **'La vérification de votre identité est bloquée. Contactez le support.'**
  String get identityBlockedNote;

  /// No description provided for @identityRetryOn.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle demande possible le {date}.'**
  String identityRetryOn(String date);

  /// No description provided for @identityAttemptsLeft.
  ///
  /// In fr, this message translates to:
  /// **'Essais restants : {count}.'**
  String identityAttemptsLeft(int count);

  /// No description provided for @errorIdentityBlocked.
  ///
  /// In fr, this message translates to:
  /// **'La vérification de votre identité est bloquée. Contactez le support.'**
  String get errorIdentityBlocked;

  /// No description provided for @errorIdentityRetryLater.
  ///
  /// In fr, this message translates to:
  /// **'Attendez 24 h après un refus avant une nouvelle demande.'**
  String get errorIdentityRetryLater;

  /// No description provided for @unblockIdentity.
  ///
  /// In fr, this message translates to:
  /// **'Débloquer la vérification'**
  String get unblockIdentity;

  /// No description provided for @identityUnblocked.
  ///
  /// In fr, this message translates to:
  /// **'Vérification débloquée'**
  String get identityUnblocked;

  /// No description provided for @identityBlockedChip.
  ///
  /// In fr, this message translates to:
  /// **'Vérification bloquée'**
  String get identityBlockedChip;

  /// No description provided for @attemptsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Demandes de ce compte'**
  String get attemptsTitle;

  /// No description provided for @refusalsCount.
  ///
  /// In fr, this message translates to:
  /// **'Refus : {count}'**
  String refusalsCount(int count);

  /// No description provided for @outcomeAuto.
  ///
  /// In fr, this message translates to:
  /// **'Validée par l\'IA'**
  String get outcomeAuto;

  /// No description provided for @outcomeVerified.
  ///
  /// In fr, this message translates to:
  /// **'Validée'**
  String get outcomeVerified;

  /// No description provided for @outcomeRejected.
  ///
  /// In fr, this message translates to:
  /// **'Refusée'**
  String get outcomeRejected;

  /// No description provided for @outcomePending.
  ///
  /// In fr, this message translates to:
  /// **'En attente'**
  String get outcomePending;

  /// No description provided for @biometricConsentLabel.
  ///
  /// In fr, this message translates to:
  /// **'J\'accepte que mon visage soit analysé pour vérifier mon identité. Analyse faite sur les serveurs de Mon Constat, photo effacée dès la décision (loi n° 2004-63).'**
  String get biometricConsentLabel;

  /// No description provided for @errorAiQuota.
  ///
  /// In fr, this message translates to:
  /// **'Trop d\'analyses en peu de temps. Réessayez dans un moment.'**
  String get errorAiQuota;

  /// No description provided for @livenessHintNoFace.
  ///
  /// In fr, this message translates to:
  /// **'Placez votre visage dans l\'ovale'**
  String get livenessHintNoFace;

  /// No description provided for @livenessHintLookStraight.
  ///
  /// In fr, this message translates to:
  /// **'Regardez la caméra bien en face'**
  String get livenessHintLookStraight;

  /// No description provided for @livenessHintTurnMore.
  ///
  /// In fr, this message translates to:
  /// **'Tournez davantage la tête'**
  String get livenessHintTurnMore;

  /// No description provided for @dashAiTitle.
  ///
  /// In fr, this message translates to:
  /// **'Vérification par l\'IA'**
  String get dashAiTitle;

  /// No description provided for @dashAiFooter.
  ///
  /// In fr, this message translates to:
  /// **'Sur la période affichée. Analyse sur nos serveurs, sans service extérieur.'**
  String get dashAiFooter;

  /// No description provided for @dashAiRequests.
  ///
  /// In fr, this message translates to:
  /// **'demandes'**
  String get dashAiRequests;

  /// No description provided for @dashAiAutoRate.
  ///
  /// In fr, this message translates to:
  /// **'validées par l\'IA seule'**
  String get dashAiAutoRate;

  /// No description provided for @dashAiAverageMatch.
  ///
  /// In fr, this message translates to:
  /// **'ressemblance moyenne'**
  String get dashAiAverageMatch;

  /// No description provided for @dashAiBlocked.
  ///
  /// In fr, this message translates to:
  /// **'comptes bloqués'**
  String get dashAiBlocked;

  /// No description provided for @checkBirthDate.
  ///
  /// In fr, this message translates to:
  /// **'Même date de naissance que le permis'**
  String get checkBirthDate;

  /// No description provided for @licenseBirthMismatch.
  ///
  /// In fr, this message translates to:
  /// **'Attention : la date de naissance du permis ne correspond pas à votre pièce d\'identité.'**
  String get licenseBirthMismatch;
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
