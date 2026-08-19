import 'dart:math' as math;

import 'package:adhan_dart/adhan_dart.dart' as adhan;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/prayer.dart';

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

  /// ISO 3166-1 alpha-2, used to pick the prayer calculation method.
  /// Null when reverse geocoding was unavailable.
  final String? isoCountryCode;

  const LocationData({
    required this.lat,
    required this.lng,
    this.city = 'Standort',
    this.isoCountryCode,
  });

  static const fallback = LocationData(lat: 52.52, lng: 13.405, city: 'Berlin');
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

    /// A cached fix older than this is not trustworthy enough to drive prayer
    /// times — the user may have travelled a long way since it was recorded.
    const maxCachedFixAge = Duration(minutes: 2);

    Position? position;
    try {
      position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (_) {
      // Live fetch failed or timed out. A recent cached fix is acceptable,
      // but a stale one would silently produce wrong prayer times.
      final cached = await Geolocator.getLastKnownPosition();
      if (cached != null) {
        final age = DateTime.now().difference(cached.timestamp);
        if (age <= maxCachedFixAge) position = cached;
      }
    }

    if (position == null) {
      state = AsyncData(LocationData.fallback);
      throw Exception(
        'Kein aktueller Standort verfügbar. Bitte Stadt manuell suchen.',
      );
    }

    final place = await _resolvePlace(position.latitude, position.longitude);
    final data = LocationData(
      lat: position.latitude,
      lng: position.longitude,
      city: place.city,
      isoCountryCode: place.isoCountryCode,
    );

    await _persist(data);
    state = AsyncData(data);
    return data;
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

  /// Sets location explicitly, e.g. from manual city search.
  Future<void> setManual(LocationData data) async {
    await _persist(data);
    state = AsyncData(data);
  }

  Future<void> _persist(LocationData data) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setDouble('cached_lat', data.lat);
    await prefs.setDouble('cached_lng', data.lng);
    await prefs.setString('cached_city', data.city);
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
    return now.subtract(const Duration(days: 1));
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

enum MuezzinVoice { misharyAlafasy, makkahAdhan, silent }

class MuezzinVoiceNotifier extends Notifier<MuezzinVoice> {
  @override
  MuezzinVoice build() {
    final prefs = ref.read(sharedPreferencesProvider);
    final stored = prefs.getString('muezzin_voice');
    return MuezzinVoice.values.firstWhere(
      (v) => v.name == stored,
      orElse: () => MuezzinVoice.misharyAlafasy,
    );
  }

  void update(MuezzinVoice voice) {
    ref.read(sharedPreferencesProvider).setString('muezzin_voice', voice.name);
    state = voice;
  }
}

final muezzinVoiceProvider =
    NotifierProvider<MuezzinVoiceNotifier, MuezzinVoice>(
      MuezzinVoiceNotifier.new,
    );

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
final qiblaBearingProvider = Provider<double>((ref) {
  final locationAsync = ref.watch(locationProvider);
  final location = switch (locationAsync) {
    AsyncData(:final value) => value,
    _ => LocationData.fallback,
  };
  return calculateQiblaBearing(location);
});

double calculateQiblaBearing(LocationData location) {
  final bearing = adhan.Qibla.qibla(
    adhan.Coordinates(location.lat, location.lng),
  );
  return (bearing + 360) % 360;
}

/// Great-circle distance from user to the Kaaba, in km. Haversine.
final distanceToKaabaProvider = Provider<double>((ref) {
  final locationAsync = ref.watch(locationProvider);
  final location = switch (locationAsync) {
    AsyncData(:final value) => value,
    _ => LocationData.fallback,
  };
  return calculateDistanceToKaabaKm(location);
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

  int get currentStreak {
    int streak = 0;
    DateTime date = DateTime.now();
    final requiredPrayers = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

    // We can't cleanly access providers inside a simple method if we don't have ref
    // Wait, PrayerTrackerNotifier has `ref`!
    final logicalDate = ref.read(logicalDateProvider);
    date = logicalDate;

    while (true) {
      bool allCompleted = true;
      for (final p in requiredPrayers) {
        if (!isCompleted(date, p)) {
          allCompleted = false;
          break;
        }
      }
      if (allCompleted) {
        streak++;
        date = date.subtract(const Duration(days: 1));
      } else {
        if (streak == 0 && date.day == logicalDate.day) {
          date = date.subtract(const Duration(days: 1));
          continue;
        }
        break;
      }
    }
    return streak;
  }
}

final prayerTrackerProvider =
    NotifierProvider<PrayerTrackerNotifier, Map<String, bool>>(
      PrayerTrackerNotifier.new,
    );

// ---------------------------------------------------------------------------
// Daily Reminder (rotating)
// ---------------------------------------------------------------------------

const _reminders = [
  (
    title: 'Erinnere dich an Allah',
    subtitle: 'Sei beständig, auch in kleinen Taten.',
  ),
  (
    title: 'Bitte um Vergebung',
    subtitle: 'Istighfar reinigt das Herz und bringt inneren Frieden.',
  ),
  (
    title: 'Lies den Quran',
    subtitle: 'Jeder Buchstabe bringt dich Allah näher.',
  ),
  (
    title: 'Sei dankbar',
    subtitle: 'Wer dankbar ist, dem wird Allah mehr geben.',
  ),
  (title: 'Geduld ist Stärke', subtitle: 'Allah ist mit den Geduldigen.'),
  (
    title: 'Sprich Gutes',
    subtitle: 'Ein gutes Wort ist wie ein Baum mit festen Wurzeln.',
  ),
  (
    title: 'Vertraue auf Allah',
    subtitle: 'Tawakkul — plane, handle, und vertraue auf Sein Ergebnis.',
  ),
  (
    title: 'Hilf deinem Nächsten',
    subtitle: 'Wer einem Menschen hilft, dem hilft Allah.',
  ),
  (title: 'Sei demütig', subtitle: 'Demut erhöht den Rang bei Allah.'),
  (
    title: 'Gedenke des Todes',
    subtitle: 'Er erinnert uns an das, was wirklich zählt.',
  ),
  (
    title: 'Bete mit Hingabe',
    subtitle: 'Das Gebet ist die Säule des Glaubens.',
  ),
  (
    title: 'Gib Sadaqa',
    subtitle: 'Jede Spende löscht Sünden wie Wasser Feuer löscht.',
  ),
  (
    title: 'Kontrolliere deinen Zorn',
    subtitle: 'Der Starke ist nicht der Ringer, sondern wer sich beherrscht.',
  ),
  (
    title: 'Bewahre deine Zunge',
    subtitle: 'Schweigen ist Gold — besonders wenn Worte verletzen.',
  ),
  (
    title: 'Pflege die Verwandtschaft',
    subtitle: 'Silat ar-Rahim bringt Segen ins Leben.',
  ),
  (
    title: 'Strebe nach Wissen',
    subtitle: 'Wissen zu suchen ist Pflicht für jeden Muslim.',
  ),
  (
    title: 'Sende Segen auf den Propheten',
    subtitle: 'Allahumma salli ala Muhammad — jeden Tag.',
  ),
  (
    title: 'Dhikr beruhigt das Herz',
    subtitle: 'Im Gedenken an Allah finden die Herzen Ruhe.',
  ),
  (
    title: 'Verzeihe anderen',
    subtitle: 'Verzeihung befreit dein Herz mehr als das des anderen.',
  ),
  (
    title: 'Nutze deine Zeit',
    subtitle: 'Jede Minute ist ein Geschenk — investiere sie weise.',
  ),
  (
    title: 'Beginne mit Bismillah',
    subtitle: 'Im Namen Allahs — lass alles gesegnet beginnen.',
  ),
  (title: 'Mache Dua', subtitle: 'Dua ist die Waffe des Gläubigen.'),
  (
    title: 'Halte deine Versprechen',
    subtitle: 'Treue zum Wort ist ein Zeichen des Imans.',
  ),
  (title: 'Sei aufrichtig', subtitle: 'Ikhlas — handle nur um Allahs willen.'),
  (
    title: 'Besuche die Kranken',
    subtitle: 'Es ist ein Recht des Muslims auf seinen Bruder.',
  ),
  (title: 'Lächle', subtitle: 'Ein Lächeln ist Sadaqa.'),
  (
    title: 'Meide das Verbotene',
    subtitle: 'Was haram ist, schadet — auch wenn es kurzfristig reizt.',
  ),
  (
    title: 'Stehe in der Nacht auf',
    subtitle: 'Qiyam al-Layl — die beste Zeit für Dua.',
  ),
  (
    title: 'Reinige deine Absicht',
    subtitle: 'Taten werden nach Absichten beurteilt.',
  ),
  (
    title: 'Verbreite den Salam',
    subtitle: 'Assalamu alaikum — Frieden sei mit dir.',
  ),
];

final dailyReminderProvider = Provider<({String title, String subtitle})>((
  ref,
) {
  final dayOfYear = DateTime.now()
      .difference(DateTime(DateTime.now().year, 1, 1))
      .inDays;
  return _reminders[dayOfYear % _reminders.length];
});
