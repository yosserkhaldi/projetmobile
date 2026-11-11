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
  /// **'Constats'**
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

  /// No description provided for @licenseNameMismatch.
  ///
  /// In fr, this message translates to:
  /// **'Attention : ce permis n\'est pas à votre nom. Ajoutez votre propre permis.'**
  String get licenseNameMismatch;

  /// No description provided for @licenseCinMismatch.
  ///
  /// In fr, this message translates to:
  /// **'Attention : le numéro de CIN du permis ne correspond pas à votre pièce d\'identité.'**
  String get licenseCinMismatch;

  /// No description provided for @errorWrongDocument.
  ///
  /// In fr, this message translates to:
  /// **'La photo ne montre pas la pièce choisie. Changez de pièce ou de photo.'**
  String get errorWrongDocument;

  /// No description provided for @errorNotALicense.
  ///
  /// In fr, this message translates to:
  /// **'Cette photo n\'est pas un permis de conduire.'**
  String get errorNotALicense;

  /// No description provided for @registerIntro.
  ///
  /// In fr, this message translates to:
  /// **'Un e-mail et un mot de passe. Le reste se fait juste après, en quelques étapes.'**
  String get registerIntro;

  /// No description provided for @registerStepYou.
  ///
  /// In fr, this message translates to:
  /// **'Vous'**
  String get registerStepYou;

  /// No description provided for @registerStepContact.
  ///
  /// In fr, this message translates to:
  /// **'Vos coordonnées'**
  String get registerStepContact;

  /// No description provided for @registerStepSecurity.
  ///
  /// In fr, this message translates to:
  /// **'Sécurité'**
  String get registerStepSecurity;

  /// No description provided for @registerPhoneHint.
  ///
  /// In fr, this message translates to:
  /// **'Un code de vérification vous sera envoyé sur WhatsApp.'**
  String get registerPhoneHint;

  /// No description provided for @passwordWeak.
  ///
  /// In fr, this message translates to:
  /// **'Faible'**
  String get passwordWeak;

  /// No description provided for @passwordFair.
  ///
  /// In fr, this message translates to:
  /// **'Moyen'**
  String get passwordFair;

  /// No description provided for @passwordGood.
  ///
  /// In fr, this message translates to:
  /// **'Bon'**
  String get passwordGood;

  /// No description provided for @passwordStrong.
  ///
  /// In fr, this message translates to:
  /// **'Excellent'**
  String get passwordStrong;

  /// No description provided for @passwordRuleLength.
  ///
  /// In fr, this message translates to:
  /// **'8 caractères'**
  String get passwordRuleLength;

  /// No description provided for @passwordRuleUpper.
  ///
  /// In fr, this message translates to:
  /// **'Une majuscule'**
  String get passwordRuleUpper;

  /// No description provided for @passwordRuleDigit.
  ///
  /// In fr, this message translates to:
  /// **'Un chiffre'**
  String get passwordRuleDigit;

  /// No description provided for @passwordRuleSymbol.
  ///
  /// In fr, this message translates to:
  /// **'Un symbole'**
  String get passwordRuleSymbol;

  /// No description provided for @identityStepDocument.
  ///
  /// In fr, this message translates to:
  /// **'Pièce'**
  String get identityStepDocument;

  /// No description provided for @identityStepReading.
  ///
  /// In fr, this message translates to:
  /// **'Lecture'**
  String get identityStepReading;

  /// No description provided for @identityStepFace.
  ///
  /// In fr, this message translates to:
  /// **'Visage'**
  String get identityStepFace;

  /// No description provided for @identityStepSend.
  ///
  /// In fr, this message translates to:
  /// **'Envoi'**
  String get identityStepSend;

  /// No description provided for @profileIdentityVerified.
  ///
  /// In fr, this message translates to:
  /// **'Identité vérifiée'**
  String get profileIdentityVerified;

  /// No description provided for @profileIdentityPending.
  ///
  /// In fr, this message translates to:
  /// **'Identité en cours'**
  String get profileIdentityPending;

  /// No description provided for @profileIdentityTodo.
  ///
  /// In fr, this message translates to:
  /// **'Identité à vérifier'**
  String get profileIdentityTodo;

  /// No description provided for @licenseStatusVerified.
  ///
  /// In fr, this message translates to:
  /// **'Permis vérifié'**
  String get licenseStatusVerified;

  /// No description provided for @licenseStatusToReview.
  ///
  /// In fr, this message translates to:
  /// **'Permis en cours de vérification'**
  String get licenseStatusToReview;

  /// No description provided for @licenseStatusRejected.
  ///
  /// In fr, this message translates to:
  /// **'Permis refusé'**
  String get licenseStatusRejected;

  /// No description provided for @licenseToReviewNote.
  ///
  /// In fr, this message translates to:
  /// **'Une information du permis ne correspond pas à votre compte : un administrateur le vérifie.'**
  String get licenseToReviewNote;

  /// No description provided for @licenseRejectedNote.
  ///
  /// In fr, this message translates to:
  /// **'Votre permis a été refusé. Motif : {reason}. Ajoutez votre propre permis.'**
  String licenseRejectedNote(String reason);

  /// No description provided for @errorLicenseNotYours.
  ///
  /// In fr, this message translates to:
  /// **'Ce permis ne semble pas être le vôtre : le nom, la date de naissance ou le numéro de CIN ne correspondent pas à votre compte. Il n\'a pas été enregistré.'**
  String get errorLicenseNotYours;

  /// No description provided for @accountFileTitle.
  ///
  /// In fr, this message translates to:
  /// **'Dossier du compte'**
  String get accountFileTitle;

  /// No description provided for @openAccountFile.
  ///
  /// In fr, this message translates to:
  /// **'Voir le dossier'**
  String get openAccountFile;

  /// No description provided for @sectionAccount.
  ///
  /// In fr, this message translates to:
  /// **'Compte'**
  String get sectionAccount;

  /// No description provided for @licenseReviewTitle.
  ///
  /// In fr, this message translates to:
  /// **'Permis à vérifier'**
  String get licenseReviewTitle;

  /// No description provided for @licenseReviewSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Un contrôle de l\'IA a échoué, ou la photo était illisible'**
  String get licenseReviewSubtitle;

  /// No description provided for @noLicenseReviews.
  ///
  /// In fr, this message translates to:
  /// **'Aucun permis à vérifier.'**
  String get noLicenseReviews;

  /// No description provided for @licensesToReviewCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 permis à vérifier} other{{count} permis à vérifier}}'**
  String licensesToReviewCount(int count);

  /// No description provided for @approveLicense.
  ///
  /// In fr, this message translates to:
  /// **'Valider le permis'**
  String get approveLicense;

  /// No description provided for @rejectLicense.
  ///
  /// In fr, this message translates to:
  /// **'Refuser le permis'**
  String get rejectLicense;

  /// No description provided for @deleteLicense.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer le permis'**
  String get deleteLicense;

  /// No description provided for @deleteLicenseBody.
  ///
  /// In fr, this message translates to:
  /// **'La photo et les informations du permis de {name} seront effacées.'**
  String deleteLicenseBody(String name);

  /// No description provided for @licenseApproved.
  ///
  /// In fr, this message translates to:
  /// **'Permis validé'**
  String get licenseApproved;

  /// No description provided for @licenseRejected.
  ///
  /// In fr, this message translates to:
  /// **'Permis refusé, le conducteur voit le motif'**
  String get licenseRejected;

  /// No description provided for @licenseDeleted.
  ///
  /// In fr, this message translates to:
  /// **'Permis supprimé'**
  String get licenseDeleted;

  /// No description provided for @licenseUpdated.
  ///
  /// In fr, this message translates to:
  /// **'Permis modifié'**
  String get licenseUpdated;

  /// No description provided for @noLicense.
  ///
  /// In fr, this message translates to:
  /// **'Aucun permis enregistré.'**
  String get noLicense;

  /// No description provided for @noIdentityDocuments.
  ///
  /// In fr, this message translates to:
  /// **'Aucune pièce enregistrée.'**
  String get noIdentityDocuments;

  /// No description provided for @aiChecksTitle.
  ///
  /// In fr, this message translates to:
  /// **'Contrôles de l\'IA'**
  String get aiChecksTitle;

  /// No description provided for @checkLicenseName.
  ///
  /// In fr, this message translates to:
  /// **'Nom du titulaire = nom du compte'**
  String get checkLicenseName;

  /// No description provided for @checkLicenseBirth.
  ///
  /// In fr, this message translates to:
  /// **'Date de naissance = pièce d\'identité'**
  String get checkLicenseBirth;

  /// No description provided for @checkLicenseCin.
  ///
  /// In fr, this message translates to:
  /// **'N° de CIN = pièce d\'identité'**
  String get checkLicenseCin;

  /// No description provided for @checkLicenseNumber.
  ///
  /// In fr, this message translates to:
  /// **'Numéro saisi = numéro lu sur la photo'**
  String get checkLicenseNumber;

  /// No description provided for @checkNotCompared.
  ///
  /// In fr, this message translates to:
  /// **'non comparable'**
  String get checkNotCompared;

  /// No description provided for @licenseRejectReasonNotOwner.
  ///
  /// In fr, this message translates to:
  /// **'Permis d\'une autre personne'**
  String get licenseRejectReasonNotOwner;

  /// No description provided for @licenseRejectReasonExpired.
  ///
  /// In fr, this message translates to:
  /// **'Permis expiré'**
  String get licenseRejectReasonExpired;

  /// No description provided for @revokeIdentity.
  ///
  /// In fr, this message translates to:
  /// **'Annuler la vérification'**
  String get revokeIdentity;

  /// No description provided for @revokeIdentityTitle.
  ///
  /// In fr, this message translates to:
  /// **'Annuler la vérification d\'identité ?'**
  String get revokeIdentityTitle;

  /// No description provided for @revokeIdentityBody.
  ///
  /// In fr, this message translates to:
  /// **'Les photos de la pièce seront effacées. Le conducteur voit le motif et peut refaire une demande tout de suite.'**
  String get revokeIdentityBody;

  /// No description provided for @identityRevoked.
  ///
  /// In fr, this message translates to:
  /// **'Vérification annulée'**
  String get identityRevoked;

  /// No description provided for @reasonLabel.
  ///
  /// In fr, this message translates to:
  /// **'Motif'**
  String get reasonLabel;

  /// No description provided for @onbSkip.
  ///
  /// In fr, this message translates to:
  /// **'Passer'**
  String get onbSkip;

  /// No description provided for @onbLater.
  ///
  /// In fr, this message translates to:
  /// **'Plus tard'**
  String get onbLater;

  /// No description provided for @onbContinue.
  ///
  /// In fr, this message translates to:
  /// **'Continuer'**
  String get onbContinue;

  /// No description provided for @onbBack.
  ///
  /// In fr, this message translates to:
  /// **'Étape précédente'**
  String get onbBack;

  /// No description provided for @onbProgress.
  ///
  /// In fr, this message translates to:
  /// **'Étape {current} sur {total}'**
  String onbProgress(int current, int total);

  /// No description provided for @onbWelcomeEyebrow.
  ///
  /// In fr, this message translates to:
  /// **'Compte créé'**
  String get onbWelcomeEyebrow;

  /// No description provided for @onbWelcomeTitle.
  ///
  /// In fr, this message translates to:
  /// **'Bienvenue,\n{name}'**
  String onbWelcomeTitle(String name);

  /// No description provided for @onbWelcomeBody.
  ///
  /// In fr, this message translates to:
  /// **'Deux minutes pour préparer votre compte, et vous serez prêt le jour où vous en aurez besoin.'**
  String get onbWelcomeBody;

  /// No description provided for @onbWelcomeStart.
  ///
  /// In fr, this message translates to:
  /// **'Préparer mon compte'**
  String get onbWelcomeStart;

  /// No description provided for @onbWelcomeSkip.
  ///
  /// In fr, this message translates to:
  /// **'Je le ferai plus tard'**
  String get onbWelcomeSkip;

  /// No description provided for @onbLicenseTitle.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez votre permis'**
  String get onbLicenseTitle;

  /// No description provided for @onbLicenseBody.
  ///
  /// In fr, this message translates to:
  /// **'Une photo suffit : l\'IA lit le numéro, les catégories et la date. Il servira à remplir vos constats.'**
  String get onbLicenseBody;

  /// No description provided for @onbLicenseScan.
  ///
  /// In fr, this message translates to:
  /// **'Photographier mon permis'**
  String get onbLicenseScan;

  /// No description provided for @onbLicenseRescan.
  ///
  /// In fr, this message translates to:
  /// **'Reprendre la photo'**
  String get onbLicenseRescan;

  /// No description provided for @onbLicenseReading.
  ///
  /// In fr, this message translates to:
  /// **'Lecture du permis…'**
  String get onbLicenseReading;

  /// No description provided for @onbLicenseRead.
  ///
  /// In fr, this message translates to:
  /// **'Lu par l\'IA'**
  String get onbLicenseRead;

  /// No description provided for @onbLicenseUnread.
  ///
  /// In fr, this message translates to:
  /// **'La carte n\'a pas pu être lue. Vous compléterez les informations depuis votre profil.'**
  String get onbLicenseUnread;

  /// No description provided for @onbLicenseTip.
  ///
  /// In fr, this message translates to:
  /// **'À plat, bien éclairé, sans reflet.'**
  String get onbLicenseTip;

  /// No description provided for @onbIdentityTitle.
  ///
  /// In fr, this message translates to:
  /// **'Vérifiez votre identité'**
  String get onbIdentityTitle;

  /// No description provided for @onbIdentityBody.
  ///
  /// In fr, this message translates to:
  /// **'Pour signer vos constats en toute confiance. Comptez deux minutes.'**
  String get onbIdentityBody;

  /// No description provided for @onbIdentityStep1.
  ///
  /// In fr, this message translates to:
  /// **'Une pièce : CIN, permis ou passeport'**
  String get onbIdentityStep1;

  /// No description provided for @onbIdentityStep2.
  ///
  /// In fr, this message translates to:
  /// **'Votre visage, en tournant la tête'**
  String get onbIdentityStep2;

  /// No description provided for @onbIdentityStep3.
  ///
  /// In fr, this message translates to:
  /// **'L\'IA compare, en quelques secondes'**
  String get onbIdentityStep3;

  /// No description provided for @onbIdentityStart.
  ///
  /// In fr, this message translates to:
  /// **'Vérifier maintenant'**
  String get onbIdentityStart;

  /// No description provided for @onbIdentityLicenseHint.
  ///
  /// In fr, this message translates to:
  /// **'Votre permis peut servir de pièce : inutile de le reprendre en photo.'**
  String get onbIdentityLicenseHint;

  /// No description provided for @onbIdentityPrivacy.
  ///
  /// In fr, this message translates to:
  /// **'Vos photos sont analysées sur nos serveurs, sans service extérieur.'**
  String get onbIdentityPrivacy;

  /// No description provided for @onbBiometricTitle.
  ///
  /// In fr, this message translates to:
  /// **'Connexion en un geste'**
  String get onbBiometricTitle;

  /// No description provided for @onbBiometricBody.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrez l\'application avec votre empreinte ou votre visage, sans retaper votre mot de passe.'**
  String get onbBiometricBody;

  /// No description provided for @onbBiometricEnable.
  ///
  /// In fr, this message translates to:
  /// **'Activer'**
  String get onbBiometricEnable;

  /// No description provided for @onbDoneTitle.
  ///
  /// In fr, this message translates to:
  /// **'Tout est prêt,\n{name}'**
  String onbDoneTitle(String name);

  /// No description provided for @onbDoneBody.
  ///
  /// In fr, this message translates to:
  /// **'Vous pouvez déclarer un accident à tout moment, même sans réseau.'**
  String get onbDoneBody;

  /// No description provided for @onbDoneLater.
  ///
  /// In fr, this message translates to:
  /// **'Le reste se termine depuis votre profil, quand vous voulez.'**
  String get onbDoneLater;

  /// No description provided for @onbDoneStart.
  ///
  /// In fr, this message translates to:
  /// **'Accéder à l\'application'**
  String get onbDoneStart;

  /// No description provided for @onbItemPhone.
  ///
  /// In fr, this message translates to:
  /// **'Téléphone'**
  String get onbItemPhone;

  /// No description provided for @onbItemLicense.
  ///
  /// In fr, this message translates to:
  /// **'Permis de conduire'**
  String get onbItemLicense;

  /// No description provided for @onbItemIdentity.
  ///
  /// In fr, this message translates to:
  /// **'Identité'**
  String get onbItemIdentity;

  /// No description provided for @onbItemBiometric.
  ///
  /// In fr, this message translates to:
  /// **'Connexion biométrique'**
  String get onbItemBiometric;

  /// No description provided for @onbStateDone.
  ///
  /// In fr, this message translates to:
  /// **'Fait'**
  String get onbStateDone;

  /// No description provided for @onbStatePending.
  ///
  /// In fr, this message translates to:
  /// **'En vérification'**
  String get onbStatePending;

  /// No description provided for @onbStateTodo.
  ///
  /// In fr, this message translates to:
  /// **'À faire'**
  String get onbStateTodo;

  /// No description provided for @registerStepAccount.
  ///
  /// In fr, this message translates to:
  /// **'Votre compte'**
  String get registerStepAccount;

  /// No description provided for @onbWelcomeNewTitle.
  ///
  /// In fr, this message translates to:
  /// **'Bienvenue sur\nMon Constat'**
  String get onbWelcomeNewTitle;

  /// No description provided for @onbProfileTitle.
  ///
  /// In fr, this message translates to:
  /// **'Faisons connaissance'**
  String get onbProfileTitle;

  /// No description provided for @onbProfileBody.
  ///
  /// In fr, this message translates to:
  /// **'Votre nom figure sur vos constats. Votre numéro sert à vous connecter et à suivre vos dossiers.'**
  String get onbProfileBody;

  /// No description provided for @onbPhoneTitle.
  ///
  /// In fr, this message translates to:
  /// **'Confirmez votre numéro'**
  String get onbPhoneTitle;

  /// No description provided for @onbCodeSent.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau code envoyé.'**
  String get onbCodeSent;

  /// No description provided for @onbReadingTitle.
  ///
  /// In fr, this message translates to:
  /// **'Lu sur la pièce'**
  String get onbReadingTitle;

  /// No description provided for @correctReading.
  ///
  /// In fr, this message translates to:
  /// **'Corriger'**
  String get correctReading;

  /// No description provided for @correctReadingTitle.
  ///
  /// In fr, this message translates to:
  /// **'Corriger la lecture de la pièce'**
  String get correctReadingTitle;

  /// No description provided for @correctReadingHint.
  ///
  /// In fr, this message translates to:
  /// **'Corrigez ce que l\'IA a mal lu, en recopiant la pièce. Dates au format AAAA-MM-JJ.'**
  String get correctReadingHint;

  /// No description provided for @readingCorrected.
  ///
  /// In fr, this message translates to:
  /// **'Lecture corrigée'**
  String get readingCorrected;

  /// No description provided for @readLastName.
  ///
  /// In fr, this message translates to:
  /// **'Nom'**
  String get readLastName;

  /// No description provided for @readFirstName.
  ///
  /// In fr, this message translates to:
  /// **'Prénom'**
  String get readFirstName;

  /// No description provided for @readBirthDate.
  ///
  /// In fr, this message translates to:
  /// **'Date de naissance'**
  String get readBirthDate;

  /// No description provided for @readBirthPlace.
  ///
  /// In fr, this message translates to:
  /// **'Lieu de naissance'**
  String get readBirthPlace;

  /// No description provided for @claimsDecisionHelpGuide.
  ///
  /// In fr, this message translates to:
  /// **'Aide à la décision : priorité, estimation, risque et pièces manquantes de ce dossier. Touchez l’icône pour l’ouvrir.'**
  String get claimsDecisionHelpGuide;

  /// No description provided for @claimsTimelineEarlier.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 étape précédente} other{{count} étapes précédentes}}'**
  String claimsTimelineEarlier(int count);

  /// No description provided for @claimsAlertOpen.
  ///
  /// In fr, this message translates to:
  /// **'Voir'**
  String get claimsAlertOpen;

  /// No description provided for @claimsTimelineCollapse.
  ///
  /// In fr, this message translates to:
  /// **'Afficher moins'**
  String get claimsTimelineCollapse;

  /// No description provided for @dashClaimsTotal.
  ///
  /// In fr, this message translates to:
  /// **'Sinistres'**
  String get dashClaimsTotal;

  /// No description provided for @dashClaimsOpen.
  ///
  /// In fr, this message translates to:
  /// **'En cours'**
  String get dashClaimsOpen;

  /// No description provided for @dashClaimsClosed.
  ///
  /// In fr, this message translates to:
  /// **'Clôturés'**
  String get dashClaimsClosed;

  /// No description provided for @dashAvgClose.
  ///
  /// In fr, this message translates to:
  /// **'Délai moyen de clôture'**
  String get dashAvgClose;

  /// No description provided for @dashDays.
  ///
  /// In fr, this message translates to:
  /// **'{days} j'**
  String dashDays(String days);

  /// No description provided for @dashIndemnities.
  ///
  /// In fr, this message translates to:
  /// **'Indemnisations versées : {amount} TND'**
  String dashIndemnities(String amount);

  /// No description provided for @dashByStatus.
  ///
  /// In fr, this message translates to:
  /// **'Par statut'**
  String get dashByStatus;

  /// No description provided for @dashBySeverity.
  ///
  /// In fr, this message translates to:
  /// **'Par gravité'**
  String get dashBySeverity;

  /// No description provided for @dashByCompany.
  ///
  /// In fr, this message translates to:
  /// **'Par compagnie'**
  String get dashByCompany;

  /// No description provided for @dashByMonth.
  ///
  /// In fr, this message translates to:
  /// **'Sinistres des 6 derniers mois'**
  String get dashByMonth;

  /// No description provided for @dashHotspots.
  ///
  /// In fr, this message translates to:
  /// **'Lieux des accidents déclarés ({count})'**
  String dashHotspots(int count);

  /// No description provided for @dashNoPoints.
  ///
  /// In fr, this message translates to:
  /// **'Aucune déclaration localisée pour l’instant.'**
  String get dashNoPoints;

  /// No description provided for @dashNoCompany.
  ///
  /// In fr, this message translates to:
  /// **'Sans compagnie'**
  String get dashNoCompany;

  /// No description provided for @vehAddVehicle.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un véhicule'**
  String get vehAddVehicle;

  /// No description provided for @vehEditVehicle.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le véhicule'**
  String get vehEditVehicle;

  /// No description provided for @vehEdit.
  ///
  /// In fr, this message translates to:
  /// **'Modifier'**
  String get vehEdit;

  /// No description provided for @vehArchive.
  ///
  /// In fr, this message translates to:
  /// **'Archiver'**
  String get vehArchive;

  /// No description provided for @vehUnarchive.
  ///
  /// In fr, this message translates to:
  /// **'Désarchiver'**
  String get vehUnarchive;

  /// No description provided for @vehDelete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get vehDelete;

  /// No description provided for @vehCancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get vehCancel;

  /// No description provided for @vehInsurance.
  ///
  /// In fr, this message translates to:
  /// **'Assurance'**
  String get vehInsurance;

  /// No description provided for @vehInsuranceContract.
  ///
  /// In fr, this message translates to:
  /// **'Contrat d\'assurance'**
  String get vehInsuranceContract;

  /// No description provided for @vehTechnicalInspection.
  ///
  /// In fr, this message translates to:
  /// **'Visite technique'**
  String get vehTechnicalInspection;

  /// No description provided for @vehMileage.
  ///
  /// In fr, this message translates to:
  /// **'Kilométrage'**
  String get vehMileage;

  /// No description provided for @vehMileageValue.
  ///
  /// In fr, this message translates to:
  /// **'{thousands} 000 km'**
  String vehMileageValue(int thousands);

  /// No description provided for @vehType.
  ///
  /// In fr, this message translates to:
  /// **'Type'**
  String get vehType;

  /// No description provided for @vehFuel.
  ///
  /// In fr, this message translates to:
  /// **'Carburant'**
  String get vehFuel;

  /// No description provided for @vehYear.
  ///
  /// In fr, this message translates to:
  /// **'Année'**
  String get vehYear;

  /// No description provided for @vehColor.
  ///
  /// In fr, this message translates to:
  /// **'Couleur'**
  String get vehColor;

  /// No description provided for @vehPolicyNumber.
  ///
  /// In fr, this message translates to:
  /// **'N° de police'**
  String get vehPolicyNumber;

  /// No description provided for @vehExpiredBadge.
  ///
  /// In fr, this message translates to:
  /// **'EXPIRÉ'**
  String get vehExpiredBadge;

  /// No description provided for @vehStatusOk.
  ///
  /// In fr, this message translates to:
  /// **'OK'**
  String get vehStatusOk;

  /// No description provided for @vehDaysShort.
  ///
  /// In fr, this message translates to:
  /// **'{days}j'**
  String vehDaysShort(int days);

  /// No description provided for @vehDaysOverdue.
  ///
  /// In fr, this message translates to:
  /// **'{days}j\ndépassé'**
  String vehDaysOverdue(int days);

  /// No description provided for @vehDateHint.
  ///
  /// In fr, this message translates to:
  /// **'JJ/MM/AAAA'**
  String get vehDateHint;

  /// No description provided for @vehTypeCar.
  ///
  /// In fr, this message translates to:
  /// **'Voiture'**
  String get vehTypeCar;

  /// No description provided for @vehTypeMoto.
  ///
  /// In fr, this message translates to:
  /// **'Moto'**
  String get vehTypeMoto;

  /// No description provided for @vehTypeTruck.
  ///
  /// In fr, this message translates to:
  /// **'Camion'**
  String get vehTypeTruck;

  /// No description provided for @vehTypeVan.
  ///
  /// In fr, this message translates to:
  /// **'Camionnette'**
  String get vehTypeVan;

  /// No description provided for @vehOther.
  ///
  /// In fr, this message translates to:
  /// **'Autre'**
  String get vehOther;

  /// No description provided for @vehFuelPetrol.
  ///
  /// In fr, this message translates to:
  /// **'Essence'**
  String get vehFuelPetrol;

  /// No description provided for @vehFuelDiesel.
  ///
  /// In fr, this message translates to:
  /// **'Diesel'**
  String get vehFuelDiesel;

  /// No description provided for @vehFuelElectric.
  ///
  /// In fr, this message translates to:
  /// **'Électrique'**
  String get vehFuelElectric;

  /// No description provided for @vehFuelHybrid.
  ///
  /// In fr, this message translates to:
  /// **'Hybride'**
  String get vehFuelHybrid;

  /// No description provided for @vehAlertsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Alertes d\'échéance'**
  String get vehAlertsTitle;

  /// No description provided for @vehAlertsEmptyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucune alerte active'**
  String get vehAlertsEmptyTitle;

  /// No description provided for @vehAlertsEmptyBody.
  ///
  /// In fr, this message translates to:
  /// **'Tous vos contrats et visites techniques\nsont à jour.'**
  String get vehAlertsEmptyBody;

  /// No description provided for @vehAlertsGroupExpired.
  ///
  /// In fr, this message translates to:
  /// **'Expiré(s)'**
  String get vehAlertsGroupExpired;

  /// No description provided for @vehAlertsGroupExpiring.
  ///
  /// In fr, this message translates to:
  /// **'Expire bientôt'**
  String get vehAlertsGroupExpiring;

  /// No description provided for @vehAlertsSummaryExpired.
  ///
  /// In fr, this message translates to:
  /// **'Expirés'**
  String get vehAlertsSummaryExpired;

  /// No description provided for @vehAlertsSummaryNear.
  ///
  /// In fr, this message translates to:
  /// **'Proches'**
  String get vehAlertsSummaryNear;

  /// No description provided for @vehAlertsSummaryTotal.
  ///
  /// In fr, this message translates to:
  /// **'Total'**
  String get vehAlertsSummaryTotal;

  /// No description provided for @vehAlertInsuranceExpired.
  ///
  /// In fr, this message translates to:
  /// **'Assurance EXPIRÉE'**
  String get vehAlertInsuranceExpired;

  /// No description provided for @vehAlertInsuranceExpiring.
  ///
  /// In fr, this message translates to:
  /// **'Assurance expire dans {days} j.'**
  String vehAlertInsuranceExpiring(int days);

  /// No description provided for @vehAlertTechnicalExpired.
  ///
  /// In fr, this message translates to:
  /// **'Visite technique EXPIRÉE'**
  String get vehAlertTechnicalExpired;

  /// No description provided for @vehAlertTechnicalExpiring.
  ///
  /// In fr, this message translates to:
  /// **'Visite technique dans {days} j.'**
  String vehAlertTechnicalExpiring(int days);

  /// No description provided for @vehListTitle.
  ///
  /// In fr, this message translates to:
  /// **'Véhicules & contrats'**
  String get vehListTitle;

  /// No description provided for @vehListActiveCount.
  ///
  /// In fr, this message translates to:
  /// **'{count} véhicule(s) actif(s)'**
  String vehListActiveCount(int count);

  /// No description provided for @vehTabActive.
  ///
  /// In fr, this message translates to:
  /// **'Actifs ({count})'**
  String vehTabActive(int count);

  /// No description provided for @vehTabArchived.
  ///
  /// In fr, this message translates to:
  /// **'Archivés ({count})'**
  String vehTabArchived(int count);

  /// No description provided for @vehEmptyArchived.
  ///
  /// In fr, this message translates to:
  /// **'Aucun véhicule archivé'**
  String get vehEmptyArchived;

  /// No description provided for @vehEmptyActive.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez votre premier véhicule'**
  String get vehEmptyActive;

  /// No description provided for @vehPolicyValue.
  ///
  /// In fr, this message translates to:
  /// **'Police {policy}'**
  String vehPolicyValue(String policy);

  /// No description provided for @vehAiAnalysis.
  ///
  /// In fr, this message translates to:
  /// **'Analyse IA'**
  String get vehAiAnalysis;

  /// No description provided for @vehDeleteTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer ce véhicule ?'**
  String get vehDeleteTitle;

  /// No description provided for @vehDeleteBody.
  ///
  /// In fr, this message translates to:
  /// **'{name} ({plate}) sera définitivement supprimé.'**
  String vehDeleteBody(String name, String plate);

  /// No description provided for @vehSectionInfo.
  ///
  /// In fr, this message translates to:
  /// **'Informations'**
  String get vehSectionInfo;

  /// No description provided for @vehRenew.
  ///
  /// In fr, this message translates to:
  /// **'Renouveler'**
  String get vehRenew;

  /// No description provided for @vehInsurer.
  ///
  /// In fr, this message translates to:
  /// **'Assureur'**
  String get vehInsurer;

  /// No description provided for @vehExpiry.
  ///
  /// In fr, this message translates to:
  /// **'Expiration'**
  String get vehExpiry;

  /// No description provided for @vehPremiumTitle.
  ///
  /// In fr, this message translates to:
  /// **'Prime d’assurance estimée (IA)'**
  String get vehPremiumTitle;

  /// No description provided for @vehPremiumValue.
  ///
  /// In fr, this message translates to:
  /// **'{amount} TND / an'**
  String vehPremiumValue(String amount);

  /// No description provided for @vehNextInspection.
  ///
  /// In fr, this message translates to:
  /// **'Prochaine visite'**
  String get vehNextInspection;

  /// No description provided for @vehClaimsHistory.
  ///
  /// In fr, this message translates to:
  /// **'Historique sinistres'**
  String get vehClaimsHistory;

  /// No description provided for @vehClaimsDeclared.
  ///
  /// In fr, this message translates to:
  /// **'Sinistres déclarés'**
  String get vehClaimsDeclared;

  /// No description provided for @vehRenewTitle.
  ///
  /// In fr, this message translates to:
  /// **'Renouveler le contrat d’assurance'**
  String get vehRenewTitle;

  /// No description provided for @vehExpiryDate.
  ///
  /// In fr, this message translates to:
  /// **'Date d’expiration'**
  String get vehExpiryDate;

  /// No description provided for @vehRenewInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Date invalide (JJ/MM/AAAA) ou n° de police manquant.'**
  String get vehRenewInvalid;

  /// No description provided for @vehRenewSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Contrat d’assurance renouvelé avec succès !'**
  String get vehRenewSuccess;

  /// No description provided for @vehRiskTitle.
  ///
  /// In fr, this message translates to:
  /// **'Analyse de risque IA'**
  String get vehRiskTitle;

  /// No description provided for @vehRiskSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Calculé depuis vos données locales'**
  String get vehRiskSubtitle;

  /// No description provided for @vehRiskFactors.
  ///
  /// In fr, this message translates to:
  /// **'Facteurs détectés'**
  String get vehRiskFactors;

  /// No description provided for @vehRecommendations.
  ///
  /// In fr, this message translates to:
  /// **'Recommandations'**
  String get vehRecommendations;

  /// No description provided for @vehPhotoTitle.
  ///
  /// In fr, this message translates to:
  /// **'Photo du véhicule'**
  String get vehPhotoTitle;

  /// No description provided for @vehAddPhoto.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une photo'**
  String get vehAddPhoto;

  /// No description provided for @vehTakePhoto.
  ///
  /// In fr, this message translates to:
  /// **'Prendre une photo'**
  String get vehTakePhoto;

  /// No description provided for @vehPickFromGallery.
  ///
  /// In fr, this message translates to:
  /// **'Choisir depuis la galerie'**
  String get vehPickFromGallery;

  /// No description provided for @vehRiskVeryOld.
  ///
  /// In fr, this message translates to:
  /// **'Véhicule très ancien'**
  String get vehRiskVeryOld;

  /// No description provided for @vehRiskVeryOldDesc.
  ///
  /// In fr, this message translates to:
  /// **'Plus de 20 ans — risque mécanique élevé.'**
  String get vehRiskVeryOldDesc;

  /// No description provided for @vehRiskOld.
  ///
  /// In fr, this message translates to:
  /// **'Véhicule ancien'**
  String get vehRiskOld;

  /// No description provided for @vehRiskOldDesc.
  ///
  /// In fr, this message translates to:
  /// **'{age} ans — entretien régulier recommandé.'**
  String vehRiskOldDesc(int age);

  /// No description provided for @vehRiskMidAge.
  ///
  /// In fr, this message translates to:
  /// **'Véhicule d\'âge moyen'**
  String get vehRiskMidAge;

  /// No description provided for @vehRiskMidAgeDesc.
  ///
  /// In fr, this message translates to:
  /// **'{age} ans — vérifier la carte grise.'**
  String vehRiskMidAgeDesc(int age);

  /// No description provided for @vehRiskInsExpiredDesc.
  ///
  /// In fr, this message translates to:
  /// **'Expirée depuis {days} jour(s) — circuler est illégal.'**
  String vehRiskInsExpiredDesc(int days);

  /// No description provided for @vehRiskInsCritical.
  ///
  /// In fr, this message translates to:
  /// **'Assurance critique'**
  String get vehRiskInsCritical;

  /// No description provided for @vehRiskInsCriticalDesc.
  ///
  /// In fr, this message translates to:
  /// **'Expire dans {days} jour(s) — renouvelez d\'urgence.'**
  String vehRiskInsCriticalDesc(int days);

  /// No description provided for @vehRiskInsSoon.
  ///
  /// In fr, this message translates to:
  /// **'Assurance bientôt expirée'**
  String get vehRiskInsSoon;

  /// No description provided for @vehRiskExpiresIn.
  ///
  /// In fr, this message translates to:
  /// **'Expire dans {days} jour(s).'**
  String vehRiskExpiresIn(int days);

  /// No description provided for @vehRiskTechExpired.
  ///
  /// In fr, this message translates to:
  /// **'Visite technique expirée'**
  String get vehRiskTechExpired;

  /// No description provided for @vehRiskExpiredSince.
  ///
  /// In fr, this message translates to:
  /// **'Expirée depuis {days} jour(s).'**
  String vehRiskExpiredSince(int days);

  /// No description provided for @vehRiskTechImminent.
  ///
  /// In fr, this message translates to:
  /// **'Visite technique imminente'**
  String get vehRiskTechImminent;

  /// No description provided for @vehRiskInDays.
  ///
  /// In fr, this message translates to:
  /// **'Dans {days} jour(s).'**
  String vehRiskInDays(int days);

  /// No description provided for @vehRiskTechNear.
  ///
  /// In fr, this message translates to:
  /// **'Visite technique proche'**
  String get vehRiskTechNear;

  /// No description provided for @vehRiskTechUnknown.
  ///
  /// In fr, this message translates to:
  /// **'Visite technique inconnue'**
  String get vehRiskTechUnknown;

  /// No description provided for @vehRiskTechUnknownDesc.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez la date pour un suivi précis.'**
  String get vehRiskTechUnknownDesc;

  /// No description provided for @vehRiskKmVeryHigh.
  ///
  /// In fr, this message translates to:
  /// **'Kilométrage très élevé'**
  String get vehRiskKmVeryHigh;

  /// No description provided for @vehRiskKmVeryHighDesc.
  ///
  /// In fr, this message translates to:
  /// **'{thousands} 000 km — usure importante.'**
  String vehRiskKmVeryHighDesc(int thousands);

  /// No description provided for @vehRiskKmHigh.
  ///
  /// In fr, this message translates to:
  /// **'Kilométrage élevé'**
  String get vehRiskKmHigh;

  /// No description provided for @vehRiskKmModerate.
  ///
  /// In fr, this message translates to:
  /// **'Kilométrage modéré'**
  String get vehRiskKmModerate;

  /// No description provided for @vehRiskKmDesc.
  ///
  /// In fr, this message translates to:
  /// **'{thousands} 000 km.'**
  String vehRiskKmDesc(int thousands);

  /// No description provided for @vehRiskClaimsHigh.
  ///
  /// In fr, this message translates to:
  /// **'Historique sinistres élevé'**
  String get vehRiskClaimsHigh;

  /// No description provided for @vehRiskClaimsHighDesc.
  ///
  /// In fr, this message translates to:
  /// **'{count} sinistre(s) enregistré(s).'**
  String vehRiskClaimsHighDesc(int count);

  /// No description provided for @vehRiskClaimsMulti.
  ///
  /// In fr, this message translates to:
  /// **'Sinistres multiples'**
  String get vehRiskClaimsMulti;

  /// No description provided for @vehRiskClaimsMultiDesc.
  ///
  /// In fr, this message translates to:
  /// **'2 sinistres enregistrés.'**
  String get vehRiskClaimsMultiDesc;

  /// No description provided for @vehRiskClaimsOne.
  ///
  /// In fr, this message translates to:
  /// **'Sinistre précédent'**
  String get vehRiskClaimsOne;

  /// No description provided for @vehRiskClaimsOneDesc.
  ///
  /// In fr, this message translates to:
  /// **'1 sinistre enregistré.'**
  String get vehRiskClaimsOneDesc;

  /// No description provided for @vehRiskOldDiesel.
  ///
  /// In fr, this message translates to:
  /// **'Diesel ancien'**
  String get vehRiskOldDiesel;

  /// No description provided for @vehRiskOldDieselDesc.
  ///
  /// In fr, this message translates to:
  /// **'Risque de particules et usure moteur accrue.'**
  String get vehRiskOldDieselDesc;

  /// No description provided for @vehRecRenewNow.
  ///
  /// In fr, this message translates to:
  /// **'Renouvelez votre assurance immédiatement.'**
  String get vehRecRenewNow;

  /// No description provided for @vehRecSeeInsurer.
  ///
  /// In fr, this message translates to:
  /// **'Prenez rendez-vous avec votre assureur dans les prochains jours.'**
  String get vehRecSeeInsurer;

  /// No description provided for @vehRecTechNow.
  ///
  /// In fr, this message translates to:
  /// **'Effectuez votre visite technique au plus tôt.'**
  String get vehRecTechNow;

  /// No description provided for @vehRecTechSchedule.
  ///
  /// In fr, this message translates to:
  /// **'Programmez votre visite technique prochainement.'**
  String get vehRecTechSchedule;

  /// No description provided for @vehRecTechAddDate.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez la date de votre prochaine visite technique.'**
  String get vehRecTechAddDate;

  /// No description provided for @vehRecFullCheck.
  ///
  /// In fr, this message translates to:
  /// **'Faites une vérification complète chez un garagiste agréé.'**
  String get vehRecFullCheck;

  /// No description provided for @vehRecBeltBrakes.
  ///
  /// In fr, this message translates to:
  /// **'Vérifiez la courroie de distribution et les plaquettes de frein.'**
  String get vehRecBeltBrakes;

  /// No description provided for @vehRecDefensive.
  ///
  /// In fr, this message translates to:
  /// **'Envisagez une conduite défensive pour réduire les sinistres.'**
  String get vehRecDefensive;

  /// No description provided for @vehRecAddMileage.
  ///
  /// In fr, this message translates to:
  /// **'Renseignez le kilométrage pour une analyse plus précise.'**
  String get vehRecAddMileage;

  /// No description provided for @vehRecAllGood.
  ///
  /// In fr, this message translates to:
  /// **'Votre véhicule est en règle. Continuez l\'entretien régulier.'**
  String get vehRecAllGood;

  /// No description provided for @vehScanNothing.
  ///
  /// In fr, this message translates to:
  /// **'Rien n’a pu être lu. Reprenez la photo à plat, bien éclairée.'**
  String get vehScanNothing;

  /// No description provided for @vehScanRead.
  ///
  /// In fr, this message translates to:
  /// **'Lu par l’IA : {fields}. Vérifiez avant d’enregistrer.'**
  String vehScanRead(String fields);

  /// No description provided for @vehScanEstimated.
  ///
  /// In fr, this message translates to:
  /// **'Fin de validité estimée à un an : vérifiez-la.'**
  String get vehScanEstimated;

  /// No description provided for @vehScanFailed.
  ///
  /// In fr, this message translates to:
  /// **'Lecture impossible : {error}'**
  String vehScanFailed(String error);

  /// No description provided for @vehScanBusy.
  ///
  /// In fr, this message translates to:
  /// **'Lecture en cours… (jusqu’à 30 s)'**
  String get vehScanBusy;

  /// No description provided for @vehScanRegistration.
  ///
  /// In fr, this message translates to:
  /// **'Photographier la carte grise'**
  String get vehScanRegistration;

  /// No description provided for @vehScanInsurance.
  ///
  /// In fr, this message translates to:
  /// **'Photographier l’attestation d’assurance'**
  String get vehScanInsurance;

  /// No description provided for @vehReadPlate.
  ///
  /// In fr, this message translates to:
  /// **'immatriculation'**
  String get vehReadPlate;

  /// No description provided for @vehReadBrand.
  ///
  /// In fr, this message translates to:
  /// **'marque'**
  String get vehReadBrand;

  /// No description provided for @vehReadModel.
  ///
  /// In fr, this message translates to:
  /// **'modèle'**
  String get vehReadModel;

  /// No description provided for @vehReadYear.
  ///
  /// In fr, this message translates to:
  /// **'année'**
  String get vehReadYear;

  /// No description provided for @vehReadPolicy.
  ///
  /// In fr, this message translates to:
  /// **'n° de contrat'**
  String get vehReadPolicy;

  /// No description provided for @vehReadExpiry.
  ///
  /// In fr, this message translates to:
  /// **'fin de validité'**
  String get vehReadExpiry;

  /// No description provided for @vehReadInsurer.
  ///
  /// In fr, this message translates to:
  /// **'assureur'**
  String get vehReadInsurer;

  /// No description provided for @vehReadInsurerToPick.
  ///
  /// In fr, this message translates to:
  /// **'assureur ({insurer}, à choisir dans la liste)'**
  String vehReadInsurerToPick(String insurer);

  /// No description provided for @vehScanTitle.
  ///
  /// In fr, this message translates to:
  /// **'Scanner vos documents avec l’IA'**
  String get vehScanTitle;

  /// No description provided for @vehScanBody.
  ///
  /// In fr, this message translates to:
  /// **'Une photo de la carte grise ou de l’attestation d’assurance : l’IA remplit le formulaire, vous vérifiez.'**
  String get vehScanBody;

  /// No description provided for @vehSectionIdentification.
  ///
  /// In fr, this message translates to:
  /// **'Identification du véhicule'**
  String get vehSectionIdentification;

  /// No description provided for @vehPlateRequired.
  ///
  /// In fr, this message translates to:
  /// **'Immatriculation *'**
  String get vehPlateRequired;

  /// No description provided for @vehPlateHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex : 215 تونس 4521'**
  String get vehPlateHint;

  /// No description provided for @vehBrandRequired.
  ///
  /// In fr, this message translates to:
  /// **'Marque *'**
  String get vehBrandRequired;

  /// No description provided for @vehModelRequired.
  ///
  /// In fr, this message translates to:
  /// **'Modèle *'**
  String get vehModelRequired;

  /// No description provided for @vehYearRequired.
  ///
  /// In fr, this message translates to:
  /// **'Année *'**
  String get vehYearRequired;

  /// No description provided for @vehColorHint.
  ///
  /// In fr, this message translates to:
  /// **'Blanc'**
  String get vehColorHint;

  /// No description provided for @vehKmUnit.
  ///
  /// In fr, this message translates to:
  /// **'km'**
  String get vehKmUnit;

  /// No description provided for @vehPolicyNumberRequired.
  ///
  /// In fr, this message translates to:
  /// **'N° de police *'**
  String get vehPolicyNumberRequired;

  /// No description provided for @vehInsuranceExpiryRequired.
  ///
  /// In fr, this message translates to:
  /// **'Date d\'expiration assurance *'**
  String get vehInsuranceExpiryRequired;

  /// No description provided for @vehNextInspectionField.
  ///
  /// In fr, this message translates to:
  /// **'Prochaine visite technique'**
  String get vehNextInspectionField;

  /// No description provided for @vehSaveChanges.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer les modifications'**
  String get vehSaveChanges;

  /// No description provided for @vehAddVehicleButton.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter le véhicule'**
  String get vehAddVehicleButton;

  /// No description provided for @vehFieldRequired.
  ///
  /// In fr, this message translates to:
  /// **'Champ obligatoire.'**
  String get vehFieldRequired;

  /// No description provided for @vehYearInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Année invalide.'**
  String get vehYearInvalid;

  /// No description provided for @vehDateFormat.
  ///
  /// In fr, this message translates to:
  /// **'Format JJ/MM/AAAA.'**
  String get vehDateFormat;

  /// No description provided for @accStepContext.
  ///
  /// In fr, this message translates to:
  /// **'Contexte'**
  String get accStepContext;

  /// No description provided for @accStepContextHint.
  ///
  /// In fr, this message translates to:
  /// **'Lieu, heure et conditions'**
  String get accStepContextHint;

  /// No description provided for @accStepDescription.
  ///
  /// In fr, this message translates to:
  /// **'Description'**
  String get accStepDescription;

  /// No description provided for @accStepDescriptionHint.
  ///
  /// In fr, this message translates to:
  /// **'Type, gravité et témoins'**
  String get accStepDescriptionHint;

  /// No description provided for @accStepEvidence.
  ///
  /// In fr, this message translates to:
  /// **'Preuves'**
  String get accStepEvidence;

  /// No description provided for @accStepEvidenceHint.
  ///
  /// In fr, this message translates to:
  /// **'Photos, vidéo et note vocale'**
  String get accStepEvidenceHint;

  /// No description provided for @accStepDriverBHint.
  ///
  /// In fr, this message translates to:
  /// **'Identité et assurance'**
  String get accStepDriverBHint;

  /// No description provided for @accStepCircumstances.
  ///
  /// In fr, this message translates to:
  /// **'Circonstances'**
  String get accStepCircumstances;

  /// No description provided for @accStepCircumstancesHint.
  ///
  /// In fr, this message translates to:
  /// **'Cases et observations'**
  String get accStepCircumstancesHint;

  /// No description provided for @accStepSketch.
  ///
  /// In fr, this message translates to:
  /// **'Croquis'**
  String get accStepSketch;

  /// No description provided for @accStepSketchHint.
  ///
  /// In fr, this message translates to:
  /// **'Choc et schéma'**
  String get accStepSketchHint;

  /// No description provided for @accStepSignatures.
  ///
  /// In fr, this message translates to:
  /// **'Signatures'**
  String get accStepSignatures;

  /// No description provided for @accStepSignaturesHint.
  ///
  /// In fr, this message translates to:
  /// **'Validation et transmission'**
  String get accStepSignaturesHint;

  /// No description provided for @accStepOf.
  ///
  /// In fr, this message translates to:
  /// **'Étape {step} sur {total}'**
  String accStepOf(int step, int total);

  /// No description provided for @accMinutesLeft.
  ///
  /// In fr, this message translates to:
  /// **'~{minutes} min'**
  String accMinutesLeft(int minutes);

  /// No description provided for @accDriverA.
  ///
  /// In fr, this message translates to:
  /// **'Conducteur A'**
  String get accDriverA;

  /// No description provided for @accDriverB.
  ///
  /// In fr, this message translates to:
  /// **'Conducteur B'**
  String get accDriverB;

  /// No description provided for @accNewDeclaration.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle déclaration'**
  String get accNewDeclaration;

  /// No description provided for @accDraft.
  ///
  /// In fr, this message translates to:
  /// **'Brouillon'**
  String get accDraft;

  /// No description provided for @accFinishDriverBFirst.
  ///
  /// In fr, this message translates to:
  /// **'Terminez d’abord la saisie du conducteur B.'**
  String get accFinishDriverBFirst;

  /// No description provided for @accContinue.
  ///
  /// In fr, this message translates to:
  /// **'Continuer'**
  String get accContinue;

  /// No description provided for @accContinueToReport.
  ///
  /// In fr, this message translates to:
  /// **'Continuer vers le constat'**
  String get accContinueToReport;

  /// No description provided for @accIAmDriverB.
  ///
  /// In fr, this message translates to:
  /// **'Je suis le conducteur B'**
  String get accIAmDriverB;

  /// No description provided for @accFinishAndReturnPhone.
  ///
  /// In fr, this message translates to:
  /// **'Terminer et rendre le téléphone'**
  String get accFinishAndReturnPhone;

  /// No description provided for @accSignAndSend.
  ///
  /// In fr, this message translates to:
  /// **'Signer et transmettre'**
  String get accSignAndSend;

  /// No description provided for @accIAmDriverA.
  ///
  /// In fr, this message translates to:
  /// **'Je suis le conducteur A'**
  String get accIAmDriverA;

  /// No description provided for @accBack.
  ///
  /// In fr, this message translates to:
  /// **'Retour'**
  String get accBack;

  /// No description provided for @accDraftSaved.
  ///
  /// In fr, this message translates to:
  /// **'Brouillon enregistré sur cet appareil'**
  String get accDraftSaved;

  /// No description provided for @accThanks.
  ///
  /// In fr, this message translates to:
  /// **'Merci !'**
  String get accThanks;

  /// No description provided for @accReturnPhoneText.
  ///
  /// In fr, this message translates to:
  /// **'Rendez maintenant le téléphone au conducteur A. Les deux conducteurs signeront ensemble à la fin du constat.'**
  String get accReturnPhoneText;

  /// No description provided for @accChooseVehicleFirst.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez votre véhicule à la première étape.'**
  String get accChooseVehicleFirst;

  /// No description provided for @accSealingTitle.
  ///
  /// In fr, this message translates to:
  /// **'Scellement cryptographique du constat…'**
  String get accSealingTitle;

  /// No description provided for @accSealingHint.
  ///
  /// In fr, this message translates to:
  /// **'Calcul du hash SHA-256 et transmission'**
  String get accSealingHint;

  /// No description provided for @accSealFailed.
  ///
  /// In fr, this message translates to:
  /// **'Le constat n’a pas pu être scellé : {error}'**
  String accSealFailed(String error);

  /// No description provided for @accVerifyIdentityTitle.
  ///
  /// In fr, this message translates to:
  /// **'Vérifiez votre identité pour signer'**
  String get accVerifyIdentityTitle;

  /// No description provided for @accVerifyIdentityText.
  ///
  /// In fr, this message translates to:
  /// **'Le constat engage les deux conducteurs : votre identité doit être vérifiée avant la signature. Votre brouillon reste enregistré.'**
  String get accVerifyIdentityText;

  /// No description provided for @accLater.
  ///
  /// In fr, this message translates to:
  /// **'Plus tard'**
  String get accLater;

  /// No description provided for @accVerifyIdentity.
  ///
  /// In fr, this message translates to:
  /// **'Vérifier mon identité'**
  String get accVerifyIdentity;

  /// No description provided for @accCheckPlace.
  ///
  /// In fr, this message translates to:
  /// **'Vérifiez le lieu de l’accident.'**
  String get accCheckPlace;

  /// No description provided for @accWitnessPhoneInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez un numéro valide pour le témoin.'**
  String get accWitnessPhoneInvalid;

  /// No description provided for @accMinPhotos.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez au moins 2 photos avant de continuer.'**
  String get accMinPhotos;

  /// No description provided for @accDriverBIncomplete.
  ///
  /// In fr, this message translates to:
  /// **'Complétez le nom, l’immatriculation et l’assurance du conducteur B.'**
  String get accDriverBIncomplete;

  /// No description provided for @accCircumstanceRequired.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionnez au moins une circonstance pour le véhicule A ou B.'**
  String get accCircumstanceRequired;

  /// No description provided for @accSketchRequired.
  ///
  /// In fr, this message translates to:
  /// **'Confirmez le croquis et une zone de choc.'**
  String get accSketchRequired;

  /// No description provided for @accSignaturesRequired.
  ///
  /// In fr, this message translates to:
  /// **'Les deux conducteurs doivent signer le constat.'**
  String get accSignaturesRequired;

  /// No description provided for @accLocalDraftSaved.
  ///
  /// In fr, this message translates to:
  /// **'Brouillon local • sauvegardé à {time}'**
  String accLocalDraftSaved(String time);

  /// No description provided for @accHandoverTitle.
  ///
  /// In fr, this message translates to:
  /// **'Passez le téléphone au conducteur B'**
  String get accHandoverTitle;

  /// No description provided for @accHandoverText.
  ///
  /// In fr, this message translates to:
  /// **'Il remplit lui-même son identité, son permis, son véhicule et son assurance.'**
  String get accHandoverText;

  /// No description provided for @accHandoverHidden.
  ///
  /// In fr, this message translates to:
  /// **'Vos informations restent masquées : le retour aux étapes précédentes est bloqué pendant sa saisie.'**
  String get accHandoverHidden;

  /// No description provided for @accHandoverScan.
  ///
  /// In fr, this message translates to:
  /// **'Il peut photographier son permis : l’IA remplit les champs.'**
  String get accHandoverScan;

  /// No description provided for @accHandoverReturn.
  ///
  /// In fr, this message translates to:
  /// **'À la fin, il vous rend le téléphone.'**
  String get accHandoverReturn;

  /// No description provided for @accChooseVehicle.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez votre véhicule : son assureur reçoit le constat.'**
  String get accChooseVehicle;

  /// No description provided for @accInsuranceExpired.
  ///
  /// In fr, this message translates to:
  /// **'Le contrat d’assurance de {vehicle} a expiré le {date}. Renouvelez-le dans Véhicules avant de déclarer.'**
  String accInsuranceExpired(String vehicle, String date);

  /// No description provided for @accYourVehicle.
  ///
  /// In fr, this message translates to:
  /// **'VOTRE VÉHICULE'**
  String get accYourVehicle;

  /// No description provided for @accAddVehicleHint.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez votre véhicule et son assureur : c’est à lui que le constat est transmis.'**
  String get accAddVehicleHint;

  /// No description provided for @accAddMyVehicle.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter mon véhicule'**
  String get accAddMyVehicle;

  /// No description provided for @accContractExpiredOn.
  ///
  /// In fr, this message translates to:
  /// **'Contrat expiré le {date}'**
  String accContractExpiredOn(String date);

  /// No description provided for @accInsurerMissing.
  ///
  /// In fr, this message translates to:
  /// **'Assureur non renseigné'**
  String get accInsurerMissing;

  /// No description provided for @accInsuredUntil.
  ///
  /// In fr, this message translates to:
  /// **'{insurer} · jusqu’au {date}'**
  String accInsuredUntil(String insurer, String date);

  /// No description provided for @accWhereWhen.
  ///
  /// In fr, this message translates to:
  /// **'Où et quand ?'**
  String get accWhereWhen;

  /// No description provided for @accWhereWhenHint.
  ///
  /// In fr, this message translates to:
  /// **'Vérifiez les informations détectées automatiquement.'**
  String get accWhereWhenHint;

  /// No description provided for @accPlaceRequired.
  ///
  /// In fr, this message translates to:
  /// **'Indiquez le lieu de l’accident'**
  String get accPlaceRequired;

  /// No description provided for @accAccidentPlace.
  ///
  /// In fr, this message translates to:
  /// **'Lieu de l’accident'**
  String get accAccidentPlace;

  /// No description provided for @accChooseOnMap.
  ///
  /// In fr, this message translates to:
  /// **'Choisir sur la carte'**
  String get accChooseOnMap;

  /// No description provided for @accGpsLine.
  ///
  /// In fr, this message translates to:
  /// **'GPS {coords} • précision ±{accuracy} m'**
  String accGpsLine(String coords, int accuracy);

  /// No description provided for @accDateTime.
  ///
  /// In fr, this message translates to:
  /// **'Date et heure'**
  String get accDateTime;

  /// No description provided for @accWeather.
  ///
  /// In fr, this message translates to:
  /// **'Météo'**
  String get accWeather;

  /// No description provided for @accRoad.
  ///
  /// In fr, this message translates to:
  /// **'Chaussée'**
  String get accRoad;

  /// No description provided for @accLight.
  ///
  /// In fr, this message translates to:
  /// **'Luminosité'**
  String get accLight;

  /// No description provided for @accPlaceConfirmed.
  ///
  /// In fr, this message translates to:
  /// **'Lieu de l’accident confirmé et sauvegardé.'**
  String get accPlaceConfirmed;

  /// No description provided for @accPositionUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Position indisponible. Réessayez dans un instant.'**
  String get accPositionUnavailable;

  /// No description provided for @accPositionDetected.
  ///
  /// In fr, this message translates to:
  /// **'Position détectée'**
  String get accPositionDetected;

  /// No description provided for @accUseDetectedQuestion.
  ///
  /// In fr, this message translates to:
  /// **'{place}\n\nVoulez-vous utiliser cette localisation ?'**
  String accUseDetectedQuestion(String place);

  /// No description provided for @accChooseAnother.
  ///
  /// In fr, this message translates to:
  /// **'Choisir une autre'**
  String get accChooseAnother;

  /// No description provided for @accUsePosition.
  ///
  /// In fr, this message translates to:
  /// **'Utiliser cette position'**
  String get accUsePosition;

  /// No description provided for @accAutoLocationFailed.
  ///
  /// In fr, this message translates to:
  /// **'Localisation automatique impossible.'**
  String get accAutoLocationFailed;

  /// No description provided for @accLocationDisabled.
  ///
  /// In fr, this message translates to:
  /// **'Activez la localisation GPS de l’appareil.'**
  String get accLocationDisabled;

  /// No description provided for @accLocationDenied.
  ///
  /// In fr, this message translates to:
  /// **'La permission de localisation a été refusée.'**
  String get accLocationDenied;

  /// No description provided for @accLocationDeniedForever.
  ///
  /// In fr, this message translates to:
  /// **'Autorisez la localisation dans les paramètres de l’application.'**
  String get accLocationDeniedForever;

  /// No description provided for @accAddressNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Adresse introuvable.'**
  String get accAddressNotFound;

  /// No description provided for @accValueSunny.
  ///
  /// In fr, this message translates to:
  /// **'Ensoleillé'**
  String get accValueSunny;

  /// No description provided for @accValueRain.
  ///
  /// In fr, this message translates to:
  /// **'Pluie'**
  String get accValueRain;

  /// No description provided for @accValueFog.
  ///
  /// In fr, this message translates to:
  /// **'Brouillard'**
  String get accValueFog;

  /// No description provided for @accValueDry.
  ///
  /// In fr, this message translates to:
  /// **'Sèche'**
  String get accValueDry;

  /// No description provided for @accValueWet.
  ///
  /// In fr, this message translates to:
  /// **'Mouillée'**
  String get accValueWet;

  /// No description provided for @accValueSlippery.
  ///
  /// In fr, this message translates to:
  /// **'Glissante'**
  String get accValueSlippery;

  /// No description provided for @accValueDay.
  ///
  /// In fr, this message translates to:
  /// **'Jour'**
  String get accValueDay;

  /// No description provided for @accValueDusk.
  ///
  /// In fr, this message translates to:
  /// **'Crépuscule'**
  String get accValueDusk;

  /// No description provided for @accValueNightLit.
  ///
  /// In fr, this message translates to:
  /// **'Nuit éclairée'**
  String get accValueNightLit;

  /// No description provided for @accValueNightDark.
  ///
  /// In fr, this message translates to:
  /// **'Nuit sombre'**
  String get accValueNightDark;

  /// No description provided for @accEvidenceOverview.
  ///
  /// In fr, this message translates to:
  /// **'Vue d’ensemble'**
  String get accEvidenceOverview;

  /// No description provided for @accEvidenceDamageA.
  ///
  /// In fr, this message translates to:
  /// **'Dégâts véhicule A'**
  String get accEvidenceDamageA;

  /// No description provided for @accEvidenceDamageB.
  ///
  /// In fr, this message translates to:
  /// **'Dégâts véhicule B'**
  String get accEvidenceDamageB;

  /// No description provided for @accEvidencePlates.
  ///
  /// In fr, this message translates to:
  /// **'Plaques'**
  String get accEvidencePlates;

  /// No description provided for @accWhatHappened.
  ///
  /// In fr, this message translates to:
  /// **'Que s’est-il passé ?'**
  String get accWhatHappened;

  /// No description provided for @accWhatHappenedHint.
  ///
  /// In fr, this message translates to:
  /// **'Ces informations permettent de prioriser votre dossier.'**
  String get accWhatHappenedHint;

  /// No description provided for @accAccidentType.
  ///
  /// In fr, this message translates to:
  /// **'Type d\'accident'**
  String get accAccidentType;

  /// No description provided for @accSeverity.
  ///
  /// In fr, this message translates to:
  /// **'Gravité'**
  String get accSeverity;

  /// No description provided for @accVehicles.
  ///
  /// In fr, this message translates to:
  /// **'Véhicules'**
  String get accVehicles;

  /// No description provided for @accInjured.
  ///
  /// In fr, this message translates to:
  /// **'Blessés'**
  String get accInjured;

  /// No description provided for @accSecureArea.
  ///
  /// In fr, this message translates to:
  /// **'Sécurisez la zone et appelez les secours'**
  String get accSecureArea;

  /// No description provided for @accSamu.
  ///
  /// In fr, this message translates to:
  /// **'SAMU'**
  String get accSamu;

  /// No description provided for @accPolice.
  ///
  /// In fr, this message translates to:
  /// **'Police'**
  String get accPolice;

  /// No description provided for @accCivilProtection.
  ///
  /// In fr, this message translates to:
  /// **'Protection civile'**
  String get accCivilProtection;

  /// No description provided for @accCalling.
  ///
  /// In fr, this message translates to:
  /// **'Appel du {number}'**
  String accCalling(String number);

  /// No description provided for @accWitnessOptional.
  ///
  /// In fr, this message translates to:
  /// **'Témoin (optionnel)'**
  String get accWitnessOptional;

  /// No description provided for @accWitnessName.
  ///
  /// In fr, this message translates to:
  /// **'Nom du témoin'**
  String get accWitnessName;

  /// No description provided for @accPhone.
  ///
  /// In fr, this message translates to:
  /// **'Téléphone'**
  String get accPhone;

  /// No description provided for @accGuidedPhotos.
  ///
  /// In fr, this message translates to:
  /// **'Photos guidées'**
  String get accGuidedPhotos;

  /// No description provided for @accPhotosProgress.
  ///
  /// In fr, this message translates to:
  /// **'{count}/4 vues ajoutées • 2 minimum requises'**
  String accPhotosProgress(int count);

  /// No description provided for @accPhotoSaved.
  ///
  /// In fr, this message translates to:
  /// **'Photo enregistrée • touchez pour reprendre'**
  String get accPhotoSaved;

  /// No description provided for @accTapToOpenCamera.
  ///
  /// In fr, this message translates to:
  /// **'Touchez pour ouvrir la caméra'**
  String get accTapToOpenCamera;

  /// No description provided for @accSceneVideo.
  ///
  /// In fr, this message translates to:
  /// **'Vidéo de la scène'**
  String get accSceneVideo;

  /// No description provided for @accOpeningCamera.
  ///
  /// In fr, this message translates to:
  /// **'Ouverture de la caméra…'**
  String get accOpeningCamera;

  /// No description provided for @accVideoSaved.
  ///
  /// In fr, this message translates to:
  /// **'Vidéo enregistrée • touchez pour la lire'**
  String get accVideoSaved;

  /// No description provided for @accFilmScene.
  ///
  /// In fr, this message translates to:
  /// **'Filmez la scène • 30 secondes maximum'**
  String get accFilmScene;

  /// No description provided for @accStopRecording.
  ///
  /// In fr, this message translates to:
  /// **'Arrêter l’enregistrement'**
  String get accStopRecording;

  /// No description provided for @accVoiceNote.
  ///
  /// In fr, this message translates to:
  /// **'Note vocale'**
  String get accVoiceNote;

  /// No description provided for @accRecordingInProgress.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrement en cours… touchez pour arrêter'**
  String get accRecordingInProgress;

  /// No description provided for @accVoiceNoteSaved.
  ///
  /// In fr, this message translates to:
  /// **'Note enregistrée • touchez pour écouter'**
  String get accVoiceNoteSaved;

  /// No description provided for @accDescribeByVoice.
  ///
  /// In fr, this message translates to:
  /// **'Décrivez la scène avec votre voix'**
  String get accDescribeByVoice;

  /// No description provided for @accVideoSaveFailed.
  ///
  /// In fr, this message translates to:
  /// **'Impossible d’enregistrer la vidéo.'**
  String get accVideoSaveFailed;

  /// No description provided for @accMicPermission.
  ///
  /// In fr, this message translates to:
  /// **'Autorisez le microphone pour enregistrer une note vocale.'**
  String get accMicPermission;

  /// No description provided for @accMicFailed.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de démarrer le microphone.'**
  String get accMicFailed;

  /// No description provided for @accVideoMissing.
  ///
  /// In fr, this message translates to:
  /// **'La vidéo n’existe plus. Vous pouvez la reprendre.'**
  String get accVideoMissing;

  /// No description provided for @accVoiceNoteMissing.
  ///
  /// In fr, this message translates to:
  /// **'La note vocale n’existe plus. Vous pouvez la refaire.'**
  String get accVoiceNoteMissing;

  /// No description provided for @accListen.
  ///
  /// In fr, this message translates to:
  /// **'Écouter'**
  String get accListen;

  /// No description provided for @accRedoRecording.
  ///
  /// In fr, this message translates to:
  /// **'Refaire l’enregistrement'**
  String get accRedoRecording;

  /// No description provided for @accDelete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get accDelete;

  /// No description provided for @accPause.
  ///
  /// In fr, this message translates to:
  /// **'Pause'**
  String get accPause;

  /// No description provided for @accPlay.
  ///
  /// In fr, this message translates to:
  /// **'Lire'**
  String get accPlay;

  /// No description provided for @accSummary.
  ///
  /// In fr, this message translates to:
  /// **'RÉCAPITULATIF'**
  String get accSummary;

  /// No description provided for @accSummaryCounts.
  ///
  /// In fr, this message translates to:
  /// **'{vehicles} véhicule(s) • {injured} blessé(s) • {photos} photo(s)'**
  String accSummaryCounts(int vehicles, int injured, int photos);

  /// No description provided for @accReportCompleted.
  ///
  /// In fr, this message translates to:
  /// **'Constat complété'**
  String get accReportCompleted;

  /// No description provided for @accReviewHint.
  ///
  /// In fr, this message translates to:
  /// **'Vérifiez toutes les informations avant la transmission.'**
  String get accReviewHint;

  /// No description provided for @accSectionAccident.
  ///
  /// In fr, this message translates to:
  /// **'Accident'**
  String get accSectionAccident;

  /// No description provided for @accPlace.
  ///
  /// In fr, this message translates to:
  /// **'Lieu'**
  String get accPlace;

  /// No description provided for @accType.
  ///
  /// In fr, this message translates to:
  /// **'Type'**
  String get accType;

  /// No description provided for @accConditions.
  ///
  /// In fr, this message translates to:
  /// **'Conditions'**
  String get accConditions;

  /// No description provided for @accVehiclesInjured.
  ///
  /// In fr, this message translates to:
  /// **'Véhicules / blessés'**
  String get accVehiclesInjured;

  /// No description provided for @accVehiclesInjuredValue.
  ///
  /// In fr, this message translates to:
  /// **'{vehicles} véhicule(s) • {injured} blessé(s)'**
  String accVehiclesInjuredValue(int vehicles, int injured);

  /// No description provided for @accWitness.
  ///
  /// In fr, this message translates to:
  /// **'Témoin'**
  String get accWitness;

  /// No description provided for @accSectionDriverA.
  ///
  /// In fr, this message translates to:
  /// **'Conducteur & Véhicule A'**
  String get accSectionDriverA;

  /// No description provided for @accName.
  ///
  /// In fr, this message translates to:
  /// **'Nom'**
  String get accName;

  /// No description provided for @accLicense.
  ///
  /// In fr, this message translates to:
  /// **'Permis'**
  String get accLicense;

  /// No description provided for @accVehicle.
  ///
  /// In fr, this message translates to:
  /// **'Véhicule'**
  String get accVehicle;

  /// No description provided for @accPlate.
  ///
  /// In fr, this message translates to:
  /// **'Immatriculation'**
  String get accPlate;

  /// No description provided for @accInsurance.
  ///
  /// In fr, this message translates to:
  /// **'Assurance'**
  String get accInsurance;

  /// No description provided for @accPolicyNumber.
  ///
  /// In fr, this message translates to:
  /// **'N° de police'**
  String get accPolicyNumber;

  /// No description provided for @accLicenseExpiry.
  ///
  /// In fr, this message translates to:
  /// **'Validité du permis'**
  String get accLicenseExpiry;

  /// No description provided for @accObservations.
  ///
  /// In fr, this message translates to:
  /// **'Observations'**
  String get accObservations;

  /// No description provided for @accImpactZones.
  ///
  /// In fr, this message translates to:
  /// **'Zones de choc'**
  String get accImpactZones;

  /// No description provided for @accPhotos.
  ///
  /// In fr, this message translates to:
  /// **'Photos'**
  String get accPhotos;

  /// No description provided for @accSketchMissing.
  ///
  /// In fr, this message translates to:
  /// **'Croquis manquant'**
  String get accSketchMissing;

  /// No description provided for @accPdfFailed.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de générer le PDF. Réessayez.'**
  String get accPdfFailed;

  /// No description provided for @accPdfTitle.
  ///
  /// In fr, this message translates to:
  /// **'Constat PDF'**
  String get accPdfTitle;

  /// No description provided for @accPdfHint.
  ///
  /// In fr, this message translates to:
  /// **'Le document reprend les informations officielles, photos, croquis et signatures.'**
  String get accPdfHint;

  /// No description provided for @accPreview.
  ///
  /// In fr, this message translates to:
  /// **'Aperçu'**
  String get accPreview;

  /// No description provided for @accShare.
  ///
  /// In fr, this message translates to:
  /// **'Partager'**
  String get accShare;

  /// No description provided for @accNotProvided.
  ///
  /// In fr, this message translates to:
  /// **'Non renseigné'**
  String get accNotProvided;

  /// No description provided for @accNoPhotos.
  ///
  /// In fr, this message translates to:
  /// **'Aucune photo enregistrée.'**
  String get accNoPhotos;

  /// No description provided for @accMyDeclarations.
  ///
  /// In fr, this message translates to:
  /// **'Mes déclarations'**
  String get accMyDeclarations;

  /// No description provided for @accMyDeclarationsHint.
  ///
  /// In fr, this message translates to:
  /// **'Brouillons et dossiers transmis'**
  String get accMyDeclarationsHint;

  /// No description provided for @accDraftInProgress.
  ///
  /// In fr, this message translates to:
  /// **'BROUILLON EN COURS'**
  String get accDraftInProgress;

  /// No description provided for @accResume.
  ///
  /// In fr, this message translates to:
  /// **'Reprendre'**
  String get accResume;

  /// No description provided for @accSentDeclarations.
  ///
  /// In fr, this message translates to:
  /// **'DÉCLARATIONS TRANSMISES'**
  String get accSentDeclarations;

  /// No description provided for @accNoSentDeclarations.
  ///
  /// In fr, this message translates to:
  /// **'Aucune déclaration transmise.'**
  String get accNoSentDeclarations;

  /// No description provided for @accDeleteDraftTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer le brouillon ?'**
  String get accDeleteDraftTitle;

  /// No description provided for @accDeleteDraftText.
  ///
  /// In fr, this message translates to:
  /// **'Les informations non transmises seront perdues.'**
  String get accDeleteDraftText;

  /// No description provided for @accCancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get accCancel;

  /// No description provided for @accEmergencyNumbers.
  ///
  /// In fr, this message translates to:
  /// **'Numéros d’urgence'**
  String get accEmergencyNumbers;

  /// No description provided for @accSearchAddress.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher une adresse'**
  String get accSearchAddress;

  /// No description provided for @accSearch.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher'**
  String get accSearch;

  /// No description provided for @accMyPosition.
  ///
  /// In fr, this message translates to:
  /// **'Ma position'**
  String get accMyPosition;

  /// No description provided for @accSelectedPlace.
  ///
  /// In fr, this message translates to:
  /// **'LIEU SÉLECTIONNÉ'**
  String get accSelectedPlace;

  /// No description provided for @accConfirmPlace.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer ce lieu'**
  String get accConfirmPlace;

  /// No description provided for @accMinChars.
  ///
  /// In fr, this message translates to:
  /// **'Saisissez au moins 3 caractères.'**
  String get accMinChars;

  /// No description provided for @accPlaceFetchFailed.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de récupérer ce lieu.'**
  String get accPlaceFetchFailed;

  /// No description provided for @cstNotProvided.
  ///
  /// In fr, this message translates to:
  /// **'Non renseigné'**
  String get cstNotProvided;

  /// No description provided for @cstClear.
  ///
  /// In fr, this message translates to:
  /// **'Effacer'**
  String get cstClear;

  /// No description provided for @cstEdit.
  ///
  /// In fr, this message translates to:
  /// **'Modifier'**
  String get cstEdit;

  /// No description provided for @cstTapToDrawFullscreen.
  ///
  /// In fr, this message translates to:
  /// **'Touchez pour dessiner en plein écran'**
  String get cstTapToDrawFullscreen;

  /// No description provided for @cstCloseWithoutSaving.
  ///
  /// In fr, this message translates to:
  /// **'Fermer sans enregistrer'**
  String get cstCloseWithoutSaving;

  /// No description provided for @cstUndoLastStroke.
  ///
  /// In fr, this message translates to:
  /// **'Annuler le dernier trait'**
  String get cstUndoLastStroke;

  /// No description provided for @cstClearAll.
  ///
  /// In fr, this message translates to:
  /// **'Tout effacer'**
  String get cstClearAll;

  /// No description provided for @cstDone.
  ///
  /// In fr, this message translates to:
  /// **'Terminé'**
  String get cstDone;

  /// No description provided for @cstSignHint.
  ///
  /// In fr, this message translates to:
  /// **'Signez avec votre doigt ou le curseur'**
  String get cstSignHint;

  /// No description provided for @cstGuestModeTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mode invité — Conducteur B'**
  String get cstGuestModeTitle;

  /// No description provided for @cstShareWithDriverB.
  ///
  /// In fr, this message translates to:
  /// **'Partage avec le conducteur B'**
  String get cstShareWithDriverB;

  /// No description provided for @cstGuestQrInstructions.
  ///
  /// In fr, this message translates to:
  /// **'Faites scanner ce QR code au conducteur B avec son smartphone pour qu’il vérifie ses informations et suive la déclaration en direct.'**
  String get cstGuestQrInstructions;

  /// No description provided for @cstNoInstallRequired.
  ///
  /// In fr, this message translates to:
  /// **'Aucune installation d’application requise pour le conducteur B.'**
  String get cstNoInstallRequired;

  /// No description provided for @cstGuestLinkCopied.
  ///
  /// In fr, this message translates to:
  /// **'Lien invité copié dans le presse-papier !'**
  String get cstGuestLinkCopied;

  /// No description provided for @cstCopyGuestLink.
  ///
  /// In fr, this message translates to:
  /// **'Copier le lien d’accès invité'**
  String get cstCopyGuestLink;

  /// No description provided for @cstContinueOnThisDevice.
  ///
  /// In fr, this message translates to:
  /// **'Continuer la saisie sur cet appareil'**
  String get cstContinueOnThisDevice;

  /// No description provided for @cstSealedTitle.
  ///
  /// In fr, this message translates to:
  /// **'Constat scellé'**
  String get cstSealedTitle;

  /// No description provided for @cstSealedOnPhone.
  ///
  /// In fr, this message translates to:
  /// **'Constat scellé sur le téléphone'**
  String get cstSealedOnPhone;

  /// No description provided for @cstSealedAndSent.
  ///
  /// In fr, this message translates to:
  /// **'Constat scellé et transmis'**
  String get cstSealedAndSent;

  /// No description provided for @cstSealedOfflineHint.
  ///
  /// In fr, this message translates to:
  /// **'Pas de réseau : il sera transmis et signé par le serveur dès le retour de la connexion.'**
  String get cstSealedOfflineHint;

  /// No description provided for @cstSealedOnlineHint.
  ///
  /// In fr, this message translates to:
  /// **'Document officiel inaltérable signé bilatéralement.'**
  String get cstSealedOnlineHint;

  /// No description provided for @cstOfflineCertification.
  ///
  /// In fr, this message translates to:
  /// **'CERTIFICATION HORS-LIGNE (JWS)'**
  String get cstOfflineCertification;

  /// No description provided for @cstScanQrToVerify.
  ///
  /// In fr, this message translates to:
  /// **'Scannez ce QR Code pour certifier l’authenticité et l’intégrité du constat sans connexion au serveur.'**
  String get cstScanQrToVerify;

  /// No description provided for @cstCertifiedQr.
  ///
  /// In fr, this message translates to:
  /// **'QR Code Certifié'**
  String get cstCertifiedQr;

  /// No description provided for @cstEcdsaCertified.
  ///
  /// In fr, this message translates to:
  /// **'Signature ECDSA P-256 certifiée — Zero-Dependency Verification'**
  String get cstEcdsaCertified;

  /// No description provided for @cstVehicleA.
  ///
  /// In fr, this message translates to:
  /// **'Véhicule A'**
  String get cstVehicleA;

  /// No description provided for @cstVehicleB.
  ///
  /// In fr, this message translates to:
  /// **'Véhicule B'**
  String get cstVehicleB;

  /// No description provided for @cstDriverA.
  ///
  /// In fr, this message translates to:
  /// **'Conducteur A'**
  String get cstDriverA;

  /// No description provided for @cstDriverB.
  ///
  /// In fr, this message translates to:
  /// **'Conducteur B'**
  String get cstDriverB;

  /// No description provided for @cstPlateA.
  ///
  /// In fr, this message translates to:
  /// **'Immatriculation A'**
  String get cstPlateA;

  /// No description provided for @cstPlateB.
  ///
  /// In fr, this message translates to:
  /// **'Immatriculation B'**
  String get cstPlateB;

  /// No description provided for @cstInsurerA.
  ///
  /// In fr, this message translates to:
  /// **'Assurance A'**
  String get cstInsurerA;

  /// No description provided for @cstInsurerB.
  ///
  /// In fr, this message translates to:
  /// **'Assurance B'**
  String get cstInsurerB;

  /// No description provided for @cstPolicyLine.
  ///
  /// In fr, this message translates to:
  /// **'Police : {policy}'**
  String cstPolicyLine(String policy);

  /// No description provided for @cstViewOfficialPdf.
  ///
  /// In fr, this message translates to:
  /// **'Consulter l’exemplaire officiel (PDF)'**
  String get cstViewOfficialPdf;

  /// No description provided for @cstShareSealed.
  ///
  /// In fr, this message translates to:
  /// **'Partager le constat scellé'**
  String get cstShareSealed;

  /// No description provided for @cstBackToHome.
  ///
  /// In fr, this message translates to:
  /// **'Retour à l’accueil'**
  String get cstBackToHome;

  /// No description provided for @cstPdfPreviewError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur aperçu PDF : {error}'**
  String cstPdfPreviewError(String error);

  /// No description provided for @cstPdfShareError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur partage PDF : {error}'**
  String cstPdfShareError(String error);

  /// No description provided for @cstDriverBTitle.
  ///
  /// In fr, this message translates to:
  /// **'Informations du conducteur B'**
  String get cstDriverBTitle;

  /// No description provided for @cstDriverBSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Données nécessaires au constat, isolées de votre profil.'**
  String get cstDriverBSubtitle;

  /// No description provided for @cstScanLicenseAi.
  ///
  /// In fr, this message translates to:
  /// **'Scanner le permis avec l’IA'**
  String get cstScanLicenseAi;

  /// No description provided for @cstScanLicenseHint.
  ///
  /// In fr, this message translates to:
  /// **'La photo est analysée localement. Vérifiez toujours les données détectées.'**
  String get cstScanLicenseHint;

  /// No description provided for @cstScanning.
  ///
  /// In fr, this message translates to:
  /// **'Analyse en cours…'**
  String get cstScanning;

  /// No description provided for @cstTakeLicensePhoto.
  ///
  /// In fr, this message translates to:
  /// **'Photographier le permis'**
  String get cstTakeLicensePhoto;

  /// No description provided for @cstFullNameRequired.
  ///
  /// In fr, this message translates to:
  /// **'Nom complet *'**
  String get cstFullNameRequired;

  /// No description provided for @cstLicenseNumber.
  ///
  /// In fr, this message translates to:
  /// **'Numéro de permis'**
  String get cstLicenseNumber;

  /// No description provided for @cstLicenseExpiry.
  ///
  /// In fr, this message translates to:
  /// **'Date de validité du permis'**
  String get cstLicenseExpiry;

  /// No description provided for @cstPlateRequired.
  ///
  /// In fr, this message translates to:
  /// **'Immatriculation *'**
  String get cstPlateRequired;

  /// No description provided for @cstInsuranceSection.
  ///
  /// In fr, this message translates to:
  /// **'ASSURANCE'**
  String get cstInsuranceSection;

  /// No description provided for @cstPolicyNumber.
  ///
  /// In fr, this message translates to:
  /// **'N° de police / attestation d’assurance'**
  String get cstPolicyNumber;

  /// No description provided for @cstNoTextDetected.
  ///
  /// In fr, this message translates to:
  /// **'Aucun texte détecté. Reprenez la photo avec plus de lumière.'**
  String get cstNoTextDetected;

  /// No description provided for @cstLicenseScanned.
  ///
  /// In fr, this message translates to:
  /// **'Permis analysé. Vérifiez les champs avant de continuer.'**
  String get cstLicenseScanned;

  /// No description provided for @cstScanFailed.
  ///
  /// In fr, this message translates to:
  /// **'Analyse impossible. Vérifiez la photo et réessayez.'**
  String get cstScanFailed;

  /// No description provided for @cstReviewDetectedData.
  ///
  /// In fr, this message translates to:
  /// **'Vérifier les données détectées'**
  String get cstReviewDetectedData;

  /// No description provided for @cstOcrWarning.
  ///
  /// In fr, this message translates to:
  /// **'L’OCR peut faire des erreurs. Corrigez les champs avant confirmation.'**
  String get cstOcrWarning;

  /// No description provided for @cstFullName.
  ///
  /// In fr, this message translates to:
  /// **'Nom complet'**
  String get cstFullName;

  /// No description provided for @cstLicenseNumberDialog.
  ///
  /// In fr, this message translates to:
  /// **'Numéro du permis'**
  String get cstLicenseNumberDialog;

  /// No description provided for @cstExpiryDate.
  ///
  /// In fr, this message translates to:
  /// **'Date de validité'**
  String get cstExpiryDate;

  /// No description provided for @cstRecognizedText.
  ///
  /// In fr, this message translates to:
  /// **'Texte reconnu par ML Kit'**
  String get cstRecognizedText;

  /// No description provided for @cstCancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get cstCancel;

  /// No description provided for @cstUseThisData.
  ///
  /// In fr, this message translates to:
  /// **'Utiliser ces données'**
  String get cstUseThisData;

  /// No description provided for @cstClearDate.
  ///
  /// In fr, this message translates to:
  /// **'Effacer la date'**
  String get cstClearDate;

  /// No description provided for @cstCircumstancesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Circonstances de l’accident (FTUSA)'**
  String get cstCircumstancesTitle;

  /// No description provided for @cstCircumstancesHint.
  ///
  /// In fr, this message translates to:
  /// **'Cochez la ou les cases utiles pour le véhicule A (bleu) et le véhicule B (ambre).'**
  String get cstCircumstancesHint;

  /// No description provided for @cstBoxesA.
  ///
  /// In fr, this message translates to:
  /// **'Véhicule A : {count} case(s)'**
  String cstBoxesA(int count);

  /// No description provided for @cstBoxesB.
  ///
  /// In fr, this message translates to:
  /// **'Véhicule B : {count} case(s)'**
  String cstBoxesB(int count);

  /// No description provided for @cstCircumstancesHeader.
  ///
  /// In fr, this message translates to:
  /// **'12. Circonstances'**
  String get cstCircumstancesHeader;

  /// No description provided for @cstCircumstance1.
  ///
  /// In fr, this message translates to:
  /// **'En stationnement / À l’arrêt'**
  String get cstCircumstance1;

  /// No description provided for @cstCircumstance2.
  ///
  /// In fr, this message translates to:
  /// **'Quittait un stationnement / ouvrait une portière'**
  String get cstCircumstance2;

  /// No description provided for @cstCircumstance3.
  ///
  /// In fr, this message translates to:
  /// **'Prenait un stationnement'**
  String get cstCircumstance3;

  /// No description provided for @cstCircumstance4.
  ///
  /// In fr, this message translates to:
  /// **'Sortait d’un parking, lieu privé ou chemin'**
  String get cstCircumstance4;

  /// No description provided for @cstCircumstance5.
  ///
  /// In fr, this message translates to:
  /// **'S’engageait dans un parking, lieu privé ou chemin'**
  String get cstCircumstance5;

  /// No description provided for @cstCircumstance6.
  ///
  /// In fr, this message translates to:
  /// **'S’engageait sur une place à sens giratoire'**
  String get cstCircumstance6;

  /// No description provided for @cstCircumstance7.
  ///
  /// In fr, this message translates to:
  /// **'Circulait sur une place à sens giratoire'**
  String get cstCircumstance7;

  /// No description provided for @cstCircumstance8.
  ///
  /// In fr, this message translates to:
  /// **'Heurtait à l’arrière (même sens, même file)'**
  String get cstCircumstance8;

  /// No description provided for @cstCircumstance9.
  ///
  /// In fr, this message translates to:
  /// **'Roulait dans le même sens sur une file différente'**
  String get cstCircumstance9;

  /// No description provided for @cstCircumstance10.
  ///
  /// In fr, this message translates to:
  /// **'Changeait de file'**
  String get cstCircumstance10;

  /// No description provided for @cstCircumstance11.
  ///
  /// In fr, this message translates to:
  /// **'Doublait'**
  String get cstCircumstance11;

  /// No description provided for @cstCircumstance12.
  ///
  /// In fr, this message translates to:
  /// **'Virait à droite'**
  String get cstCircumstance12;

  /// No description provided for @cstCircumstance13.
  ///
  /// In fr, this message translates to:
  /// **'Virait à gauche'**
  String get cstCircumstance13;

  /// No description provided for @cstCircumstance14.
  ///
  /// In fr, this message translates to:
  /// **'Reculait'**
  String get cstCircumstance14;

  /// No description provided for @cstCircumstance15.
  ///
  /// In fr, this message translates to:
  /// **'Empiétait sur la chaussée en sens inverse'**
  String get cstCircumstance15;

  /// No description provided for @cstCircumstance16.
  ///
  /// In fr, this message translates to:
  /// **'Venait de droite (dans un carrefour)'**
  String get cstCircumstance16;

  /// No description provided for @cstCircumstance17.
  ///
  /// In fr, this message translates to:
  /// **'N’avait pas observé un signal de priorité'**
  String get cstCircumstance17;

  /// No description provided for @cstObservations.
  ///
  /// In fr, this message translates to:
  /// **'Observations complémentaires'**
  String get cstObservations;

  /// No description provided for @cstSketchTitle.
  ///
  /// In fr, this message translates to:
  /// **'Croquis et point de choc'**
  String get cstSketchTitle;

  /// No description provided for @cstSketchFieldTitle.
  ///
  /// In fr, this message translates to:
  /// **'Croquis de l’accident'**
  String get cstSketchFieldTitle;

  /// No description provided for @cstSketchHint.
  ///
  /// In fr, this message translates to:
  /// **'Dessinez les voies, les véhicules et leur direction'**
  String get cstSketchHint;

  /// No description provided for @cstImpactZoneTitle.
  ///
  /// In fr, this message translates to:
  /// **'Zone de choc sur votre véhicule'**
  String get cstImpactZoneTitle;

  /// No description provided for @cstSignInstructions.
  ///
  /// In fr, this message translates to:
  /// **'Relisez les informations puis signez dans les deux zones.'**
  String get cstSignInstructions;

  /// No description provided for @cstSignatureA.
  ///
  /// In fr, this message translates to:
  /// **'Signature conducteur A'**
  String get cstSignatureA;

  /// No description provided for @cstSignatureB.
  ///
  /// In fr, this message translates to:
  /// **'Signature conducteur B'**
  String get cstSignatureB;

  /// No description provided for @cstShaLock.
  ///
  /// In fr, this message translates to:
  /// **'Verrouillage SHA-256'**
  String get cstShaLock;

  /// No description provided for @cstShaLockHint.
  ///
  /// In fr, this message translates to:
  /// **'Le constat sera rendu infalsifiable après la double signature.'**
  String get cstShaLockHint;

  /// No description provided for @nameLockedNotice.
  ///
  /// In fr, this message translates to:
  /// **'Nom vérifié sur votre pièce d’identité : il ne peut plus être modifié.'**
  String get nameLockedNotice;
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
