import 'dart:async';
import 'dart:math' as math;

import 'package:adhan_dart/adhan_dart.dart' as adhan;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/prayer.dart';
import '../services/location_refresh_policy.dart';
import '../services/notification_service.dart';

// ---------------------------------------------------------------------------
// Storage
// ---------------------------------------------------------------------------

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Override in main.dart');
});

// ---------------------------------------------------------------------------
// Onboarding completion gate
// ---------------------------------------------------------------------------

class HasCompletedOnboardingNotifier extends Notifier<bool> {
  @override
  bool build() {
    final prefs = ref.read(sharedPreferencesProvider);
    return prefs.getBool('onboarding_complete') ?? false;
  }

  void complete() {
    ref.read(sharedPreferencesProvider).setBool('onboarding_complete', true);
    state = true;
  }
}

final hasCompletedOnboardingProvider =
    NotifierProvider<HasCompletedOnboardingNotifier, bool>(
      HasCompletedOnboardingNotifier.new,
    );

// ---------------------------------------------------------------------------
// User
// ---------------------------------------------------------------------------

class UserNameNotifier extends Notifier<String> {
  @override
  String build() {
    final prefs = ref.read(sharedPreferencesProvider);
    return prefs.getString('user_name') ?? '';
  }

  void update(String name) {
    ref.read(sharedPreferencesProvider).setString('user_name', name);
    state = name;
  }
}

final userNameProvider = NotifierProvider<UserNameNotifier, String>(
  UserNameNotifier.new,
);

// ---------------------------------------------------------------------------
// App language
// ---------------------------------------------------------------------------

/// Locale codes the app ships translations for, in the order the picker shows.
const supportedLanguageCodes = ['de', 'en', 'tr', 'ar', 'fr'];

/// Display names for the language picker, in the language itself.
const languageDisplayNames = {
  'de': 'Deutsch',
  'en': 'English',
  'tr': 'Türkçe',
  'ar': 'العربية',
  'fr': 'Français',
};

class AppLanguageNotifier extends Notifier<String> {
  static const _key = 'app_language';

  @override
  String build() {
    final stored = ref.read(sharedPreferencesProvider).getString(_key);
    return _normalize(stored);
  }

  /// Earlier builds stored the display name ('Deutsch') rather than a locale
  /// code, so anything that is not a known code is mapped back onto one.
  static String _normalize(String? stored) {
    if (stored == null) return 'de';
    if (supportedLanguageCodes.contains(stored)) return stored;
    for (final entry in languageDisplayNames.entries) {
      if (entry.value == stored) return entry.key;
    }
    return 'de';
  }

  void update(String languageCode) {
    if (!supportedLanguageCodes.contains(languageCode)) return;
    ref.read(sharedPreferencesProvider).setString(_key, languageCode);
    state = languageCode;
  }
}

final appLanguageProvider = NotifierProvider<AppLanguageNotifier, String>(
  AppLanguageNotifier.new,
);

// ---------------------------------------------------------------------------
// Location
// ---------------------------------------------------------------------------

class LocationData {
  final double lat;
  final double lng;
  final String city;

  /// True only for the temporary Berlin value used while no user location is
  /// available. Qibla must never present this as the user's actual position.
  final bool isFallback;

  /// ISO 3166-1 alpha-2, used to pick the prayer calculation method.
  /// Null when reverse geocoding was unavailable.
  final String? isoCountryCode;

  const LocationData({
    required this.lat,
    required this.lng,
    this.city = 'Standort',
    this.isoCountryCode,
    this.isFallback = false,
  });

  /// The city name only when one was actually resolved.
  ///
  /// [city] falls back to the literal 'Standort' when reverse geocoding gave
  /// nothing, which is fine as a label above a field but reads as nonsense in
  /// a sentence like "Berechnet für Standort".
  String? get resolvedCity =>
      city.isEmpty || city == 'Standort' ? null : city;

  static const fallback = LocationData(
    lat: 52.52,
    lng: 13.405,
    city: 'Berlin',
    isFallback: true,
  );
}

class LocationNotifier extends AsyncNotifier<LocationData> {
  @override
  Future<LocationData> build() async {
    final prefs = ref.read(sharedPreferencesProvider);

    final cachedLat = prefs.getDouble('cached_lat');
    final cachedLng = prefs.getDouble('cached_lng');
    final cachedCity = prefs.getString('cached_city') ?? 'Standort';

    if (cachedLat != null && cachedLng != null) {
      return LocationData(lat: cachedLat, lng: cachedLng, city: cachedCity);
    }

    return LocationData.fallback;
  }

  static const _sourceKey = 'location_source';
  static const _sourceGps = 'gps';
  static const _sourceManual = 'manual';

  /// Whether the stored position came from GPS rather than from a city the
  /// user typed in.
  ///
  /// Only the GPS one is refreshed on its own. A city picked by hand is a
  /// decision — someone keeping their home town's times while away, or a
  /// phone whose GPS is not to be trusted — and quietly replacing it would
  /// be the app overruling the user.
  ///
  /// Installs from before this key existed answer yes, because the detect
  /// button was the usual way in and the alternative — every existing user
  /// having to tap the location row once before the app tracked them again
  /// — is the worse of the two wrong answers. The permission check in
  /// [refreshQuietly] covers most of the rest: someone who searched for a
  /// city by hand generally did so having refused location access, and a
  /// refused permission stops the refresh before it starts.
  bool get followsGps =>
      ref.read(sharedPreferencesProvider).getString(_sourceKey) !=
      _sourceManual;

