// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Munir';

  @override
  String get navHome => 'Home';

  @override
  String get navPrayers => 'Prayer';

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
  String get nextPrayer => 'Next prayer';

  @override
  String inHoursMinutes(int hours, int minutes) {
    return 'in $hours hr $minutes min';
  }

  @override
  String inMinutesSeconds(int minutes, int seconds) {
    return 'in $minutes min $seconds sec';
  }

  @override
  String get todaysProgress => 'Today\'s Progress';

  @override
  String get overallProgress => 'Overall Progress';

  @override
  String percentComplete(int percent) {
    return '$percent % Complete';
  }

  @override
  String get prayerNotYetDue => 'This prayer is still ahead.';

  @override
  String get prayerFajr => 'Fajr';

  @override
  String get prayerSunrise => 'Sunrise';

  @override
  String get prayerDhuhr => 'Dhuhr';

  @override
  String get prayerAsr => 'Asr';

  @override
  String get prayerMaghrib => 'Maghrib';

  @override
  String get prayerIsha => 'Isha';

  @override
  String get quickMosques => 'Mosques';

  @override
  String get quickQibla => 'Qibla';

  @override
  String get quickDuas => 'Duas';

  @override
  String get quickNames => '99 Names';

  @override
  String get locationWarning =>
      'No location access. Prayer times use defaults (Berlin).';

  @override
  String get activate => 'Enable';

  @override
  String get today => 'Today';

  @override
  String todayShort(String date) {
    return 'Today, $date';
  }

  @override
  String get mosquesTitle => 'Mosques';

  @override
  String get mosquesRadius => 'Radius';

  @override
  String mosquesKm(int km) {
    return '$km km';
  }

  @override
  String get mosquesRefresh => 'Refresh';

  @override
  String get mosquesShowList => 'List';

  @override
  String get mosquesShowMap => 'Map';

  @override
  String get mosquesRoute => 'Directions';

  @override
  String get mosquesWebsite => 'Website';

  @override
  String get mosquesCall => 'Call';

  @override
  String mosquesEmpty(int km) {
    return 'No mosques found within $km km.';
  }

  @override
  String get mosquesRetry => 'Try again';

  @override
  String get mosquesCouldNotOpen => 'Could not be opened.';

  @override
  String mosquesDistanceKm(String km) {
    return '$km km';
  }

  @override
  String get mosquesConsentTitle => 'Find mosques near you';

  @override
  String get mosquesConsentBody =>
      'This sends your coordinates to OpenStreetMap. No other data is transmitted.';

  @override
  String get mosquesConsentAccept => 'Agree and search';

  @override
  String get qiblaTitle => 'Qibla';

  @override
  String get qiblaTurnToKaaba => 'Turn towards the Kaaba';

  @override
  String qiblaDistanceToMecca(String km) {
    return 'Distance to Mecca: $km km';
  }

  @override
  String get qiblaNoCompass => 'Your device has no compass.';

  @override
  String get tasbihTitle => 'Tasbih';

  @override
  String get tasbihTapToCount => 'Tap to count';

  @override
  String tasbihRound(int round) {
    return 'Round $round';
  }

  @override
  String get tasbihReset => 'Reset';

  @override
  String get quranTitle => 'Qur\'an';

  @override
  String quranVerses(int count) {
    return '$count verses';
  }

  @override
  String get quranSearchHint => 'Search surah…';

  @override
  String get duasTitle => 'Duas';

  @override
  String get duasSearchHint => 'Search dua…';

  @override
  String duasCount(int count) {
    return '$count duas';
  }

  @override
  String get namesTitle => 'The 99 Names';

  @override
  String get namesSearchHint => 'Search name or meaning…';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSectionPrayer => 'Prayer';

  @override
  String get settingsSectionNotifications => 'Notifications';

  @override
  String get settingsSectionDisplay => 'Display';

  @override
  String get settingsSectionData => 'Data';

  @override
  String get settingsSectionLegal => 'Legal';

  @override
  String get settingsLocation => 'Location';

  @override
  String get settingsLocationHint => 'Tap to detect again';

  @override
  String get settingsCalculationMethod => 'Calculation method';

  @override
  String get settingsMadhab => 'School of thought';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsAdhanVoice => 'Adhan voice';

  @override
  String get settingsName => 'Name';

  @override
  String get settingsNameHint => 'What should we call you?';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsMosqueConsent => 'Allow mosque search';

  @override
  String get settingsMosqueConsentHint =>
      'Sends your coordinates to OpenStreetMap';

  @override
  String get settingsClearMapCache => 'Clear map cache';

  @override
  String get settingsClearMapCacheHint => 'Remove stored map tiles';

  @override
  String get settingsClearMapCacheDone => 'Map cache cleared.';

  @override
  String get settingsResetTracker => 'Reset prayer history';

  @override
  String get settingsResetTrackerHint =>
      'Deletes all ticked prayers and your streak';

  @override
  String get settingsResetTrackerConfirm =>
      'Really reset? All ticked prayers and your streak will be lost.';

  @override
  String get settingsResetTrackerDone => 'Prayer history reset.';

  @override
  String get settingsPrivacy => 'Privacy policy';

  @override
  String get settingsImprint => 'Legal notice';

  @override
  String get settingsNotConfigured => 'Not set up yet';

  @override
  String settingsVersion(String version) {
    return 'Version $version';
  }

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonSave => 'Save';

  @override
  String get commonReset => 'Reset';

  @override
  String get commonClose => 'Close';

  @override
  String get commonContinue => 'Continue';

  @override
  String get commonBack => 'Back';

  @override
  String get commonDone => 'Done';

  @override
  String commonComingSoon(String feature) {
    return '$feature coming soon!';
  }

  @override
  String get onboardingLanguageTitle => 'Choose language';

  @override
  String get onboardingNameTitle => 'What\'s your name?';

  @override
  String get onboardingNameHint => 'Your name';

  @override
  String get onboardingLocationTitle => 'Location';

  @override
  String get onboardingLocationBody =>
      'We need your location for accurate prayer times.';

  @override
  String get onboardingLocationAllow => 'Allow location';

  @override
  String get onboardingLocationManual => 'Pick a city manually';

  @override
  String get onboardingMethodTitle => 'Calculation method';

  @override
  String get onboardingAdhanTitle => 'Adhan voice';

  @override
  String get onboardingDoneTitle => 'All set';

  @override
  String get onboardingDoneBody => 'May this app support you in your prayers.';

  @override
  String get onboardingStart => 'Get started';

  @override
  String notificationPrayerTimeTitle(String prayer) {
    return '$prayer is now';
  }

  @override
  String get notificationPrayerTimeBody => 'Time for prayer.';

  @override
  String get settingsMadhabShafiHint => 'Also Maliki and Hanbali — earlier Asr';

  @override
  String get settingsMadhabHanafiHint => 'Later Asr';

  @override
  String get muezzinSilent => 'Vibration only / silent';

  @override
  String get settingsNotSet => 'not set';

  @override
  String get qiblaAligned => 'Aligned — facing Mecca';

  @override
  String get settingsDataSources => 'Data sources';

  @override
  String get nowLabel => 'now';
}
