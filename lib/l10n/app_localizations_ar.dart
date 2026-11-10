// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get claimsMyClaims => 'ملفاتي';

  @override
  String get claimsReceived => 'الحوادث الواردة';

  @override
  String claimsCount(String shown, String total) {
    return '$shown من أصل $total ملفات';
  }

  @override
  String get claimsFilterHint => 'تصفية حسب الرقم أو الحالة أو الخطورة';

  @override
  String get claimsStatus => 'الحالة';

  @override
  String get claimsSeverity => 'الخطورة';

  @override
  String get claimsDate => 'التاريخ';

  @override
  String claimsAllOf(String label) {
    return 'الكل: $label';
  }

  @override
  String get claimsNoMatch => 'لا يوجد ملف مطابق.';

  @override
  String get claimsAgentSpace => 'فضاء العون';

  @override
  String get claimsAgentSubtitle => 'دراسة ملفات الحوادث';

  @override
  String get claimsStatistics => 'الإحصائيات';

  @override
  String get claimsNotifications => 'الإشعارات';

  @override
  String get claimsToHandle => 'للمعالجة';

  @override
  String get claimsExpertises => 'الخبرات';

  @override
  String get claimsClosedCount => 'مغلقة';

  @override
  String get claimsPriority => 'الملفات ذات الأولوية';

  @override
  String get claimsNothingToHandle => 'لا يوجد ملف للمعالجة.';

  @override
  String get claimsAssistant => 'المساعد';

  @override
  String get claimsMessaging => 'المحادثات';

  @override
  String get claimsRequestedDocuments => 'الوثائق المطلوبة';

  @override
  String get claimsUpload => 'إيداع';

  @override
  String get claimsExpertiseTitle => 'الخبرة الفنية';

  @override
  String claimsAppointmentOn(String date) {
    return 'الموعد يوم $date';
  }

  @override
  String get claimsTimeline => 'التسلسل الزمني';

  @override
  String get claimsConstat => 'المحضر';

  @override
  String get claimsDocuments => 'وثائق الملف';

  @override
  String get claimsDownload => 'تنزيل';

  @override
  String get claimsNoDocument => 'لم تودَع أي وثيقة.';

  @override
  String get claimsUploadDocument => 'إيداع وثيقة';

  @override
  String get claimsHandling => 'الدراسة';

  @override
  String get claimsDocMismatch => 'لا تطابق الطلب.';

  @override
  String get claimsRejectedTitle => 'ملف مرفوض';

  @override
  String get claimsClosedTitle => 'ملف مغلق';

  @override
  String claimsReason(String reason) {
    return 'السبب: $reason';
  }

  @override
  String claimsResponsibilitySplit(String a, String b) {
    return 'المسؤولية: A $a %، B $b %';
  }

  @override
  String claimsIndemnity(String amount) {
    return 'التعويض: $amount دينار';
  }

  @override
  String get claimsCircumstances => 'الظروف';

  @override
  String get claimsImpactPoint => 'نقطة الاصطدام';

  @override
  String get claimsObservations => 'الملاحظات';

  @override
  String get claimsNoConstat => 'لا توجد معلومات عن المحضر.';

  @override
  String claimsLabelColon(String label) {
    return '$label: ';
  }

  @override
  String get claimsTakeCharge => 'التكفّل بالملف';

  @override
  String get claimsRequestDocument => 'طلب وثيقة';

  @override
  String get claimsMoveAppointment => 'تغيير الموعد';

  @override
  String get claimsAppointExpert => 'تعيين خبير';

  @override
  String get claimsAttachReport => 'إرفاق تقرير الخبير';

  @override
  String get claimsReject => 'رفض الملف';

  @override
  String get claimsDocument => 'الوثيقة';

  @override
  String get claimsDetail => 'توضيح';

  @override
  String get claimsSendRequest => 'إرسال الطلب';

  @override
  String get claimsExpert => 'الخبير';

  @override
  String get claimsSchedule => 'تحديد الموعد';

  @override
  String get claimsReasonLabel => 'السبب';

  @override
  String get claimsRejectAction => 'رفض';

  @override
  String get claimsInvalidAmount => 'أدخل مبلغًا صحيحًا.';

  @override
  String get claimsDecision => 'القرار';

  @override
  String claimsProposal(String a, String b, String reason) {
    return 'المقترح: A $a %، B $b %. $reason';
  }

  @override
  String get claimsIndemnityAmount => 'مبلغ التعويض (دينار)';

  @override
  String get claimsCloseClaim => 'إغلاق الملف';

  @override
  String claimsProposalFault(String box) {
    return '$box: مناورة خطرة من السائق A.';
  }

  @override
  String get claimsProposalParked => 'كانت سيارة A متوقفة.';

  @override
  String claimsProposalTurn(String box) {
    return '$box: مسؤولية مشتركة افتراضيًا.';
  }

  @override
  String get claimsProposalUnknown =>
      'الخانات غير كافية: مسؤولية مشتركة افتراضيًا.';

  @override
  String get claimsSummaryOffline => 'الملخص غير متاح دون اتصال.';

  @override
  String get claimsDecisionHelp => 'المساعدة على القرار';

  @override
  String claimsOverdue(String days) {
    return 'تأخير $days يوم';
  }

  @override
  String get claimsEstimate => 'التقدير';

  @override
  String claimsRange(String low, String high) {
    return 'من $low إلى $high دينار';
  }

  @override
  String get claimsUsualDuration => 'المدة المعتادة';

  @override
  String claimsDays(String days) {
    return '$days يوم';
  }

  @override
  String get claimsRejectionRisk => 'خطر الرفض';

  @override
  String get claimsRiskLow => 'منخفض';

  @override
  String get claimsRiskMedium => 'متوسط';

  @override
  String get claimsRiskHigh => 'مرتفع';

  @override
  String claimsRiskWithFactors(String level, String factors) {
    return '$level: $factors';
  }

  @override
  String get claimsRecommended => 'موصى بها لهذا الملف';

  @override
  String get claimsToCheck => 'للتحقق';

  @override
  String get claimsMissingDocuments => 'الوثائق الناقصة';

  @override
  String get claimsRequest => 'طلب';

  @override
  String get claimsSimilar => 'ملفات مشابهة';

  @override
  String claimsSummaryBy(String by) {
    return 'ملخص كتبه $by';
  }

  @override
  String get claimsSummaryRules => 'ملخص آلي دون ذكاء اصطناعي توليدي';

  @override
  String get claimsSummarizing => 'جارٍ التلخيص';

  @override
  String get claimsSummarize => 'تلخيص الملف';

  @override
  String get claimsModelDisclaimer =>
      'التقديرات صادرة عن نموذج مدرَّب على بيانات محاكاة. القرار يعود إلى العون.';

  @override
  String get claimsDriverIdea1 => 'أين وصل ملفي؟';

  @override
  String get claimsDriverIdea2 => 'ما الوثائق التي عليّ إيداعها؟';

  @override
  String get claimsDriverIdea3 => 'كم من الوقت سيستغرق ذلك؟';

  @override
  String get claimsAgentIdea1 => 'ماذا عليّ أن أفعل بعد ذلك؟';

  @override
  String get claimsAgentIdea2 => 'ما النقاط التي يجب التحقق منها؟';

  @override
  String get claimsAgentIdea3 => 'ما المسؤولية التي تقترحها؟';

  @override
  String get claimsAssistantUnavailable =>
      'المساعد غير متاح حاليًا. أعد المحاولة لاحقًا.';

  @override
  String claimsAssistantTitle(String id) {
    return 'المساعد $id';
  }

  @override
  String get claimsAssistantIntro =>
      'اطرح سؤالًا عن هذا الملف. المساعد يُعلِم ولا يتخذ أي قرار.';

  @override
  String get claimsAssistantReading => 'المساعد يقرأ الملف…';

  @override
  String get claimsYourQuestion => 'سؤالك';

  @override
  String get claimsSend => 'إرسال';

  @override
  String get claimsAutomaticAnswer => 'إجابة آلية';

  @override
  String get claimsStatsServerOnly => 'الإحصائيات متاحة مع الخادم.';

  @override
  String get claimsTotal => 'الملفات';

  @override
  String get claimsLate => 'متأخرة';

  @override
  String get claimsAverageDuration => 'متوسط المدة';

  @override
  String claimsDaysShort(String days) {
    return '$days يوم';
  }

  @override
  String get claimsIndemnified => 'التعويضات (دينار)';

  @override
  String get claimsByStatus => 'الملفات حسب الحالة';

  @override
  String get claimsSystemVsAgents => 'النظام مقارنة بالأعوان';

  @override
  String get claimsNoDecisionYet => 'لا توجد قرارات للمقارنة بعد.';

  @override
  String claimsAgreement(String count, String percent) {
    return 'من أصل $count قرار، اعتُمدت المسؤولية المقترحة في $percent % من الحالات.';
  }

  @override
  String claimsAverageGap(String gap) {
    return 'متوسط الفارق مع المبلغ المقرَّر: $gap دينار.';
  }

  @override
  String get claimsModel => 'النموذج';

  @override
  String claimsModelVersion(String version) {
    return 'الإصدار $version';
  }

  @override
  String claimsTrainedOn(String synthetic, String real) {
    return 'مدرَّب على $synthetic حالة محاكاة و$real ملف حقيقي.';
  }

  @override
  String claimsModelTest(String mae, String auc) {
    return 'الاختبار: متوسط الخطأ $mae دينار، AUC الرفض $auc.';
  }

  @override
  String get claimsSimulatedWarning =>
      'هذه القياسات مبنية على بيانات محاكاة: لا تبيّن بعد إن كان النموذج دقيقًا في الحوادث الحقيقية.';

  @override
  String get claimsSuggestionsUnavailable => 'الاقتراحات غير متاحة.';

  @override
  String get claimsNoMessages => 'لا توجد رسائل في هذا الملف.';

  @override
  String get claimsSuggestReply => 'اقتراح ردّ';

  @override
  String get claimsAttachFile => 'إرفاق ملف';

  @override
  String get claimsYourMessage => 'رسالتك';

  @override
  String get claimsOneConversation => 'محادثة لكل ملف';

  @override
  String get claimsNoClaims => 'لا توجد ملفات.';

  @override
  String get claimsNoMessage => 'لا توجد رسائل';

  @override
  String get claimsMarkAllRead => 'تعليم الكل كمقروء';

  @override
  String get claimsNoNotification => 'لا توجد إشعارات.';

  @override
  String get claimsOffline => 'دون اتصال: ستُرسَل تغييراتك عند عودة الشبكة';

  @override
  String get claimsFileUnavailable => 'الملف غير متاح حاليًا.';

  @override
  String get claimsValueDraft => 'مسودة';

  @override
  String get claimsValueDeclared => 'مُصرَّح به';

  @override
  String get claimsValueSigned => 'محضر موقَّع';

  @override
  String get claimsValueTransmitted => 'مُرسَل';

  @override
  String get claimsValueInReview => 'قيد الدراسة';

  @override
  String get claimsValueDocumentRequested => 'وثيقة مطلوبة';

  @override
  String get claimsValueExpertise => 'خبرة فنية';

  @override
  String get claimsValueClosed => 'مُغلَق';

  @override
  String get claimsValueRejected => 'مرفوض';

  @override
  String get claimsValueCollision => 'تصادم';

  @override
  String get claimsValueOffRoad => 'خروج عن الطريق';

  @override
  String get claimsValuePedestrian => 'حادث مع مترجّل';

  @override
  String get claimsValueMaterialAccident => 'حادث مادي';

  @override
  String get claimsValueOther => 'أخرى';

  @override
  String get claimsValueMaterial => 'أضرار مادية';

  @override
  String get claimsValueLight => 'خفيف';

  @override
  String get claimsValueSerious => 'خطير';

  @override
  String get claimsValueParked => 'متوقفة';

  @override
  String get claimsValueLeavingParking => 'تغادر مكان التوقف';

  @override
  String get claimsValueChangingLane => 'تغيّر المسار';

  @override
  String get claimsValueOvertaking => 'تتجاوز';

  @override
  String get claimsValueTurningRight => 'تنعطف يمينًا';

  @override
  String get claimsValueTurningLeft => 'تنعطف يسارًا';

  @override
  String get claimsValueReversing => 'ترجع إلى الخلف';

  @override
  String get claimsValueFront => 'الأمام';

  @override
  String get claimsValueRear => 'الخلف';

  @override
  String get claimsValueLeftSide => 'الجانب الأيسر';

  @override
  String get claimsValueRightSide => 'الجانب الأيمن';

  @override
  String get claimsValueQuote => 'تقدير كلفة الإصلاح';

  @override
  String get claimsValueInvoice => 'فاتورة';

  @override
  String get claimsValuePoliceReport => 'محضر الشرطة';

  @override
  String get claimsValueExpertReport => 'تقرير الخبير';

  @override
  String get claimsValueSupporting => 'وثيقة';

  @override
  String get claimsValuePhoto => 'صورة';

  @override
  String get claimsValueVideo => 'فيديو';

  @override
  String get claimsValueVoiceNote => 'تسجيل صوتي';

  @override
  String get claimsValueAccidentReport => 'المحضر الودّي';

  @override
  String get claimsEventDraftCreated => 'تم إنشاء المسودة';

  @override
  String get claimsEventDeclared => 'اكتمل التصريح';

  @override
  String claimsEventEvidence(String count) {
    return 'أضيفت $count أدلة';
  }

  @override
  String get claimsEventSigned => 'توقيع الطرفين';

  @override
  String get claimsEventPdfLocked => 'تم قفل ملف PDF';

  @override
  String get claimsEventSent => 'أُرسل إلى شركات التأمين';

  @override
  String get claimsEventMoved => 'تم تغيير الموعد';

  @override
  String get claimsEventReport => 'أُرفق تقرير الخبير';

  @override
  String claimsEventDetail(String status, String detail) {
    return '$status: $detail';
  }

  @override
  String claimsNotifNew(String id) {
    return 'حادث جديد وارد: $id';
  }

  @override
  String claimsNotifRequested(String id, String document) {
    return '$id: وثيقة مطلوبة ($document)';
  }

  @override
  String claimsNotifUploaded(String id, String name) {
    return '$id: أُودعت وثيقة ($name)';
  }

  @override
  String claimsNotifMoved(String id) {
    return '$id: تم تغيير موعد الخبرة';
  }

  @override
  String claimsNotifEvent(String id, String event) {
    return '$id: $event';
  }

  @override
  String claimsNotifInReview(String id) {
    return 'ملفك $id قيد الدراسة.';
  }

  @override
  String claimsNotifContract(String days) {
    return 'ينتهي عقدك خلال $days أيام.';
  }

  @override
  String get claimsValueVehicle => 'المركبة';

  @override
  String get claimsValueBodily => 'أضرار جسدية';

  @override
  String get claimsValueReopened => 'أُعيد فتحه';

  @override
  String get claimsEventConfirmed => 'تم تأكيد الموعد';

  @override
  String get claimsEventOtherSlot => 'اقتُرح موعد آخر';

  @override
  String claimsNotifConfirmed(String id) {
    return '$id: تم تأكيد موعد الخبرة';
  }

  @override
  String claimsNotifOtherSlot(String id) {
    return '$id: اقتُرح موعد آخر للخبرة';
  }

  @override
  String get claimsQuestionOnDecision => 'سؤال حول القرار؟ راسل العون';

  @override
  String get claimsReportPending =>
      'يرسل الخبير تقريره إلى شركة التأمين بعد الموعد. سيظهر هنا.';

  @override
  String get claimsReportReceived => 'تقرير الخبير، أرفقه العون';

  @override
  String get claimsReopen => 'إعادة فتح الملف';

  @override
  String get claimsReopenHelp =>
      'في حال وجود خطأ، أعد فتح الملف: يعود إلى الدراسة ويبقى القرار السابق في التسلسل الزمني.';

  @override
  String get claimsReopenAction => 'إعادة الفتح';

  @override
  String get claimsKindHelp =>
      'أضرار جسدية: فحص طبي لشخص مصاب، مترجّل مثلًا. لا توجد مركبة لعرضها.';

  @override
  String get claimsExpertPhone => 'هاتف الخبير';

  @override
  String get claimsExpertPlace => 'مكان الموعد';

  @override
  String get claimsPlaceHintBody => 'عيادة، مصحة…';

  @override
  String get claimsPlaceHintVehicle => 'مستودع، وكالة، المنزل…';

  @override
  String get claimsSuggestedSlots => 'مواعيد مقترحة';

  @override
  String get claimsNoteOptional => 'رسالة (اختياري)';

  @override
  String get claimsExpertRequired => 'أدخل اسم الخبير.';

  @override
  String get claimsSlotConfirmed => 'مؤكَّد';

  @override
  String get claimsSlotYourTurn => 'بانتظار تأكيدك';

  @override
  String get claimsSlotWaitingAgent => 'بانتظار العون';

  @override
  String get claimsSlotWaitingDriver => 'بانتظار السائق';

  @override
  String get claimsExpertiseBody => 'خبرة طبية';

  @override
  String get claimsExpertiseVehicle => 'خبرة المركبة';

  @override
  String get claimsPlaceFromExpert => 'يحدّد الخبير المكان';

  @override
  String get claimsFromDriver => 'من السائق';

  @override
  String get claimsFromAgent => 'من العون';

  @override
  String get claimsToBring => 'ما يجب إحضاره';

  @override
  String get claimsBringId => 'بطاقة هويتك';

  @override
  String get claimsBringCertificates => 'الشهادات الطبية';

  @override
  String get claimsBringPrescriptions => 'الوصفات وفواتير العلاج';

  @override
  String get claimsBringVehicle => 'المركبة قبل إصلاحها';

  @override
  String get claimsBringRegistration => 'البطاقة الرمادية';

  @override
  String get claimsBringLicence => 'رخصة السياقة';

  @override
  String get claimsBringInsurance => 'شهادة التأمين';

  @override
  String get claimsAccept => 'قبول';

  @override
  String get claimsProposeOther => 'اقتراح موعد آخر';

  @override
  String get claimsCannotCome => 'لم يعد بإمكاني الحضور';

  @override
  String get claimsOtherDateTime => 'تاريخ وساعة أخرى';

  @override
  String get claimsSendProposal => 'إرسال الاقتراح';

  @override
  String get claimsStepReceived => 'استُلم';

  @override
  String get claimsStepReview => 'دراسة';

  @override
  String get claimsStepExpertise => 'خبرة';

  @override
  String get claimsStepDecision => 'قرار';

  @override
  String get claimsYourTodo => 'المطلوب منك';

  @override
  String claimsRemainingDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'يبقى حوالي $days يومًا',
      few: 'يبقى حوالي $days أيام',
      two: 'يبقى حوالي يومين',
      one: 'يبقى حوالي يوم واحد',
    );
    return '$_temp0';
  }

  @override
  String get claimsEstimateNote => 'تقدير وليس التزامًا.';

  @override
  String get claimsTakingLonger =>
      'ملفك يستغرق وقتًا أطول من المعتاد. يمكنك مراسلة العون.';

  @override
  String get claimsCircumstancesA => 'ظروف السائق A';

  @override
  String get claimsCircumstancesB => 'ظروف السائق B';

  @override
  String claimsProposalFaultB(String box) {
    return '$box: مناورة خطرة من السائق B.';
  }

  @override
  String claimsProposalBoth(String a, String b) {
    return 'A: $a، B: $b. مناورات خطرة من الطرفين: مسؤولية مشتركة.';
  }

  @override
  String get claimsProposalParkedB => 'كانت سيارة B متوقفة.';

  @override
  String get claimsNoCompany => 'شركة التأمين غير محدّدة';

  @override
  String claimsEventSealed(String hash) {
    return 'تم ختم المحضر (SHA-256 $hash)';
  }

  @override
  String claimsEventSealedLocal(String hash) {
    return 'تم ختم المحضر على الهاتف (SHA-256 $hash)';
  }

  @override
  String get claimsEventWaitingSync => 'في انتظار الاتصال للإرسال';

  @override
  String get claimsSummaryTitle => 'ملخص الملف';

  @override
  String claimsPriorityScore(String score) {
    return 'الأولوية $score';
  }

  @override
  String get claimsSearchMine => 'البحث في ملفاتي';

  @override
  String get claimsBySeverity => 'حسب الخطورة';

  @override
  String get claimsByType => 'حسب نوع الحادث';

  @override
  String get claimsAnswersBySource => 'الإجابات حسب المصدر';

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

  @override
  String get biometricConsentLabel =>
      'أوافق على تحليل وجهي للتحقق من هويتي. يتم التحليل على خوادم Mon Constat وتُحذف الصورة فور اتخاذ القرار (القانون عدد 63 لسنة 2004).';

  @override
  String get errorAiQuota =>
      'عدد كبير من التحاليل في وقت قصير. أعد المحاولة بعد قليل.';

  @override
  String get livenessHintNoFace => 'ضع وجهك داخل الإطار';

  @override
  String get livenessHintLookStraight => 'انظر مباشرة إلى الكاميرا';

  @override
  String get livenessHintTurnMore => 'أدر رأسك أكثر';

  @override
  String get dashAiTitle => 'التحقق بالذكاء الاصطناعي';

  @override
  String get dashAiFooter =>
      'خلال الفترة المعروضة. التحليل على خوادمنا دون خدمة خارجية.';

  @override
  String get dashAiRequests => 'طلبات';

  @override
  String get dashAiAutoRate => 'وثّقها الذكاء الاصطناعي وحده';

  @override
  String get dashAiAverageMatch => 'متوسط التطابق';

  @override
  String get dashAiBlocked => 'حسابات محظورة';

  @override
  String get checkBirthDate => 'نفس تاريخ الولادة في الرخصة';

  @override
  String get licenseBirthMismatch =>
      'تنبيه: تاريخ الولادة في الرخصة لا يطابق وثيقة هويتك.';

  @override
  String get licenseNameMismatch =>
      'تنبيه: هذه الرخصة ليست باسمك. أضف رخصتك أنت.';

  @override
  String get licenseCinMismatch =>
      'تنبيه: رقم بطاقة التعريف في الرخصة لا يطابق وثيقة هويتك.';

  @override
  String get errorWrongDocument =>
      'الصورة لا تُظهر الوثيقة المختارة. غيّر الوثيقة أو الصورة.';

  @override
  String get errorNotALicense => 'هذه الصورة ليست رخصة سياقة.';

  @override
  String get registerIntro =>
      'ثلاث خطوات، أقل من دقيقة. سيتم بعدها التحقق من رقمك برمز.';

  @override
  String get registerStepYou => 'أنت';

  @override
  String get registerStepContact => 'بيانات الاتصال';

  @override
  String get registerStepSecurity => 'الأمان';

  @override
  String get registerPhoneHint => 'سيصلك رمز التحقق على واتساب.';

  @override
  String get passwordWeak => 'ضعيفة';

  @override
  String get passwordFair => 'متوسطة';

  @override
  String get passwordGood => 'جيدة';

  @override
  String get passwordStrong => 'ممتازة';

  @override
  String get passwordRuleLength => '8 أحرف';

  @override
  String get passwordRuleUpper => 'حرف كبير';

  @override
  String get passwordRuleDigit => 'رقم';

  @override
  String get passwordRuleSymbol => 'رمز';

  @override
  String get identityStepDocument => 'الوثيقة';

  @override
  String get identityStepReading => 'القراءة';

  @override
  String get identityStepFace => 'الوجه';

  @override
  String get identityStepSend => 'الإرسال';

  @override
  String get profileIdentityVerified => 'هوية موثّقة';

  @override
  String get profileIdentityPending => 'الهوية قيد التحقق';

  @override
  String get profileIdentityTodo => 'تحقّق من هويتك';

  @override
  String get licenseStatusVerified => 'رخصة موثقة';

  @override
  String get licenseStatusToReview => 'الرخصة قيد التحقق';

  @override
  String get licenseStatusRejected => 'الرخصة مرفوضة';

  @override
  String get licenseToReviewNote =>
      'معلومة في الرخصة لا تطابق حسابك: يقوم مشرف بالتحقق منها.';

  @override
  String licenseRejectedNote(String reason) {
    return 'تم رفض رخصتك. السبب: $reason. أضف رخصتك الخاصة.';
  }

  @override
  String get errorLicenseNotYours =>
      'يبدو أن هذه الرخصة ليست لك: الاسم أو تاريخ الميلاد أو رقم بطاقة التعريف لا يطابق حسابك. لم يتم حفظها.';

  @override
  String get accountFileTitle => 'ملف الحساب';

  @override
  String get openAccountFile => 'عرض الملف';

  @override
  String get sectionAccount => 'الحساب';

  @override
  String get licenseReviewTitle => 'رخص للتحقق';

  @override
  String get licenseReviewSubtitle =>
      'فشل أحد فحوص الذكاء الاصطناعي، أو تعذرت قراءة الصورة';

  @override
  String get noLicenseReviews => 'لا توجد رخص للتحقق.';

  @override
  String licensesToReviewCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count رخص للتحقق',
      one: 'رخصة واحدة للتحقق',
    );
    return '$_temp0';
  }

  @override
  String get approveLicense => 'قبول الرخصة';

  @override
  String get rejectLicense => 'رفض الرخصة';

  @override
  String get deleteLicense => 'حذف الرخصة';

  @override
  String deleteLicenseBody(String name) {
    return 'سيتم حذف صورة ومعلومات رخصة $name.';
  }

  @override
  String get licenseApproved => 'تم قبول الرخصة';

  @override
  String get licenseRejected => 'تم رفض الرخصة، يرى السائق السبب';

  @override
  String get licenseDeleted => 'تم حذف الرخصة';

  @override
  String get licenseUpdated => 'تم تعديل الرخصة';

  @override
  String get noLicense => 'لا توجد رخصة مسجلة.';

  @override
  String get noIdentityDocuments => 'لا توجد وثيقة مسجلة.';

  @override
  String get aiChecksTitle => 'فحوص الذكاء الاصطناعي';

  @override
  String get checkLicenseName => 'اسم صاحب الرخصة = اسم الحساب';

  @override
  String get checkLicenseBirth => 'تاريخ الميلاد = وثيقة الهوية';

  @override
  String get checkLicenseCin => 'رقم بطاقة التعريف = وثيقة الهوية';

  @override
  String get checkLicenseNumber => 'الرقم المدخل = الرقم المقروء من الصورة';

  @override
  String get checkNotCompared => 'غير قابل للمقارنة';

  @override
  String get licenseRejectReasonNotOwner => 'رخصة شخص آخر';

  @override
  String get licenseRejectReasonExpired => 'رخصة منتهية الصلاحية';

  @override
  String get revokeIdentity => 'إلغاء التحقق';

  @override
  String get revokeIdentityTitle => 'إلغاء التحقق من الهوية؟';

  @override
  String get revokeIdentityBody =>
      'سيتم حذف صور الوثيقة. يرى السائق السبب ويمكنه إعادة الطلب فورا.';

  @override
  String get identityRevoked => 'تم إلغاء التحقق';

  @override
  String get reasonLabel => 'السبب';

  @override
  String get onbSkip => 'تخطي';

  @override
  String get onbLater => 'لاحقا';

  @override
  String get onbContinue => 'متابعة';

  @override
  String get onbBack => 'الخطوة السابقة';

  @override
  String onbProgress(int current, int total) {
    return 'الخطوة $current من $total';
  }

  @override
  String get onbWelcomeEyebrow => 'تم إنشاء الحساب';

  @override
  String onbWelcomeTitle(String name) {
    return 'مرحبا،\n$name';
  }

  @override
  String get onbWelcomeBody =>
      'دقيقتان لتجهيز حسابك، وستكون مستعدا يوم تحتاج إليه.';

  @override
  String get onbWelcomeStart => 'تجهيز حسابي';

  @override
  String get onbWelcomeSkip => 'سأفعل ذلك لاحقا';

  @override
  String get onbLicenseTitle => 'أضف رخصة القيادة';

  @override
  String get onbLicenseBody =>
      'صورة واحدة تكفي: يقرأ الذكاء الاصطناعي الرقم والأصناف والتاريخ. ستُستعمل لملء محاضرك.';

  @override
  String get onbLicenseScan => 'تصوير رخصتي';

  @override
  String get onbLicenseRescan => 'إعادة التصوير';

  @override
  String get onbLicenseReading => 'جار قراءة الرخصة…';

  @override
  String get onbLicenseRead => 'قرأها الذكاء الاصطناعي';

  @override
  String get onbLicenseUnread =>
      'تعذرت قراءة البطاقة. ستكمل المعلومات من ملفك الشخصي.';

  @override
  String get onbLicenseTip => 'على سطح مستو، بإضاءة جيدة ودون انعكاس.';

  @override
  String get onbIdentityTitle => 'تحقق من هويتك';

  @override
  String get onbIdentityBody => 'لتوقيع محاضرك بكل ثقة. يستغرق ذلك دقيقتين.';

  @override
  String get onbIdentityStep1 => 'وثيقة: بطاقة تعريف أو رخصة أو جواز سفر';

  @override
  String get onbIdentityStep2 => 'وجهك، مع إدارة الرأس';

  @override
  String get onbIdentityStep3 => 'يقارن الذكاء الاصطناعي في ثوان';

  @override
  String get onbIdentityStart => 'التحقق الآن';

  @override
  String get onbIdentityLicenseHint =>
      'يمكن استعمال رخصتك كوثيقة: لا حاجة لتصويرها مجددا.';

  @override
  String get onbIdentityPrivacy => 'تُحلل صورك على خوادمنا دون أي خدمة خارجية.';

  @override
  String get onbBiometricTitle => 'الدخول بلمسة واحدة';

  @override
  String get onbBiometricBody =>
      'افتح التطبيق ببصمتك أو وجهك دون إعادة كتابة كلمة المرور.';

  @override
  String get onbBiometricEnable => 'تفعيل';

  @override
  String onbDoneTitle(String name) {
    return 'كل شيء جاهز،\n$name';
  }

  @override
  String get onbDoneBody => 'يمكنك التصريح بحادث في أي وقت، حتى دون شبكة.';

  @override
  String get onbDoneLater => 'يمكنك إكمال الباقي من ملفك الشخصي متى شئت.';

  @override
  String get onbDoneStart => 'الدخول إلى التطبيق';

  @override
  String get onbItemPhone => 'الهاتف';

  @override
  String get onbItemLicense => 'رخصة القيادة';

  @override
  String get onbItemIdentity => 'الهوية';

  @override
  String get onbItemBiometric => 'الدخول البيومتري';

  @override
  String get onbStateDone => 'تم';

  @override
  String get onbStatePending => 'قيد التحقق';

  @override
  String get onbStateTodo => 'للإنجاز';
}