  /// Detects location via GPS. Returns the resolved data, or throws on failure.
  Future<LocationData> detectViaGps() async {
    state = const AsyncLoading();

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      state = AsyncData(LocationData.fallback);
      throw Exception('Standortdienste sind deaktiviert.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      state = AsyncData(LocationData.fallback);
      throw Exception('Standortzugriff wurde verweigert.');
    }

    final position = await _currentOrRecentFix();
    if (position == null) {
      state = AsyncData(LocationData.fallback);
      throw Exception(
        'Kein aktueller Standort verfügbar. Bitte Stadt manuell suchen.',
      );
    }

    final data = await _describe(position);
    await _persist(data, fromGps: true);
    state = AsyncData(data);
    return data;
  }

  /// Brings the position up to date without anyone having asked for it.
  ///
  /// Deliberately quiet. It sets no loading state — the home screen would
  /// flash a spinner every time the app is opened — throws nothing, because
  /// there is nobody watching to show it to, and never asks for permission:
  /// a system dialog appearing with no tap behind it is worse than a
  /// slightly stale position. What it cannot get, it gives up on.
  ///
  /// Driven by [LocationRefresher]: on launch, on resume and on a timer.
  Future<void> refreshQuietly() async {
    if (!followsGps) return;

    try {
      if (!await Geolocator.isLocationServiceEnabled()) return;

      final permission = await Geolocator.checkPermission();
      final granted =
          permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
      if (!granted) return;

      final position = await _currentOrRecentFix();
      if (position == null) return;

      final previous = state.value;
      if (previous != null && !_worthAdopting(previous, position)) return;

      final data = await _describe(position);
      await _persist(data, fromGps: true);
      state = AsyncData(data);
    } catch (e) {
      // No fix, no geocoder, permission revoked mid-call, plugin missing in
      // a test. The stored position stays and the next attempt tries again.
      debugPrint('Quiet location refresh skipped: $e');
    }
  }

  bool _worthAdopting(LocationData previous, Position fix) {
    return locationRefreshPolicy.worthAdopting(
      movedMetres: Geolocator.distanceBetween(
        previous.lat,
        previous.lng,
        fix.latitude,
        fix.longitude,
      ),
      previousWasFallback: previous.isFallback,
      previousCityUnresolved: previous.resolvedCity == null,
    );
  }

  /// A live fix, or a cached one recent enough to still be true.
  ///
  /// A stale cached fix would silently produce prayer times for wherever the
  /// phone was hours ago, which is worse than admitting to having no
  /// position at all.
  Future<Position?> _currentOrRecentFix() async {
    const maxCachedFixAge = Duration(minutes: 2);

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (_) {
      // Live fetch failed or timed out.
      final cached = await Geolocator.getLastKnownPosition();
      if (cached == null) return null;

      final age = DateTime.now().difference(cached.timestamp);
      return age <= maxCachedFixAge ? cached : null;
    }
  }

  Future<LocationData> _describe(Position position) async {
    final place = await _resolvePlace(position.latitude, position.longitude);
    return LocationData(
      lat: position.latitude,
      lng: position.longitude,
      city: place.city,
      isoCountryCode: place.isoCountryCode,
    );
  }

  /// Reverse-geocodes coordinates into a city label and a country code.
  /// Falls back to formatted coordinates when no geocoder result is available
  /// (offline, emulator without Google Play services, unnamed area).
  Future<({String city, String? isoCountryCode})> _resolvePlace(
    double lat,
    double lng,
  ) async {
    try {
      final placemarks = await Geocoding()
          .placemarkFromCoordinates(lat, lng)
          .timeout(const Duration(seconds: 8));

      for (final p in placemarks) {
        final city = p.locality?.trim().isNotEmpty == true
            ? p.locality!.trim()
            : p.subAdministrativeArea?.trim().isNotEmpty == true
            ? p.subAdministrativeArea!.trim()
            : p.administrativeArea?.trim().isNotEmpty == true
            ? p.administrativeArea!.trim()
            : null;
        if (city == null) continue;

        final country = p.country?.trim();
        return (
          city: country != null && country.isNotEmpty
              ? '$city, $country'
              : city,
          isoCountryCode: p.isoCountryCode,
        );
      }
    } catch (_) {
      // Geocoding unavailable — fall through to coordinate label.
    }

    return (
      city: '${lat.toStringAsFixed(3)}, ${lng.toStringAsFixed(3)}',
      isoCountryCode: null,
    );
  }

  /// Sets location explicitly, from the manual city search.
  ///
  /// Recorded as the user's own choice, which is what stops
  /// [refreshQuietly] from ever replacing it.
  Future<void> setManual(LocationData data) async {
    await _persist(data, fromGps: false);
    state = AsyncData(data);
  }

  Future<void> _persist(LocationData data, {required bool fromGps}) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setDouble('cached_lat', data.lat);
    await prefs.setDouble('cached_lng', data.lng);
    await prefs.setString('cached_city', data.city);
    await prefs.setString(_sourceKey, fromGps ? _sourceGps : _sourceManual);
  }
}

