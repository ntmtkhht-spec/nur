// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appName => 'Munir';

  @override
  String get navHome => 'Ana sayfa';

  @override
  String get navPrayers => 'Namaz';

  @override
  String get navQuran => 'Kur\'an';

  @override
  String get navTasbih => 'Tesbih';

  @override
  String get navQibla => 'Kıble';

  @override
  String greeting(String name) {
    return 'Esselamü aleyküm, $name';
  }

  @override
  String get greetingNoName => 'Esselamü aleyküm';

  @override
  String get nextPrayer => 'Sonraki namaz';

  @override
  String inHoursMinutes(int hours, int minutes) {
    return '$hours sa $minutes dk içinde';
  }

  @override
  String inMinutesSeconds(int minutes, int seconds) {
    return '$minutes dk $seconds sn içinde';
  }

  @override
  String get todaysProgress => 'Bugünkü İlerleme';

  @override
  String get overallProgress => 'Genel İlerleme';

  @override
  String percentComplete(int percent) {
    return '%$percent tamamlandı';
  }

  @override
  String get prayerNotYetDue => 'Bu namazın vakti henüz gelmedi.';

  @override
  String get statsTitle => 'İstatistikler';

  @override
  String get statsStreakLabel => 'Gün üst üste';

  @override
  String get statsBestLabel => 'En iyi';

  @override
  String get statsWeekLabel => 'Son 7 gün';

  @override
  String get statsTotalLabel => 'Kaydedilen namaz';

  @override
  String statsWeekValue(int done) {
    return '$done/7';
  }

  @override
  String statsWeakest(String prayer) {
    return 'Son zamanlarda en çok kaçan: $prayer';
  }

  @override
  String get statsEmpty =>
      'İlk namazını işaretle — rakamların burada görünecek.';

  @override
  String get streakTitle => 'Namaz serin';

  @override
  String streakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gün üst üste',
    );
    return '$_temp0';
  }

  @override
  String streakBest(int count) {
    return 'En iyi: $count';
  }

  @override
  String get streakMilestoneTitle => 'Dönüm noktası!';

  @override
  String streakMilestoneBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gün üst üste',
    );
    return '$_temp0';
  }

  @override
  String get praiseTitle => 'MaşaAllah!';

  @override
  String praiseAllPrayers(int completed, int total) {
    return '$completed/$total tamamlandı';
  }

  @override
  String tasbihTotal(int count) {
    return 'Toplam $count';
  }

  @override
  String get prayerFajr => 'İmsak';

  @override
  String get prayerSunrise => 'Güneş';

  @override
  String get prayerDhuhr => 'Öğle';

  @override
  String get prayerAsr => 'İkindi';

  @override
  String get prayerMaghrib => 'Akşam';

  @override
  String get prayerIsha => 'Yatsı';

  @override
  String get quickMosques => 'Camiler';

  @override
  String get quickQibla => 'Kıble';

  @override
  String get quickDuas => 'Dualar';

  @override
  String get quickNames => '99 İsim';

  @override
  String get locationWarning =>
      'Konum erişimi yok. Namaz vakitleri varsayılan değerleri kullanıyor (Berlin).';

  @override
  String get activate => 'Etkinleştir';

  @override
  String get today => 'Bugün';

  @override
  String todayShort(String date) {
    return 'Bugün, $date';
  }

  @override
  String get mosquesTitle => 'Camiler';

  @override
  String get mosquesRadius => 'Yarıçap';

  @override
  String mosquesKm(int km) {
    return '$km km';
  }

  @override
  String get mosquesRefresh => 'Yenile';

  @override
  String get mosquesShowList => 'Liste';

  @override
  String get mosquesShowMap => 'Harita';

  @override
  String get mosquesRoute => 'Yol tarifi';

  @override
  String get mosquesWebsite => 'Web sitesi';

  @override
  String get mosquesCall => 'Ara';

  @override
  String mosquesEmpty(int km) {
    return '$km km çapında cami bulunamadı.';
  }

  @override
  String get mosquesRetry => 'Tekrar dene';

  @override
  String get mosquesCouldNotOpen => 'Açılamadı.';

  @override
  String mosquesDistanceKm(String km) {
    return '$km km';
  }

  @override
  String get mosquesConsentTitle => 'Yakınındaki camileri bul';

  @override
  String get mosquesConsentBody =>
      'Bunun için koordinatların OpenStreetMap\'e gönderilir. Başka veri aktarılmaz.';

  @override
  String get mosquesConsentAccept => 'Kabul et ve ara';

  @override
  String get qiblaTitle => 'Kıble';

  @override
  String get qiblaTurnToKaaba => 'Kâbe\'ye dön';

  @override
  String qiblaDistanceToMecca(String km) {
    return 'Mekke\'ye uzaklık: $km km';
  }

  @override
  String get qiblaNoCompass => 'Cihazında pusula yok.';

  @override
  String get tasbihTitle => 'Tesbih';

  @override
  String get tasbihTapToCount => 'Saymak için dokun';

  @override
  String tasbihRound(int round) {
    return '$round. tur';
  }

  @override
  String get tasbihReset => 'Sıfırla';

  @override
  String get quranTitle => 'Kur\'an';

  @override
  String quranVerses(int count) {
    return '$count ayet';
  }

  @override
  String get quranSearchHint => 'Sure ara…';

  @override
  String get duasTitle => 'Dualar';

  @override
  String get duasSearchHint => 'Dua ara…';

  @override
  String duasCount(int count) {
    return '$count dua';
  }

  @override
  String get namesTitle => '99 İsim';

  @override
  String get namesSearchHint => 'İsim veya anlam ara…';

  @override
  String get settingsTitle => 'Ayarlar';

  @override
  String get settingsSectionPrayer => 'Namaz';

  @override
  String get settingsSectionNotifications => 'Bildirimler';

  @override
  String get settingsSectionDisplay => 'Görünüm';

  @override
  String get settingsSectionData => 'Veriler';

  @override
  String get settingsSectionLegal => 'Yasal';

  @override
  String get settingsLocation => 'Konum';

  @override
  String get settingsLocationHint => 'Yeniden belirlemek için dokun';

  @override
  String get settingsCalculationMethod => 'Hesaplama yöntemi';

  @override
  String get settingsMadhab => 'Mezhep';

  @override
  String get settingsNotifications => 'Bildirimler';

  @override
  String get settingsName => 'İsim';

  @override
  String get settingsNameHint => 'Sana nasıl hitap edelim?';

  @override
  String get settingsLanguage => 'Dil';

  @override
  String get settingsMosqueConsent => 'Cami aramaya izin ver';

  @override
  String get settingsMosqueConsentHint =>
      'Koordinatlarını OpenStreetMap\'e gönderir';

  @override
  String get settingsClearMapCache => 'Harita önbelleğini temizle';

  @override
  String get settingsClearMapCacheHint => 'Kayıtlı harita parçalarını kaldır';

  @override
  String get settingsClearMapCacheDone => 'Harita önbelleği temizlendi.';

  @override
  String get settingsResetTracker => 'Namaz geçmişini sıfırla';

  @override
  String get settingsResetTrackerHint =>
      'İşaretlenen tüm namazları ve seriyi siler';

  @override
  String get settingsResetTrackerConfirm =>
      'Gerçekten sıfırlansın mı? İşaretlenen tüm namazlar ve serin kaybolacak.';

  @override
  String get settingsResetTrackerDone => 'Namaz geçmişi sıfırlandı.';

  @override
  String get settingsPrivacy => 'Gizlilik politikası';

  @override
  String get settingsImprint => 'Künye';

  @override
  String get settingsNotConfigured => 'Henüz tanımlanmadı';

  @override
  String settingsVersion(String version) {
    return 'Sürüm $version';
  }

  @override
  String get commonCancel => 'İptal';

  @override
  String get commonDelete => 'Sil';

  @override
  String get commonSave => 'Kaydet';

  @override
  String get commonReset => 'Sıfırla';

  @override
  String get commonClose => 'Kapat';

  @override
  String get commonContinue => 'Devam';

  @override
  String get commonBack => 'Geri';

  @override
  String get commonDone => 'Tamam';

  @override
  String commonComingSoon(String feature) {
    return '$feature yakında!';
  }

  @override
  String get onboardingLanguageTitle => 'Dil seç';

  @override
  String get onboardingNameTitle => 'Adın ne?';

  @override
  String get onboardingNameHint => 'Adın';

  @override
  String get onboardingLocationTitle => 'Konum';

  @override
  String get onboardingLocationBody =>
      'Doğru namaz vakitleri için konumuna ihtiyacımız var.';

  @override
  String get onboardingLocationAllow => 'Konuma izin ver';

  @override
  String get onboardingLocationManual => 'Şehri elle seç';

  @override
  String get onboardingMethodTitle => 'Hesaplama yöntemi';

  @override
  String get onboardingAdhanTitle => 'Ezan sesi';

  @override
  String get onboardingDoneTitle => 'Her şey hazır';

  @override
  String get onboardingDoneBody =>
      'Bu uygulama namazlarında sana yardımcı olsun.';

  @override
  String get onboardingStart => 'Başla';

  @override
  String notificationPrayerTimeTitle(String prayer, String time) {
    return '$prayer vakti girdi · $time';
  }

  @override
  String get notificationBodyFajr =>
      'الصلاة خير من النوم\nNamaz uykudan hayırlıdır.';

  @override
  String get notificationBodyDhuhr =>
      'Gün gürültülü oldu. Öğle, sessizleştiği andır — geçmeden onu al.';

  @override
  String get notificationBodyAsr =>
      'Işık altın rengine dönüyor. Bu anı al ve ikindi namazını kıl.';

  @override
  String get notificationBodyMaghrib => 'Güneş battı. Bir şükür anı.';

  @override
  String get notificationBodyIsha =>
      'Gün bitti, son namaz henüz değil. Uyumadan önce yatsıyı kıl.';

  @override
  String notificationLocationLine(String city) {
    return '$city için hesaplandı';
  }

  @override
  String notificationCatchUpTitle(String prayer) {
    return '$prayer vakti yakında bitiyor';
  }

  @override
  String notificationCatchUpBody(String next, String time) {
    return '$next saat $time itibarıyla başlamadan önce kalan zamanı değerlendir.';
  }

  @override
  String get notificationCatchUpChannelName => 'Açık namazlar';

  @override
  String get notificationCatchUpChannelDescription =>
      'Bir namaz henüz kaydedilmediğinde hatırlatma';

  @override
  String get settingsCatchUpReminders => 'Açık namazları hatırlat';

  @override
  String get settingsCatchUpRemindersHint =>
      'Henüz kayıt yoksa, sonraki namazdan 30 dakika önce';

  @override
  String get settingsMadhabShafiHint =>
      'Maliki ve Hanbeli de — daha erken ikindi';

  @override
  String get settingsMadhabHanafiHint => 'Daha geç ikindi';

  @override
  String get settingsNotSet => 'ayarlanmadı';

  @override
  String get qiblaAligned => 'Hizalandı — Mekke yönünde';

  @override
  String get settingsDataSources => 'Veri kaynakları';

  @override
  String get nowLabel => 'şimdi';

  @override
  String get onboardingLanguageSubtitle =>
      'Bunu istediğin zaman değiştirebilirsin';

  @override
  String get onboardingNameQuestion => 'Sana nasıl hitap edelim?';

  @override
  String get onboardingNameSubtitle => 'Kişisel selamlaman için.';

  @override
  String onboardingNamePreview(String name) {
    return 'örn. „Esselamü aleyküm, $name“ için';
  }

  @override
  String get onboardingLocationDetect => 'Konumu otomatik algıla';

  @override
  String get onboardingLocationSearch => 'Şehri elle ara…';

  @override
  String get onboardingLocationSkip => 'Konumsuz devam et';

  @override
  String get onboardingLocationPrivacy =>
      'Namaz vakitleri ve kıble cihazında hesaplanır. Yalnızca cami araması konumunu gönderir — ve önce sorar.';

  @override
  String onboardingLocationDetected(String city) {
    return 'Konum algılandı: $city';
  }

  @override
  String get onboardingLocationNotFound => 'Yer bulunamadı.';

  @override
  String get onboardingLocationSearchFailed =>
      'Arama başarısız. Bağlantını kontrol et.';

  @override
  String get onboardingMethodHeading => 'Namaz vakitlerini ayarla';

  @override
  String get onboardingMethodSection => 'HESAPLAMA YÖNTEMİ';

  @override
  String get onboardingMadhabSection => 'İKİNDİ HESABI (MEZHEP)';

  @override
  String get onboardingAdhanHeading => 'Ezan hatırlatmaları';

  @override
  String get onboardingAdhanBody => 'Her namaz vaktinde nazikçe hatırlatalım.';

  @override
  String get onboardingAdhanEnable => 'Bildirimleri etkinleştir';

  @override
  String get onboardingAdhanEnabled => 'Bildirimler etkinleştirildi.';

  @override
  String get onboardingAdhanDenied => 'İzin verilmedi.';

  @override
  String get onboardingDoneHeading => 'Her şey hazır';

  @override
  String onboardingDoneHeadingNamed(String name) {
    return 'Her şey hazır, $name';
  }

  @override
  String get onboardingDoneCompanion => 'Munir gününde sana eşlik etsin.';

  @override
  String get onboardingOpenApp => 'Uygulamayı aç';

  @override
  String get onboardingAdhanOn => 'Ezan açık';

  @override
  String get onboardingAdhanOff => 'Ezan kapalı';

  @override
  String get featurePrayerTitle => 'Bir daha namaz kaçırma';

  @override
  String get featurePrayerBody =>
      'Konumuna göre kesin namaz vakitleri, ezan hatırlatmasıyla.';

  @override
  String get featureQiblaTitle => 'Kıble yönünü bul';

  @override
  String get featureQiblaBody =>
      'Hassas bir pusula her yerde Mekke\'yi gösterir.';

  @override
  String get featureQuranTitle => 'Kur\'an hep yanında';

  @override
  String get featureQuranBody =>
      'Oku, dinle ve ilerlemeni işaretle — çevrimdışı kullanılabilir.';

  @override
  String get commonSkip => 'Atla';

  @override
  String get commonNext => 'İleri';

  @override
  String get onboardingLocationQuestion => 'Neredesin?';

  @override
  String get notificationChannelName => 'Namaz vakitleri';

  @override
  String get notificationChannelDescription =>
      'Günlük namaz vakitleri için hatırlatmalar';

  @override
  String get onboardingLocationWhy =>
      'Doğru namaz vakitleri ve kıble yönü için konumuna ihtiyacımız var.';

  @override
  String get commonOr => 'veya';

  @override
  String get settingsSectionAccount => 'Hesap';

  @override
  String get settingsSignInGoogle => 'Google ile giriş yap';

  @override
  String get settingsSignInApple => 'Apple ile giriş yap';

  @override
  String get settingsSignInWhy =>
      'Namaz geçmişini yedekler ve cihazların arasında eşitler';

  @override
  String get settingsSignOut => 'Çıkış yap';

  @override
  String get settingsDeleteAccount => 'Hesabı sil';

  @override
  String get settingsDeleteAccountHint =>
      'Hesabını ve kayıtlı tüm verileri kalıcı olarak siler';

  @override
  String get settingsDeleteAccountConfirm =>
      'Hesabın gerçekten silinsin mi? Geçmişin hem hesabından hem de bu cihazdan kalıcı olarak silinir. Bu geri alınamaz.';

  @override
  String get onboardingPrivacyLink => 'Gizlilik politikasını oku';

  @override
  String get adoptLocalDataTitle => 'Mevcut kayıtlar eklensin mi?';

  @override
  String get adoptLocalDataBody =>
      'Bu cihazda henüz hiçbir hesaba ait olmayan kayıtlar var. Hesabına eklensin mi? Bu cihazı başkasından aldıysan onları sil.';

  @override
  String adoptLocalDataBodyCounted(int count) {
    return 'Bu cihazda henüz hiçbir hesaba ait olmayan $count namaz kaydı var. Hesabına eklensin mi? Bu cihazı başkasından aldıysan onları sil.';
  }

  @override
  String get adoptLocalDataKeep => 'Ekle';

  @override
  String get adoptLocalDataDiscard => 'Sil';

  @override
  String get settingsSignOutConfirm =>
      'Çıkış yapılsın mı? Kayıtların önce hesabına yedeklenir, sonra bu cihazdan kaldırılır. Tekrar giriş yaptığında geri gelirler. Bunun için internet bağlantısı gerekir.';

  @override
  String get settingsSignOutNeedsConnection =>
      'Çıkış yapmak için bağlantı gerekir – kayıtların önce hesabına yedeklenir. Lütfen daha sonra tekrar dene.';

  @override
  String settingsSignedInAs(String email) {
    return '$email olarak giriş yapıldı';
  }

  @override
  String get settingsSignInFailed => 'Giriş başarısız.';

  @override
  String get settingsSyncNow => 'Şimdi eşitle';

  @override
  String get settingsSyncDone => 'Eşitlendi.';

  @override
  String get settingsAccountDeleted => 'Hesap silindi.';

  @override
  String get onboardingAccountTitle => 'İlerlemeni koru';

  @override
  String get onboardingAccountBody =>
      'Hesapla namaz geçmişin korunur — cihaz değiştirsen bile. Hesapsız her şey yalnızca bu cihazda kalır.';

  @override
  String get commonLater => 'Daha sonra';

  @override
  String quranTranslationCredit(String translator) {
    return 'Çeviri: $translator';
  }

  @override
  String get quranSourceCredit =>
      'Arapça metin, transkripsiyon ve tilavet alquran.cloud üzerinden';

  @override
  String get settingsLicenses => 'Açık kaynak lisansları';

  @override
  String get settingsLicensesHint =>
      'Kullanılan kütüphanelerin lisans metinleri';

  @override
  String get mosqueConsentHeading => 'Yakındaki camileri bul';

  @override
  String get mosqueConsentBody =>
      'Bunun için geçerli konumunuz, OpenStreetMap verilerinde çevre aramasını yapmak üzere Overpass API\'ye (FOSSGIS e.V. tarafından işletilir) gönderilir.\n\nKonumunuzun cihazdan ayrıldığı tek işlev budur. Başka hiçbir veri ve hiçbir tanımlayıcı iletilmez.';

  @override
  String get mosqueConsentAccept => 'Kabul et ve camileri ara';

  @override
  String get mosqueConsentRevocable =>
      'Bunu istediğiniz zaman geri alabilirsiniz.';

  @override
  String get mosqueSearching => 'Camiler aranıyor …';

  @override
  String get mosqueUnnamed => 'Cami (adsız)';

  @override
  String get qiblaCalibrateAction => 'Pusulayı kalibre et';

  @override
  String get qiblaCalibrateHint =>
      'Pusulayı kalibre etmek için cihazınızı sekiz (∞) çizerek hareket ettirin.';

  @override
  String get qiblaNeedsLocation =>
      'Doğru bir kıble için geçerli konumunuz gerekir.';

  @override
  String get qiblaLocationUnavailable =>
      'Konum kullanılamıyor. Lütfen ayarlardan etkinleştirin.';

  @override
  String get qiblaCompassUnsupported => 'Bu cihazda pusula yok.';

  @override
  String get qiblaInaccurate =>
      'Yön hassas değil. Cihazınızı sekiz (∞) çizerek hareket ettirin.';

  @override
  String get locationServicesDisabled => 'Konum servisleri kapalı.';

  @override
  String get locationPermissionDenied => 'Konum erişimi reddedildi.';

  @override
  String get locationNoFix =>
      'Geçerli konum alınamadı. Lütfen şehri elle arayın.';

  @override
  String get locationDetecting => 'Konum belirleniyor …';

  @override
  String get locationUnavailableShort => 'kullanılamıyor';

  @override
  String get settingsNamePlaceholder => 'Adınız';

  @override
  String get commonLoadFailed => 'Yüklenemedi.';

  @override
  String get commonRetry => 'Yeniden dene';

  @override
  String get surahSearchOpen => 'Sure ara';

  @override
  String get surahSearchClose => 'Aramayı kapat';

  @override
  String get surahSearchClear => 'Aramayı temizle';

  @override
  String get quranProgressHeading => 'İlerlemeniz';

  @override
  String get quranProgressEmpty =>
      'Bir ayet okuduğunuzda ilerlemeniz burada görünür.';

  @override
  String get quranArabicTextSize => 'Yazı boyutu (Arapça)';

  @override
  String get namesNoMatch => 'Ad bulunamadı.';

  @override
  String get adviceTomorrow => 'Yarın burada bir sonraki öneri olacak.';

  @override
  String get locationLabelFallback => 'Konum';

  @override
  String get mosqueSearchBusy =>
      'Cami servisi şu anda yoğun. Lütfen birkaç dakika sonra tekrar deneyin.';

  @override
  String get mosqueSearchFailed => 'Cami araması başarısız oldu.';

  @override
  String get quranShowTranslation => 'Çeviriyi göster';

  @override
  String get adviceSectionLabel => 'GÜNÜN ÖNERİSİ';

  @override
  String get adviceReadMore => 'Devamını oku';

  @override
  String get adviceActionLabel => 'BUGÜN UYGULA';

  @override
  String get surahSearchHint => 'Sure ara';

  @override
  String dateToday(String date) {
    return 'Bugün, $date';
  }
}
