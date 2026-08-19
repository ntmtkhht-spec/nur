// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appName => 'Nur';

  @override
  String get navHome => 'Start';

  @override
  String get navPrayers => 'Gebet';

  @override
  String get navQuran => 'Qur\'an';

  @override
  String get navTasbih => 'Tasbih';

  @override
  String get navQibla => 'Qibla';

  @override
  String greeting(String name) {
    return 'Assalamu alaikum, $name';
  }

  @override
  String get greetingNoName => 'Assalamu alaikum';

  @override
  String get nextPrayer => 'Nächstes Gebet';

  @override
  String inHoursMinutes(int hours, int minutes) {
    return 'in $hours Std $minutes Min';
  }

  @override
  String inMinutesSeconds(int minutes, int seconds) {
    return 'in $minutes Min $seconds Sek';
  }

  @override
  String get todaysProgress => 'Heutiger Fortschritt';

  @override
  String get overallProgress => 'Gesamtfortschritt';

  @override
  String percentComplete(int percent) {
    return '$percent % erledigt';
  }

  @override
  String get prayerNotYetDue => 'Dieses Gebet liegt noch vor dir.';

  @override
  String get prayerFajr => 'Fajr';

  @override
  String get prayerSunrise => 'Sonnenaufgang';

  @override
  String get prayerDhuhr => 'Dhuhr';

  @override
  String get prayerAsr => 'Asr';

  @override
  String get prayerMaghrib => 'Maghrib';

  @override
  String get prayerIsha => 'Isha';

  @override
  String get quickMosques => 'Moscheen';

  @override
  String get quickQibla => 'Qibla';

  @override
  String get quickDuas => 'Duas';

  @override
  String get quickNames => '99 Namen';

  @override
  String get locationWarning =>
      'Standortzugriff fehlt. Gebetszeiten nutzen Standardwerte (Berlin).';

  @override
  String get activate => 'Aktivieren';

  @override
  String get today => 'Heute';

  @override
  String todayShort(String date) {
    return 'Heute, $date';
  }

  @override
  String get mosquesTitle => 'Moscheen';

  @override
  String get mosquesRadius => 'Umkreis';

  @override
  String mosquesKm(int km) {
    return '$km km';
  }

  @override
  String get mosquesRefresh => 'Aktualisieren';

  @override
  String get mosquesShowList => 'Liste';

  @override
  String get mosquesShowMap => 'Karte';

  @override
  String get mosquesRoute => 'Route';

  @override
  String get mosquesWebsite => 'Website';

  @override
  String get mosquesCall => 'Anrufen';

  @override
  String mosquesEmpty(int km) {
    return 'Keine Moscheen im Umkreis von $km km gefunden.';
  }

  @override
  String get mosquesRetry => 'Erneut versuchen';

  @override
  String get mosquesCouldNotOpen => 'Konnte nicht geöffnet werden.';

  @override
  String mosquesDistanceKm(String km) {
    return '$km km';
  }

  @override
  String get mosquesConsentTitle => 'Moscheen in deiner Nähe finden';

  @override
  String get mosquesConsentBody =>
      'Dafür werden deine Koordinaten an OpenStreetMap gesendet. Es werden keine weiteren Daten übertragen.';

  @override
  String get mosquesConsentAccept => 'Einverstanden, suchen';

  @override
  String get qiblaTitle => 'Qibla';

  @override
  String get qiblaTurnToKaaba => 'Drehe dich zur Kaaba';

  @override
  String qiblaDistanceToMecca(String km) {
    return 'Entfernung nach Mekka: $km km';
  }

  @override
  String get qiblaNoCompass => 'Dein Gerät hat keinen Kompass.';

  @override
  String get tasbihTitle => 'Tasbih';

  @override
  String get tasbihTapToCount => 'Tippe zum Zählen';

  @override
  String tasbihRound(int round) {
    return '$round. Runde';
  }

  @override
  String get tasbihReset => 'Zurücksetzen';

  @override
  String get quranTitle => 'Qur\'an';

  @override
  String quranVerses(int count) {
    return '$count Verse';
  }

  @override
  String get quranSearchHint => 'Sure suchen…';

  @override
  String get duasTitle => 'Duas';

  @override
  String get duasSearchHint => 'Dua suchen…';

  @override
  String duasCount(int count) {
    return '$count Duas';
  }

  @override
  String get namesTitle => 'Die 99 Namen';

  @override
  String get namesSearchHint => 'Name oder Bedeutung suchen…';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get settingsSectionPrayer => 'Gebet';

  @override
  String get settingsSectionNotifications => 'Benachrichtigungen';

  @override
  String get settingsSectionDisplay => 'Darstellung';

  @override
  String get settingsSectionData => 'Daten';

  @override
  String get settingsSectionLegal => 'Rechtliches';

  @override
  String get settingsLocation => 'Standort';

  @override
  String get settingsLocationHint => 'Tippen, um neu zu bestimmen';

  @override
  String get settingsCalculationMethod => 'Berechnungsmethode';

  @override
  String get settingsMadhab => 'Rechtsschule';

  @override
  String get settingsNotifications => 'Benachrichtigungen';

  @override
  String get settingsAdhanVoice => 'Adhan-Stimme';

  @override
  String get settingsName => 'Name';

  @override
  String get settingsNameHint => 'Wie sollen wir dich ansprechen?';

  @override
  String get settingsLanguage => 'Sprache';

  @override
  String get settingsMosqueConsent => 'Moscheesuche erlauben';

  @override
  String get settingsMosqueConsentHint =>
      'Sendet deine Koordinaten an OpenStreetMap';

  @override
  String get settingsClearMapCache => 'Kartenspeicher leeren';

  @override
  String get settingsClearMapCacheHint =>
      'Gespeicherte Kartenkacheln entfernen';

  @override
  String get settingsClearMapCacheDone => 'Kartenspeicher geleert.';

  @override
  String get settingsResetTracker => 'Gebets-Verlauf zurücksetzen';

  @override
  String get settingsResetTrackerHint =>
      'Löscht alle abgehakten Gebete und die Serie';

  @override
  String get settingsResetTrackerConfirm =>
      'Wirklich zurücksetzen? Alle abgehakten Gebete und deine Serie gehen verloren.';

  @override
  String get settingsResetTrackerDone => 'Gebets-Verlauf zurückgesetzt.';

  @override
  String get settingsPrivacy => 'Datenschutz';

  @override
  String get settingsImprint => 'Impressum';

  @override
  String get settingsNotConfigured => 'Noch nicht hinterlegt';

  @override
  String settingsVersion(String version) {
    return 'Version $version';
  }

  @override
  String get commonCancel => 'Abbrechen';

  @override
  String get commonDelete => 'Löschen';

  @override
  String get commonSave => 'Speichern';

  @override
  String get commonReset => 'Zurücksetzen';

  @override
  String get commonClose => 'Schließen';

  @override
  String get commonContinue => 'Weiter';

  @override
  String get commonBack => 'Zurück';

  @override
  String get commonDone => 'Fertig';

  @override
  String commonComingSoon(String feature) {
    return '$feature kommt bald!';
  }

  @override
  String get onboardingLanguageTitle => 'Sprache wählen';

  @override
  String get onboardingNameTitle => 'Wie heißt du?';

  @override
  String get onboardingNameHint => 'Dein Name';

  @override
  String get onboardingLocationTitle => 'Standort';

  @override
  String get onboardingLocationBody =>
      'Für genaue Gebetszeiten brauchen wir deinen Standort.';

  @override
  String get onboardingLocationAllow => 'Standort erlauben';

  @override
  String get onboardingLocationManual => 'Stadt manuell wählen';

  @override
  String get onboardingMethodTitle => 'Berechnungsmethode';

  @override
  String get onboardingAdhanTitle => 'Adhan-Stimme';

  @override
  String get onboardingDoneTitle => 'Alles bereit';

  @override
  String get onboardingDoneBody =>
      'Möge dir die App bei deinen Gebeten helfen.';

  @override
  String get onboardingStart => 'Los geht\'s';

  @override
  String notificationPrayerTimeTitle(String prayer) {
    return '$prayer ist jetzt';
  }

  @override
  String get notificationPrayerTimeBody => 'Zeit für das Gebet.';

  @override
  String get settingsMadhabShafiHint =>
      'Auch Maliki und Hanbali — früheres Asr';

  @override
  String get settingsMadhabHanafiHint => 'Späteres Asr';

  @override
  String get muezzinSilent => 'Nur Vibration / stumm';

  @override
  String get settingsNotSet => 'nicht gesetzt';

  @override
  String get qiblaAligned => 'Ausgerichtet — Richtung Mekka';

  @override
  String get settingsDataSources => 'Datenquellen';

  @override
  String get nowLabel => 'jetzt';
}