final locationProvider = AsyncNotifierProvider<LocationNotifier, LocationData>(
  LocationNotifier.new,
);

// ---------------------------------------------------------------------------
// Calculation method + Madhab (persisted settings)
// ---------------------------------------------------------------------------

extension CalculationMethodLabel on adhan.CalculationMethod {
  /// Compact badge label for tight spaces. Falls back to the method's own
  /// display name so newly added methods still render something meaningful.
  String get shortLabel => switch (this) {
    adhan.CalculationMethod.muslimWorldLeague => 'MWL',
    adhan.CalculationMethod.northAmerica => 'ISNA',
    adhan.CalculationMethod.ummAlQura => 'UAQ',
    adhan.CalculationMethod.egyptian => 'Egypt',
    adhan.CalculationMethod.karachi => 'Karachi',
    adhan.CalculationMethod.turkiye => 'Diyanet',
    adhan.CalculationMethod.dubai => 'Dubai',
    adhan.CalculationMethod.qatar => 'Qatar',
    adhan.CalculationMethod.kuwait => 'Kuwait',
    adhan.CalculationMethod.singapore => 'Singapur',
    adhan.CalculationMethod.france => 'UOIF',
    adhan.CalculationMethod.jafari => 'Jafari',
    adhan.CalculationMethod.tehran => 'Tehran',
    adhan.CalculationMethod.moonsightingCommittee => 'Moonsighting',
    _ => displayName,
  };
}

class CalculationMethodNotifier extends Notifier<adhan.CalculationMethod> {
  @override
  adhan.CalculationMethod build() {
    final prefs = ref.read(sharedPreferencesProvider);
    final stored = prefs.getString('calculation_method');
    if (stored == null) return adhan.CalculationMethod.muslimWorldLeague;
    return adhan.CalculationMethod.values.firstWhere(
      (m) => m.name == stored,
      orElse: () => adhan.CalculationMethod.muslimWorldLeague,
    );
  }

  void update(adhan.CalculationMethod method) {
    ref
        .read(sharedPreferencesProvider)
        .setString('calculation_method', method.name);
    state = method;
  }
}

final calculationMethodProvider =
    NotifierProvider<CalculationMethodNotifier, adhan.CalculationMethod>(
      CalculationMethodNotifier.new,
    );

class MadhabNotifier extends Notifier<adhan.Madhab> {
  @override
  adhan.Madhab build() {
    final prefs = ref.read(sharedPreferencesProvider);
    final stored = prefs.getString('madhab');
    return stored == 'hanafi' ? adhan.Madhab.hanafi : adhan.Madhab.shafi;
  }

  void update(adhan.Madhab madhab) {
    ref
        .read(sharedPreferencesProvider)
        .setString(
          'madhab',
          madhab == adhan.Madhab.hanafi ? 'hanafi' : 'shafi',
        );
    state = madhab;
  }
}

final madhabProvider = NotifierProvider<MadhabNotifier, adhan.Madhab>(
  MadhabNotifier.new,
);

adhan.CalculationParameters resolveCalculationParameters(
  adhan.CalculationMethod method,
) {
  final params = switch (method) {
    adhan.CalculationMethod.algerian =>
      adhan.CalculationMethodParameters.algerian(),
    adhan.CalculationMethod.dubai => adhan.CalculationMethodParameters.dubai(),
    adhan.CalculationMethod.egyptian =>
      adhan.CalculationMethodParameters.egyptian(),
    adhan.CalculationMethod.france =>
      adhan.CalculationMethodParameters.france(),
    adhan.CalculationMethod.gulfRegion =>
      adhan.CalculationMethodParameters.gulfRegion(),
    adhan.CalculationMethod.indonesian =>
      adhan.CalculationMethodParameters.indonesian(),
    adhan.CalculationMethod.jafari =>
      adhan.CalculationMethodParameters.jafari(),
    adhan.CalculationMethod.jordan =>
      adhan.CalculationMethodParameters.jordan(),
    adhan.CalculationMethod.karachi =>
      adhan.CalculationMethodParameters.karachi(),
    adhan.CalculationMethod.kuwait =>
      adhan.CalculationMethodParameters.kuwait(),
    adhan.CalculationMethod.moonsightingCommittee =>
      adhan.CalculationMethodParameters.moonsightingCommittee(),
    adhan.CalculationMethod.morocco =>
      adhan.CalculationMethodParameters.morocco(),
    adhan.CalculationMethod.muslimWorldLeague =>
      adhan.CalculationMethodParameters.muslimWorldLeague(),
    adhan.CalculationMethod.northAmerica =>
      adhan.CalculationMethodParameters.northAmerica(),
    adhan.CalculationMethod.other => adhan.CalculationMethodParameters.other(),
    adhan.CalculationMethod.portugal =>
      adhan.CalculationMethodParameters.portugal(),
    adhan.CalculationMethod.qatar => adhan.CalculationMethodParameters.qatar(),
    adhan.CalculationMethod.russia =>
      adhan.CalculationMethodParameters.russia(),
    adhan.CalculationMethod.singapore =>
      adhan.CalculationMethodParameters.singapore(),
    adhan.CalculationMethod.tehran =>
      adhan.CalculationMethodParameters.tehran(),
    adhan.CalculationMethod.tunisia =>
      adhan.CalculationMethodParameters.tunisia(),
    adhan.CalculationMethod.turkiye =>
      adhan.CalculationMethodParameters.turkiye(),
    adhan.CalculationMethod.ummAlQura =>
      adhan.CalculationMethodParameters.ummAlQura(),
  };
  return params;
}

