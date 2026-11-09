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
      'An administrator checks your ID card. It is required to sign an accident report.';

  @override
  String get identityPendingNote =>
      'An administrator is checking your documents. You will be told on WhatsApp and by email.';

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
  String get identityPhotosRequired =>
      'Add the front and back of your ID card.';

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
  String get rejectReasonNotCin => 'Not an ID card';

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
  String get errorCinInUse => 'This ID card number is already used.';

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
  String get selectRequest => 'Select a request to see the ID card.';

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
}
