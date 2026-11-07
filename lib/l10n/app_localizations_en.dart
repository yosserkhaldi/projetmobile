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
    return 'Enter the 6-digit code sent by SMS to $phone.';
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
      'A new number will need to be verified by SMS.';

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
}