// ---------------------------------------------------------------------------
// Prayer Times (real calculation)
// ---------------------------------------------------------------------------

List<PrayerTime> computePrayerTimes({
  required LocationData location,
  required adhan.CalculationMethod method,
  required adhan.Madhab madhab,
  DateTime? date,
  bool includeSunrise = false,
}) {
  final coords = adhan.Coordinates(location.lat, location.lng);
  final params = resolveCalculationParameters(method);
  params.madhab = madhab;

  // At high latitudes the sun never descends far enough below the horizon for
  // the method's Fajr/Isha angles to be reached (Berlin in July, for example),
  // so those two times must fall back to a night-fraction rule.
  //
  // twilightAngle (fajrAngle/60 and ishaAngle/60 of the night) is used rather
  // than HighLatitudeRule.recommended(), which returns seventhOfTheNight above
  // 48° latitude. Compared against published timetables for 26 July:
  //   Berlin   twilightAngle Fajr 02:50 / Isha 23:27  (tables ~02:50 / ~23:30)
  //            seventhOfTheNight  04:07 /       22:18  — both far off
  //            middleOfTheNight   01:15 /       00:12  — both far off
  //   Istanbul twilightAngle Fajr 03:59  (tables ~03:55)
  //            seventhOfTheNight  04:33      — off
  // All three rules are only clamps: where the true angle is reachable
  // (Berlin in January, Makkah year-round) they produce identical output, so
  // this never distorts normal latitudes.
  params.highLatitudeRule = adhan.HighLatitudeRule.twilightAngle;

  final pt = adhan.PrayerTimes(
    date: date ?? DateTime.now(),
    coordinates: coords,
    calculationParameters: params,
  );

  return [
    PrayerTime(name: 'Fajr', arabicName: 'الفجر', time: pt.fajr.toLocal()),
    if (includeSunrise)
      PrayerTime(
        name: 'Sonnenaufgang',
        arabicName: 'الشروق',
        time: pt.sunrise.toLocal(),
        isPrayer: false,
      ),
    PrayerTime(name: 'Dhuhr', arabicName: 'الظهر', time: pt.dhuhr.toLocal()),
    PrayerTime(name: 'Asr', arabicName: 'العصر', time: pt.asr.toLocal()),
    PrayerTime(
      name: 'Maghrib',
      arabicName: 'المغرب',
      time: pt.maghrib.toLocal(),
    ),
    PrayerTime(name: 'Isha', arabicName: 'العشاء', time: pt.isha.toLocal()),
  ];
}

final logicalDateProvider = Provider<DateTime>((ref) {
  final locationAsync = ref.watch(locationProvider);
  final location = switch (locationAsync) {
    AsyncData(:final value) => value,
    _ => LocationData.fallback,
  };
  final method = ref.watch(calculationMethodProvider);
  final madhab = ref.watch(madhabProvider);

  var now = DateTime.now();
  final prayers = computePrayerTimes(
    location: location,
    method: method,
    madhab: madhab,
    date: now,
  );
  final fajr = prayers.firstWhere((p) => p.name == 'Fajr').time;

  if (now.isBefore(fajr)) {
    // Calendar arithmetic, not `Duration(days: 1)`: subtracting 24 hours
    // across a daylight-saving boundary can land on the wrong calendar day,
    // and the tracker keys are built from year/month/day.
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    return DateTime(
      yesterday.year,
      yesterday.month,
      yesterday.day,
      now.hour,
      now.minute,
      now.second,
    );
  }
  return now;
});

final prayerTimesProvider = Provider<List<PrayerTime>>((ref) {
  final locationAsync = ref.watch(locationProvider);
  final location = switch (locationAsync) {
    AsyncData(:final value) => value,
    _ => LocationData.fallback,
  };
  final method = ref.watch(calculationMethodProvider);
  final madhab = ref.watch(madhabProvider);
  final date = ref.watch(logicalDateProvider);

  return computePrayerTimes(
    location: location,
    method: method,
    madhab: madhab,
    date: date,
    includeSunrise: true,
  );
});

/// Keeps prayer-time notifications armed by re-scheduling a rolling week
/// whenever anything that changes prayer times changes, and on every app
/// launch. Previously this only ran once, at onboarding, for that single
/// day — so reminders silently stopped for good the first day the app
/// wasn't opened, and any later change to location/method/madhab kept
/// notifying stale times. Watching this provider (see `_MainShell` in
/// app.dart) is the only wiring needed; it's a no-op via [cancelAll] when
/// notifications are off.
const _notificationScheduleWindowDays = 7;

final notificationSchedulerProvider = FutureProvider<void>((ref) async {
  try {
    await _runNotificationScheduler(ref);
  } catch (e, st) {
    debugPrint('notificationSchedulerProvider failed: $e\n$st');
    rethrow;
  }
});

