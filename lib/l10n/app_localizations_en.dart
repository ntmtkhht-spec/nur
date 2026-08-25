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
  String get statsTitle => 'Statistics';

  @override
  String get statsStreakLabel => 'Days in a row';

  @override
  String get statsBestLabel => 'Best ever';

  @override
  String get statsWeekLabel => 'Last 7 days';

  @override
  String get statsTotalLabel => 'Prayers logged';

  @override
  String statsWeekValue(int done) {
    return '$done/7';
  }

  @override
  String statsWeakest(String prayer) {
    return 'Missed most lately: $prayer';
  }

  @override
  String get statsEmpty =>
      'Tick off your first prayer — your numbers appear here.';

  @override
  String get streakTitle => 'Your prayer streak';

  @override
  String streakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days in a row',
      one: '1 day in a row',
    );
    return '$_temp0';
  }

  @override
  String streakBest(int count) {
    return 'Best: $count';
  }

  @override
  String get streakMilestoneTitle => 'Milestone reached!';

  @override
  String streakMilestoneBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days in a row',
    );
    return '$_temp0';
  }

  @override
  String get praiseTitle => 'MashaAllah!';

  @override
  String praiseAllPrayers(int completed, int total) {
    return '$completed/$total done';
  }

  @override
  String tasbihTotal(int count) {
    return '$count total';
  }

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
  String notificationPrayerTimeTitle(String prayer, String time) {
    return 'Time for $prayer · $time';
  }

  @override
  String get notificationBodyFajr =>
      'الصلاة خير من النوم\nPrayer is better than sleep.';

  @override
  String get notificationBodyDhuhr =>
      'The day has grown loud. Dhuhr is the moment it goes quiet — take it before it passes.';

  @override
  String get notificationBodyAsr =>
      'The light turns golden. Take this moment and pray your Asr.';

  @override
  String get notificationBodyMaghrib =>
      'The sun has set. A moment of gratitude.';

  @override
  String get notificationBodyIsha =>
      'The day is over, the last prayer is not. Pray Isha before you sleep.';

  @override
  String notificationLocationLine(String city) {
    return 'Calculated for $city';
  }

  @override
  String notificationCatchUpTitle(String prayer) {
    return '$prayer is ending soon';
  }

  @override
  String notificationCatchUpBody(String next, String time) {
    return 'Use the time you have left before $next begins at $time.';
  }

  @override
  String get notificationCatchUpChannelName => 'Open prayers';

  @override
  String get notificationCatchUpChannelDescription =>
      'Reminder when a prayer has not been logged yet';

  @override
  String get settingsCatchUpReminders => 'Remind me about open prayers';

  @override
  String get settingsCatchUpRemindersHint =>
      '30 minutes before the next prayer, if nothing is logged yet';

  @override
  String get settingsMadhabShafiHint => 'Also Maliki and Hanbali — earlier Asr';

  @override
  String get settingsMadhabHanafiHint => 'Later Asr';

  @override
  String get settingsNotSet => 'not set';

  @override
  String get qiblaAligned => 'Aligned — facing Mecca';

  @override
  String get settingsDataSources => 'Data sources';

  @override
  String get nowLabel => 'now';

  @override
  String get onboardingLanguageSubtitle => 'You can change this at any time';

  @override
  String get onboardingNameQuestion => 'What should we call you?';

  @override
  String get onboardingNameSubtitle => 'For your personal greeting.';

  @override
  String onboardingNamePreview(String name) {
    return 'e.g. for “Assalamu alaikum, $name”';
  }

  @override
  String get onboardingLocationDetect => 'Detect location automatically';

  @override
  String get onboardingLocationSearch => 'Search for a city…';

  @override
  String get onboardingLocationSkip => 'Continue without location';

  @override
  String get onboardingLocationPrivacy =>
      'Prayer times and qibla are calculated on your device. Only the mosque search sends your location — and it asks first.';

  @override
  String onboardingLocationDetected(String city) {
    return 'Location detected: $city';
  }

  @override
  String get onboardingLocationNotFound => 'Place not found.';

  @override
  String get onboardingLocationSearchFailed =>
      'Search failed. Check your connection.';

  @override
  String get onboardingMethodHeading => 'Adjust prayer times';

  @override
  String get onboardingMethodSection => 'CALCULATION METHOD';

  @override
  String get onboardingMadhabSection => 'ASR CALCULATION (MADHAB)';

  @override
  String get onboardingAdhanHeading => 'Adhan reminders';

  @override
  String get onboardingAdhanBody =>
      'Get a gentle reminder at every prayer time.';

  @override
  String get onboardingAdhanEnable => 'Enable notifications';

  @override
  String get onboardingAdhanEnabled => 'Notifications enabled.';

  @override
  String get onboardingAdhanDenied => 'Permission was not granted.';

  @override
  String get onboardingDoneHeading => 'All set';

  @override
  String onboardingDoneHeadingNamed(String name) {
    return 'All set, $name';
  }

  @override
  String get onboardingDoneCompanion =>
      'May Munir accompany you through your day.';

  @override
  String get onboardingOpenApp => 'Open app';

  @override
  String get onboardingAdhanOn => 'Adhan on';

  @override
  String get onboardingAdhanOff => 'Adhan off';

  @override
  String get featurePrayerTitle => 'Never miss a prayer again';

  @override
  String get featurePrayerBody =>
      'Accurate prayer times for your location, with adhan reminders.';

  @override
  String get featureQiblaTitle => 'Find the qibla direction';

  @override
  String get featureQiblaBody =>
      'A precise compass points you towards Makkah anywhere.';

  @override
  String get featureQuranTitle => 'The Qur\'an, always with you';

  @override
  String get featureQuranBody =>
      'Read, listen and mark your progress — available offline.';

  @override
  String get commonSkip => 'Skip';

  @override
  String get commonNext => 'Next';

  @override
  String get onboardingLocationQuestion => 'Where are you?';

  @override
  String get notificationChannelName => 'Prayer times';

  @override
  String get notificationChannelDescription =>
      'Reminders for the daily prayer times';

  @override
  String get onboardingLocationWhy =>
      'We need your location for accurate prayer times and the qibla direction.';

  @override
  String get commonOr => 'or';

  @override
  String get settingsSectionAccount => 'Account';

  @override
  String get settingsSignInGoogle => 'Sign in with Google';

  @override
  String get settingsSignInApple => 'Sign in with Apple';

  @override
  String get settingsSignInWhy =>
      'Backs up your prayer history and syncs it across your devices';

  @override
  String get settingsSignOut => 'Sign out';

  @override
  String get settingsDeleteAccount => 'Delete account';

  @override
  String get settingsDeleteAccountHint =>
      'Permanently deletes your account and all stored data';

  @override
  String get settingsDeleteAccountConfirm =>
      'Really delete your account? Your history will be permanently deleted — from the account and from this device. This cannot be undone.';

  @override
  String get onboardingPrivacyLink => 'Read the privacy policy';

  @override
  String get adoptLocalDataTitle => 'Add existing entries?';

  @override
  String get adoptLocalDataBody =>
      'This device holds entries that do not belong to any account yet. Add them to your account? If you got this device from someone else, discard them.';

  @override
  String adoptLocalDataBodyCounted(int count) {
    return 'This device holds $count recorded prayers that do not belong to any account yet. Add them to your account? If you got this device from someone else, discard them.';
  }

  @override
  String get adoptLocalDataKeep => 'Add';

  @override
  String get adoptLocalDataDiscard => 'Discard';

  @override
  String get settingsSignOutConfirm =>
      'Sign out? Your entries are saved to your account first, then removed from this device. They come back next time you sign in. This needs an internet connection.';

  @override
  String get settingsSignOutNeedsConnection =>
      'Signing out needs a connection — your entries are saved to your account first. Please try again later.';

  @override
  String settingsSignedInAs(String email) {
    return 'Signed in as $email';
  }

  @override
  String get settingsSignInFailed => 'Sign-in failed.';

  @override
  String get settingsSyncNow => 'Sync now';

  @override
  String get settingsSyncDone => 'Synced.';

  @override
  String get settingsAccountDeleted => 'Account deleted.';

  @override
  String get onboardingAccountTitle => 'Keep your progress';

  @override
  String get onboardingAccountBody =>
      'With an account your prayer history is kept — even when you change devices. Without one, everything stays on this device only.';

  @override
  String get commonLater => 'Later';

  @override
  String quranTranslationCredit(String translator) {
    return 'Translation: $translator';
  }

  @override
  String get quranSourceCredit =>
      'Arabic text, transliteration and recitation via alquran.cloud';

  @override
  String get settingsLicenses => 'Open source licences';

  @override
  String get settingsLicensesHint => 'Licence texts of the bundled libraries';

  @override
  String get mosqueConsentHeading => 'Find mosques nearby';

  @override
  String get mosqueConsentBody =>
      'Your current location is sent to the Overpass API (operated by FOSSGIS e.V.) to run the area search against OpenStreetMap data.\n\nThis is the only feature where your location leaves the device. Nothing else about you and no identifier is sent with it.';

  @override
  String get mosqueConsentAccept => 'Agree and search for mosques';

  @override
  String get mosqueConsentRevocable => 'You can withdraw this at any time.';

  @override
  String get mosqueSearching => 'Searching for mosques …';

  @override
  String get mosqueUnnamed => 'Mosque (unnamed)';

  @override
  String get qiblaCalibrateAction => 'Calibrate compass';

  @override
  String get qiblaCalibrateHint =>
      'Move your device in a figure of eight (∞) to calibrate the compass.';

  @override
  String get qiblaNeedsLocation =>
      'An accurate Qibla needs your current location.';

  @override
  String get qiblaLocationUnavailable =>
      'Location is unavailable. Please enable it in Settings.';

  @override
  String get qiblaCompassUnsupported => 'No compass available on this device.';

  @override
  String get qiblaInaccurate =>
      'The direction is imprecise. Move your device in a figure of eight (∞).';

  @override
  String get locationServicesDisabled => 'Location services are turned off.';

  @override
  String get locationPermissionDenied => 'Location access was denied.';

  @override
  String get locationNoFix =>
      'No current location available. Please search for a city manually.';

  @override
  String get locationDetecting => 'Detecting location …';

  @override
  String get locationUnavailableShort => 'unavailable';

  @override
  String get settingsNamePlaceholder => 'Your name';

  @override
  String get commonLoadFailed => 'Could not load.';

  @override
  String get commonRetry => 'Try again';

  @override
  String get surahSearchOpen => 'Search surahs';

  @override
  String get surahSearchClose => 'Close search';

  @override
  String get surahSearchClear => 'Clear search';

  @override
  String get quranProgressHeading => 'Your progress';

  @override
  String get quranProgressEmpty =>
      'Your progress appears here once you have read a verse.';

  @override
  String get quranArabicTextSize => 'Text size (Arabic)';

  @override
  String get namesNoMatch => 'No name found.';

  @override
  String get adviceTomorrow =>
      'Tomorrow the next piece of guidance appears here.';

  @override
  String get locationLabelFallback => 'Location';

  @override
  String get mosqueSearchBusy =>
      'The mosque service is busy right now. Please try again in a few minutes.';

  @override
  String get mosqueSearchFailed => 'The mosque search failed.';

  @override
  String get quranShowTranslation => 'Show translation';

  @override
  String get adviceSectionLabel => 'GUIDANCE OF THE DAY';

  @override
  String get adviceReadMore => 'Read more';

  @override
  String get adviceActionLabel => 'DO THIS TODAY';

  @override
  String get surahSearchHint => 'Search surah';

  @override
  String dateToday(String date) {
    return 'Today, $date';
  }
}
