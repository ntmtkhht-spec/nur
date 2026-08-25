// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'منير';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navPrayers => 'الصلاة';

  @override
  String get navQuran => 'القرآن';

  @override
  String get navTasbih => 'التسبيح';

  @override
  String get navQibla => 'القبلة';

  @override
  String greeting(String name) {
    return 'السلام عليكم، $name';
  }

  @override
  String get greetingNoName => 'السلام عليكم';

  @override
  String get nextPrayer => 'الصلاة القادمة';

  @override
  String inHoursMinutes(int hours, int minutes) {
    return 'خلال $hours س $minutes د';
  }

  @override
  String inMinutesSeconds(int minutes, int seconds) {
    return 'خلال $minutes د $seconds ث';
  }

  @override
  String get todaysProgress => 'تقدم اليوم';

  @override
  String get overallProgress => 'التقدم العام';

  @override
  String percentComplete(int percent) {
    return '$percent٪ مكتمل';
  }

  @override
  String get prayerNotYetDue => 'لم يحن وقت هذه الصلاة بعد.';

  @override
  String get statsTitle => 'الإحصائيات';

  @override
  String get statsStreakLabel => 'يوم متتالٍ';

  @override
  String get statsBestLabel => 'الأفضل';

  @override
  String get statsWeekLabel => 'آخر ٧ أيام';

  @override
  String get statsTotalLabel => 'صلوات مسجلة';

  @override
  String statsWeekValue(int done) {
    return '$done/7';
  }

  @override
  String statsWeakest(String prayer) {
    return 'الأكثر فواتًا مؤخرًا: $prayer';
  }

  @override
  String get statsEmpty => 'سجّل أول صلاة لك — ستظهر أرقامك هنا.';

  @override
  String get streakTitle => 'سلسلة صلواتك';

  @override
  String streakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count يوم متتالٍ',
      many: '$count يومًا متتاليًا',
      few: '$count أيام متتالية',
      two: 'يومان متتاليان',
      one: 'يوم واحد متتالٍ',
      zero: '$count يوم متتالٍ',
    );
    return '$_temp0';
  }

  @override
  String streakBest(int count) {
    return 'الأفضل: $count';
  }

  @override
  String get streakMilestoneTitle => 'إنجاز جديد!';

  @override
  String streakMilestoneBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count يوم متتالٍ',
      many: '$count يومًا متتاليًا',
      few: '$count أيام متتالية',
      two: 'يومان متتاليان',
      one: 'يوم واحد متتالٍ',
      zero: '$count يوم متتالٍ',
    );
    return '$_temp0';
  }

  @override
  String get praiseTitle => 'ما شاء الله!';

  @override
  String praiseAllPrayers(int completed, int total) {
    return '$completed/$total تمت';
  }

  @override
  String tasbihTotal(int count) {
    return 'المجموع $count';
  }

  @override
  String get prayerFajr => 'الفجر';

  @override
  String get prayerSunrise => 'الشروق';

  @override
  String get prayerDhuhr => 'الظهر';

  @override
  String get prayerAsr => 'العصر';

  @override
  String get prayerMaghrib => 'المغرب';

  @override
  String get prayerIsha => 'العشاء';

  @override
  String get quickMosques => 'المساجد';

  @override
  String get quickQibla => 'القبلة';

  @override
  String get quickDuas => 'الأدعية';

  @override
  String get quickNames => 'أسماء الله الحسنى';

  @override
  String get locationWarning =>
      'لا يوجد وصول إلى الموقع. مواقيت الصلاة تستخدم القيم الافتراضية (برلين).';

  @override
  String get activate => 'تفعيل';

  @override
  String get today => 'اليوم';

  @override
  String todayShort(String date) {
    return 'اليوم، $date';
  }

  @override
  String get mosquesTitle => 'المساجد';

  @override
  String get mosquesRadius => 'نطاق البحث';

  @override
  String mosquesKm(int km) {
    return '$km كم';
  }

  @override
  String get mosquesRefresh => 'تحديث';

  @override
  String get mosquesShowList => 'قائمة';

  @override
  String get mosquesShowMap => 'خريطة';

  @override
  String get mosquesRoute => 'الاتجاهات';

  @override
  String get mosquesWebsite => 'الموقع الإلكتروني';

  @override
  String get mosquesCall => 'اتصال';

  @override
  String mosquesEmpty(int km) {
    return 'لم يتم العثور على مساجد ضمن $km كم.';
  }

  @override
  String get mosquesRetry => 'حاول مرة أخرى';

  @override
  String get mosquesCouldNotOpen => 'تعذّر الفتح.';

  @override
  String mosquesDistanceKm(String km) {
    return '$km كم';
  }

  @override
  String get mosquesConsentTitle => 'ابحث عن المساجد القريبة منك';

  @override
  String get mosquesConsentBody =>
      'سيتم إرسال إحداثياتك إلى OpenStreetMap. لن تُرسل أي بيانات أخرى.';

  @override
  String get mosquesConsentAccept => 'أوافق، ابحث';

  @override
  String get qiblaTitle => 'القبلة';

  @override
  String get qiblaTurnToKaaba => 'استدر نحو الكعبة';

  @override
  String qiblaDistanceToMecca(String km) {
    return 'المسافة إلى مكة: $km كم';
  }

  @override
  String get qiblaNoCompass => 'جهازك لا يحتوي على بوصلة.';

  @override
  String get tasbihTitle => 'التسبيح';

  @override
  String get tasbihTapToCount => 'اضغط للعد';

  @override
  String tasbihRound(int round) {
    return 'الجولة $round';
  }

  @override
  String get tasbihReset => 'إعادة تعيين';

  @override
  String get quranTitle => 'القرآن';

  @override
  String quranVerses(int count) {
    return '$count آية';
  }

  @override
  String get quranSearchHint => 'ابحث عن سورة…';

  @override
  String get duasTitle => 'الأدعية';

  @override
  String get duasSearchHint => 'ابحث عن دعاء…';

  @override
  String duasCount(int count) {
    return '$count دعاء';
  }

  @override
  String get namesTitle => 'أسماء الله الحسنى';

  @override
  String get namesSearchHint => 'ابحث بالاسم أو المعنى…';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get settingsSectionPrayer => 'الصلاة';

  @override
  String get settingsSectionNotifications => 'الإشعارات';

  @override
  String get settingsSectionDisplay => 'المظهر';

  @override
  String get settingsSectionData => 'البيانات';

  @override
  String get settingsSectionLegal => 'قانوني';

  @override
  String get settingsLocation => 'الموقع';

  @override
  String get settingsLocationHint => 'اضغط لتحديد الموقع من جديد';

  @override
  String get settingsCalculationMethod => 'طريقة الحساب';

  @override
  String get settingsMadhab => 'المذهب';

  @override
  String get settingsNotifications => 'الإشعارات';

  @override
  String get settingsName => 'الاسم';

  @override
  String get settingsNameHint => 'بماذا نناديك؟';

  @override
  String get settingsLanguage => 'اللغة';

  @override
  String get settingsMosqueConsent => 'السماح بالبحث عن المساجد';

  @override
  String get settingsMosqueConsentHint => 'يُرسل إحداثياتك إلى OpenStreetMap';

  @override
  String get settingsClearMapCache => 'مسح ذاكرة الخرائط';

  @override
  String get settingsClearMapCacheHint => 'إزالة مربعات الخريطة المحفوظة';

  @override
  String get settingsClearMapCacheDone => 'تم مسح ذاكرة الخرائط.';

  @override
  String get settingsResetTracker => 'إعادة تعيين سجل الصلاة';

  @override
  String get settingsResetTrackerHint =>
      'يحذف جميع الصلوات المسجّلة وسلسلة المتابعة';

  @override
  String get settingsResetTrackerConfirm =>
      'هل تريد إعادة التعيين فعلاً؟ ستفقد جميع الصلوات المسجّلة وسلسلة المتابعة.';

  @override
  String get settingsResetTrackerDone => 'تمت إعادة تعيين سجل الصلاة.';

  @override
  String get settingsPrivacy => 'سياسة الخصوصية';

  @override
  String get settingsImprint => 'بيانات الناشر';

  @override
  String get settingsNotConfigured => 'لم يتم إعداده بعد';

  @override
  String settingsVersion(String version) {
    return 'الإصدار $version';
  }

  @override
  String get commonCancel => 'إلغاء';

  @override
  String get commonDelete => 'حذف';

  @override
  String get commonSave => 'حفظ';

  @override
  String get commonReset => 'إعادة تعيين';

  @override
  String get commonClose => 'إغلاق';

  @override
  String get commonContinue => 'متابعة';

  @override
  String get commonBack => 'رجوع';

  @override
  String get commonDone => 'تم';

  @override
  String commonComingSoon(String feature) {
    return '$feature قريباً!';
  }

  @override
  String get onboardingLanguageTitle => 'اختر اللغة';

  @override
  String get onboardingNameTitle => 'ما اسمك؟';

  @override
  String get onboardingNameHint => 'اسمك';

  @override
  String get onboardingLocationTitle => 'الموقع';

  @override
  String get onboardingLocationBody => 'نحتاج موقعك لحساب مواقيت الصلاة بدقة.';

  @override
  String get onboardingLocationAllow => 'السماح بالوصول للموقع';

  @override
  String get onboardingLocationManual => 'اختر المدينة يدوياً';

  @override
  String get onboardingMethodTitle => 'طريقة الحساب';

  @override
  String get onboardingAdhanTitle => 'صوت الأذان';

  @override
  String get onboardingDoneTitle => 'كل شيء جاهز';

  @override
  String get onboardingDoneBody => 'نسأل الله أن يعينك هذا التطبيق على صلاتك.';

  @override
  String get onboardingStart => 'لنبدأ';

  @override
  String notificationPrayerTimeTitle(String prayer, String time) {
    return 'حان وقت $prayer · $time';
  }

  @override
  String get notificationBodyFajr => 'الصلاة خير من النوم';

  @override
  String get notificationBodyDhuhr =>
      'صخب اليوم يعلو. الظهر هو اللحظة التي يهدأ فيها — اغتنمها قبل أن تمضي.';

  @override
  String get notificationBodyAsr =>
      'يتحول الضوء إلى الذهبي. اغتنم هذه اللحظة وصلِّ العصر.';

  @override
  String get notificationBodyMaghrib => 'غربت الشمس. لحظة شكر.';

  @override
  String get notificationBodyIsha =>
      'انتهى اليوم، ولم تنتهِ الصلاة الأخيرة. صلِّ العشاء قبل أن تنام.';

  @override
  String notificationLocationLine(String city) {
    return 'محسوبة لـ $city';
  }

  @override
  String notificationCatchUpTitle(String prayer) {
    return '$prayer على وشك الانتهاء';
  }

  @override
  String notificationCatchUpBody(String next, String time) {
    return 'اغتنم الوقت المتبقي قبل أن يبدأ $next في $time.';
  }

  @override
  String get notificationCatchUpChannelName => 'صلوات لم تُسجَّل';

  @override
  String get notificationCatchUpChannelDescription =>
      'تذكير عندما لا تكون الصلاة مسجَّلة بعد';

  @override
  String get settingsCatchUpReminders => 'تذكيري بالصلوات غير المسجَّلة';

  @override
  String get settingsCatchUpRemindersHint =>
      'قبل الصلاة التالية بثلاثين دقيقة، إذا لم يُسجَّل شيء بعد';

  @override
  String get settingsMadhabShafiHint => 'وكذلك المالكي والحنبلي — العصر مبكراً';

  @override
  String get settingsMadhabHanafiHint => 'العصر متأخراً';

  @override
  String get settingsNotSet => 'غير محدد';

  @override
  String get qiblaAligned => 'في الاتجاه الصحيح — نحو مكة';

  @override
  String get settingsDataSources => 'مصادر البيانات';

  @override
  String get nowLabel => 'الآن';

  @override
  String get onboardingLanguageSubtitle => 'يمكنك تغيير ذلك في أي وقت';

  @override
  String get onboardingNameQuestion => 'بماذا نناديك؟';

  @override
  String get onboardingNameSubtitle => 'من أجل تحيتك الشخصية.';

  @override
  String onboardingNamePreview(String name) {
    return 'مثلاً لـ «السلام عليكم، $name»';
  }

  @override
  String get onboardingLocationDetect => 'تحديد الموقع تلقائياً';

  @override
  String get onboardingLocationSearch => 'ابحث عن مدينة…';

  @override
  String get onboardingLocationSkip => 'المتابعة بدون الموقع';

  @override
  String get onboardingLocationPrivacy =>
      'تُحسب مواقيت الصلاة والقبلة على جهازك. البحث عن المساجد وحده يرسل موقعك — وبعد إذنك.';

  @override
  String onboardingLocationDetected(String city) {
    return 'تم تحديد الموقع: $city';
  }

  @override
  String get onboardingLocationNotFound => 'لم يتم العثور على المكان.';

  @override
  String get onboardingLocationSearchFailed => 'فشل البحث. تحقق من اتصالك.';

  @override
  String get onboardingMethodHeading => 'ضبط مواقيت الصلاة';

  @override
  String get onboardingMethodSection => 'طريقة الحساب';

  @override
  String get onboardingMadhabSection => 'حساب العصر (المذهب)';

  @override
  String get onboardingAdhanHeading => 'تنبيهات الأذان';

  @override
  String get onboardingAdhanBody => 'لتصلك تذكرة لطيفة عند كل وقت صلاة.';

  @override
  String get onboardingAdhanEnable => 'تفعيل الإشعارات';

  @override
  String get onboardingAdhanEnabled => 'تم تفعيل الإشعارات.';

  @override
  String get onboardingAdhanDenied => 'لم يتم منح الإذن.';

  @override
  String get onboardingDoneHeading => 'كل شيء جاهز';

  @override
  String onboardingDoneHeadingNamed(String name) {
    return 'كل شيء جاهز، $name';
  }

  @override
  String get onboardingDoneCompanion => 'عسى أن يرافقك منير في يومك.';

  @override
  String get onboardingOpenApp => 'فتح التطبيق';

  @override
  String get onboardingAdhanOn => 'الأذان مفعّل';

  @override
  String get onboardingAdhanOff => 'الأذان متوقف';

  @override
  String get featurePrayerTitle => 'لا تفوّت صلاة بعد اليوم';

  @override
  String get featurePrayerBody => 'مواقيت دقيقة لموقعك، مع تنبيه الأذان.';

  @override
  String get featureQiblaTitle => 'اعرف اتجاه القبلة';

  @override
  String get featureQiblaBody => 'بوصلة دقيقة تدلك على مكة أينما كنت.';

  @override
  String get featureQuranTitle => 'القرآن معك دائماً';

  @override
  String get featureQuranBody => 'اقرأ واستمع وسجّل تقدمك — متاح دون إنترنت.';

  @override
  String get commonSkip => 'تخطي';

  @override
  String get commonNext => 'التالي';

  @override
  String get onboardingLocationQuestion => 'أين أنت؟';

  @override
  String get notificationChannelName => 'مواقيت الصلاة';

  @override
  String get notificationChannelDescription => 'تنبيهات لمواقيت الصلاة اليومية';

  @override
  String get onboardingLocationWhy =>
      'نحتاج موقعك لحساب مواقيت الصلاة واتجاه القبلة بدقة.';

  @override
  String get commonOr => 'أو';

  @override
  String get settingsSectionAccount => 'الحساب';

  @override
  String get settingsSignInGoogle => 'تسجيل الدخول عبر Google';

  @override
  String get settingsSignInApple => 'تسجيل الدخول عبر Apple';

  @override
  String get settingsSignInWhy => 'يحفظ سجل صلاتك ويزامنه بين أجهزتك';

  @override
  String get settingsSignOut => 'تسجيل الخروج';

  @override
  String get settingsDeleteAccount => 'حذف الحساب';

  @override
  String get settingsDeleteAccountHint =>
      'يحذف حسابك وجميع البيانات المحفوظة نهائياً';

  @override
  String get settingsDeleteAccountConfirm =>
      'هل تريد حذف حسابك فعلاً؟ سيُحذف سجلك نهائياً من الحساب ومن هذا الجهاز. لا يمكن التراجع عن ذلك.';

  @override
  String get onboardingPrivacyLink => 'اقرأ سياسة الخصوصية';

  @override
  String get adoptLocalDataTitle => 'إضافة السجلات الموجودة؟';

  @override
  String get adoptLocalDataBody =>
      'يحتوي هذا الجهاز على سجلات لا تنتمي بعد إلى أي حساب. هل تريد إضافتها إلى حسابك؟ إذا حصلت على هذا الجهاز من شخص آخر، فاحذفها.';

  @override
  String adoptLocalDataBodyCounted(int count) {
    return 'يحتوي هذا الجهاز على $count صلاة مسجلة لا تنتمي بعد إلى أي حساب. هل تريد إضافتها إلى حسابك؟ إذا حصلت على هذا الجهاز من شخص آخر، فاحذفها.';
  }

  @override
  String get adoptLocalDataKeep => 'إضافة';

  @override
  String get adoptLocalDataDiscard => 'حذف';

  @override
  String get settingsSignOutConfirm =>
      'تسجيل الخروج؟ ستُحفظ سجلاتك في حسابك أولاً ثم تُزال من هذا الجهاز. ستعود عند تسجيل الدخول مرة أخرى. يتطلب ذلك اتصالاً بالإنترنت.';

  @override
  String get settingsSignOutNeedsConnection =>
      'يتطلب تسجيل الخروج اتصالاً – تُحفظ سجلاتك في حسابك أولاً. يرجى المحاولة لاحقاً.';

  @override
  String settingsSignedInAs(String email) {
    return 'تم تسجيل الدخول باسم $email';
  }

  @override
  String get settingsSignInFailed => 'فشل تسجيل الدخول.';

  @override
  String get settingsSyncNow => 'مزامنة الآن';

  @override
  String get settingsSyncDone => 'تمت المزامنة.';

  @override
  String get settingsAccountDeleted => 'تم حذف الحساب.';

  @override
  String get onboardingAccountTitle => 'احفظ تقدمك';

  @override
  String get onboardingAccountBody =>
      'مع حساب يبقى سجل صلاتك محفوظاً — حتى عند تغيير الجهاز. بدون حساب يبقى كل شيء على هذا الجهاز فقط.';

  @override
  String get commonLater => 'لاحقاً';

  @override
  String quranTranslationCredit(String translator) {
    return 'الترجمة: $translator';
  }

  @override
  String get quranSourceCredit =>
      'النص العربي والنقحرة والتلاوة عبر alquran.cloud';

  @override
  String get settingsLicenses => 'تراخيص المصادر المفتوحة';

  @override
  String get settingsLicensesHint => 'نصوص تراخيص المكتبات المستخدمة';

  @override
  String get mosqueConsentHeading => 'العثور على المساجد القريبة';

  @override
  String get mosqueConsentBody =>
      'يُرسَل موقعك الحالي إلى واجهة Overpass (التي يشغّلها FOSSGIS e.V.) لتنفيذ البحث في محيطك ضمن بيانات OpenStreetMap.\n\nهذه هي الوظيفة الوحيدة التي يغادر فيها موقعك الجهاز. ولا تُرسَل أي بيانات أخرى ولا أي معرّف.';

  @override
  String get mosqueConsentAccept => 'أوافق، ابحث عن المساجد';

  @override
  String get mosqueConsentRevocable => 'يمكنك التراجع عن ذلك في أي وقت.';

  @override
  String get mosqueSearching => 'جارٍ البحث عن المساجد …';

  @override
  String get mosqueUnnamed => 'مسجد (بدون اسم)';

  @override
  String get qiblaCalibrateAction => 'معايرة البوصلة';

  @override
  String get qiblaCalibrateHint =>
      'حرّك جهازك على شكل رقم ثمانية (∞) لمعايرة البوصلة.';

  @override
  String get qiblaNeedsLocation => 'تحديد القبلة بدقة يتطلب موقعك الحالي.';

  @override
  String get qiblaLocationUnavailable => 'الموقع غير متاح. فعّله من الإعدادات.';

  @override
  String get qiblaCompassUnsupported => 'لا تتوفر بوصلة في هذا الجهاز.';

  @override
  String get qiblaInaccurate =>
      'الاتجاه غير دقيق. حرّك جهازك على شكل رقم ثمانية (∞).';

  @override
  String get locationServicesDisabled => 'خدمات الموقع معطّلة.';

  @override
  String get locationPermissionDenied => 'تم رفض الوصول إلى الموقع.';

  @override
  String get locationNoFix => 'لا يتوفر موقع حالي. ابحث عن المدينة يدويًا.';

  @override
  String get locationDetecting => 'جارٍ تحديد الموقع …';

  @override
  String get locationUnavailableShort => 'غير متاح';

  @override
  String get settingsNamePlaceholder => 'اسمك';

  @override
  String get commonLoadFailed => 'تعذّر التحميل.';

  @override
  String get commonRetry => 'أعد المحاولة';

  @override
  String get surahSearchOpen => 'ابحث في السور';

  @override
  String get surahSearchClose => 'إغلاق البحث';

  @override
  String get surahSearchClear => 'مسح البحث';

  @override
  String get quranProgressHeading => 'تقدّمك';

  @override
  String get quranProgressEmpty => 'يظهر تقدّمك هنا بمجرد قراءتك آية.';

  @override
  String get quranArabicTextSize => 'حجم النص (العربية)';

  @override
  String get namesNoMatch => 'لم يُعثر على اسم.';

  @override
  String get adviceTomorrow => 'غدًا تجد هنا الإرشاد التالي.';

  @override
  String get locationLabelFallback => 'الموقع';

  @override
  String get mosqueSearchBusy =>
      'خدمة البحث عن المساجد مزدحمة الآن. حاول مرة أخرى بعد بضع دقائق.';

  @override
  String get mosqueSearchFailed => 'فشل البحث عن المساجد.';

  @override
  String get quranShowTranslation => 'إظهار الترجمة';

  @override
  String get adviceSectionLabel => 'إرشاد اليوم';

  @override
  String get adviceReadMore => 'اقرأ المزيد';

  @override
  String get adviceActionLabel => 'طبّقه اليوم';

  @override
  String get surahSearchHint => 'ابحث عن سورة';

  @override
  String dateToday(String date) {
    return 'اليوم، $date';
  }
}