Future<void> _runNotificationScheduler(Ref ref) async {
  final enabled = ref.watch(notificationsEnabledProvider);
  if (!enabled) {
    await NotificationService.cancelAll();
    return;
  }

  final locationAsync = ref.watch(locationProvider);
  final location = switch (locationAsync) {
    AsyncData(:final value) => value,
    _ => LocationData.fallback,
  };
  final method = ref.watch(calculationMethodProvider);
  final madhab = ref.watch(madhabProvider);
  final languageCode = ref.watch(appLanguageProvider);
  final enabledPrayers = ref.watch(prayerNotificationsProvider);

  final today = DateTime.now();
  final upcoming = <PrayerTime>[
    for (var offset = 0; offset < _notificationScheduleWindowDays; offset++)
      ...computePrayerTimes(
        location: location,
        method: method,
        madhab: madhab,
        date: DateTime(today.year, today.month, today.day + offset, 12),
      ),
  ];

  // Read, not watch: ticking a prayer off must not tear down and rebuild
  // every scheduled alarm. The one reminder that becomes obsolete is
  // withdrawn directly by the tracker.
  final catchUpEnabled = ref.watch(catchUpRemindersProvider);
  final tracker = ref.read(prayerTrackerProvider);

  await NotificationService.scheduleMany(
    upcoming,
    languageCode: languageCode,
    enabledPrayers: enabledPrayers,
    catchUpEnabled: catchUpEnabled,
    isPrayerLogged: (day, prayerName) =>
        tracker['prayer_tracker_${day.year}_${day.month}_${day.day}_'
            '$prayerName'] ==
        true,
    city: location.resolvedCity,
  );
}

/// Returns prayer times for [date] (day-precision) including sunrise.
/// Used by the prayers screen where the user browses per day.
final prayerTimesForDateProvider = Provider.family<List<PrayerTime>, DateTime>((
  ref,
  date,
) {
  final locationAsync = ref.watch(locationProvider);
  final location = switch (locationAsync) {
    AsyncData(:final value) => value,
    _ => LocationData.fallback,
  };
  final method = ref.watch(calculationMethodProvider);
  final madhab = ref.watch(madhabProvider);

  return computePrayerTimes(
    location: location,
    method: method,
    madhab: madhab,
    date: DateTime(date.year, date.month, date.day, 12),
    includeSunrise: true,
  );
});

final currentPrayerProvider = Provider<PrayerTime?>((ref) {
  final prayers = ref.watch(prayerTimesProvider);
  final now = DateTime.now();

  // Find the last prayer that has started
  PrayerTime? current;
  for (final p in prayers) {
    if (!p.isPrayer) continue;
    if (now.isAfter(p.time) || now.isAtSameMomentAs(p.time)) {
      current = p;
    }
  }
  return current;
});

final nextPrayerProvider = Provider<PrayerTime>((ref) {
  final prayers = ref.watch(prayerTimesProvider);
  final now = DateTime.now();

  for (final p in prayers) {
    if (!p.isPrayer) continue;
    if (p.time.isAfter(now)) {
      return p;
    }
  }

  // If no more prayers today, it's Fajr of tomorrow (relative to logicalDate)
  final locationAsync = ref.watch(locationProvider);
  final location = switch (locationAsync) {
    AsyncData(:final value) => value,
    _ => LocationData.fallback,
  };
  final method = ref.watch(calculationMethodProvider);
  final madhab = ref.watch(madhabProvider);
  final logicalDate = ref.watch(logicalDateProvider);

  final tomorrow = logicalDate.add(const Duration(days: 1));
  final tomorrowPrayers = computePrayerTimes(
    location: location,
    method: method,
    madhab: madhab,
    date: DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 12),
  );

  return tomorrowPrayers.firstWhere((p) => p.name == 'Fajr');
});

// ---------------------------------------------------------------------------
// Hijri Date
// ---------------------------------------------------------------------------

const _hijriMonthNamesDE = {
  1: 'Muharram',
  2: 'Safar',
  3: 'Rabi al-Awwal',
  4: 'Rabi ath-Thani',
  5: 'Dschumada l-Ula',
  6: 'Dschumada th-Thaniya',
  7: 'Radschab',
  8: 'Schaban',
  9: 'Ramadan',
  10: 'Schawwal',
  11: 'Dhu l-Qada',
  12: 'Dhu l-Hiddscha',
};

final hijriDateProvider = Provider<String>((ref) {
  HijriCalendar.setLocal('ar');
  final hijri = HijriCalendar.now();
  final monthName = _hijriMonthNamesDE[hijri.hMonth] ?? hijri.longMonthName;
  return '${hijri.hDay} $monthName ${hijri.hYear}';
});

// ---------------------------------------------------------------------------
// Adhan notification settings
// ---------------------------------------------------------------------------

// A muezzin-voice picker used to sit here. It offered two reciters and a
// silent option, stored the choice — and nothing ever read it: the app ships
// no adhan audio, and NotificationService never set a per-channel sound, so
// every option produced the system default. Removed rather than left in
// place; the setting is worth having, but only once the audio behind it
// exists.

class NotificationsEnabledNotifier extends Notifier<bool> {
  @override
  bool build() {
    final prefs = ref.read(sharedPreferencesProvider);
    return prefs.getBool('notifications_enabled') ?? false;
  }

  void set(bool enabled) {
    ref
        .read(sharedPreferencesProvider)
        .setBool('notifications_enabled', enabled);
    state = enabled;
  }
}

