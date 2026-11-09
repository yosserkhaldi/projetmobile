// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

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
}
