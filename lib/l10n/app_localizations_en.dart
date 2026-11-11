// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get claimsMyClaims => 'My claims';

  @override
  String get claimsReceived => 'Received claims';

  @override
  String claimsCount(String shown, String total) {
    return '$shown of $total claims';
  }

  @override
  String get claimsFilterHint => 'Filter by number, status or severity';

  @override
  String get claimsStatus => 'Status';

  @override
  String get claimsSeverity => 'Severity';

  @override
  String get claimsDate => 'Date';

  @override
  String claimsAllOf(String label) {
    return 'All: $label';
  }

  @override
  String get claimsNoMatch => 'No claim matches.';

  @override
  String get claimsAgentSpace => 'Agent workspace';

  @override
  String get claimsAgentSubtitle => 'Claims handling';

  @override
  String get claimsStatistics => 'Statistics';

  @override
  String get claimsNotifications => 'Notifications';

  @override
  String get claimsToHandle => 'To handle';

  @override
  String get claimsExpertises => 'Expert assessments';

  @override
  String get claimsClosedCount => 'Closed';

  @override
  String get claimsPriority => 'Priority claims';

  @override
  String get claimsNothingToHandle => 'No claim to handle.';

  @override
  String get claimsAssistant => 'Assistant';

  @override
  String get claimsMessaging => 'Messages';

  @override
  String get claimsRequestedDocuments => 'Requested documents';

  @override
  String get claimsUpload => 'Upload';

  @override
  String get claimsExpertiseTitle => 'Expert assessment';

  @override
  String claimsAppointmentOn(String date) {
    return 'Appointment on $date';
  }

  @override
  String get claimsTimeline => 'Timeline';

  @override
  String get claimsConstat => 'Accident report';

  @override
  String get claimsDocuments => 'Claim documents';

  @override
  String get claimsDownload => 'Download';

  @override
  String get claimsNoDocument => 'No document uploaded.';

  @override
  String get claimsUploadDocument => 'Upload a document';

  @override
  String get claimsHandling => 'Handling';

  @override
  String get claimsDocMismatch => 'Does not match the request.';

  @override
  String get claimsRejectedTitle => 'Claim rejected';

  @override
  String get claimsClosedTitle => 'Claim closed';

  @override
  String claimsReason(String reason) {
    return 'Reason: $reason';
  }

  @override
  String claimsResponsibilitySplit(String a, String b) {
    return 'Responsibility: A $a %, B $b %';
  }

  @override
  String claimsIndemnity(String amount) {
    return 'Compensation: $amount TND';
  }

  @override
  String get claimsCircumstances => 'Circumstances';

  @override
  String get claimsImpactPoint => 'Impact point';

  @override
  String get claimsObservations => 'Observations';

  @override
  String get claimsNoConstat => 'No accident report information.';

  @override
  String claimsLabelColon(String label) {
    return '$label: ';
  }

  @override
  String get claimsTakeCharge => 'Take on';

  @override
  String get claimsRequestDocument => 'Request a document';

  @override
  String get claimsMoveAppointment => 'Reschedule the appointment';

  @override
  String get claimsAppointExpert => 'Appoint an expert';

  @override
  String get claimsAttachReport => 'Attach the expert report';

  @override
  String get claimsReject => 'Reject the claim';

  @override
  String get claimsDocument => 'Document';

  @override
  String get claimsDetail => 'Details';

  @override
  String get claimsSendRequest => 'Send the request';

  @override
  String get claimsExpert => 'Expert';

  @override
  String get claimsSchedule => 'Schedule';

  @override
  String get claimsReasonLabel => 'Reason';

  @override
  String get claimsRejectAction => 'Reject';

  @override
  String get claimsInvalidAmount => 'Enter a valid amount.';

  @override
  String get claimsDecision => 'Decision';

  @override
  String claimsProposal(String a, String b, String reason) {
    return 'Proposal: A $a %, B $b %. $reason';
  }

  @override
  String get claimsIndemnityAmount => 'Compensation amount (TND)';

  @override
  String get claimsCloseClaim => 'Close the claim';

  @override
  String claimsProposalFault(String box) {
    return '$box: risky manoeuvre by A.';
  }

  @override
  String get claimsProposalParked => 'A was parked.';

  @override
  String claimsProposalTurn(String box) {
    return '$box: shared by default.';
  }

  @override
  String get claimsProposalUnknown =>
      'Not enough boxes ticked: shared by default.';

  @override
  String get claimsSummaryOffline => 'Summary unavailable offline.';

  @override
  String get claimsDecisionHelp => 'Decision support';

  @override
  String claimsOverdue(String days) {
    return '$days d overdue';
  }

  @override
  String get claimsEstimate => 'Estimate';

  @override
  String claimsRange(String low, String high) {
    return '$low to $high TND';
  }

  @override
  String get claimsUsualDuration => 'Usual duration';

  @override
  String claimsDays(String days) {
    return '$days days';
  }

  @override
  String get claimsRejectionRisk => 'Rejection risk';

  @override
  String get claimsRiskLow => 'low';

  @override
  String get claimsRiskMedium => 'medium';

  @override
  String get claimsRiskHigh => 'high';

  @override
  String claimsRiskWithFactors(String level, String factors) {
    return '$level: $factors';
  }

  @override
  String get claimsRecommended => 'Recommended for this claim';

  @override
  String get claimsToCheck => 'To check';

  @override
  String get claimsMissingDocuments => 'Missing documents';

  @override
  String get claimsRequest => 'Request';

  @override
  String get claimsSimilar => 'Similar claims';

  @override
  String claimsSummaryBy(String by) {
    return 'Summary written by $by';
  }

  @override
  String get claimsSummaryRules => 'Automatic summary, without generative AI';

  @override
  String get claimsSummarizing => 'Summarising';

  @override
  String get claimsSummarize => 'Summarise the claim';

  @override
  String get claimsModelDisclaimer =>
      'Estimates come from a model trained on simulated data. The agent makes the decision.';

  @override
  String get claimsDriverIdea1 => 'Where is my claim at?';

  @override
  String get claimsDriverIdea2 => 'Which documents should I upload?';

  @override
  String get claimsDriverIdea3 => 'How long will it take?';

  @override
  String get claimsAgentIdea1 => 'What should I do next?';

  @override
  String get claimsAgentIdea2 => 'What should I check?';

  @override
  String get claimsAgentIdea3 => 'What responsibility do you suggest?';

  @override
  String get claimsAssistantUnavailable =>
      'Assistant unavailable right now. Try again later.';

  @override
  String claimsAssistantTitle(String id) {
    return 'Assistant $id';
  }

  @override
  String get claimsAssistantIntro =>
      'Ask a question about this claim. The assistant informs; it makes no decision.';

  @override
  String get claimsAssistantReading => 'The assistant is reading the claim…';

  @override
  String get claimsYourQuestion => 'Your question';

  @override
  String get claimsSend => 'Send';

  @override
  String get claimsAutomaticAnswer => 'Automatic answer';

  @override
  String get claimsStatsServerOnly => 'Statistics available with the server.';

  @override
  String get claimsTotal => 'Claims';

  @override
  String get claimsLate => 'Overdue';

  @override
  String get claimsAverageDuration => 'Average duration';

  @override
  String claimsDaysShort(String days) {
    return '$days d';
  }

  @override
  String get claimsIndemnified => 'Compensated (TND)';

  @override
  String get claimsByStatus => 'Claims by status';

  @override
  String get claimsSystemVsAgents => 'The system vs. the agents';

  @override
  String get claimsNoDecisionYet => 'No decision to compare yet.';

  @override
  String claimsAgreement(String count, String percent) {
    return 'Out of $count decision(s), the proposed responsibility was kept in $percent % of cases.';
  }

  @override
  String claimsAverageGap(String gap) {
    return 'Average gap with the decided amount: $gap TND.';
  }

  @override
  String get claimsModel => 'Model';

  @override
  String claimsModelVersion(String version) {
    return 'Version $version';
  }

  @override
  String claimsTrainedOn(String synthetic, String real) {
    return 'Trained on $synthetic simulated cases and $real real claims.';
  }

  @override
  String claimsModelTest(String mae, String auc) {
    return 'Test: mean error $mae TND, rejection AUC $auc.';
  }

  @override
  String get claimsSimulatedWarning =>
      'These measures use simulated data: they do not yet tell whether the model is right on real claims.';

  @override
  String get claimsSuggestionsUnavailable => 'Suggestions unavailable.';

  @override
  String get claimsNoMessages => 'No messages on this claim.';

  @override
  String get claimsSuggestReply => 'Suggest a reply';

  @override
  String get claimsAttachFile => 'Attach a file';

  @override
  String get claimsYourMessage => 'Your message';

  @override
  String get claimsOneConversation => 'One conversation per claim';

  @override
  String get claimsNoClaims => 'No claims.';

  @override
  String get claimsNoMessage => 'No messages';

  @override
  String get claimsMarkAllRead => 'Mark all as read';

  @override
  String get claimsNoNotification => 'No notifications.';

  @override
  String get claimsOffline =>
      'Offline: your changes will be sent when the network is back';

  @override
  String get claimsFileUnavailable => 'File unavailable right now.';

  @override
  String get claimsValueDraft => 'Draft';

  @override
  String get claimsValueDeclared => 'Declared';

  @override
  String get claimsValueSigned => 'Report signed';

  @override
  String get claimsValueTransmitted => 'Submitted';

  @override
  String get claimsValueInReview => 'Under review';

  @override
  String get claimsValueDocumentRequested => 'Document requested';

  @override
  String get claimsValueExpertise => 'Expert assessment';

  @override
  String get claimsValueClosed => 'Closed';

  @override
  String get claimsValueRejected => 'Rejected';

  @override
  String get claimsValueCollision => 'Collision';

  @override
  String get claimsValueOffRoad => 'Ran off the road';

  @override
  String get claimsValuePedestrian => 'Pedestrian';

  @override
  String get claimsValueMaterialAccident => 'Property damage';

  @override
  String get claimsValueOther => 'Other';

  @override
  String get claimsValueMaterial => 'Damage only';

  @override
  String get claimsValueLight => 'Minor';

  @override
  String get claimsValueSerious => 'Serious';

  @override
  String get claimsValueParked => 'Parked';

  @override
  String get claimsValueLeavingParking => 'Leaving a parking space';

  @override
  String get claimsValueChangingLane => 'Changing lanes';

  @override
  String get claimsValueOvertaking => 'Overtaking';

  @override
  String get claimsValueTurningRight => 'Turning right';

  @override
  String get claimsValueTurningLeft => 'Turning left';

  @override
  String get claimsValueReversing => 'Reversing';

  @override
  String get claimsValueFront => 'Front';

  @override
  String get claimsValueRear => 'Rear';

  @override
  String get claimsValueLeftSide => 'Left side';

  @override
  String get claimsValueRightSide => 'Right side';

  @override
  String get claimsValueQuote => 'Repair quote';

  @override
  String get claimsValueInvoice => 'Invoice';

  @override
  String get claimsValuePoliceReport => 'Police report';

  @override
  String get claimsValueExpertReport => 'Expert report';

  @override
  String get claimsValueSupporting => 'Document';

  @override
  String get claimsValuePhoto => 'Photo';

  @override
  String get claimsValueVideo => 'Video';

  @override
  String get claimsValueVoiceNote => 'Voice note';

  @override
  String get claimsValueAccidentReport => 'Accident report';

  @override
  String get claimsEventDraftCreated => 'Draft created';

  @override
  String get claimsEventDeclared => 'Declaration completed';

  @override
  String claimsEventEvidence(String count) {
    return '$count pieces of evidence added';
  }

  @override
  String get claimsEventSigned => 'Signed by both drivers';

  @override
  String get claimsEventPdfLocked => 'PDF locked';

  @override
  String get claimsEventSent => 'Sent to the insurers';

  @override
  String get claimsEventMoved => 'Appointment rescheduled';

  @override
  String get claimsEventReport => 'Expert report attached';

  @override
  String claimsEventDetail(String status, String detail) {
    return '$status: $detail';
  }

  @override
  String claimsNotifNew(String id) {
    return 'New claim received: $id';
  }

  @override
  String claimsNotifRequested(String id, String document) {
    return '$id: document requested ($document)';
  }

  @override
  String claimsNotifUploaded(String id, String name) {
    return '$id: document uploaded ($name)';
  }

  @override
  String claimsNotifMoved(String id) {
    return '$id: expert appointment rescheduled';
  }

  @override
  String claimsNotifEvent(String id, String event) {
    return '$id: $event';
  }

  @override
  String claimsNotifInReview(String id) {
    return 'Your claim $id is under review.';
  }

  @override
  String claimsNotifContract(String days) {
    return 'Your contract expires in $days days.';
  }

  @override
  String get claimsValueVehicle => 'Vehicle';

  @override
  String get claimsValueBodily => 'Bodily injury';

  @override
  String get claimsValueReopened => 'Reopened';

  @override
  String get claimsEventConfirmed => 'Appointment confirmed';

  @override
  String get claimsEventOtherSlot => 'Another time proposed';

  @override
  String claimsNotifConfirmed(String id) {
    return '$id: expert appointment confirmed';
  }

  @override
  String claimsNotifOtherSlot(String id) {
    return '$id: another time proposed for the expert assessment';
  }

  @override
  String get claimsQuestionOnDecision =>
      'A question about the decision? Write to the agent';

  @override
  String get claimsReportPending =>
      'The expert sends the report to the insurer after the appointment. It will appear here.';

  @override
  String get claimsReportReceived => 'Expert’s report, attached by the agent';

  @override
  String get claimsReopen => 'Reopen the claim';

  @override
  String get claimsReopenHelp =>
      'If there was a mistake, reopen the claim: it goes back under review and the previous decision stays in the timeline.';

  @override
  String get claimsReopenAction => 'Reopen';

  @override
  String get claimsKindHelp =>
      'Bodily injury: medical examination of an injured person, a pedestrian for example. No vehicle to show.';

  @override
  String get claimsExpertPhone => 'Expert’s phone';

  @override
  String get claimsExpertPlace => 'Appointment place';

  @override
  String get claimsPlaceHintBody => 'Medical practice, clinic…';

  @override
  String get claimsPlaceHintVehicle => 'Garage, branch, home…';

  @override
  String get claimsSuggestedSlots => 'Suggested times';

  @override
  String get claimsNoteOptional => 'Message (optional)';

  @override
  String get claimsExpertRequired => 'Enter the expert’s name.';

  @override
  String get claimsSlotConfirmed => 'Confirmed';

  @override
  String get claimsSlotYourTurn => 'To confirm';

  @override
  String get claimsSlotWaitingAgent => 'Waiting for the agent';

  @override
  String get claimsSlotWaitingDriver => 'Waiting for the driver';

  @override
  String get claimsExpertiseBody => 'Medical assessment';

  @override
  String get claimsExpertiseVehicle => 'Vehicle assessment';

  @override
  String get claimsPlaceFromExpert => 'Place given by the expert';

  @override
  String get claimsFromDriver => 'From the driver';

  @override
  String get claimsFromAgent => 'From the agent';

  @override
  String get claimsToBring => 'To bring';

  @override
  String get claimsBringId => 'Your ID card';

  @override
  String get claimsBringCertificates => 'Medical certificates';

  @override
  String get claimsBringPrescriptions => 'Prescriptions and medical bills';

  @override
  String get claimsBringVehicle => 'The vehicle, not yet repaired';

  @override
  String get claimsBringRegistration => 'The registration certificate';

  @override
  String get claimsBringLicence => 'Your driving licence';

  @override
  String get claimsBringInsurance => 'Proof of insurance';

  @override
  String get claimsAccept => 'Accept';

  @override
  String get claimsProposeOther => 'Propose another time';

  @override
  String get claimsCannotCome => 'I can no longer come';

  @override
  String get claimsOtherDateTime => 'Another date and time';

  @override
  String get claimsSendProposal => 'Send the proposal';

  @override
  String get claimsStepReceived => 'Received';

  @override
  String get claimsStepReview => 'Review';

  @override
  String get claimsStepExpertise => 'Expertise';

  @override
  String get claimsStepDecision => 'Decision';

  @override
  String get claimsYourTodo => 'To do';

  @override
  String claimsRemainingDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'About $days days left',
      one: 'About 1 day left',
    );
    return '$_temp0';
  }

  @override
  String get claimsEstimateNote => 'An estimate, not a commitment.';

  @override
  String get claimsTakingLonger =>
      'Your claim is taking longer than usual. You can write to your agent.';

  @override
  String get claimsCircumstancesA => 'Circumstances of A';

  @override
  String get claimsCircumstancesB => 'Circumstances of B';

  @override
  String claimsProposalFaultB(String box) {
    return '$box: risky manoeuvre by B.';
  }

  @override
  String claimsProposalBoth(String a, String b) {
    return 'A: $a, B: $b. Risky manoeuvres on both sides: shared.';
  }

  @override
  String get claimsProposalParkedB => 'B was parked.';

  @override
  String get claimsNoCompany => 'Insurer not given';

  @override
  String claimsEventSealed(String hash) {
    return 'Report sealed (SHA-256 $hash)';
  }

  @override
  String claimsEventSealedLocal(String hash) {
    return 'Report sealed on the phone (SHA-256 $hash)';
  }

  @override
  String get claimsEventWaitingSync => 'Waiting for a connection to send';

  @override
  String get claimsSummaryTitle => 'Claim summary';

  @override
  String claimsPriorityScore(String score) {
    return 'Priority $score';
  }

  @override
  String get claimsSearchMine => 'Search my claims';

  @override
  String get claimsBySeverity => 'By severity';

  @override
  String get claimsByType => 'By accident type';

  @override
  String get claimsAnswersBySource => 'Answers by source';

  @override
  String get appTitle => 'Mon Constat Digital';

  @override
  String get brand => 'Mon Constat';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get retry => 'Retry';

  @override
  String get later => 'Later';

  @override
  String get or => 'or';

  @override
  String get validate => 'Confirm';

  @override
  String get notProvided => 'Not provided';

  @override
  String get requiredField => 'Required field.';

  @override
  String get invalidEmail => 'Invalid email address.';

  @override
  String get invalidPhone => 'Invalid phone number.';

  @override
  String get passwordTooShort =>
      'The password must be at least 8 characters long.';

  @override
  String get codeFormat => 'The code has 6 digits.';

  @override
  String get passwordsDontMatch => 'The passwords do not match.';

  @override
  String get roleDriver => 'Driver';

  @override
  String get roleAgent => 'Insurance agent';

  @override
  String get roleAdmin => 'Administrator';

  @override
  String get heroTitleLine1 => 'Accident reports,';

  @override
  String get heroTitleLine2 => 'paper-free.';

  @override
  String get heroSubtitle =>
      'Report, sign and follow your claim from your phone.';

  @override
  String get loginTitle => 'Sign in';

  @override
  String get identifierLabel => 'Email or phone';

  @override
  String get passwordLabel => 'Password';

  @override
  String get forgotPasswordLink => 'Forgot password?';

  @override
  String get signIn => 'Sign in';

  @override
  String get biometricButton => 'Fingerprint or Face ID';

  @override
  String get noAccount => 'No account yet?';

  @override
  String get createAccountLink => 'Create an account';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get biometricLoginReason => 'Sign in to Mon Constat';

  @override
  String get biometricEnableReason => 'Confirm to turn on biometric sign-in';

  @override
  String get languageSwitcher => 'App language';

  @override
  String get registerTitle => 'Create an account';

  @override
  String get firstNameLabel => 'First name';

  @override
  String get lastNameLabel => 'Last name';

  @override
  String get emailLabel => 'Email';

  @override
  String get phoneLabel => 'Phone';

  @override
  String get confirmPasswordLabel => 'Confirm password';

  @override
  String get createMyAccount => 'Create my account';

  @override
  String get otpTitle => 'Verify my phone';

  @override
  String otpInstructions(String phone) {
    return 'Enter the 6-digit code sent on WhatsApp to $phone.';
  }

  @override
  String get otpCodeLabel => 'Verification code';

  @override
  String get resendCode => 'Resend code';

  @override
  String resendCodeIn(int seconds) {
    return 'Resend code ($seconds s)';
  }

  @override
  String get forgotTitle => 'Forgot password';

  @override
  String get forgotIntro => 'Enter your email address to receive a reset code.';

  @override
  String forgotCodeSent(String email) {
    return 'If an account exists for $email, a code valid for 15 minutes has just been sent to it.';
  }

  @override
  String get codeFromEmailLabel => 'Code received by email';

  @override
  String get newPasswordLabel => 'New password';

  @override
  String get receiveCode => 'Get a code';

  @override
  String get changePassword => 'Change password';

  @override
  String get passwordChanged => 'Password changed. You can now sign in.';

  @override
  String get profileTitle => 'My profile';

  @override
  String get profileSubtitle => 'Identity, licence and preferences';

  @override
  String profileCompletion(int percent) {
    return 'Profile $percent% complete';
  }

  @override
  String get profileCompleteHint =>
      'Add your driving licence: it fills in your part of the accident report.';

  @override
  String get profileComplete =>
      'Profile complete, ready for an accident report.';

  @override
  String get sectionIdentity => 'Identity';

  @override
  String get sectionLicense => 'Driving licence';

  @override
  String get sectionSecurity => 'Security';

  @override
  String get sectionPreferences => 'Preferences';

  @override
  String get fullNameLabel => 'Full name';

  @override
  String get emailNotEditable => 'The email cannot be changed.';

  @override
  String get phoneVerified => 'Number verified';

  @override
  String get phoneNotVerified => 'Number not verified';

  @override
  String get verify => 'Verify';

  @override
  String get licenseNumberLabel => 'Licence number';

  @override
  String get licenseCategoryLabel => 'Category';

  @override
  String get licenseIssuedLabel => 'Issue date';

  @override
  String get licenseEmpty =>
      'No licence saved. It fills in your part of the accident report.';

  @override
  String get addLicense => 'Add my licence';

  @override
  String licenseIssuedOn(String date) {
    return 'Issued on $date';
  }

  @override
  String get licensePhotoAdd => 'Add a photo of the licence';

  @override
  String get replace => 'Replace';

  @override
  String get biometricTitle => 'Fingerprint sign-in';

  @override
  String get biometricSubtitle =>
      'Fingerprint or face recognition, 30 days on this phone';

  @override
  String get biometricEnabled => 'Biometric sign-in turned on';

  @override
  String get languageLabel => 'Language';

  @override
  String get logout => 'Sign out';

  @override
  String get profileSaved => 'Profile saved';

  @override
  String get editIdentityTitle => 'Edit identity';

  @override
  String get editLicenseTitle => 'Edit licence';

  @override
  String get changeProfilePhoto => 'Change profile photo';

  @override
  String get phoneChangeNotice =>
      'A new number will need to be verified with a WhatsApp code.';

  @override
  String get takePhoto => 'Take a photo';

  @override
  String get chooseFromGallery => 'Choose from gallery';

  @override
  String get deletePhoto => 'Delete photo';

  @override
  String get photoSaved => 'Photo saved';

  @override
  String get accountsTitle => 'Accounts';

  @override
  String get accountsSubtitle => 'Roles, agents and suspensions';

  @override
  String get createAgentTooltip => 'Create an agent';

  @override
  String get searchHint => 'Name, email or phone';

  @override
  String get noAccounts => 'No accounts found.';

  @override
  String get roleLabel => 'Role';

  @override
  String get companyLabel => 'Company';

  @override
  String get createAgentTitle => 'Create an agent';

  @override
  String get tempPasswordLabel => 'Temporary password';

  @override
  String get createAccountButton => 'Create account';

  @override
  String get companiesTitle => 'Insurance companies';

  @override
  String get companiesSubtitle => 'Companies and branches';

  @override
  String get addCompany => 'Add a company';

  @override
  String get noCompanies => 'No companies yet.';

  @override
  String agencyCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count branches',
      one: '1 branch',
      zero: 'No branches',
    );
    return '$_temp0';
  }

  @override
  String get addAgency => 'Add a branch';

  @override
  String get rename => 'Rename';

  @override
  String get newCompany => 'New company';

  @override
  String get renameCompany => 'Rename company';

  @override
  String get companyNameLabel => 'Company name';

  @override
  String get newAgency => 'New branch';

  @override
  String get editAgency => 'Edit branch';

  @override
  String get agencyNameLabel => 'Branch name';

  @override
  String get cityLabel => 'City';

  @override
  String deleteCompanyTitle(String name) {
    return 'Delete $name?';
  }

  @override
  String get deleteCompanyBody => 'Its branches will also be deleted.';

  @override
  String get deleteAgencyTooltip => 'Delete branch';

  @override
  String get adminTitle => 'Administration';

  @override
  String get adminSubtitle => 'Platform overview';

  @override
  String get demoData => 'Demo data';

  @override
  String get statAccidents => 'Accidents';

  @override
  String get statOpen => 'Open';

  @override
  String get statClosed => 'Closed';

  @override
  String get statAvgDelay => 'Average time';

  @override
  String get heatmapTitle => 'Accident hotspot map';

  @override
  String get severityTitle => 'Breakdown by severity';

  @override
  String severityMaterial(int percent) {
    return '$percent% damage only';
  }

  @override
  String get navHome => 'Home';

  @override
  String get navVehicles => 'Vehicles';

  @override
  String get navClaims => 'Claims';

  @override
  String get navMessages => 'Messages';

  @override
  String get navProfile => 'Profile';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navCases => 'Claims';

  @override
  String get navAccounts => 'Accounts';

  @override
  String get navCompanies => 'Companies';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get errorNetwork => 'Cannot reach the server. Check your connection.';

  @override
  String get errorInvalidCredentials => 'Wrong login or password.';

  @override
  String get errorAccountLocked =>
      'Account locked for 15 minutes after 5 failed attempts. Try again later.';

  @override
  String get errorAccountSuspended => 'This account is suspended.';

  @override
  String get errorAlreadyExists => 'This value is already in use.';

  @override
  String get errorInvalidCode => 'Wrong or expired code.';

  @override
  String get errorCodeCooldown => 'Wait a minute before asking for a new code.';

  @override
  String get errorSessionExpired => 'Session expired. Please sign in again.';

  @override
  String get errorBiometricInvalid =>
      'Biometric sign-in expired. Sign in with your password.';

  @override
  String get errorBiometricUnavailable =>
      'Fingerprint or face recognition unavailable. Check the phone\'s security settings.';

  @override
  String get errorFileTooLarge => 'Image too large: 5 MB maximum.';

  @override
  String get errorUnsupportedImage => 'Accepted formats: JPEG, PNG or WebP.';

  @override
  String get errorCompanyInUse => 'Agents are still attached to this company.';

  @override
  String get errorSelfChange => 'You cannot change your own role or status.';

  @override
  String get errorInvalidData => 'Some of the data is invalid.';

  @override
  String get appearanceLabel => 'Appearance';

  @override
  String get themeSystem => 'Same as phone';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get navDeclarations => 'Reports';

  @override
  String get securityDevicesTitle => 'Connected devices';

  @override
  String get securityDevicesSubtitle => 'Where your account is signed in';

  @override
  String get thisDevice => 'This device';

  @override
  String lastActive(String when) {
    return 'Active on $when';
  }

  @override
  String get signOutDevice => 'Sign out';

  @override
  String signOutDeviceConfirm(String name) {
    return 'Sign out $name?';
  }

  @override
  String get signOutDeviceBody =>
      'This device will need the password to sign in again.';

  @override
  String get signOutOthers => 'Sign out all other devices';

  @override
  String signedOutOthers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count devices signed out',
      one: '1 device signed out',
      zero: 'No other device signed in',
    );
    return '$_temp0';
  }

  @override
  String get unknownDevice => 'Unknown device';

  @override
  String get securityAlertNote =>
      'A sign-in from a new device is reported to you on WhatsApp and by email.';

  @override
  String get loginHistoryTitle => 'Sign-in history';

  @override
  String get noHistory => 'No sign-ins yet.';

  @override
  String get loginSuccess => 'Signed in';

  @override
  String get loginMethodPassword => 'password';

  @override
  String get loginMethodBiometric => 'fingerprint';

  @override
  String get loginMethodRegister => 'account created';

  @override
  String get loginFailedWrongPassword => 'Wrong password';

  @override
  String get loginFailedLocked => 'Attempt on locked account';

  @override
  String get loginFailedSuspended => 'Attempt on suspended account';

  @override
  String get identityTitle => 'Identity check';

  @override
  String get identityStatusUnverified => 'Identity not verified';

  @override
  String get identityStatusPending => 'Under review';

  @override
  String get identityStatusVerified => 'Identity verified';

  @override
  String get identityStatusRejected => 'Check declined';

  @override
  String get identityIntro =>
      'Choose a document, take a photo of it, then check your face. Our AI compares your face with the photo on the document, on our own servers, with no outside service.';

  @override
  String get identityPendingNote =>
      'The AI could not decide: an administrator is comparing your photos. You will be notified on WhatsApp and by email.';

  @override
  String get identityVerifiedNote => 'You can sign your accident reports.';

  @override
  String identityRejectedReason(String reason) {
    return 'Reason: $reason';
  }

  @override
  String get cinNumberLabel => 'ID card number';

  @override
  String get cinInvalid => 'The ID card number has 8 digits.';

  @override
  String get cinFront => 'Front of ID card';

  @override
  String get cinBack => 'Back of ID card';

  @override
  String get addPhoto => 'Add photo';

  @override
  String get identityPhotosRequired => 'Add the photos of your document.';

  @override
  String get submitIdentity => 'Send for review';

  @override
  String get identitySent => 'Request sent. You will be told on WhatsApp.';

  @override
  String get navIdentities => 'Identities';

  @override
  String get reviewTitle => 'Identity checks';

  @override
  String get reviewSubtitle => 'Pending requests, oldest first';

  @override
  String get noPendingReviews => 'No pending requests.';

  @override
  String submittedOn(String date) {
    return 'Sent on $date';
  }

  @override
  String get approve => 'Approve';

  @override
  String get reject => 'Decline';

  @override
  String get rejectTitle => 'Reason for declining';

  @override
  String get rejectReasonBlurry => 'Blurry photo';

  @override
  String get rejectReasonUnreadable => 'Unreadable document';

  @override
  String get rejectReasonNameMismatch => 'Name doesn\'t match the account';

  @override
  String get rejectReasonNotCin => 'Invalid document';

  @override
  String get otherReason => 'Other reason';

  @override
  String get identityApproved => 'Identity approved, the holder is notified';

  @override
  String get identityRejected => 'Request declined, the holder is notified';

  @override
  String get errorIdentityLocked =>
      'Your identity is under review or already verified.';

  @override
  String get errorCinInUse => 'This document number is already in use.';

  @override
  String get errorIdentityNotVerified =>
      'Your identity must be verified first.';

  @override
  String get errorIdentityNotPending => 'This request is no longer pending.';

  @override
  String get consentLabel =>
      'I agree that my data is processed to manage my accident reports, under Tunisian law no. 2004-63.';

  @override
  String get consentRequired =>
      'Your consent is required to create an account.';

  @override
  String get sectionPrivacy => 'Personal data';

  @override
  String get exportData => 'Download my data';

  @override
  String get exportDataSubtitle =>
      'A PDF of everything Mon Constat keeps about you';

  @override
  String get deleteAccount => 'Delete my account';

  @override
  String get deleteAccountSubtitle =>
      'Permanent. Your reports stay, without your name.';

  @override
  String get deleteAccountTitle => 'Delete your account?';

  @override
  String get deleteAccountBody =>
      'Your name, contact details, licence, ID card and photos will be erased. Accidents and claims already filed stay, anonymised, as insurance requires. This cannot be undone.';

  @override
  String get deleteAccountConfirm => 'Delete permanently';

  @override
  String get accountDeleted => 'Your account has been deleted.';

  @override
  String get errorAdminCannotDelete =>
      'An administrator cannot delete their account here.';

  @override
  String get dashUsers => 'Users';

  @override
  String dashActive(int count) {
    return '$count active';
  }

  @override
  String get dashPendingIds => 'To review';

  @override
  String dashVerifiedIds(int count) {
    return '$count verified';
  }

  @override
  String get dashPhones => 'Phones verified';

  @override
  String get dashSignIns => 'Sign-ins 7 days';

  @override
  String dashFailed(int count) {
    return '$count failed';
  }

  @override
  String get dashSignupsTitle => 'Sign-ups, last 30 days';

  @override
  String get dashRolesTitle => 'Accounts by role';

  @override
  String get dashIdentityTitle => 'Driver identity checks';

  @override
  String dashNetwork(int companies, int agencies) {
    return '$companies companies · $agencies branches';
  }

  @override
  String get dashAccidentsTitle => 'Accidents and claims';

  @override
  String get dashAccidentsPending =>
      'Indicators, breakdowns and the hotspot map: available as soon as modules 3 and 5 send their data to the server.';

  @override
  String get agencyLabel => 'Branch';

  @override
  String companiesOffline(String date) {
    return 'Offline: list saved on $date';
  }

  @override
  String get pendingSyncTitle => 'Changes waiting to sync';

  @override
  String get pendingSyncBody =>
      'Saved on this phone. They will be sent as soon as the network is back.';

  @override
  String syncFailed(String reason) {
    return 'The server declined the change: $reason';
  }

  @override
  String get syncNow => 'Sync now';

  @override
  String get retrySync => 'Retry';

  @override
  String get discardChanges => 'Discard changes';

  @override
  String get savedOffline =>
      'Saved on this phone. Sent when the network is back.';

  @override
  String get syncing => 'Syncing…';

  @override
  String get consoleDashboard => 'Dashboard';

  @override
  String get consoleToHandle => 'To handle';

  @override
  String get consoleReview => 'Review';

  @override
  String get consoleSeeAll => 'See all';

  @override
  String get consoleNothingToHandle => 'Nothing to handle right now.';

  @override
  String get refresh => 'Refresh';

  @override
  String get signedInAs => 'Signed in';

  @override
  String get colUser => 'User';

  @override
  String get colStatus => 'Status';

  @override
  String get filterAll => 'All';

  @override
  String get filterDrivers => 'Drivers';

  @override
  String get filterAgents => 'Agents';

  @override
  String get filterAdmins => 'Administrators';

  @override
  String accountsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count accounts',
      one: '1 account',
      zero: 'No accounts',
    );
    return '$_temp0';
  }

  @override
  String get statusActive => 'Active';

  @override
  String get statusSuspended => 'Suspended';

  @override
  String get changeRole => 'Change role';

  @override
  String get suspendAccount => 'Suspend';

  @override
  String get reactivateAccount => 'Reactivate';

  @override
  String get selectRequest => 'Select a request to see the document.';

  @override
  String pendingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count requests',
      one: '1 request',
      zero: 'No requests',
    );
    return '$_temp0';
  }

  @override
  String get selectCompany => 'Select a company to manage its branches.';

  @override
  String get agenciesTitle => 'Branches';

  @override
  String get noAgencies => 'No branches yet.';

  @override
  String get heroPoint1 =>
      'A complete report in under 10 minutes, even offline';

  @override
  String get heroPoint2 => 'Both drivers\' signatures and a tamper-proof PDF';

  @override
  String get heroPoint3 => 'Real-time tracking until compensation';

  @override
  String get identityVerifiedAutoNote =>
      'Verified automatically by face recognition. You can now sign your accident reports.';

  @override
  String get documentTypeLabel => 'Identity document';

  @override
  String get documentCin => 'ID card';

  @override
  String get documentLicense => 'Licence';

  @override
  String get documentPassport => 'Passport';

  @override
  String get passportNumberLabel => 'Passport number';

  @override
  String get licenseNumberInvalid => 'Invalid licence number (e.g. 12/345678).';

  @override
  String get passportNumberInvalid =>
      'Invalid passport number (e.g. X1234567).';

  @override
  String get licenseFront => 'Licence front';

  @override
  String get licenseBack => 'Licence back';

  @override
  String get passportPage => 'Passport photo page';

  @override
  String get faceCheckTitle => 'Face check';

  @override
  String get faceCheckIntro =>
      'Three quick photos: facing the camera, then turning your head each way. A printed photo or a screen will not pass.';

  @override
  String get faceCheckDone => 'Face checked';

  @override
  String get faceCheckStart => 'Check my face';

  @override
  String get faceCheckRedo => 'Start again';

  @override
  String get faceCheckRequired => 'Do the face check first.';

  @override
  String get livenessCenter => 'Look straight at the camera';

  @override
  String get livenessLeft => 'Turn your head to the left';

  @override
  String get livenessRight => 'Turn your head to the right';

  @override
  String livenessStepOf(int current, int total) {
    return 'Photo $current of $total';
  }

  @override
  String get livenessAnalyzing => 'AI analysis…';

  @override
  String get livenessNoCamera =>
      'Camera unavailable. Allow camera access, then try again.';

  @override
  String get livenessPrivacy =>
      'The front photo is only used for this check. It is deleted as soon as a decision is made.';

  @override
  String get livenessSuccess => 'Face checked. You can send your request.';

  @override
  String get identityVerifiedByAi => 'Identity verified by the AI';

  @override
  String get errorNoFaceOnDocument =>
      'No face found on the document. Retake the photo flat, well lit and without glare.';

  @override
  String get errorLivenessNoFace =>
      'Face not found. Put your face in the oval, in good light.';

  @override
  String get errorLivenessManyFaces =>
      'Only one person should be in front of the camera.';

  @override
  String get errorLivenessNotCentered =>
      'Look straight at the camera for the first photo.';

  @override
  String get errorLivenessNoTurn => 'Turn your head further when asked.';

  @override
  String get errorLivenessDifferentFaces =>
      'The photos do not show the same person.';

  @override
  String get errorLivenessExpired =>
      'The challenge expired. Start the face check again.';

  @override
  String get errorFaceEngine =>
      'Face analysis is unavailable. Try again in a moment.';

  @override
  String aiMatch(int percent) {
    return 'AI match: $percent%';
  }

  @override
  String get aiNoConclusion => 'AI: no conclusion';

  @override
  String get livenessPassed => 'Live face checked';

  @override
  String get selfieLabel => 'Face photo';

  @override
  String get documentNumberLabel => 'Document number';

  @override
  String get rejectReasonFaceMismatch => 'The face does not match the document';

  @override
  String dashVerifiedIdsAi(int count, int ai) {
    return '$count verified, $ai by the AI';
  }

  @override
  String get readingDocument => 'The AI is reading your document…';

  @override
  String get readOnCard => 'Read from the document by the AI';

  @override
  String get readNumber => 'Number';

  @override
  String get readName => 'Name';

  @override
  String get readParents => 'Parents';

  @override
  String get readBirth => 'Birth';

  @override
  String get readExpiry => 'Valid until';

  @override
  String get readConfirm =>
      'Check this information. The number you enter must be the one on the document.';

  @override
  String get readNothing =>
      'The AI could not read the document. Enter the number: an administrator will check it.';

  @override
  String get useNumberRead => 'Use this number';

  @override
  String get useLicensePhoto => 'Use the licence photo from my profile';

  @override
  String get errorBackHasFace =>
      'This photo shows a front side. Take a photo of the back of the same document.';

  @override
  String get errorLicensePhotoMissing => 'No licence photo in your profile.';

  @override
  String get checksTitle => 'AI checks';

  @override
  String get checkLiveness => 'Live face';

  @override
  String get checkFace => 'Face matches the document photo';

  @override
  String checkNumber(String number) {
    return 'Entered number = number read ($number)';
  }

  @override
  String get checkNumberUnread => 'Number unreadable on the document';

  @override
  String get checkName => 'Account name on the document';

  @override
  String get checkExpiry => 'Document still valid';

  @override
  String get scanLicense => 'Scan my licence';

  @override
  String get scanLicenseHint =>
      'Take a photo of your licence: the AI fills in the number, categories and date.';

  @override
  String get licenseFilledByAi =>
      'Filled in by the AI from the photo. Check before saving.';

  @override
  String get licenseNotRead =>
      'Photo saved, but the AI could not read the licence. Fill in the fields.';

  @override
  String get errorBackNotRecognized =>
      'This is not the back of the document. On an ID card, the barcode must be sharp and fully visible.';

  @override
  String get checkBack => 'Back side recognised';

  @override
  String get rejectSevere => 'Final refusal: block new requests';

  @override
  String get rejectSevereHint =>
      'For likely fraud: different face, fake document.';

  @override
  String get identityBlockedNote =>
      'Your identity verification is blocked. Contact support.';

  @override
  String identityRetryOn(String date) {
    return 'You can send a new request on $date.';
  }

  @override
  String identityAttemptsLeft(int count) {
    return 'Attempts left: $count.';
  }

  @override
  String get errorIdentityBlocked =>
      'Your identity verification is blocked. Contact support.';

  @override
  String get errorIdentityRetryLater =>
      'Wait 24 hours after a refusal before a new request.';

  @override
  String get unblockIdentity => 'Unblock verification';

  @override
  String get identityUnblocked => 'Verification unblocked';

  @override
  String get identityBlockedChip => 'Verification blocked';

  @override
  String get attemptsTitle => 'Requests from this account';

  @override
  String refusalsCount(int count) {
    return 'Refusals: $count';
  }

  @override
  String get outcomeAuto => 'Verified by the AI';

  @override
  String get outcomeVerified => 'Verified';

  @override
  String get outcomeRejected => 'Refused';

  @override
  String get outcomePending => 'Pending';

  @override
  String get biometricConsentLabel =>
      'I agree to have my face analysed to verify my identity. Analysis on Mon Constat servers, photo deleted as soon as a decision is made (law no. 2004-63).';

  @override
  String get errorAiQuota =>
      'Too many analyses in a short time. Try again in a while.';

  @override
  String get livenessHintNoFace => 'Put your face in the oval';

  @override
  String get livenessHintLookStraight => 'Look straight at the camera';

  @override
  String get livenessHintTurnMore => 'Turn your head further';

  @override
  String get dashAiTitle => 'AI verification';

  @override
  String get dashAiFooter =>
      'Over the period shown. Analysis on our servers, no outside service.';

  @override
  String get dashAiRequests => 'requests';

  @override
  String get dashAiAutoRate => 'verified by the AI alone';

  @override
  String get dashAiAverageMatch => 'average match';

  @override
  String get dashAiBlocked => 'blocked accounts';

  @override
  String get checkBirthDate => 'Same birth date as the licence';

  @override
  String get licenseBirthMismatch =>
      'Warning: the birth date on the licence does not match your identity document.';

  @override
  String get licenseNameMismatch =>
      'Warning: this licence is not in your name. Add your own licence.';

  @override
  String get licenseCinMismatch =>
      'Warning: the ID number on the licence does not match your identity document.';

  @override
  String get errorWrongDocument =>
      'The photo does not show the chosen document. Change the document or the photo.';

  @override
  String get errorNotALicense => 'This photo is not a driving licence.';

  @override
  String get registerIntro =>
      'An e-mail and a password. The rest comes right after, in a few steps.';

  @override
  String get registerStepYou => 'You';

  @override
  String get registerStepContact => 'Your contact details';

  @override
  String get registerStepSecurity => 'Security';

  @override
  String get registerPhoneHint =>
      'A verification code will be sent to you on WhatsApp.';

  @override
  String get passwordWeak => 'Weak';

  @override
  String get passwordFair => 'Fair';

  @override
  String get passwordGood => 'Good';

  @override
  String get passwordStrong => 'Strong';

  @override
  String get passwordRuleLength => '8 characters';

  @override
  String get passwordRuleUpper => 'A capital letter';

  @override
  String get passwordRuleDigit => 'A digit';

  @override
  String get passwordRuleSymbol => 'A symbol';

  @override
  String get identityStepDocument => 'Document';

  @override
  String get identityStepReading => 'Reading';

  @override
  String get identityStepFace => 'Face';

  @override
  String get identityStepSend => 'Send';

  @override
  String get profileIdentityVerified => 'Identity verified';

  @override
  String get profileIdentityPending => 'Identity in review';

  @override
  String get profileIdentityTodo => 'Verify your identity';

  @override
  String get licenseStatusVerified => 'Licence verified';

  @override
  String get licenseStatusToReview => 'Licence being checked';

  @override
  String get licenseStatusRejected => 'Licence declined';

  @override
  String get licenseToReviewNote =>
      'Something on the licence does not match your account: an administrator is checking it.';

  @override
  String licenseRejectedNote(String reason) {
    return 'Your licence was declined. Reason: $reason. Add your own licence.';
  }

  @override
  String get errorLicenseNotYours =>
      'This licence does not seem to be yours: the name, date of birth or ID number do not match your account. It was not saved.';

  @override
  String get accountFileTitle => 'Account file';

  @override
  String get openAccountFile => 'Open file';

  @override
  String get sectionAccount => 'Account';

  @override
  String get licenseReviewTitle => 'Licences to check';

  @override
  String get licenseReviewSubtitle =>
      'An AI check failed, or the photo could not be read';

  @override
  String get noLicenseReviews => 'No licence to check.';

  @override
  String licensesToReviewCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count licences to check',
      one: '1 licence to check',
    );
    return '$_temp0';
  }

  @override
  String get approveLicense => 'Approve licence';

  @override
  String get rejectLicense => 'Decline licence';

  @override
  String get deleteLicense => 'Delete licence';

  @override
  String deleteLicenseBody(String name) {
    return '$name\'s licence photo and details will be erased.';
  }

  @override
  String get licenseApproved => 'Licence approved';

  @override
  String get licenseRejected => 'Licence declined, the driver sees the reason';

  @override
  String get licenseDeleted => 'Licence deleted';

  @override
  String get licenseUpdated => 'Licence updated';

  @override
  String get noLicense => 'No licence saved.';

  @override
  String get noIdentityDocuments => 'No document saved.';

  @override
  String get aiChecksTitle => 'AI checks';

  @override
  String get checkLicenseName => 'Holder name = account name';

  @override
  String get checkLicenseBirth => 'Date of birth = ID document';

  @override
  String get checkLicenseCin => 'ID number = ID document';

  @override
  String get checkLicenseNumber => 'Typed number = number read on the photo';

  @override
  String get checkNotCompared => 'not comparable';

  @override
  String get licenseRejectReasonNotOwner => 'Someone else\'s licence';

  @override
  String get licenseRejectReasonExpired => 'Expired licence';

  @override
  String get revokeIdentity => 'Cancel verification';

  @override
  String get revokeIdentityTitle => 'Cancel the identity verification?';

  @override
  String get revokeIdentityBody =>
      'The document photos will be erased. The driver sees the reason and can apply again straight away.';

  @override
  String get identityRevoked => 'Verification cancelled';

  @override
  String get reasonLabel => 'Reason';

  @override
  String get onbSkip => 'Skip';

  @override
  String get onbLater => 'Later';

  @override
  String get onbContinue => 'Continue';

  @override
  String get onbBack => 'Previous step';

  @override
  String onbProgress(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get onbWelcomeEyebrow => 'Account created';

  @override
  String onbWelcomeTitle(String name) {
    return 'Welcome,\n$name';
  }

  @override
  String get onbWelcomeBody =>
      'Two minutes to set up your account, and you\'ll be ready the day you need it.';

  @override
  String get onbWelcomeStart => 'Set up my account';

  @override
  String get onbWelcomeSkip => 'I\'ll do it later';

  @override
  String get onbLicenseTitle => 'Add your licence';

  @override
  String get onbLicenseBody =>
      'One photo is enough: the AI reads the number, categories and date. It will fill in your accident reports.';

  @override
  String get onbLicenseScan => 'Take a photo of my licence';

  @override
  String get onbLicenseRescan => 'Retake the photo';

  @override
  String get onbLicenseReading => 'Reading the licence…';

  @override
  String get onbLicenseRead => 'Read by the AI';

  @override
  String get onbLicenseUnread =>
      'The card could not be read. You\'ll fill in the details from your profile.';

  @override
  String get onbLicenseTip => 'Flat, well lit, no glare.';

  @override
  String get onbIdentityTitle => 'Verify your identity';

  @override
  String get onbIdentityBody =>
      'So you can sign your accident reports with confidence. It takes two minutes.';

  @override
  String get onbIdentityStep1 => 'A document: ID card, licence or passport';

  @override
  String get onbIdentityStep2 => 'Your face, turning your head';

  @override
  String get onbIdentityStep3 => 'The AI compares, in a few seconds';

  @override
  String get onbIdentityStart => 'Verify now';

  @override
  String get onbIdentityLicenseHint =>
      'Your licence can be used as the document: no need to photograph it again.';

  @override
  String get onbIdentityPrivacy =>
      'Your photos are analysed on our servers, with no outside service.';

  @override
  String get onbBiometricTitle => 'Sign in with one touch';

  @override
  String get onbBiometricBody =>
      'Open the app with your fingerprint or face, without typing your password again.';

  @override
  String get onbBiometricEnable => 'Turn on';

  @override
  String onbDoneTitle(String name) {
    return 'You\'re all set,\n$name';
  }

  @override
  String get onbDoneBody =>
      'You can report an accident at any time, even without signal.';

  @override
  String get onbDoneLater =>
      'You can finish the rest from your profile whenever you like.';

  @override
  String get onbDoneStart => 'Go to the app';

  @override
  String get onbItemPhone => 'Phone';

  @override
  String get onbItemLicense => 'Driving licence';

  @override
  String get onbItemIdentity => 'Identity';

  @override
  String get onbItemBiometric => 'Biometric sign-in';

  @override
  String get onbStateDone => 'Done';

  @override
  String get onbStatePending => 'Being checked';

  @override
  String get onbStateTodo => 'To do';

  @override
  String get registerStepAccount => 'Your account';

  @override
  String get onbWelcomeNewTitle => 'Welcome to\nMon Constat';

  @override
  String get onbProfileTitle => 'Let\'s get to know you';

  @override
  String get onbProfileBody =>
      'Your name appears on your accident reports. Your number is used to sign in and follow your claims.';

  @override
  String get onbPhoneTitle => 'Confirm your number';

  @override
  String get onbCodeSent => 'New code sent.';

  @override
  String get onbReadingTitle => 'Read on the document';

  @override
  String get correctReading => 'Correct';

  @override
  String get correctReadingTitle => 'Correct the document reading';

  @override
  String get correctReadingHint =>
      'Fix what the AI misread by copying the document. Dates as YYYY-MM-DD.';

  @override
  String get readingCorrected => 'Reading corrected';

  @override
  String get readLastName => 'Surname';

  @override
  String get readFirstName => 'Given name';

  @override
  String get readBirthDate => 'Date of birth';

  @override
  String get readBirthPlace => 'Place of birth';

  @override
  String get claimsDecisionHelpGuide =>
      'Decision help: priority, estimate, risk and missing documents for this claim. Tap the icon to open it.';

  @override
  String claimsTimelineEarlier(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count earlier steps',
      one: '1 earlier step',
    );
    return '$_temp0';
  }

  @override
  String get claimsAlertOpen => 'View';

  @override
  String get claimsTimelineCollapse => 'Show less';

  @override
  String get dashClaimsTotal => 'Claims';

  @override
  String get dashClaimsOpen => 'Open';

  @override
  String get dashClaimsClosed => 'Closed';

  @override
  String get dashAvgClose => 'Average time to close';

  @override
  String dashDays(String days) {
    return '$days d';
  }

  @override
  String dashIndemnities(String amount) {
    return 'Indemnities paid: $amount TND';
  }

  @override
  String get dashByStatus => 'By status';

  @override
  String get dashBySeverity => 'By severity';

  @override
  String get dashByCompany => 'By insurer';

  @override
  String get dashByMonth => 'Claims over the last 6 months';

  @override
  String dashHotspots(int count) {
    return 'Locations of reported accidents ($count)';
  }

  @override
  String get dashNoPoints => 'No located declaration yet.';

  @override
  String get dashNoCompany => 'No insurer';

  @override
  String get vehAddVehicle => 'Add a vehicle';

  @override
  String get vehEditVehicle => 'Edit vehicle';

  @override
  String get vehEdit => 'Edit';

  @override
  String get vehArchive => 'Archive';

  @override
  String get vehUnarchive => 'Unarchive';

  @override
  String get vehDelete => 'Delete';

  @override
  String get vehCancel => 'Cancel';

  @override
  String get vehInsurance => 'Insurance';

  @override
  String get vehInsuranceContract => 'Insurance contract';

  @override
  String get vehTechnicalInspection => 'Technical inspection';

  @override
  String get vehMileage => 'Mileage';

  @override
  String vehMileageValue(int thousands) {
    return '$thousands,000 km';
  }

  @override
  String get vehType => 'Type';

  @override
  String get vehFuel => 'Fuel';

  @override
  String get vehYear => 'Year';

  @override
  String get vehColor => 'Color';

  @override
  String get vehPolicyNumber => 'Policy no.';

  @override
  String get vehExpiredBadge => 'EXPIRED';

  @override
  String get vehStatusOk => 'OK';

  @override
  String vehDaysShort(int days) {
    return '${days}d';
  }

  @override
  String vehDaysOverdue(int days) {
    return '${days}d\noverdue';
  }

  @override
  String get vehDateHint => 'DD/MM/YYYY';

  @override
  String get vehTypeCar => 'Car';

  @override
  String get vehTypeMoto => 'Motorcycle';

  @override
  String get vehTypeTruck => 'Truck';

  @override
  String get vehTypeVan => 'Van';

  @override
  String get vehOther => 'Other';

  @override
  String get vehFuelPetrol => 'Petrol';

  @override
  String get vehFuelDiesel => 'Diesel';

  @override
  String get vehFuelElectric => 'Electric';

  @override
  String get vehFuelHybrid => 'Hybrid';

  @override
  String get vehAlertsTitle => 'Expiry alerts';

  @override
  String get vehAlertsEmptyTitle => 'No active alerts';

  @override
  String get vehAlertsEmptyBody =>
      'All your contracts and technical inspections\nare up to date.';

  @override
  String get vehAlertsGroupExpired => 'Expired';

  @override
  String get vehAlertsGroupExpiring => 'Expiring soon';

  @override
  String get vehAlertsSummaryExpired => 'Expired';

  @override
  String get vehAlertsSummaryNear => 'Upcoming';

  @override
  String get vehAlertsSummaryTotal => 'Total';

  @override
  String get vehAlertInsuranceExpired => 'Insurance EXPIRED';

  @override
  String vehAlertInsuranceExpiring(int days) {
    return 'Insurance expires in $days d.';
  }

  @override
  String get vehAlertTechnicalExpired => 'Technical inspection EXPIRED';

  @override
  String vehAlertTechnicalExpiring(int days) {
    return 'Technical inspection in $days d.';
  }

  @override
  String get vehListTitle => 'Vehicles & contracts';

  @override
  String vehListActiveCount(int count) {
    return '$count active vehicle(s)';
  }

  @override
  String vehTabActive(int count) {
    return 'Active ($count)';
  }

  @override
  String vehTabArchived(int count) {
    return 'Archived ($count)';
  }

  @override
  String get vehEmptyArchived => 'No archived vehicles';

  @override
  String get vehEmptyActive => 'Add your first vehicle';

  @override
  String vehPolicyValue(String policy) {
    return 'Policy $policy';
  }

  @override
  String get vehAiAnalysis => 'AI analysis';

  @override
  String get vehDeleteTitle => 'Delete this vehicle?';

  @override
  String vehDeleteBody(String name, String plate) {
    return '$name ($plate) will be permanently deleted.';
  }

  @override
  String get vehSectionInfo => 'Details';

  @override
  String get vehRenew => 'Renew';

  @override
  String get vehInsurer => 'Insurer';

  @override
  String get vehExpiry => 'Expiry';

  @override
  String get vehPremiumTitle => 'Estimated insurance premium (AI)';

  @override
  String vehPremiumValue(String amount) {
    return '$amount TND / year';
  }

  @override
  String get vehNextInspection => 'Next inspection';

  @override
  String get vehClaimsHistory => 'Claims history';

  @override
  String get vehClaimsDeclared => 'Claims filed';

  @override
  String get vehRenewTitle => 'Renew insurance contract';

  @override
  String get vehExpiryDate => 'Expiry date';

  @override
  String get vehRenewInvalid =>
      'Invalid date (DD/MM/YYYY) or missing policy number.';

  @override
  String get vehRenewSuccess => 'Insurance contract renewed!';

  @override
  String get vehRiskTitle => 'AI risk analysis';

  @override
  String get vehRiskSubtitle => 'Calculated from your local data';

  @override
  String get vehRiskFactors => 'Detected factors';

  @override
  String get vehRecommendations => 'Recommendations';

  @override
  String get vehPhotoTitle => 'Vehicle photo';

  @override
  String get vehAddPhoto => 'Add a photo';

  @override
  String get vehTakePhoto => 'Take a photo';

  @override
  String get vehPickFromGallery => 'Choose from gallery';

  @override
  String get vehRiskVeryOld => 'Very old vehicle';

  @override
  String get vehRiskVeryOldDesc => 'Over 20 years old — high mechanical risk.';

  @override
  String get vehRiskOld => 'Old vehicle';

  @override
  String vehRiskOldDesc(int age) {
    return '$age years old — regular servicing recommended.';
  }

  @override
  String get vehRiskMidAge => 'Middle-aged vehicle';

  @override
  String vehRiskMidAgeDesc(int age) {
    return '$age years old — check the registration certificate.';
  }

  @override
  String vehRiskInsExpiredDesc(int days) {
    return 'Expired $days day(s) ago — driving is illegal.';
  }

  @override
  String get vehRiskInsCritical => 'Insurance critical';

  @override
  String vehRiskInsCriticalDesc(int days) {
    return 'Expires in $days day(s) — renew urgently.';
  }

  @override
  String get vehRiskInsSoon => 'Insurance expiring soon';

  @override
  String vehRiskExpiresIn(int days) {
    return 'Expires in $days day(s).';
  }

  @override
  String get vehRiskTechExpired => 'Technical inspection expired';

  @override
  String vehRiskExpiredSince(int days) {
    return 'Expired $days day(s) ago.';
  }

  @override
  String get vehRiskTechImminent => 'Technical inspection imminent';

  @override
  String vehRiskInDays(int days) {
    return 'In $days day(s).';
  }

  @override
  String get vehRiskTechNear => 'Technical inspection coming up';

  @override
  String get vehRiskTechUnknown => 'Technical inspection date unknown';

  @override
  String get vehRiskTechUnknownDesc => 'Add the date for accurate tracking.';

  @override
  String get vehRiskKmVeryHigh => 'Very high mileage';

  @override
  String vehRiskKmVeryHighDesc(int thousands) {
    return '$thousands,000 km — significant wear.';
  }

  @override
  String get vehRiskKmHigh => 'High mileage';

  @override
  String get vehRiskKmModerate => 'Moderate mileage';

  @override
  String vehRiskKmDesc(int thousands) {
    return '$thousands,000 km.';
  }

  @override
  String get vehRiskClaimsHigh => 'High claims history';

  @override
  String vehRiskClaimsHighDesc(int count) {
    return '$count claim(s) recorded.';
  }

  @override
  String get vehRiskClaimsMulti => 'Multiple claims';

  @override
  String get vehRiskClaimsMultiDesc => '2 claims recorded.';

  @override
  String get vehRiskClaimsOne => 'Previous claim';

  @override
  String get vehRiskClaimsOneDesc => '1 claim recorded.';

  @override
  String get vehRiskOldDiesel => 'Old diesel';

  @override
  String get vehRiskOldDieselDesc =>
      'Particulate risk and increased engine wear.';

  @override
  String get vehRecRenewNow => 'Renew your insurance immediately.';

  @override
  String get vehRecSeeInsurer =>
      'Book an appointment with your insurer in the next few days.';

  @override
  String get vehRecTechNow =>
      'Get your technical inspection done as soon as possible.';

  @override
  String get vehRecTechSchedule => 'Schedule your technical inspection soon.';

  @override
  String get vehRecTechAddDate =>
      'Add the date of your next technical inspection.';

  @override
  String get vehRecFullCheck => 'Get a full check-up at an approved garage.';

  @override
  String get vehRecBeltBrakes => 'Check the timing belt and brake pads.';

  @override
  String get vehRecDefensive => 'Consider defensive driving to reduce claims.';

  @override
  String get vehRecAddMileage =>
      'Enter the mileage for a more accurate analysis.';

  @override
  String get vehRecAllGood =>
      'Your vehicle is in order. Keep up regular maintenance.';

  @override
  String get vehScanNothing =>
      'Nothing could be read. Retake the photo flat and well lit.';

  @override
  String vehScanRead(String fields) {
    return 'Read by AI: $fields. Check before saving.';
  }

  @override
  String get vehScanEstimated =>
      'Expiry date estimated at one year: please check it.';

  @override
  String vehScanFailed(String error) {
    return 'Could not read: $error';
  }

  @override
  String get vehScanBusy => 'Reading… (up to 30 s)';

  @override
  String get vehScanRegistration => 'Photograph the registration certificate';

  @override
  String get vehScanInsurance => 'Photograph the insurance certificate';

  @override
  String get vehReadPlate => 'registration number';

  @override
  String get vehReadBrand => 'make';

  @override
  String get vehReadModel => 'model';

  @override
  String get vehReadYear => 'year';

  @override
  String get vehReadPolicy => 'contract no.';

  @override
  String get vehReadExpiry => 'expiry date';

  @override
  String get vehReadInsurer => 'insurer';

  @override
  String vehReadInsurerToPick(String insurer) {
    return 'insurer ($insurer, pick it from the list)';
  }

  @override
  String get vehScanTitle => 'Scan your documents with AI';

  @override
  String get vehScanBody =>
      'One photo of the registration certificate or insurance certificate: AI fills in the form, you check it.';

  @override
  String get vehSectionIdentification => 'Vehicle identification';

  @override
  String get vehPlateRequired => 'Registration number *';

  @override
  String get vehPlateHint => 'e.g. 215 تونس 4521';

  @override
  String get vehBrandRequired => 'Make *';

  @override
  String get vehModelRequired => 'Model *';

  @override
  String get vehYearRequired => 'Year *';

  @override
  String get vehColorHint => 'White';

  @override
  String get vehKmUnit => 'km';

  @override
  String get vehPolicyNumberRequired => 'Policy no. *';

  @override
  String get vehInsuranceExpiryRequired => 'Insurance expiry date *';

  @override
  String get vehNextInspectionField => 'Next technical inspection';

  @override
  String get vehSaveChanges => 'Save changes';

  @override
  String get vehAddVehicleButton => 'Add vehicle';

  @override
  String get vehFieldRequired => 'Required field.';

  @override
  String get vehYearInvalid => 'Invalid year.';

  @override
  String get vehDateFormat => 'Format DD/MM/YYYY.';

  @override
  String get accStepContext => 'Context';

  @override
  String get accStepContextHint => 'Place, time and conditions';

  @override
  String get accStepDescription => 'Description';

  @override
  String get accStepDescriptionHint => 'Type, severity and witnesses';

  @override
  String get accStepEvidence => 'Evidence';

  @override
  String get accStepEvidenceHint => 'Photos, video and voice note';

  @override
  String get accStepDriverBHint => 'Identity and insurance';

  @override
  String get accStepCircumstances => 'Circumstances';

  @override
  String get accStepCircumstancesHint => 'Boxes and remarks';

  @override
  String get accStepSketch => 'Sketch';

  @override
  String get accStepSketchHint => 'Impact and diagram';

  @override
  String get accStepSignatures => 'Signatures';

  @override
  String get accStepSignaturesHint => 'Approval and sending';

  @override
  String accStepOf(int step, int total) {
    return 'Step $step of $total';
  }

  @override
  String accMinutesLeft(int minutes) {
    return '~$minutes min';
  }

  @override
  String get accDriverA => 'Driver A';

  @override
  String get accDriverB => 'Driver B';

  @override
  String get accNewDeclaration => 'New declaration';

  @override
  String get accDraft => 'Draft';

  @override
  String get accFinishDriverBFirst => 'Finish driver B’s details first.';

  @override
  String get accContinue => 'Continue';

  @override
  String get accContinueToReport => 'Continue to the accident report';

  @override
  String get accIAmDriverB => 'I am driver B';

  @override
  String get accFinishAndReturnPhone => 'Finish and hand the phone back';

  @override
  String get accSignAndSend => 'Sign and send';

  @override
  String get accIAmDriverA => 'I am driver A';

  @override
  String get accBack => 'Back';

  @override
  String get accDraftSaved => 'Draft saved on this device';

  @override
  String get accThanks => 'Thank you!';

  @override
  String get accReturnPhoneText =>
      'Now hand the phone back to driver A. Both drivers will sign together at the end of the report.';

  @override
  String get accChooseVehicleFirst => 'Choose your vehicle in the first step.';

  @override
  String get accSealingTitle => 'Cryptographic sealing of the report…';

  @override
  String get accSealingHint => 'Computing the SHA-256 hash and sending';

  @override
  String accSealFailed(String error) {
    return 'The report could not be sealed: $error';
  }

  @override
  String get accVerifyIdentityTitle => 'Verify your identity to sign';

  @override
  String get accVerifyIdentityText =>
      'The report binds both drivers: your identity must be verified before signing. Your draft stays saved.';

  @override
  String get accLater => 'Later';

  @override
  String get accVerifyIdentity => 'Verify my identity';

  @override
  String get accCheckPlace => 'Check the accident location.';

  @override
  String get accWitnessPhoneInvalid => 'Add a valid number for the witness.';

  @override
  String get accMinPhotos => 'Add at least 2 photos before continuing.';

  @override
  String get accDriverBIncomplete =>
      'Fill in driver B’s name, plate number and insurance.';

  @override
  String get accCircumstanceRequired =>
      'Select at least one circumstance for vehicle A or B.';

  @override
  String get accSketchRequired => 'Confirm the sketch and an impact area.';

  @override
  String get accSignaturesRequired => 'Both drivers must sign the report.';

  @override
  String accLocalDraftSaved(String time) {
    return 'Local draft • saved at $time';
  }

  @override
  String get accHandoverTitle => 'Hand the phone to driver B';

  @override
  String get accHandoverText =>
      'They fill in their own identity, licence, vehicle and insurance.';

  @override
  String get accHandoverHidden =>
      'Your details stay hidden: going back to earlier steps is locked while they type.';

  @override
  String get accHandoverScan =>
      'They can take a photo of their licence: AI fills in the fields.';

  @override
  String get accHandoverReturn =>
      'At the end, they hand the phone back to you.';

  @override
  String get accChooseVehicle =>
      'Choose your vehicle: its insurer receives the report.';

  @override
  String accInsuranceExpired(String vehicle, String date) {
    return 'The insurance contract for $vehicle expired on $date. Renew it in Vehicles before declaring.';
  }

  @override
  String get accYourVehicle => 'YOUR VEHICLE';

  @override
  String get accAddVehicleHint =>
      'Add your vehicle and its insurer: the report is sent to them.';

  @override
  String get accAddMyVehicle => 'Add my vehicle';

  @override
  String accContractExpiredOn(String date) {
    return 'Contract expired on $date';
  }

  @override
  String get accInsurerMissing => 'Insurer not specified';

  @override
  String accInsuredUntil(String insurer, String date) {
    return '$insurer · until $date';
  }

  @override
  String get accWhereWhen => 'Where and when?';

  @override
  String get accWhereWhenHint => 'Check the automatically detected details.';

  @override
  String get accPlaceRequired => 'Enter the accident location';

  @override
  String get accAccidentPlace => 'Accident location';

  @override
  String get accChooseOnMap => 'Choose on the map';

  @override
  String accGpsLine(String coords, int accuracy) {
    return 'GPS $coords • accuracy ±$accuracy m';
  }

  @override
  String get accDateTime => 'Date and time';

  @override
  String get accWeather => 'Weather';

  @override
  String get accRoad => 'Road surface';

  @override
  String get accLight => 'Lighting';

  @override
  String get accPlaceConfirmed => 'Accident location confirmed and saved.';

  @override
  String get accPositionUnavailable =>
      'Location unavailable. Try again in a moment.';

  @override
  String get accPositionDetected => 'Location detected';

  @override
  String accUseDetectedQuestion(String place) {
    return '$place\n\nDo you want to use this location?';
  }

  @override
  String get accChooseAnother => 'Choose another';

  @override
  String get accUsePosition => 'Use this location';

  @override
  String get accAutoLocationFailed => 'Automatic location failed.';

  @override
  String get accLocationDisabled => 'Turn on the device’s GPS location.';

  @override
  String get accLocationDenied => 'Location permission was denied.';

  @override
  String get accLocationDeniedForever =>
      'Allow location access in the app settings.';

  @override
  String get accAddressNotFound => 'Address not found.';

  @override
  String get accValueSunny => 'Sunny';

  @override
  String get accValueRain => 'Rain';

  @override
  String get accValueFog => 'Fog';

  @override
  String get accValueDry => 'Dry';

  @override
  String get accValueWet => 'Wet';

  @override
  String get accValueSlippery => 'Slippery';

  @override
  String get accValueDay => 'Daylight';

  @override
  String get accValueDusk => 'Dusk';

  @override
  String get accValueNightLit => 'Night, lit';

  @override
  String get accValueNightDark => 'Night, unlit';

  @override
  String get accEvidenceOverview => 'Overview';

  @override
  String get accEvidenceDamageA => 'Vehicle A damage';

  @override
  String get accEvidenceDamageB => 'Vehicle B damage';

  @override
  String get accEvidencePlates => 'Plates';

  @override
  String get accWhatHappened => 'What happened?';

  @override
  String get accWhatHappenedHint => 'This helps us prioritise your claim.';

  @override
  String get accAccidentType => 'Accident type';

  @override
  String get accSeverity => 'Severity';

  @override
  String get accVehicles => 'Vehicles';

  @override
  String get accInjured => 'Injured';

  @override
  String get accSecureArea => 'Secure the area and call emergency services';

  @override
  String get accSamu => 'Ambulance (SAMU)';

  @override
  String get accPolice => 'Police';

  @override
  String get accCivilProtection => 'Civil protection';

  @override
  String accCalling(String number) {
    return 'Calling $number';
  }

  @override
  String get accWitnessOptional => 'Witness (optional)';

  @override
  String get accWitnessName => 'Witness name';

  @override
  String get accPhone => 'Phone';

  @override
  String get accGuidedPhotos => 'Guided photos';

  @override
  String accPhotosProgress(int count) {
    return '$count/4 views added • at least 2 required';
  }

  @override
  String get accPhotoSaved => 'Photo saved • tap to retake';

  @override
  String get accTapToOpenCamera => 'Tap to open the camera';

  @override
  String get accSceneVideo => 'Scene video';

  @override
  String get accOpeningCamera => 'Opening the camera…';

  @override
  String get accVideoSaved => 'Video saved • tap to play';

  @override
  String get accFilmScene => 'Film the scene • 30 seconds max';

  @override
  String get accStopRecording => 'Stop recording';

  @override
  String get accVoiceNote => 'Voice note';

  @override
  String get accRecordingInProgress => 'Recording… tap to stop';

  @override
  String get accVoiceNoteSaved => 'Note saved • tap to listen';

  @override
  String get accDescribeByVoice => 'Describe the scene with your voice';

  @override
  String get accVideoSaveFailed => 'Could not record the video.';

  @override
  String get accMicPermission => 'Allow the microphone to record a voice note.';

  @override
  String get accMicFailed => 'Could not start the microphone.';

  @override
  String get accVideoMissing =>
      'The video no longer exists. You can record it again.';

  @override
  String get accVoiceNoteMissing =>
      'The voice note no longer exists. You can record it again.';

  @override
  String get accListen => 'Listen';

  @override
  String get accRedoRecording => 'Record again';

  @override
  String get accDelete => 'Delete';

  @override
  String get accPause => 'Pause';

  @override
  String get accPlay => 'Play';

  @override
  String get accSummary => 'SUMMARY';

  @override
  String accSummaryCounts(int vehicles, int injured, int photos) {
    return '$vehicles vehicle(s) • $injured injured • $photos photo(s)';
  }

  @override
  String get accReportCompleted => 'Report completed';

  @override
  String get accReviewHint => 'Check all the details before sending.';

  @override
  String get accSectionAccident => 'Accident';

  @override
  String get accPlace => 'Place';

  @override
  String get accType => 'Type';

  @override
  String get accConditions => 'Conditions';

  @override
  String get accVehiclesInjured => 'Vehicles / injured';

  @override
  String accVehiclesInjuredValue(int vehicles, int injured) {
    return '$vehicles vehicle(s) • $injured injured';
  }

  @override
  String get accWitness => 'Witness';

  @override
  String get accSectionDriverA => 'Driver & vehicle A';

  @override
  String get accName => 'Name';

  @override
  String get accLicense => 'Licence';

  @override
  String get accVehicle => 'Vehicle';

  @override
  String get accPlate => 'Plate number';

  @override
  String get accInsurance => 'Insurance';

  @override
  String get accPolicyNumber => 'Policy number';

  @override
  String get accLicenseExpiry => 'Licence valid until';

  @override
  String get accObservations => 'Remarks';

  @override
  String get accImpactZones => 'Impact areas';

  @override
  String get accPhotos => 'Photos';

  @override
  String get accSketchMissing => 'Sketch missing';

  @override
  String get accPdfFailed => 'Could not generate the PDF. Try again.';

  @override
  String get accPdfTitle => 'PDF report';

  @override
  String get accPdfHint =>
      'The document includes the official details, photos, sketch and signatures.';

  @override
  String get accPreview => 'Preview';

  @override
  String get accShare => 'Share';

  @override
  String get accNotProvided => 'Not provided';

  @override
  String get accNoPhotos => 'No photos saved.';

  @override
  String get accMyDeclarations => 'My declarations';

  @override
  String get accMyDeclarationsHint => 'Drafts and submitted claims';

  @override
  String get accDraftInProgress => 'DRAFT IN PROGRESS';

  @override
  String get accResume => 'Resume';

  @override
  String get accSentDeclarations => 'SUBMITTED DECLARATIONS';

  @override
  String get accNoSentDeclarations => 'No declarations submitted.';

  @override
  String get accDeleteDraftTitle => 'Delete the draft?';

  @override
  String get accDeleteDraftText => 'Unsent information will be lost.';

  @override
  String get accCancel => 'Cancel';

  @override
  String get accEmergencyNumbers => 'Emergency numbers';

  @override
  String get accSearchAddress => 'Search for an address';

  @override
  String get accSearch => 'Search';

  @override
  String get accMyPosition => 'My location';

  @override
  String get accSelectedPlace => 'SELECTED PLACE';

  @override
  String get accConfirmPlace => 'Confirm this place';

  @override
  String get accMinChars => 'Type at least 3 characters.';

  @override
  String get accPlaceFetchFailed => 'Could not get this place.';

  @override
  String get cstNotProvided => 'Not provided';

  @override
  String get cstClear => 'Clear';

  @override
  String get cstEdit => 'Edit';

  @override
  String get cstTapToDrawFullscreen => 'Tap to draw in full screen';

  @override
  String get cstCloseWithoutSaving => 'Close without saving';

  @override
  String get cstUndoLastStroke => 'Undo last stroke';

  @override
  String get cstClearAll => 'Clear all';

  @override
  String get cstDone => 'Done';

  @override
  String get cstSignHint => 'Sign with your finger or a stylus';

  @override
  String get cstGuestModeTitle => 'Guest mode — Driver B';

  @override
  String get cstShareWithDriverB => 'Share with driver B';

  @override
  String get cstGuestQrInstructions =>
      'Have driver B scan this QR code with their smartphone to check their details and follow the report live.';

  @override
  String get cstNoInstallRequired =>
      'Driver B doesn’t need to install the app.';

  @override
  String get cstGuestLinkCopied => 'Guest link copied to clipboard!';

  @override
  String get cstCopyGuestLink => 'Copy guest access link';

  @override
  String get cstContinueOnThisDevice => 'Continue on this device';

  @override
  String get cstSealedTitle => 'Sealed report';

  @override
  String get cstSealedOnPhone => 'Report sealed on the phone';

  @override
  String get cstSealedAndSent => 'Report sealed and sent';

  @override
  String get cstSealedOfflineHint =>
      'No network: it will be sent and signed by the server as soon as you’re back online.';

  @override
  String get cstSealedOnlineHint =>
      'Tamper-proof official document signed by both parties.';

  @override
  String get cstOfflineCertification => 'OFFLINE CERTIFICATION (JWS)';

  @override
  String get cstScanQrToVerify =>
      'Scan this QR code to verify the report’s authenticity and integrity without contacting the server.';

  @override
  String get cstCertifiedQr => 'Certified QR code';

  @override
  String get cstEcdsaCertified =>
      'Certified ECDSA P-256 signature — zero-dependency verification';

  @override
  String get cstVehicleA => 'Vehicle A';

  @override
  String get cstVehicleB => 'Vehicle B';

  @override
  String get cstDriverA => 'Driver A';

  @override
  String get cstDriverB => 'Driver B';

  @override
  String get cstPlateA => 'Plate A';

  @override
  String get cstPlateB => 'Plate B';

  @override
  String get cstInsurerA => 'Insurer A';

  @override
  String get cstInsurerB => 'Insurer B';

  @override
  String cstPolicyLine(String policy) {
    return 'Policy: $policy';
  }

  @override
  String get cstViewOfficialPdf => 'View the official copy (PDF)';

  @override
  String get cstShareSealed => 'Share the sealed report';

  @override
  String get cstBackToHome => 'Back to home';

  @override
  String cstPdfPreviewError(String error) {
    return 'PDF preview error: $error';
  }

  @override
  String cstPdfShareError(String error) {
    return 'PDF sharing error: $error';
  }

  @override
  String get cstDriverBTitle => 'Driver B details';

  @override
  String get cstDriverBSubtitle =>
      'Data needed for the report, kept separate from your profile.';

  @override
  String get cstScanLicenseAi => 'Scan the licence with AI';

  @override
  String get cstScanLicenseHint =>
      'The photo is analysed locally. Always check the detected data.';

  @override
  String get cstScanning => 'Analysing…';

  @override
  String get cstTakeLicensePhoto => 'Take a photo of the licence';

  @override
  String get cstFullNameRequired => 'Full name *';

  @override
  String get cstLicenseNumber => 'Licence number';

  @override
  String get cstLicenseExpiry => 'Licence expiry date';

  @override
  String get cstPlateRequired => 'Plate number *';

  @override
  String get cstInsuranceSection => 'INSURANCE';

  @override
  String get cstPolicyNumber => 'Policy / insurance certificate no.';

  @override
  String get cstNoTextDetected =>
      'No text detected. Retake the photo with more light.';

  @override
  String get cstLicenseScanned =>
      'Licence analysed. Check the fields before continuing.';

  @override
  String get cstScanFailed =>
      'Couldn’t analyse it. Check the photo and try again.';

  @override
  String get cstReviewDetectedData => 'Check the detected data';

  @override
  String get cstOcrWarning =>
      'Text recognition can make mistakes. Correct the fields before confirming.';

  @override
  String get cstFullName => 'Full name';

  @override
  String get cstLicenseNumberDialog => 'Licence number';

  @override
  String get cstExpiryDate => 'Expiry date';

  @override
  String get cstRecognizedText => 'Text recognised by ML Kit';

  @override
  String get cstCancel => 'Cancel';

  @override
  String get cstUseThisData => 'Use this data';

  @override
  String get cstClearDate => 'Clear date';

  @override
  String get cstCircumstancesTitle => 'Accident circumstances (FTUSA)';

  @override
  String get cstCircumstancesHint =>
      'Tick the relevant boxes for vehicle A (blue) and vehicle B (amber).';

  @override
  String cstBoxesA(int count) {
    return 'Vehicle A: $count box(es)';
  }

  @override
  String cstBoxesB(int count) {
    return 'Vehicle B: $count box(es)';
  }

  @override
  String get cstCircumstancesHeader => '12. Circumstances';

  @override
  String get cstCircumstance1 => 'Parked / Stationary';

  @override
  String get cstCircumstance2 => 'Leaving a parking space / opening a door';

  @override
  String get cstCircumstance3 => 'Pulling into a parking space';

  @override
  String get cstCircumstance4 =>
      'Leaving a car park, private property or track';

  @override
  String get cstCircumstance5 =>
      'Entering a car park, private property or track';

  @override
  String get cstCircumstance6 => 'Entering a roundabout';

  @override
  String get cstCircumstance7 => 'Driving on a roundabout';

  @override
  String get cstCircumstance8 => 'Hit the rear (same direction, same lane)';

  @override
  String get cstCircumstance9 =>
      'Driving in the same direction in a different lane';

  @override
  String get cstCircumstance10 => 'Changing lanes';

  @override
  String get cstCircumstance11 => 'Overtaking';

  @override
  String get cstCircumstance12 => 'Turning right';

  @override
  String get cstCircumstance13 => 'Turning left';

  @override
  String get cstCircumstance14 => 'Reversing';

  @override
  String get cstCircumstance15 => 'Crossing into the oncoming lane';

  @override
  String get cstCircumstance16 => 'Coming from the right (at a junction)';

  @override
  String get cstCircumstance17 => 'Failed to observe a right-of-way sign';

  @override
  String get cstObservations => 'Additional remarks';

  @override
  String get cstSketchTitle => 'Sketch and point of impact';

  @override
  String get cstSketchFieldTitle => 'Accident sketch';

  @override
  String get cstSketchHint =>
      'Draw the lanes, the vehicles and their direction';

  @override
  String get cstImpactZoneTitle => 'Point of impact on your vehicle';

  @override
  String get cstSignInstructions =>
      'Review the details, then sign in both boxes.';

  @override
  String get cstSignatureA => 'Driver A signature';

  @override
  String get cstSignatureB => 'Driver B signature';

  @override
  String get cstShaLock => 'SHA-256 lock';

  @override
  String get cstShaLockHint =>
      'The report becomes tamper-proof once both parties have signed.';
}