final notificationsEnabledProvider =
    NotifierProvider<NotificationsEnabledNotifier, bool>(
      NotificationsEnabledNotifier.new,
    );

/// Whether to follow up on a prayer that has not been ticked off.
///
/// Sits under the prayer reminders rather than beside them: it only ever
/// fires for prayers whose reminder is already switched on.
class CatchUpRemindersNotifier extends Notifier<bool> {
  static const _key = 'catchup_reminders_enabled';

  @override
  bool build() {
    return ref.read(sharedPreferencesProvider).getBool(_key) ?? true;
  }

  void set(bool enabled) {
    ref.read(sharedPreferencesProvider).setBool(_key, enabled);
    state = enabled;
  }
}

final catchUpRemindersProvider =
    NotifierProvider<CatchUpRemindersNotifier, bool>(
      CatchUpRemindersNotifier.new,
    );

/// Which individual prayers should trigger an Adhan notification.
/// Default: all five prayers enabled.
class PrayerNotificationsNotifier extends Notifier<Set<String>> {
  static const _key = 'prayer_notifications';
  static const _defaults = {'Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'};

  @override
  Set<String> build() {
    final prefs = ref.read(sharedPreferencesProvider);
    final stored = prefs.getStringList(_key);
    return stored?.toSet() ?? _defaults;
  }

  void toggle(String prayerName) {
    final updated = {...state};
    if (updated.contains(prayerName)) {
      updated.remove(prayerName);
    } else {
      updated.add(prayerName);
    }
    state = updated;
    ref.read(sharedPreferencesProvider).setStringList(_key, updated.toList());
  }
}

final prayerNotificationsProvider =
    NotifierProvider<PrayerNotificationsNotifier, Set<String>>(
      PrayerNotificationsNotifier.new,
    );

// ---------------------------------------------------------------------------
// Qibla
// ---------------------------------------------------------------------------

/// Bearing from user's location to the Kaaba, in degrees clockwise from north.
///
/// Null means that no real location has been established yet. A fallback city
/// is allowed for non-directional app content, but never for Qibla.
final qiblaBearingProvider = Provider<double?>((ref) {
  final locationAsync = ref.watch(locationProvider);
  final location = switch (locationAsync) {
    AsyncData(:final value) when !value.isFallback => value,
    _ => null,
  };
  return location == null ? null : calculateQiblaBearing(location);
});

double calculateQiblaBearing(LocationData location) {
  final bearing = adhan.Qibla.qibla(
    adhan.Coordinates(location.lat, location.lng),
  );
  return (bearing + 360) % 360;
}

/// Great-circle distance from user to the Kaaba, in km. Haversine.
final distanceToKaabaProvider = Provider<double?>((ref) {
  final locationAsync = ref.watch(locationProvider);
  final location = switch (locationAsync) {
    AsyncData(:final value) when !value.isFallback => value,
    _ => null,
  };
  return location == null ? null : calculateDistanceToKaabaKm(location);
});

double calculateDistanceToKaabaKm(LocationData location) {
  const kaabaLat = 21.4225241;
  const kaabaLng = 39.8261818;
  const earthRadiusKm = 6371.0;

  double toRad(double d) => d * math.pi / 180.0;

  final dLat = toRad(kaabaLat - location.lat);
  final dLng = toRad(kaabaLng - location.lng);
  final a =
      math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(toRad(location.lat)) *
          math.cos(toRad(kaabaLat)) *
          math.sin(dLng / 2) *
          math.sin(dLng / 2);
  final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  return earthRadiusKm * c;
}

// ---------------------------------------------------------------------------
// Prayer Tracker (persistent)
// ---------------------------------------------------------------------------

class PrayerTrackerNotifier extends Notifier<Map<String, bool>> {
  @override
  Map<String, bool> build() {
    final prefs = ref.read(sharedPreferencesProvider);
    final keys = prefs.getKeys().where((k) => k.startsWith('prayer_tracker_'));
    final Map<String, bool> data = {};
    for (final key in keys) {
      data[key] = prefs.getBool(key) ?? false;
    }
    return data;
  }

  String _key(DateTime date, String prayerName) {
    return 'prayer_tracker_${date.year}_${date.month}_${date.day}_$prayerName';
  }

  bool isCompleted(DateTime date, String prayerName) {
    return state[_key(date, prayerName)] ?? false;
  }

  void toggle(DateTime date, String prayerName) {
    final key = _key(date, prayerName);
    final current = state[key] ?? false;
    ref.read(sharedPreferencesProvider).setBool(key, !current);
    state = {...state, key: !current};

    if (!current) {
      // Now ticked off. The catch-up reminder was scheduled in advance and
      // cannot notice that by itself when it fires, so it is withdrawn here.
      unawaited(NotificationService.cancelCatchUp(date, prayerName));
    }
  }

  /// Folds entries coming from another device into the local state.
  ///
  /// A prayer ticked off on either device stays ticked: the union is taken
  /// rather than letting one side overwrite the other, because a sync must
  /// never silently un-tick something the user recorded.
  void mergeRemote(Map<String, bool> remote) {
    final prefs = ref.read(sharedPreferencesProvider);
    final merged = {...state};
    remote.forEach((key, done) {
      if (!key.startsWith('prayer_tracker_')) return;
      if (done && merged[key] != true) {
        merged[key] = true;
        prefs.setBool(key, true);
      }
    });
    state = merged;
  }

