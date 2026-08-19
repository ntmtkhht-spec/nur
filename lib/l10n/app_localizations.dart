import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('fr'),
    Locale('tr'),
  ];

  /// No description provided for @appName.
  ///
  /// In de, this message translates to:
  /// **'Munir'**
  String get appName;

  /// No description provided for @navHome.
  ///
  /// In de, this message translates to:
  /// **'Start'**
  String get navHome;

  /// No description provided for @navPrayers.
  ///
  /// In de, this message translates to:
  /// **'Gebet'**
  String get navPrayers;

  /// No description provided for @navQuran.
  ///
  /// In de, this message translates to:
  /// **'Qur\'an'**
  String get navQuran;

  /// No description provided for @navTasbih.
  ///
  /// In de, this message translates to:
  /// **'Tasbih'**
  String get navTasbih;

  /// No description provided for @navQibla.
  ///
  /// In de, this message translates to:
  /// **'Qibla'**
  String get navQibla;

  /// No description provided for @greeting.
  ///
  /// In de, this message translates to:
  /// **'Assalamu alaikum, {name}'**
  String greeting(String name);

  /// No description provided for @greetingNoName.
  ///
  /// In de, this message translates to:
  /// **'Assalamu alaikum'**
  String get greetingNoName;

  /// No description provided for @nextPrayer.
  ///
  /// In de, this message translates to:
  /// **'Nächstes Gebet'**
  String get nextPrayer;

  /// No description provided for @inHoursMinutes.
  ///
  /// In de, this message translates to:
  /// **'in {hours} Std {minutes} Min'**
  String inHoursMinutes(int hours, int minutes);

  /// No description provided for @inMinutesSeconds.
  ///
  /// In de, this message translates to:
  /// **'in {minutes} Min {seconds} Sek'**
  String inMinutesSeconds(int minutes, int seconds);

  /// No description provided for @todaysProgress.
  ///
  /// In de, this message translates to:
  /// **'Heutiger Fortschritt'**
  String get todaysProgress;

  /// No description provided for @overallProgress.
  ///
  /// In de, this message translates to:
  /// **'Gesamtfortschritt'**
  String get overallProgress;

  /// No description provided for @percentComplete.
  ///
  /// In de, this message translates to:
  /// **'{percent} % erledigt'**
  String percentComplete(int percent);

  /// No description provided for @prayerNotYetDue.
  ///
  /// In de, this message translates to:
  /// **'Dieses Gebet liegt noch vor dir.'**
  String get prayerNotYetDue;

  /// No description provided for @prayerFajr.
  ///
  /// In de, this message translates to:
  /// **'Fajr'**
  String get prayerFajr;

  /// No description provided for @prayerSunrise.
  ///
  /// In de, this message translates to:
  /// **'Sonnenaufgang'**
  String get prayerSunrise;

  /// No description provided for @prayerDhuhr.
  ///
  /// In de, this message translates to:
  /// **'Dhuhr'**
  String get prayerDhuhr;

  /// No description provided for @prayerAsr.
  ///
  /// In de, this message translates to:
  /// **'Asr'**
  String get prayerAsr;

  /// No description provided for @prayerMaghrib.
  ///
  /// In de, this message translates to:
  /// **'Maghrib'**
  String get prayerMaghrib;

  /// No description provided for @prayerIsha.
  ///
  /// In de, this message translates to:
  /// **'Isha'**
  String get prayerIsha;

  /// No description provided for @quickMosques.
  ///
  /// In de, this message translates to:
  /// **'Moscheen'**
  String get quickMosques;

  /// No description provided for @quickQibla.
  ///
  /// In de, this message translates to:
  /// **'Qibla'**
  String get quickQibla;

  /// No description provided for @quickDuas.
  ///
  /// In de, this message translates to:
  /// **'Duas'**
  String get quickDuas;

  /// No description provided for @quickNames.
  ///
  /// In de, this message translates to:
  /// **'99 Namen'**
  String get quickNames;

  /// No description provided for @locationWarning.
  ///
  /// In de, this message translates to:
  /// **'Standortzugriff fehlt. Gebetszeiten nutzen Standardwerte (Berlin).'**
  String get locationWarning;

  /// No description provided for @activate.
  ///
  /// In de, this message translates to:
  /// **'Aktivieren'**
  String get activate;

  /// No description provided for @today.
  ///
  /// In de, this message translates to:
  /// **'Heute'**
  String get today;

  /// No description provided for @todayShort.
  ///
  /// In de, this message translates to:
  /// **'Heute, {date}'**
  String todayShort(String date);

  /// No description provided for @mosquesTitle.
  ///
  /// In de, this message translates to:
  /// **'Moscheen'**
  String get mosquesTitle;

  /// No description provided for @mosquesRadius.
  ///
  /// In de, this message translates to:
  /// **'Umkreis'**
  String get mosquesRadius;

  /// No description provided for @mosquesKm.
  ///
  /// In de, this message translates to:
  /// **'{km} km'**
  String mosquesKm(int km);

  /// No description provided for @mosquesRefresh.
  ///
  /// In de, this message translates to:
  /// **'Aktualisieren'**
  String get mosquesRefresh;

  /// No description provided for @mosquesShowList.
  ///
  /// In de, this message translates to:
  /// **'Liste'**
  String get mosquesShowList;

  /// No description provided for @mosquesShowMap.
  ///
  /// In de, this message translates to:
  /// **'Karte'**
  String get mosquesShowMap;

  /// No description provided for @mosquesRoute.
  ///
  /// In de, this message translates to:
  /// **'Route'**
  String get mosquesRoute;

  /// No description provided for @mosquesWebsite.
  ///
  /// In de, this message translates to:
  /// **'Website'**
  String get mosquesWebsite;

  /// No description provided for @mosquesCall.
  ///
  /// In de, this message translates to:
  /// **'Anrufen'**
  String get mosquesCall;

  /// No description provided for @mosquesEmpty.
  ///
  /// In de, this message translates to:
  /// **'Keine Moscheen im Umkreis von {km} km gefunden.'**
  String mosquesEmpty(int km);

  /// No description provided for @mosquesRetry.
  ///
  /// In de, this message translates to:
  /// **'Erneut versuchen'**
  String get mosquesRetry;

  /// No description provided for @mosquesCouldNotOpen.
  ///
  /// In de, this message translates to:
  /// **'Konnte nicht geöffnet werden.'**
  String get mosquesCouldNotOpen;

  /// No description provided for @mosquesDistanceKm.
  ///
  /// In de, this message translates to:
  /// **'{km} km'**
  String mosquesDistanceKm(String km);

  /// No description provided for @mosquesConsentTitle.
  ///
  /// In de, this message translates to:
  /// **'Moscheen in deiner Nähe finden'**
  String get mosquesConsentTitle;

  /// No description provided for @mosquesConsentBody.
  ///
  /// In de, this message translates to:
  /// **'Dafür werden deine Koordinaten an OpenStreetMap gesendet. Es werden keine weiteren Daten übertragen.'**
  String get mosquesConsentBody;

  /// No description provided for @mosquesConsentAccept.
  ///
  /// In de, this message translates to:
  /// **'Einverstanden, suchen'**
  String get mosquesConsentAccept;

  /// No description provided for @qiblaTitle.
  ///
  /// In de, this message translates to:
  /// **'Qibla'**
  String get qiblaTitle;

  /// No description provided for @qiblaTurnToKaaba.
  ///
  /// In de, this message translates to:
  /// **'Drehe dich zur Kaaba'**
  String get qiblaTurnToKaaba;

  /// No description provided for @qiblaDistanceToMecca.
  ///
  /// In de, this message translates to:
  /// **'Entfernung nach Mekka: {km} km'**
  String qiblaDistanceToMecca(String km);

  /// No description provided for @qiblaNoCompass.
  ///
  /// In de, this message translates to:
  /// **'Dein Gerät hat keinen Kompass.'**
  String get qiblaNoCompass;

  /// No description provided for @tasbihTitle.
  ///
  /// In de, this message translates to:
  /// **'Tasbih'**
  String get tasbihTitle;

  /// No description provided for @tasbihTapToCount.
  ///
  /// In de, this message translates to:
  /// **'Tippe zum Zählen'**
  String get tasbihTapToCount;

  /// No description provided for @tasbihRound.
  ///
  /// In de, this message translates to:
  /// **'{round}. Runde'**
  String tasbihRound(int round);

  /// No description provided for @tasbihReset.
  ///
  /// In de, this message translates to:
  /// **'Zurücksetzen'**
  String get tasbihReset;

  /// No description provided for @quranTitle.
  ///
  /// In de, this message translates to:
  /// **'Qur\'an'**
  String get quranTitle;

  /// No description provided for @quranVerses.
  ///
  /// In de, this message translates to:
  /// **'{count} Verse'**
  String quranVerses(int count);

  /// No description provided for @quranSearchHint.
  ///
  /// In de, this message translates to:
  /// **'Sure suchen…'**
  String get quranSearchHint;

  /// No description provided for @duasTitle.
  ///
  /// In de, this message translates to:
  /// **'Duas'**
  String get duasTitle;

  /// No description provided for @duasSearchHint.
  ///
  /// In de, this message translates to:
  /// **'Dua suchen…'**
  String get duasSearchHint;

  /// No description provided for @duasCount.
  ///
  /// In de, this message translates to:
  /// **'{count} Duas'**
  String duasCount(int count);

  /// No description provided for @namesTitle.
  ///
  /// In de, this message translates to:
  /// **'Die 99 Namen'**
  String get namesTitle;

  /// No description provided for @namesSearchHint.
  ///
  /// In de, this message translates to:
  /// **'Name oder Bedeutung suchen…'**
  String get namesSearchHint;

  /// No description provided for @settingsTitle.
  ///
  /// In de, this message translates to:
  /// **'Einstellungen'**
  String get settingsTitle;

  /// No description provided for @settingsSectionPrayer.
  ///
  /// In de, this message translates to:
  /// **'Gebet'**
  String get settingsSectionPrayer;

  /// No description provided for @settingsSectionNotifications.
  ///
  /// In de, this message translates to:
  /// **'Benachrichtigungen'**
  String get settingsSectionNotifications;

  /// No description provided for @settingsSectionDisplay.
  ///
  /// In de, this message translates to:
  /// **'Darstellung'**
  String get settingsSectionDisplay;

  /// No description provided for @settingsSectionData.
  ///
  /// In de, this message translates to:
  /// **'Daten'**
  String get settingsSectionData;

  /// No description provided for @settingsSectionLegal.
  ///
  /// In de, this message translates to:
  /// **'Rechtliches'**
  String get settingsSectionLegal;

  /// No description provided for @settingsLocation.
  ///
  /// In de, this message translates to:
  /// **'Standort'**
  String get settingsLocation;

  /// No description provided for @settingsLocationHint.
  ///
  /// In de, this message translates to:
  /// **'Tippen, um neu zu bestimmen'**
  String get settingsLocationHint;

  /// No description provided for @settingsCalculationMethod.
  ///
  /// In de, this message translates to:
  /// **'Berechnungsmethode'**
  String get settingsCalculationMethod;

  /// No description provided for @settingsMadhab.
  ///
  /// In de, this message translates to:
  /// **'Rechtsschule'**
  String get settingsMadhab;

  /// No description provided for @settingsNotifications.
  ///
  /// In de, this message translates to:
  /// **'Benachrichtigungen'**
  String get settingsNotifications;

  /// No description provided for @settingsAdhanVoice.
  ///
  /// In de, this message translates to:
  /// **'Adhan-Stimme'**
  String get settingsAdhanVoice;

  /// No description provided for @settingsName.
  ///
  /// In de, this message translates to:
  /// **'Name'**
  String get settingsName;

  /// No description provided for @settingsNameHint.
  ///
  /// In de, this message translates to:
  /// **'Wie sollen wir dich ansprechen?'**
  String get settingsNameHint;

  /// No description provided for @settingsLanguage.
  ///
  /// In de, this message translates to:
  /// **'Sprache'**
  String get settingsLanguage;

  /// No description provided for @settingsMosqueConsent.
  ///
  /// In de, this message translates to:
  /// **'Moscheesuche erlauben'**
  String get settingsMosqueConsent;

  /// No description provided for @settingsMosqueConsentHint.
  ///
  /// In de, this message translates to:
  /// **'Sendet deine Koordinaten an OpenStreetMap'**
  String get settingsMosqueConsentHint;

  /// No description provided for @settingsClearMapCache.
  ///
  /// In de, this message translates to:
  /// **'Kartenspeicher leeren'**
  String get settingsClearMapCache;

  /// No description provided for @settingsClearMapCacheHint.
  ///
  /// In de, this message translates to:
  /// **'Gespeicherte Kartenkacheln entfernen'**
  String get settingsClearMapCacheHint;

  /// No description provided for @settingsClearMapCacheDone.
  ///
  /// In de, this message translates to:
  /// **'Kartenspeicher geleert.'**
  String get settingsClearMapCacheDone;

  /// No description provided for @settingsResetTracker.
  ///
  /// In de, this message translates to:
  /// **'Gebets-Verlauf zurücksetzen'**
  String get settingsResetTracker;

  /// No description provided for @settingsResetTrackerHint.
  ///
  /// In de, this message translates to:
  /// **'Löscht alle abgehakten Gebete und die Serie'**
  String get settingsResetTrackerHint;

  /// No description provided for @settingsResetTrackerConfirm.
  ///
  /// In de, this message translates to:
  /// **'Wirklich zurücksetzen? Alle abgehakten Gebete und deine Serie gehen verloren.'**
  String get settingsResetTrackerConfirm;

  /// No description provided for @settingsResetTrackerDone.
  ///
  /// In de, this message translates to:
  /// **'Gebets-Verlauf zurückgesetzt.'**
  String get settingsResetTrackerDone;

  /// No description provided for @settingsPrivacy.
  ///
  /// In de, this message translates to:
  /// **'Datenschutz'**
  String get settingsPrivacy;

  /// No description provided for @settingsImprint.
  ///
  /// In de, this message translates to:
  /// **'Impressum'**
  String get settingsImprint;

  /// No description provided for @settingsNotConfigured.
  ///
  /// In de, this message translates to:
  /// **'Noch nicht hinterlegt'**
  String get settingsNotConfigured;

  /// No description provided for @settingsVersion.
  ///
  /// In de, this message translates to:
  /// **'Version {version}'**
  String settingsVersion(String version);

  /// No description provided for @commonCancel.
  ///
  /// In de, this message translates to:
  /// **'Abbrechen'**
  String get commonCancel;

  /// No description provided for @commonDelete.
  ///
  /// In de, this message translates to:
  /// **'Löschen'**
  String get commonDelete;

  /// No description provided for @commonSave.
  ///
  /// In de, this message translates to:
  /// **'Speichern'**
  String get commonSave;

  /// No description provided for @commonReset.
  ///
  /// In de, this message translates to:
  /// **'Zurücksetzen'**
  String get commonReset;

  /// No description provided for @commonClose.
  ///
  /// In de, this message translates to:
  /// **'Schließen'**
  String get commonClose;

  /// No description provided for @commonContinue.
  ///
  /// In de, this message translates to:
  /// **'Weiter'**
  String get commonContinue;

  /// No description provided for @commonBack.
  ///
  /// In de, this message translates to:
  /// **'Zurück'**
  String get commonBack;

  /// No description provided for @commonDone.
  ///
  /// In de, this message translates to:
  /// **'Fertig'**
  String get commonDone;

  /// No description provided for @commonComingSoon.
  ///
  /// In de, this message translates to:
  /// **'{feature} kommt bald!'**
  String commonComingSoon(String feature);

  /// No description provided for @onboardingLanguageTitle.
  ///
  /// In de, this message translates to:
  /// **'Sprache wählen'**
  String get onboardingLanguageTitle;

  /// No description provided for @onboardingNameTitle.
  ///
  /// In de, this message translates to:
  /// **'Wie heißt du?'**
  String get onboardingNameTitle;

  /// No description provided for @onboardingNameHint.
  ///
  /// In de, this message translates to:
  /// **'Dein Name'**
  String get onboardingNameHint;

  /// No description provided for @onboardingLocationTitle.
  ///
  /// In de, this message translates to:
  /// **'Standort'**
  String get onboardingLocationTitle;

  /// No description provided for @onboardingLocationBody.
  ///
  /// In de, this message translates to:
  /// **'Für genaue Gebetszeiten brauchen wir deinen Standort.'**
  String get onboardingLocationBody;

  /// No description provided for @onboardingLocationAllow.
  ///
  /// In de, this message translates to:
  /// **'Standort erlauben'**
  String get onboardingLocationAllow;

  /// No description provided for @onboardingLocationManual.
  ///
  /// In de, this message translates to:
  /// **'Stadt manuell wählen'**
  String get onboardingLocationManual;

  /// No description provided for @onboardingMethodTitle.
  ///
  /// In de, this message translates to:
  /// **'Berechnungsmethode'**
  String get onboardingMethodTitle;

  /// No description provided for @onboardingAdhanTitle.
  ///
  /// In de, this message translates to:
  /// **'Adhan-Stimme'**
  String get onboardingAdhanTitle;

  /// No description provided for @onboardingDoneTitle.
  ///
  /// In de, this message translates to:
  /// **'Alles bereit'**
  String get onboardingDoneTitle;

  /// No description provided for @onboardingDoneBody.
  ///
  /// In de, this message translates to:
  /// **'Möge dir die App bei deinen Gebeten helfen.'**
  String get onboardingDoneBody;

  /// No description provided for @onboardingStart.
  ///
  /// In de, this message translates to:
  /// **'Los geht\'s'**
  String get onboardingStart;

  /// No description provided for @notificationPrayerTimeTitle.
  ///
  /// In de, this message translates to:
  /// **'{prayer} ist jetzt'**
  String notificationPrayerTimeTitle(String prayer);

  /// No description provided for @notificationPrayerTimeBody.
  ///
  /// In de, this message translates to:
  /// **'Zeit für das Gebet.'**
  String get notificationPrayerTimeBody;

  /// No description provided for @settingsMadhabShafiHint.
  ///
  /// In de, this message translates to:
  /// **'Auch Maliki und Hanbali — früheres Asr'**
  String get settingsMadhabShafiHint;

  /// No description provided for @settingsMadhabHanafiHint.
  ///
  /// In de, this message translates to:
  /// **'Späteres Asr'**
  String get settingsMadhabHanafiHint;

  /// No description provided for @muezzinSilent.
  ///
  /// In de, this message translates to:
  /// **'Nur Vibration / stumm'**
  String get muezzinSilent;

  /// No description provided for @settingsNotSet.
  ///
  /// In de, this message translates to:
  /// **'nicht gesetzt'**
  String get settingsNotSet;

  /// No description provided for @qiblaAligned.
  ///
  /// In de, this message translates to:
  /// **'Ausgerichtet — Richtung Mekka'**
  String get qiblaAligned;

  /// No description provided for @settingsDataSources.
  ///
  /// In de, this message translates to:
  /// **'Datenquellen'**
  String get settingsDataSources;

  /// No description provided for @nowLabel.
  ///
  /// In de, this message translates to:
  /// **'jetzt'**
  String get nowLabel;

  /// No description provided for @onboardingLanguageSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Du kannst das später jederzeit ändern'**
  String get onboardingLanguageSubtitle;

  /// No description provided for @onboardingNameQuestion.
  ///
  /// In de, this message translates to:
  /// **'Wie dürfen wir dich nennen?'**
  String get onboardingNameQuestion;

  /// No description provided for @onboardingNameSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Für deine persönliche Begrüßung.'**
  String get onboardingNameSubtitle;

  /// No description provided for @onboardingNamePreview.
  ///
  /// In de, this message translates to:
  /// **'z. B. für „Assalamu alaikum, {name}“'**
  String onboardingNamePreview(String name);

  /// No description provided for @onboardingLocationDetect.
  ///
  /// In de, this message translates to:
  /// **'Standort automatisch erkennen'**
  String get onboardingLocationDetect;

  /// No description provided for @onboardingLocationSearch.
  ///
  /// In de, this message translates to:
  /// **'Stadt manuell suchen…'**
  String get onboardingLocationSearch;

  /// No description provided for @onboardingLocationSkip.
  ///
  /// In de, this message translates to:
  /// **'Ohne Standort fortfahren'**
  String get onboardingLocationSkip;

  /// No description provided for @onboardingLocationPrivacy.
  ///
  /// In de, this message translates to:
  /// **'Gebetszeiten und Qibla werden auf deinem Gerät berechnet. Nur die Moschee-Suche überträgt deinen Standort — und fragt vorher.'**
  String get onboardingLocationPrivacy;

  /// No description provided for @onboardingLocationDetected.
  ///
  /// In de, this message translates to:
  /// **'Standort erkannt: {city}'**
  String onboardingLocationDetected(String city);

  /// No description provided for @onboardingLocationNotFound.
  ///
  /// In de, this message translates to:
  /// **'Ort nicht gefunden.'**
  String get onboardingLocationNotFound;

  /// No description provided for @onboardingMethodHeading.
  ///
  /// In de, this message translates to:
  /// **'Gebetszeiten anpassen'**
  String get onboardingMethodHeading;

  /// No description provided for @onboardingMethodSection.
  ///
  /// In de, this message translates to:
  /// **'BERECHNUNGSMETHODE'**
  String get onboardingMethodSection;

  /// No description provided for @onboardingMadhabSection.
  ///
  /// In de, this message translates to:
  /// **'ASR-BERECHNUNG (MADHAB)'**
  String get onboardingMadhabSection;

  /// No description provided for @onboardingAdhanHeading.
  ///
  /// In de, this message translates to:
  /// **'Adhan-Erinnerungen'**
  String get onboardingAdhanHeading;

  /// No description provided for @onboardingAdhanBody.
  ///
  /// In de, this message translates to:
  /// **'Lass dich zu jeder Gebetszeit sanft erinnern.'**
  String get onboardingAdhanBody;

  /// No description provided for @onboardingAdhanEnable.
  ///
  /// In de, this message translates to:
  /// **'Benachrichtigungen aktivieren'**
  String get onboardingAdhanEnable;

  /// No description provided for @onboardingAdhanEnabled.
  ///
  /// In de, this message translates to:
  /// **'Benachrichtigungen aktiviert.'**
  String get onboardingAdhanEnabled;

  /// No description provided for @onboardingAdhanDenied.
  ///
  /// In de, this message translates to:
  /// **'Berechtigung wurde nicht erteilt.'**
  String get onboardingAdhanDenied;

  /// No description provided for @onboardingMuezzinSection.
  ///
  /// In de, this message translates to:
  /// **'MUEZZIN-STIMME'**
  String get onboardingMuezzinSection;

  /// No description provided for @onboardingDoneHeading.
  ///
  /// In de, this message translates to:
  /// **'Alles bereit'**
  String get onboardingDoneHeading;

  /// No description provided for @onboardingDoneHeadingNamed.
  ///
  /// In de, this message translates to:
  /// **'Alles bereit, {name}'**
  String onboardingDoneHeadingNamed(String name);

  /// No description provided for @onboardingDoneCompanion.
  ///
  /// In de, this message translates to:
  /// **'Möge Munir dich durch deinen Tag begleiten.'**
  String get onboardingDoneCompanion;

  /// No description provided for @onboardingOpenApp.
  ///
  /// In de, this message translates to:
  /// **'App öffnen'**
  String get onboardingOpenApp;

  /// No description provided for @onboardingAdhanOn.
  ///
  /// In de, this message translates to:
  /// **'Adhan an'**
  String get onboardingAdhanOn;

  /// No description provided for @onboardingAdhanOff.
  ///
  /// In de, this message translates to:
  /// **'Adhan aus'**
  String get onboardingAdhanOff;

  /// No description provided for @featurePrayerTitle.
  ///
  /// In de, this message translates to:
  /// **'Verpasse kein Gebet mehr'**
  String get featurePrayerTitle;

  /// No description provided for @featurePrayerBody.
  ///
  /// In de, this message translates to:
  /// **'Präzise Gebetszeiten für deinen Standort, mit Adhan-Erinnerung.'**
  String get featurePrayerBody;

  /// No description provided for @featureQiblaTitle.
  ///
  /// In de, this message translates to:
  /// **'Finde die Qibla-Richtung'**
  String get featureQiblaTitle;

  /// No description provided for @featureQiblaBody.
  ///
  /// In de, this message translates to:
  /// **'Ein präziser Kompass zeigt dir überall den Weg nach Makkah.'**
  String get featureQiblaBody;

  /// No description provided for @featureQuranTitle.
  ///
  /// In de, this message translates to:
  /// **'Der Quran, immer bei dir'**
  String get featureQuranTitle;

  /// No description provided for @featureQuranBody.
  ///
  /// In de, this message translates to:
  /// **'Lies, höre und markiere deine Fortschritte — offline verfügbar.'**
  String get featureQuranBody;

  /// No description provided for @commonSkip.
  ///
  /// In de, this message translates to:
  /// **'Überspringen'**
  String get commonSkip;

  /// No description provided for @commonNext.
  ///
  /// In de, this message translates to:
  /// **'Weiter'**
  String get commonNext;

  /// No description provided for @onboardingLocationQuestion.
  ///
  /// In de, this message translates to:
  /// **'Wo befindest du dich?'**
  String get onboardingLocationQuestion;

  /// No description provided for @notificationChannelName.
  ///
  /// In de, this message translates to:
  /// **'Gebetszeiten'**
  String get notificationChannelName;

  /// No description provided for @notificationChannelDescription.
  ///
  /// In de, this message translates to:
  /// **'Erinnerungen zu den täglichen Gebetszeiten'**
  String get notificationChannelDescription;

  /// No description provided for @onboardingLocationWhy.
  ///
  /// In de, this message translates to:
  /// **'Wir brauchen deinen Standort für exakte Gebetszeiten und die Qibla-Richtung.'**
  String get onboardingLocationWhy;

  /// No description provided for @commonOr.
  ///
  /// In de, this message translates to:
  /// **'oder'**
  String get commonOr;

  /// No description provided for @settingsSectionAccount.
  ///
  /// In de, this message translates to:
  /// **'Konto'**
  String get settingsSectionAccount;

  /// No description provided for @settingsSignInGoogle.
  ///
  /// In de, this message translates to:
  /// **'Mit Google anmelden'**
  String get settingsSignInGoogle;

  /// No description provided for @settingsSignInWhy.
  ///
  /// In de, this message translates to:
  /// **'Sichert deinen Gebets-Verlauf und synchronisiert ihn auf deinen Geräten'**
  String get settingsSignInWhy;

  /// No description provided for @settingsSignOut.
  ///
  /// In de, this message translates to:
  /// **'Abmelden'**
  String get settingsSignOut;

  /// No description provided for @settingsDeleteAccount.
  ///
  /// In de, this message translates to:
  /// **'Konto löschen'**
  String get settingsDeleteAccount;

  /// No description provided for @settingsDeleteAccountHint.
  ///
  /// In de, this message translates to:
  /// **'Löscht dein Konto und alle gespeicherten Daten endgültig'**
  String get settingsDeleteAccountHint;

  /// No description provided for @settingsDeleteAccountConfirm.
  ///
  /// In de, this message translates to:
  /// **'Konto wirklich löschen? Dein Verlauf auf den Servern wird endgültig gelöscht. Die Daten auf diesem Gerät bleiben erhalten.'**
  String get settingsDeleteAccountConfirm;

  /// No description provided for @settingsSignedInAs.
  ///
  /// In de, this message translates to:
  /// **'Angemeldet als {email}'**
  String settingsSignedInAs(String email);

  /// No description provided for @settingsSignInFailed.
  ///
  /// In de, this message translates to:
  /// **'Anmeldung fehlgeschlagen.'**
  String get settingsSignInFailed;

  /// No description provided for @settingsSyncNow.
  ///
  /// In de, this message translates to:
  /// **'Jetzt synchronisieren'**
  String get settingsSyncNow;

  /// No description provided for @settingsSyncDone.
  ///
  /// In de, this message translates to:
  /// **'Synchronisiert.'**
  String get settingsSyncDone;

  /// No description provided for @settingsAccountDeleted.
  ///
  /// In de, this message translates to:
  /// **'Konto gelöscht.'**
  String get settingsAccountDeleted;

  /// No description provided for @onboardingAccountTitle.
  ///
  /// In de, this message translates to:
  /// **'Fortschritt sichern'**
  String get onboardingAccountTitle;

  /// No description provided for @onboardingAccountBody.
  ///
  /// In de, this message translates to:
  /// **'Mit einem Konto bleibt dein Gebets-Verlauf erhalten — auch bei einem Gerätewechsel. Ohne Konto wird alles nur auf diesem Gerät gespeichert.'**
  String get onboardingAccountBody;

  /// No description provided for @commonLater.
  ///
  /// In de, this message translates to:
  /// **'Später'**
  String get commonLater;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'de', 'en', 'fr', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
