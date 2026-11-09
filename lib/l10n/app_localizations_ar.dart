// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'Mon Constat Digital';

  @override
  String get brand => 'Mon Constat';

  @override
  String get save => 'حفظ';

  @override
  String get cancel => 'إلغاء';

  @override
  String get delete => 'حذف';

  @override
  String get edit => 'تعديل';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get later => 'لاحقًا';

  @override
  String get or => 'أو';

  @override
  String get validate => 'تأكيد';

  @override
  String get notProvided => 'غير محدد';

  @override
  String get requiredField => 'حقل إلزامي.';

  @override
  String get invalidEmail => 'بريد إلكتروني غير صالح.';

  @override
  String get invalidPhone => 'رقم هاتف غير صالح.';

  @override
  String get passwordTooShort =>
      'يجب أن تحتوي كلمة المرور على 8 أحرف على الأقل.';

  @override
  String get codeFormat => 'يتكوّن الرمز من 6 أرقام.';

  @override
  String get passwordsDontMatch => 'كلمتا المرور غير متطابقتين.';

  @override
  String get roleDriver => 'سائق';

  @override
  String get roleAgent => 'عون تأمين';

  @override
  String get roleAdmin => 'مسؤول';

  @override
  String get heroTitleLine1 => 'المعاينة الودية،';

  @override
  String get heroTitleLine2 => 'بدون ورق.';

  @override
  String get heroSubtitle => 'صرّح بالحادث ووقّع وتابع ملفك من هاتفك.';

  @override
  String get loginTitle => 'تسجيل الدخول';

  @override
  String get identifierLabel => 'البريد الإلكتروني أو الهاتف';

  @override
  String get passwordLabel => 'كلمة المرور';

  @override
  String get forgotPasswordLink => 'نسيت كلمة المرور؟';

  @override
  String get signIn => 'تسجيل الدخول';

  @override
  String get biometricButton => 'البصمة أو التعرّف على الوجه';

  @override
  String get noAccount => 'ليس لديك حساب؟';

  @override
  String get createAccountLink => 'إنشاء حساب';

  @override
  String get showPassword => 'إظهار كلمة المرور';

  @override
  String get hidePassword => 'إخفاء كلمة المرور';

  @override
  String get biometricLoginReason => 'سجّل الدخول إلى Mon Constat';

  @override
  String get biometricEnableReason => 'أكّد لتفعيل الدخول بالبصمة';

  @override
  String get languageSwitcher => 'لغة التطبيق';

  @override
  String get registerTitle => 'إنشاء حساب';

  @override
  String get firstNameLabel => 'الاسم';

  @override
  String get lastNameLabel => 'اللقب';

  @override
  String get emailLabel => 'البريد الإلكتروني';

  @override
  String get phoneLabel => 'الهاتف';

  @override
  String get confirmPasswordLabel => 'تأكيد كلمة المرور';

  @override
  String get createMyAccount => 'إنشاء حسابي';

  @override
  String get otpTitle => 'التحقق من هاتفي';

  @override
  String otpInstructions(String phone) {
    return 'أدخل الرمز المكوّن من 6 أرقام المرسل عبر واتساب إلى $phone.';
  }

  @override
  String get otpCodeLabel => 'رمز التحقق';

  @override
  String get resendCode => 'إعادة إرسال الرمز';

  @override
  String resendCodeIn(int seconds) {
    return 'إعادة إرسال الرمز ($seconds ث)';
  }

  @override
  String get forgotTitle => 'نسيت كلمة المرور';

  @override
  String get forgotIntro => 'أدخل بريدك الإلكتروني لتتلقى رمز إعادة التعيين.';

  @override
  String forgotCodeSent(String email) {
    return 'إذا كان هناك حساب مرتبط بـ $email، فقد أُرسل إليه رمز صالح لمدة 15 دقيقة.';
  }

  @override
  String get codeFromEmailLabel => 'الرمز المستلم عبر البريد';

  @override
  String get newPasswordLabel => 'كلمة المرور الجديدة';

  @override
  String get receiveCode => 'تلقّي رمز';

  @override
  String get changePassword => 'تغيير كلمة المرور';

  @override
  String get passwordChanged => 'تم تغيير كلمة المرور. يمكنك تسجيل الدخول.';

  @override
  String get profileTitle => 'ملفي الشخصي';

  @override
  String get profileSubtitle => 'الهوية ورخصة السياقة والتفضيلات';

  @override
  String profileCompletion(int percent) {
    return 'اكتمل الملف بنسبة $percent٪';
  }

  @override
  String get profileCompleteHint =>
      'أكمل بيانات رخصة السياقة: ستُستعمل لتعبئة المعاينة.';

  @override
  String get profileComplete => 'الملف مكتمل وجاهز للمعاينة.';

  @override
  String get sectionIdentity => 'الهوية';

  @override
  String get sectionLicense => 'رخصة السياقة';

  @override
  String get sectionSecurity => 'الأمان';

  @override
  String get sectionPreferences => 'التفضيلات';

  @override
  String get fullNameLabel => 'الاسم الكامل';

  @override
  String get emailNotEditable => 'لا يمكن تغيير البريد الإلكتروني.';

  @override
  String get phoneVerified => 'الرقم مؤكَّد';

  @override
  String get phoneNotVerified => 'الرقم غير مؤكَّد';

  @override
  String get verify => 'تأكيد';

  @override
  String get licenseNumberLabel => 'رقم الرخصة';

  @override
  String get licenseCategoryLabel => 'الصنف';

  @override
  String get licenseIssuedLabel => 'تاريخ الإصدار';

  @override
  String get licenseEmpty =>
      'لا توجد رخصة مسجّلة. تُستعمل لتعبئة جزئك من المعاينة.';

  @override
  String get addLicense => 'إضافة رخصتي';

  @override
  String licenseIssuedOn(String date) {
    return 'صدرت في $date';
  }

  @override
  String get licensePhotoAdd => 'إضافة صورة الرخصة';

  @override
  String get replace => 'استبدال';

  @override
  String get biometricTitle => 'الدخول بالبصمة';

  @override
  String get biometricSubtitle =>
      'البصمة أو التعرّف على الوجه، لمدة 30 يومًا على هذا الهاتف';

  @override
  String get biometricEnabled => 'تم تفعيل الدخول بالبصمة';

  @override
  String get languageLabel => 'اللغة';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get profileSaved => 'تم حفظ الملف';

  @override
  String get editIdentityTitle => 'تعديل الهوية';

  @override
  String get editLicenseTitle => 'تعديل الرخصة';

  @override
  String get changeProfilePhoto => 'تغيير صورة الملف';

  @override
  String get phoneChangeNotice => 'يجب تأكيد الرقم الجديد برمز عبر واتساب.';

  @override
  String get takePhoto => 'التقاط صورة';

  @override
  String get chooseFromGallery => 'اختيار من المعرض';

  @override
  String get deletePhoto => 'حذف الصورة';

  @override
  String get photoSaved => 'تم حفظ الصورة';

  @override
  String get accountsTitle => 'إدارة الحسابات';

  @override
  String get accountsSubtitle => 'الأدوار والأعوان والإيقاف';

  @override
  String get createAgentTooltip => 'إنشاء عون';

  @override
  String get searchHint => 'الاسم أو البريد أو الهاتف';

  @override
  String get noAccounts => 'لا توجد حسابات.';

  @override
  String get roleLabel => 'الدور';

  @override
  String get companyLabel => 'الشركة';

  @override
  String get createAgentTitle => 'إنشاء عون';

  @override
  String get tempPasswordLabel => 'كلمة مرور مؤقتة';

  @override
  String get createAccountButton => 'إنشاء الحساب';

  @override
  String get companiesTitle => 'شركات التأمين';

  @override
  String get companiesSubtitle => 'الشركات والوكالات';

  @override
  String get addCompany => 'إضافة شركة';

  @override
  String get noCompanies => 'لا توجد شركات مسجّلة.';

  @override
  String agencyCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count وكالة',
      few: '$count وكالات',
      two: 'وكالتان',
      one: 'وكالة واحدة',
      zero: 'لا توجد وكالات',
    );
    return '$_temp0';
  }

  @override
  String get addAgency => 'إضافة وكالة';

  @override
  String get rename => 'إعادة التسمية';

  @override
  String get newCompany => 'شركة جديدة';

  @override
  String get renameCompany => 'إعادة تسمية الشركة';

  @override
  String get companyNameLabel => 'اسم الشركة';

  @override
  String get newAgency => 'وكالة جديدة';

  @override
  String get editAgency => 'تعديل الوكالة';

  @override
  String get agencyNameLabel => 'اسم الوكالة';

  @override
  String get cityLabel => 'المدينة';

  @override
  String deleteCompanyTitle(String name) {
    return 'حذف $name؟';
  }

  @override
  String get deleteCompanyBody => 'ستُحذف وكالاتها أيضًا.';

  @override
  String get deleteAgencyTooltip => 'حذف الوكالة';

  @override
  String get adminTitle => 'الإدارة';

  @override
  String get adminSubtitle => 'نظرة عامة على المنصة';

  @override
  String get demoData => 'بيانات تجريبية';

  @override
  String get statAccidents => 'الحوادث';

  @override
  String get statOpen => 'مفتوحة';

  @override
  String get statClosed => 'مغلقة';

  @override
  String get statAvgDelay => 'متوسط المدة';

  @override
  String get heatmapTitle => 'خريطة المناطق الأكثر حوادث';

  @override
  String get severityTitle => 'التوزيع حسب الخطورة';

  @override
  String severityMaterial(int percent) {
    return '$percent٪ أضرار مادية';
  }

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navVehicles => 'السيارات';

  @override
  String get navClaims => 'الملفات';

  @override
  String get navMessages => 'الرسائل';

  @override
  String get navProfile => 'الملف';

  @override
  String get navDashboard => 'اللوحة';

  @override
  String get navCases => 'الحوادث';

  @override
  String get navAccounts => 'الحسابات';

  @override
  String get navCompanies => 'الشركات';

  @override
  String get errorGeneric => 'حدث خطأ. أعد المحاولة.';

  @override
  String get errorNetwork => 'تعذّر الاتصال بالخادم. تحقّق من الشبكة.';

  @override
  String get errorInvalidCredentials => 'المعرّف أو كلمة المرور غير صحيحة.';

  @override
  String get errorAccountLocked =>
      'الحساب مقفل لمدة 15 دقيقة بعد 5 محاولات فاشلة. أعد المحاولة لاحقًا.';

  @override
  String get errorAccountSuspended => 'هذا الحساب موقوف.';

  @override
  String get errorAlreadyExists => 'هذه القيمة مستعملة من قبل.';

  @override
  String get errorInvalidCode => 'الرمز غير صحيح أو منتهي الصلاحية.';

  @override
  String get errorCodeCooldown => 'انتظر دقيقة قبل طلب رمز جديد.';

  @override
  String get errorSessionExpired => 'انتهت الجلسة. أعد تسجيل الدخول.';

  @override
  String get errorBiometricInvalid =>
      'انتهت صلاحية الدخول بالبصمة. سجّل الدخول بكلمة المرور.';

  @override
  String get errorBiometricUnavailable =>
      'البصمة أو التعرّف على الوجه غير متاح. تحقّق من إعدادات الأمان في الهاتف.';

  @override
  String get errorFileTooLarge => 'الصورة كبيرة جدًا: 5 ميغابايت كحد أقصى.';

  @override
  String get errorUnsupportedImage => 'الصيغ المقبولة: JPEG أو PNG أو WebP.';

  @override
  String get errorCompanyInUse => 'ما زال أعوان مرتبطون بهذه الشركة.';

  @override
  String get errorSelfChange => 'لا يمكنك تغيير دورك أو حالة حسابك بنفسك.';

  @override
  String get errorInvalidData => 'بعض البيانات غير صالحة.';

  @override
  String get appearanceLabel => 'المظهر';

  @override
  String get themeSystem => 'مثل الهاتف';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeDark => 'داكن';

  @override
  String get navDeclarations => 'التصريحات';

  @override
  String get securityDevicesTitle => 'الأجهزة المتصلة';

  @override
  String get securityDevicesSubtitle => 'الأماكن التي فُتح فيها حسابك';

  @override
  String get thisDevice => 'هذا الجهاز';

  @override
  String lastActive(String when) {
    return 'نشط في $when';
  }

  @override
  String get signOutDevice => 'إخراج';

  @override
  String signOutDeviceConfirm(String name) {
    return 'إخراج $name؟';
  }

  @override
  String get signOutDeviceBody =>
      'سيحتاج هذا الجهاز إلى كلمة المرور للدخول مجددًا.';

  @override
  String get signOutOthers => 'إخراج كل الأجهزة الأخرى';

  @override
  String signedOutOthers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تم إخراج $count جهاز',
      few: 'تم إخراج $count أجهزة',
      two: 'تم إخراج جهازين',
      one: 'تم إخراج جهاز واحد',
      zero: 'لا يوجد جهاز آخر متصل',
    );
    return '$_temp0';
  }

  @override
  String get unknownDevice => 'جهاز غير معروف';

  @override
  String get securityAlertNote =>
      'يصلك إشعار عبر واتساب والبريد الإلكتروني عند الدخول من جهاز جديد.';

  @override
  String get loginHistoryTitle => 'سجل تسجيل الدخول';

  @override
  String get noHistory => 'لا توجد عمليات دخول مسجّلة.';

  @override
  String get loginSuccess => 'دخول ناجح';

  @override
  String get loginMethodPassword => 'كلمة المرور';

  @override
  String get loginMethodBiometric => 'البصمة';

  @override
  String get loginMethodRegister => 'إنشاء الحساب';

  @override
  String get loginFailedWrongPassword => 'كلمة مرور خاطئة';

  @override
  String get loginFailedLocked => 'محاولة على حساب مقفل';

  @override
  String get loginFailedSuspended => 'محاولة على حساب موقوف';

  @override
  String get identityTitle => 'التحقق من الهوية';

  @override
  String get identityStatusUnverified => 'الهوية غير مُتحقَّق منها';

  @override
  String get identityStatusPending => 'قيد المراجعة';

  @override
  String get identityStatusVerified => 'تم التحقق من الهوية';

  @override
  String get identityStatusRejected => 'تم رفض التحقق';

  @override
  String get identityIntro =>
      'اختر وثيقة، صوّرها، ثم تحقّق من وجهك. يقارن الذكاء الاصطناعي وجهك بصورة الوثيقة على خوادمنا، دون أي خدمة خارجية.';

  @override
  String get identityPendingNote =>
      'لم يتمكن الذكاء الاصطناعي من الحسم: يقارن أحد المشرفين صورك. ستصلك رسالة على واتساب وبالبريد الإلكتروني.';

  @override
  String get identityVerifiedNote => 'يمكنك توقيع معايناتك.';

  @override
  String identityRejectedReason(String reason) {
    return 'السبب: $reason';
  }

  @override
  String get cinNumberLabel => 'رقم بطاقة التعريف';

  @override
  String get cinInvalid => 'يتكوّن رقم بطاقة التعريف من 8 أرقام.';

  @override
  String get cinFront => 'وجه بطاقة التعريف';

  @override
  String get cinBack => 'ظهر بطاقة التعريف';

  @override
  String get addPhoto => 'إضافة صورة';

  @override
  String get identityPhotosRequired => 'أضف صور الوثيقة.';

  @override
  String get submitIdentity => 'إرسال للمراجعة';

  @override
  String get identitySent => 'تم إرسال الطلب. سيصلك إشعار عبر واتساب.';

  @override
  String get navIdentities => 'الهويات';

  @override
  String get reviewTitle => 'التحقق من الهويات';

  @override
  String get reviewSubtitle => 'الطلبات المعلّقة، الأقدم أولًا';

  @override
  String get noPendingReviews => 'لا توجد طلبات معلّقة.';

  @override
  String submittedOn(String date) {
    return 'أُرسلت في $date';
  }

  @override
  String get approve => 'قبول';

  @override
  String get reject => 'رفض';

  @override
  String get rejectTitle => 'سبب الرفض';

  @override
  String get rejectReasonBlurry => 'صورة غير واضحة';

  @override
  String get rejectReasonUnreadable => 'وثيقة غير مقروءة';

  @override
  String get rejectReasonNameMismatch => 'الاسم لا يطابق الحساب';

  @override
  String get rejectReasonNotCin => 'وثيقة غير صالحة';

  @override
  String get otherReason => 'سبب آخر';

  @override
  String get identityApproved => 'تم قبول الهوية وإشعار صاحبها';

  @override
  String get identityRejected => 'تم رفض الطلب وإشعار صاحبه';

  @override
  String get errorIdentityLocked => 'هويتك قيد المراجعة أو تم التحقق منها.';

  @override
  String get errorCinInUse => 'رقم هذه الوثيقة مستعمل من قبل.';

  @override
  String get errorIdentityNotVerified => 'يجب التحقق من هويتك أولًا.';

  @override
  String get errorIdentityNotPending => 'هذا الطلب لم يعد معلّقًا.';

  @override
  String get consentLabel =>
      'أوافق على معالجة بياناتي لإدارة معايناتي، وفقًا للقانون عدد 63 لسنة 2004.';

  @override
  String get consentRequired => 'موافقتك ضرورية لإنشاء حساب.';

  @override
  String get sectionPrivacy => 'البيانات الشخصية';

  @override
  String get exportData => 'تنزيل بياناتي';

  @override
  String get exportDataSubtitle => 'ملف PDF بكل ما يحتفظ به Mon Constat عنك';

  @override
  String get deleteAccount => 'حذف حسابي';

  @override
  String get deleteAccountSubtitle => 'نهائي. تبقى معايناتك دون اسمك.';

  @override
  String get deleteAccountTitle => 'حذف حسابك؟';

  @override
  String get deleteAccountBody =>
      'سيتم محو اسمك وبياناتك ورخصتك وبطاقة تعريفك وصورك. تبقى الحوادث والملفات المصرّح بها دون اسم كما يقتضي التأمين. لا يمكن التراجع عن ذلك.';

  @override
  String get deleteAccountConfirm => 'حذف نهائي';

  @override
  String get accountDeleted => 'تم حذف حسابك.';

  @override
  String get errorAdminCannotDelete => 'لا يمكن للمسؤول حذف حسابه من هنا.';

  @override
  String get dashUsers => 'المستخدمون';

  @override
  String dashActive(int count) {
    return '$count نشط';
  }

  @override
  String get dashPendingIds => 'للمراجعة';

  @override
  String dashVerifiedIds(int count) {
    return '$count هوية مُتحقَّق منها';
  }

  @override
  String get dashPhones => 'الهواتف المؤكدة';

  @override
  String get dashSignIns => 'الدخول 7 أيام';

  @override
  String dashFailed(int count) {
    return '$count فشل';
  }

  @override
  String get dashSignupsTitle => 'التسجيلات، آخر 30 يومًا';

  @override
  String get dashRolesTitle => 'الحسابات حسب الدور';

  @override
  String get dashIdentityTitle => 'التحقق من هوية السائقين';

  @override
  String dashNetwork(int companies, int agencies) {
    return '$companies شركات · $agencies وكالات';
  }

  @override
  String get dashAccidentsTitle => 'الحوادث والملفات';

  @override
  String get dashAccidentsPending =>
      'المؤشرات والتوزيع وخريطة المناطق الخطرة: متاحة حين ترسل الوحدتان 3 و5 بياناتهما إلى الخادم.';

  @override
  String get agencyLabel => 'الوكالة';

  @override
  String companiesOffline(String date) {
    return 'دون اتصال: قائمة محفوظة في $date';
  }

  @override
  String get pendingSyncTitle => 'تعديلات في الانتظار';

  @override
  String get pendingSyncBody => 'محفوظة على الهاتف. ستُرسل فور عودة الشبكة.';

  @override
  String syncFailed(String reason) {
    return 'رفض الخادم التعديل: $reason';
  }

  @override
  String get syncNow => 'مزامنة';

  @override
  String get retrySync => 'إعادة المحاولة';

  @override
  String get discardChanges => 'إلغاء التعديلات';

  @override
  String get savedOffline => 'حُفظ على الهاتف. سيُرسل عند عودة الشبكة.';

  @override
  String get syncing => 'جارٍ المزامنة…';

  @override
  String get consoleDashboard => 'لوحة القيادة';

  @override
  String get consoleToHandle => 'للمعالجة';

  @override
  String get consoleReview => 'مراجعة';

  @override
  String get consoleSeeAll => 'عرض الكل';

  @override
  String get consoleNothingToHandle => 'لا شيء للمعالجة حاليًا.';

  @override
  String get refresh => 'تحديث';

  @override
  String get signedInAs => 'متصل';

  @override
  String get colUser => 'المستخدم';

  @override
  String get colStatus => 'الحالة';

  @override
  String get filterAll => 'الكل';

  @override
  String get filterDrivers => 'السائقون';

  @override
  String get filterAgents => 'الأعوان';

  @override
  String get filterAdmins => 'المسؤولون';

  @override
  String accountsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count حساب',
      few: '$count حسابات',
      two: 'حسابان',
      one: 'حساب واحد',
      zero: 'لا توجد حسابات',
    );
    return '$_temp0';
  }

  @override
  String get statusActive => 'نشط';

  @override
  String get statusSuspended => 'موقوف';

  @override
  String get changeRole => 'تغيير الدور';

  @override
  String get suspendAccount => 'إيقاف';

  @override
  String get reactivateAccount => 'إعادة التفعيل';

  @override
  String get selectRequest => 'اختر طلبًا لعرض الوثيقة.';

  @override
  String pendingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count طلب',
      few: '$count طلبات',
      two: 'طلبان',
      one: 'طلب واحد',
      zero: 'لا توجد طلبات',
    );
    return '$_temp0';
  }

  @override
  String get selectCompany => 'اختر شركة لإدارة وكالاتها.';

  @override
  String get agenciesTitle => 'الوكالات';

  @override
  String get noAgencies => 'لا توجد وكالات بعد.';

  @override
  String get heroPoint1 => 'معاينة كاملة في أقل من 10 دقائق، حتى دون اتصال';

  @override
  String get heroPoint2 => 'توقيع السائقين وملف PDF غير قابل للتزوير';

  @override
  String get heroPoint3 => 'متابعة الملف لحظيًا حتى التعويض';

  @override
  String get identityVerifiedAutoNote =>
      'تم التحقق تلقائيًا عبر التعرّف على الوجه. يمكنك الآن توقيع المعاينات.';

  @override
  String get documentTypeLabel => 'وثيقة الهوية';

  @override
  String get documentCin => 'بطاقة التعريف';

  @override
  String get documentLicense => 'رخصة السياقة';

  @override
  String get documentPassport => 'جواز السفر';

  @override
  String get passportNumberLabel => 'رقم جواز السفر';

  @override
  String get licenseNumberInvalid => 'رقم رخصة غير صالح (مثال: 12/345678).';

  @override
  String get passportNumberInvalid => 'رقم جواز سفر غير صالح (مثال: X1234567).';

  @override
  String get licenseFront => 'وجه الرخصة';

  @override
  String get licenseBack => 'ظهر الرخصة';

  @override
  String get passportPage => 'صفحة الصورة في جواز السفر';

  @override
  String get faceCheckTitle => 'التحقق من الوجه';

  @override
  String get faceCheckIntro =>
      'ثلاث صور سريعة: من الأمام، ثم مع إدارة الرأس إلى كل جهة. لا تنجح صورة مطبوعة أو شاشة.';

  @override
  String get faceCheckDone => 'تم التحقق من الوجه';

  @override
  String get faceCheckStart => 'تحقّق من وجهي';

  @override
  String get faceCheckRedo => 'إعادة';

  @override
  String get faceCheckRequired => 'قم أولًا بالتحقق من الوجه.';

  @override
  String get livenessCenter => 'انظر مباشرة إلى الكاميرا';

  @override
  String get livenessLeft => 'أدر رأسك إلى اليسار';

  @override
  String get livenessRight => 'أدر رأسك إلى اليمين';

  @override
  String livenessStepOf(int current, int total) {
    return 'الصورة $current من $total';
  }

  @override
  String get livenessAnalyzing => 'تحليل بالذكاء الاصطناعي…';

  @override
  String get livenessNoCamera =>
      'الكاميرا غير متاحة. اسمح بالوصول إلى الكاميرا ثم أعد المحاولة.';

  @override
  String get livenessPrivacy =>
      'تُستعمل الصورة الأمامية لهذا التحقق فقط، وتُحذف فور اتخاذ القرار.';

  @override
  String get livenessSuccess => 'تم التحقق من الوجه. يمكنك إرسال الطلب.';

  @override
  String get identityVerifiedByAi => 'تم التحقق من الهوية بالذكاء الاصطناعي';

  @override
  String get errorNoFaceOnDocument =>
      'لم يُعثر على وجه في الوثيقة. أعد التصوير والوثيقة مسطّحة، بإضاءة جيدة ودون انعكاس.';

  @override
  String get errorLivenessNoFace =>
      'لم يُعثر على الوجه. ضع وجهك داخل الإطار البيضاوي بإضاءة جيدة.';

  @override
  String get errorLivenessManyFaces =>
      'يجب أن يكون شخص واحد فقط أمام الكاميرا.';

  @override
  String get errorLivenessNotCentered =>
      'انظر مباشرة إلى الكاميرا في الصورة الأولى.';

  @override
  String get errorLivenessNoTurn => 'أدر رأسك أكثر عندما يُطلب منك ذلك.';

  @override
  String get errorLivenessDifferentFaces => 'الصور لا تُظهر الشخص نفسه.';

  @override
  String get errorLivenessExpired =>
      'انتهت صلاحية التحدي. أعد التحقق من الوجه.';

  @override
  String get errorFaceEngine => 'تحليل الوجه غير متاح. أعد المحاولة بعد قليل.';

  @override
  String aiMatch(int percent) {
    return 'تطابق الذكاء الاصطناعي: $percent٪';
  }

  @override
  String get aiNoConclusion => 'الذكاء الاصطناعي: دون حسم';

  @override
  String get livenessPassed => 'تم التحقق من وجه حيّ';

  @override
  String get selfieLabel => 'صورة الوجه';

  @override
  String get documentNumberLabel => 'رقم الوثيقة';

  @override
  String get rejectReasonFaceMismatch => 'الوجه لا يطابق الوثيقة';

  @override
  String dashVerifiedIdsAi(int count, int ai) {
    return '$count موثّقة، منها $ai بالذكاء الاصطناعي';
  }

  @override
  String get readingDocument => 'يقرأ الذكاء الاصطناعي وثيقتك…';

  @override
  String get readOnCard => 'ما قرأه الذكاء الاصطناعي من الوثيقة';

  @override
  String get readNumber => 'الرقم';

  @override
  String get readName => 'الاسم';

  @override
  String get readParents => 'النسب';

  @override
  String get readBirth => 'الولادة';

  @override
  String get readExpiry => 'صالحة إلى غاية';

  @override
  String get readConfirm =>
      'تحقق من هذه المعلومات. يجب أن يكون الرقم المُدخل هو رقم الوثيقة.';

  @override
  String get readNothing =>
      'لم يتمكن الذكاء الاصطناعي من قراءة الوثيقة. أدخل الرقم وسيتحقق منه أحد المشرفين.';

  @override
  String get useNumberRead => 'استعمل هذا الرقم';

  @override
  String get useLicensePhoto => 'استعمل صورة الرخصة من ملفي';

  @override
  String get errorBackHasFace =>
      'هذه الصورة تُظهر الوجه الأمامي. صوّر ظهر الوثيقة نفسها.';

  @override
  String get errorLicensePhotoMissing => 'لا توجد صورة رخصة في ملفك.';

  @override
  String get checksTitle => 'فحوصات الذكاء الاصطناعي';

  @override
  String get checkLiveness => 'وجه حيّ';

  @override
  String get checkFace => 'الوجه يطابق صورة الوثيقة';

  @override
  String checkNumber(String number) {
    return 'الرقم المُدخل = الرقم المقروء ($number)';
  }

  @override
  String get checkNumberUnread => 'الرقم غير مقروء في الوثيقة';

  @override
  String get checkName => 'اسم الحساب على الوثيقة';

  @override
  String get checkExpiry => 'الوثيقة سارية المفعول';

  @override
  String get scanLicense => 'امسح رخصتي';

  @override
  String get scanLicenseHint =>
      'صوّر رخصتك: يملأ الذكاء الاصطناعي الرقم والأصناف والتاريخ.';

  @override
  String get licenseFilledByAi =>
      'ملأها الذكاء الاصطناعي من الصورة. تحقق قبل الحفظ.';

  @override
  String get licenseNotRead =>
      'حُفظت الصورة لكن الذكاء الاصطناعي لم يتمكن من قراءة الرخصة. أكمل الحقول.';

  @override
  String get errorBackNotRecognized =>
      'هذا ليس ظهر الوثيقة. في بطاقة التعريف يجب أن يظهر الرمز الشريطي كاملًا وواضحًا.';

  @override
  String get checkBack => 'تم التعرّف على ظهر الوثيقة';

  @override
  String get rejectSevere => 'رفض نهائي: منع الطلبات الجديدة';

  @override
  String get rejectSevereHint =>
      'في حالة احتيال محتمل: وجه مختلف أو وثيقة مزورة.';

  @override
  String get identityBlockedNote => 'تم حظر التحقق من هويتك. اتصل بالدعم.';

  @override
  String identityRetryOn(String date) {
    return 'يمكنك إرسال طلب جديد يوم $date.';
  }

  @override
  String identityAttemptsLeft(int count) {
    return 'المحاولات المتبقية: $count.';
  }

  @override
  String get errorIdentityBlocked => 'تم حظر التحقق من هويتك. اتصل بالدعم.';

  @override
  String get errorIdentityRetryLater =>
      'انتظر 24 ساعة بعد الرفض قبل تقديم طلب جديد.';

  @override
  String get unblockIdentity => 'رفع حظر التحقق';

  @override
  String get identityUnblocked => 'تم رفع حظر التحقق';

  @override
  String get identityBlockedChip => 'التحقق محظور';

  @override
  String get attemptsTitle => 'طلبات هذا الحساب';

  @override
  String refusalsCount(int count) {
    return 'عدد الرفض: $count';
  }

  @override
  String get outcomeAuto => 'وثّقها الذكاء الاصطناعي';

  @override
  String get outcomeVerified => 'موثّقة';

  @override
  String get outcomeRejected => 'مرفوضة';

  @override
  String get outcomePending => 'قيد الانتظار';
}