  /// Wipes the whole prayer history. Offered from the settings screen, which
  /// asks for confirmation first — this does not ask again.
  Future<void> resetAll() async {
    final prefs = ref.read(sharedPreferencesProvider);
    for (final key in state.keys) {
      await prefs.remove(key);
    }
    state = {};
  }
}

final prayerTrackerProvider =
    NotifierProvider<PrayerTrackerNotifier, Map<String, bool>>(
      PrayerTrackerNotifier.new,
    );

// ---------------------------------------------------------------------------
// Streaks (derived from the tracker, never stored separately)
// ---------------------------------------------------------------------------

const _trackerKeyPrefix = 'prayer_tracker_';

/// The five prayers a day has to contain to count towards a streak. Sunrise
/// is a time marker, not something that can be performed.
const obligatoryPrayerNames = {'Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'};

/// Calendar arithmetic, not `Duration(days: 1)`.
///
/// Subtracting 24 hours is wrong across a daylight-saving boundary — it can
/// land on the same calendar day twice, or skip one. `DateTime(y, m, d ± 1)`
/// normalises month and year boundaries on its own.
DateTime _previousDay(DateTime day) =>
    DateTime(day.year, day.month, day.day - 1);

DateTime _nextDay(DateTime day) => DateTime(day.year, day.month, day.day + 1);

/// Which obligatory prayers were ticked off, grouped by day.
///
/// The single place the flat `prayer_tracker_<y>_<m>_<d>_<name>` keys are
/// parsed; streaks and statistics both read this rather than re-deriving it.
Map<DateTime, Set<String>> trackedPrayersByDay(Map<String, bool> tracker) {
  final perDay = <DateTime, Set<String>>{};

  for (final entry in tracker.entries) {
    if (entry.value != true) continue;
    if (!entry.key.startsWith(_trackerKeyPrefix)) continue;

    final parts = entry.key.substring(_trackerKeyPrefix.length).split('_');
    if (parts.length != 4) continue;
    if (!obligatoryPrayerNames.contains(parts[3])) continue;

    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final day = int.tryParse(parts[2]);
    if (year == null || month == null || day == null) continue;

    perDay
        .putIfAbsent(DateTime(year, month, day), () => <String>{})
        .add(parts[3]);
  }

  return perDay;
}

/// Days on which all five obligatory prayers were ticked off.
///
/// Derived from the tracker rather than counted up in a separate field, so it
/// stays correct after a sync merge, a reset, or a prayer being un-ticked —
/// none of which a stored counter would survive.
Set<DateTime> completedDaysFrom(Map<String, bool> tracker) {
  return trackedPrayersByDay(tracker)
      .entries
      .where((e) => e.value.length == obligatoryPrayerNames.length)
      .map((e) => e.key)
      .toSet();
}

/// Consecutive complete days ending today.
///
/// An incomplete today does not break the streak — the day is not over yet,
/// it just does not count towards it. An incomplete yesterday does.
int currentStreakFrom(Set<DateTime> completedDays, DateTime logicalDate) {
  var day = DateTime(logicalDate.year, logicalDate.month, logicalDate.day);
  if (!completedDays.contains(day)) day = _previousDay(day);

  var streak = 0;
  while (completedDays.contains(day)) {
    streak++;
    day = _previousDay(day);
  }
  return streak;
}

/// Longest run of consecutive complete days ever recorded.
int longestStreakFrom(Set<DateTime> completedDays) {
  if (completedDays.isEmpty) return 0;

  final days = completedDays.toList()..sort();
  var longest = 1;
  var run = 1;

  for (var i = 1; i < days.length; i++) {
    run = days[i] == _nextDay(days[i - 1]) ? run + 1 : 1;
    if (run > longest) longest = run;
  }
  return longest;
}

/// Cached so the walk over the history happens once per tracker change.
///
/// The prayers screen rebuilds every second to drive its countdown; computing
/// this in the widget would re-scan the whole history on every tick.
final completedPrayerDaysProvider = Provider<Set<DateTime>>((ref) {
  return completedDaysFrom(ref.watch(prayerTrackerProvider));
});

final currentStreakProvider = Provider<int>((ref) {
  return currentStreakFrom(
    ref.watch(completedPrayerDaysProvider),
    ref.watch(logicalDateProvider),
  );
});

final longestStreakProvider = Provider<int>((ref) {
  return longestStreakFrom(ref.watch(completedPrayerDaysProvider));
});

/// Streak lengths worth celebrating.
const streakMilestones = [7, 30, 100, 365];

/// The milestone [streak] just reached, or null if it is not a milestone.
int? milestoneReachedAt(int streak) {
  return streakMilestones.contains(streak) ? streak : null;
}

// ---------------------------------------------------------------------------
// Statistics
// ---------------------------------------------------------------------------

/// How far back the per-prayer reliability figure looks.
const _statsWindowDays = 30;

/// Days of history needed before the weakest-prayer hint means anything.
const _statsMinDaysForHint = 7;

/// Everything the statistics card shows, all measured from the tracker.
class PrayerStats {
  final int currentStreak;
  final int longestStreak;

  /// Fully completed days among the last seven, today included.
  final int completeDaysLastWeek;

  /// Every obligatory prayer ever ticked off.
  final int totalPrayersLogged;

