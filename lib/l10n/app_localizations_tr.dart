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
  String get settingsAdhanVoice => 'Ezan sesi';

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
  String notificationPrayerTimeTitle(String prayer) {
    return '$prayer vakti girdi';
  }

  @override
  String get notificationPrayerTimeBody => 'Namaz vakti.';

  @override
  String get settingsMadhabShafiHint =>
      'Maliki ve Hanbeli de — daha erken ikindi';

  @override
  String get settingsMadhabHanafiHint => 'Daha geç ikindi';

  @override
  String get muezzinSilent => 'Sadece titreşim / sessiz';

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
  String get onboardingMuezzinSection => 'MÜEZZİN SESİ';

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
}