  /// Days with at least one prayer recorded.
  final int daysTracked;

  /// The prayer slipping most often lately, or null while there is too
  /// little history for the answer to mean anything.
  final String? weakestPrayer;

  const PrayerStats({
    required this.currentStreak,
    required this.longestStreak,
    required this.completeDaysLastWeek,
    required this.totalPrayersLogged,
    required this.daysTracked,
    required this.weakestPrayer,
  });

  bool get hasHistory => daysTracked > 0;
}

/// Measures the statistics card's figures from the raw tracker.
PrayerStats computePrayerStats({
  required Map<String, bool> tracker,
  required DateTime logicalDate,
}) {
  final perDay = trackedPrayersByDay(tracker);
  final completedDays = perDay.entries
      .where((e) => e.value.length == obligatoryPrayerNames.length)
      .map((e) => e.key)
      .toSet();

  final today = DateTime(logicalDate.year, logicalDate.month, logicalDate.day);

  var completeLastWeek = 0;
  for (var back = 0; back < 7; back++) {
    final day = DateTime(today.year, today.month, today.day - back);
    if (completedDays.contains(day)) completeLastWeek++;
  }

  var totalLogged = 0;
  for (final prayers in perDay.values) {
    totalLogged += prayers.length;
  }

  return PrayerStats(
    currentStreak: currentStreakFrom(completedDays, logicalDate),
    longestStreak: longestStreakFrom(completedDays),
    completeDaysLastWeek: completeLastWeek,
    totalPrayersLogged: totalLogged,
    daysTracked: perDay.length,
    weakestPrayer: _weakestPrayer(perDay, today),
  );
}

/// The prayer missed most often over the recent window.
///
/// Only days the user actually recorded something on are counted. Days the
/// app went untouched would add a miss to every prayer alike, which says
/// nothing about which one is slipping — and today is left out because it is
/// still in progress.
String? _weakestPrayer(Map<DateTime, Set<String>> perDay, DateTime today) {
  final windowStart = DateTime(
    today.year,
    today.month,
    today.day - _statsWindowDays,
  );

  final misses = {for (final prayer in obligatoryPrayerNames) prayer: 0};
  var daysConsidered = 0;

  for (final entry in perDay.entries) {
    final day = entry.key;
    if (!day.isAfter(windowStart)) continue;
    if (!day.isBefore(today)) continue;

    daysConsidered++;
    for (final prayer in obligatoryPrayerNames) {
      if (!entry.value.contains(prayer)) misses[prayer] = misses[prayer]! + 1;
    }
  }

  if (daysConsidered < _statsMinDaysForHint) return null;

  final worst = misses.entries.reduce((a, b) => b.value > a.value ? b : a);
  // Nothing missed at all is worth saying nothing about.
  return worst.value == 0 ? null : worst.key;
}

final prayerStatsProvider = Provider<PrayerStats>((ref) {
  return computePrayerStats(
    tracker: ref.watch(prayerTrackerProvider),
    logicalDate: ref.watch(logicalDateProvider),
  );
});

/// A finished day that has not been acknowledged with a celebration yet.
class PrayerDayCelebration {
  final String dateKey;
  final int completed;
  final int total;
  final int streak;

  /// Set when this day also closed a streak milestone.
  final int? milestone;

  const PrayerDayCelebration({
    required this.dateKey,
    required this.completed,
    required this.total,
    required this.streak,
    required this.milestone,
  });
}

/// Raises the daily and milestone celebrations for the whole app.
///
/// Prayers can be ticked off from the home card and from the prayers tab, so
/// a celebration owned by either screen is missed whenever the user finishes
/// the day on the other one. Milestones are reached once and never again, so
/// missing one is not recoverable.
///
/// Which day was last celebrated is persisted rather than tracked as a state
/// transition: a transition only exists in the widget that happened to be
/// mounted, and would fire a second time on the next launch.
class PrayerCelebrationNotifier extends Notifier<PrayerDayCelebration?> {
  static const prefsKey = 'celebrated_day';

  @override
  PrayerDayCelebration? build() {
    final completedDays = ref.watch(completedPrayerDaysProvider);
    final logicalDate = ref.watch(logicalDateProvider);

    final today = DateTime(
      logicalDate.year,
      logicalDate.month,
      logicalDate.day,
    );
    if (!completedDays.contains(today)) return null;

    final dateKey = '${today.year}_${today.month}_${today.day}';
    if (ref.read(sharedPreferencesProvider).getString(prefsKey) == dateKey) {
      return null;
    }

    final streak = currentStreakFrom(completedDays, logicalDate);
    return PrayerDayCelebration(
      dateKey: dateKey,
      // A day only counts as complete once every obligatory prayer is in.
      completed: obligatoryPrayerNames.length,
      total: obligatoryPrayerNames.length,
      streak: streak,
      milestone: milestoneReachedAt(streak),
    );
  }

  /// Records the pending celebration as shown so it does not return.
  void acknowledge() {
    final pending = state;
    if (pending == null) return;
    ref.read(sharedPreferencesProvider).setString(prefsKey, pending.dateKey);
    state = null;
  }
}

final prayerCelebrationProvider =
    NotifierProvider<PrayerCelebrationNotifier, PrayerDayCelebration?>(
      PrayerCelebrationNotifier.new,
    );
