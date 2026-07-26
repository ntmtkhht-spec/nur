import 'dart:convert';

import 'package:adhan_dart/adhan_dart.dart' as adhan;
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
// User
// ---------------------------------------------------------------------------

class UserNameNotifier extends Notifier<String> {
  @override
  String build() {
    final prefs = ref.read(sharedPreferencesProvider);
    return prefs.getString('user_name') ?? 'Mohammed';
  }

  void update(String name) {
    ref.read(sharedPreferencesProvider).setString('user_name', name);
    state = name;
  }
}

final userNameProvider =
    NotifierProvider<UserNameNotifier, String>(UserNameNotifier.new);

// ---------------------------------------------------------------------------
// Location
// ---------------------------------------------------------------------------

class LocationData {
  final double lat;
  final double lng;
  final String city;

  const LocationData({
    required this.lat,
    required this.lng,
    this.city = 'Standort',
  });

  static const fallback = LocationData(
    lat: 52.52,
    lng: 13.405,
    city: 'Berlin',
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
      _refreshGpsInBackground();
      return LocationData(lat: cachedLat, lng: cachedLng, city: cachedCity);
    }

    return _fetchFromGps();
  }

  Future<LocationData> _fetchFromGps() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return LocationData.fallback;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          return LocationData.fallback;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        return LocationData.fallback;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.low),
      );

      final data = LocationData(
        lat: position.latitude,
        lng: position.longitude,
      );

      final prefs = ref.read(sharedPreferencesProvider);
      await prefs.setDouble('cached_lat', data.lat);
      await prefs.setDouble('cached_lng', data.lng);

      return data;
    } catch (_) {
      return LocationData.fallback;
    }
  }

  Future<void> _refreshGpsInBackground() async {
    try {
      final data = await _fetchFromGps();
      state = AsyncData(data);
    } catch (_) {
      // keep cached
    }
  }
}

final locationProvider =
    AsyncNotifierProvider<LocationNotifier, LocationData>(LocationNotifier.new);

// ---------------------------------------------------------------------------
// Prayer Times (real calculation)
// ---------------------------------------------------------------------------

final prayerTimesProvider = Provider<List<PrayerTime>>((ref) {
  final locationAsync = ref.watch(locationProvider);
  final location = switch (locationAsync) {
    AsyncData(:final value) => value,
    _ => LocationData.fallback,
  };

  final coords = adhan.Coordinates(location.lat, location.lng);
  final params = adhan.CalculationMethodParameters.muslimWorldLeague();
  params.madhab = adhan.Madhab.hanafi;

  final now = DateTime.now();
  final pt = adhan.PrayerTimes(
    date: now,
    coordinates: coords,
    calculationParameters: params,
  );

  return [
    PrayerTime(
      name: 'Fajr',
      arabicName: 'الفجر',
      time: pt.fajr,
    ),
    PrayerTime(
      name: 'Dhuhr',
      arabicName: 'الظهر',
      time: pt.dhuhr,
    ),
    PrayerTime(
      name: 'Asr',
      arabicName: 'العصر',
      time: pt.asr,
    ),
    PrayerTime(
      name: 'Maghrib',
      arabicName: 'المغرب',
      time: pt.maghrib,
    ),
    PrayerTime(
      name: 'Isha',
      arabicName: 'العشاء',
      time: pt.isha,
    ),
  ];
});

final nextPrayerIndexProvider = Provider<int>((ref) {
  final prayers = ref.watch(prayerTimesProvider);
  final now = DateTime.now();
  for (var i = 0; i < prayers.length; i++) {
    if (prayers[i].time.isAfter(now)) return i;
  }
  return 0;
});

// ---------------------------------------------------------------------------
// Hijri Date
// ---------------------------------------------------------------------------

final hijriDateProvider = Provider<String>((ref) {
  HijriCalendar.setLocal('ar');
  final hijri = HijriCalendar.now();

  const monthNamesDE = {
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

  final monthName = monthNamesDE[hijri.hMonth] ?? hijri.longMonthName;
  return '${hijri.hDay} $monthName ${hijri.hYear}';
});

// ---------------------------------------------------------------------------
// Prayer Tracker (persistent)
// ---------------------------------------------------------------------------

class CompletedPrayersNotifier extends Notifier<Set<String>> {
  String get _todayKey =>
      'prayers_${DateTime.now().toIso8601String().substring(0, 10)}';

  @override
  Set<String> build() {
    final prefs = ref.read(sharedPreferencesProvider);
    final stored = prefs.getString(_todayKey);
    if (stored != null) {
      return (jsonDecode(stored) as List).cast<String>().toSet();
    }
    return {};
  }

  void toggle(String prayerName) {
    final updated = {...state};
    if (updated.contains(prayerName)) {
      updated.remove(prayerName);
    } else {
      updated.add(prayerName);
    }
    state = updated;

    final prefs = ref.read(sharedPreferencesProvider);
    prefs.setString(_todayKey, jsonEncode(updated.toList()));
  }
}

final completedPrayersProvider =
    NotifierProvider<CompletedPrayersNotifier, Set<String>>(
  CompletedPrayersNotifier.new,
);

// ---------------------------------------------------------------------------
// Daily Reminder (rotating)
// ---------------------------------------------------------------------------

const _reminders = [
  (
    title: 'Erinnere dich an Allah',
    subtitle: 'Sei beständig, auch in kleinen Taten.'
  ),
  (
    title: 'Bitte um Vergebung',
    subtitle: 'Istighfar reinigt das Herz und bringt inneren Frieden.'
  ),
  (
    title: 'Lies den Quran',
    subtitle: 'Jeder Buchstabe bringt dich Allah näher.'
  ),
  (
    title: 'Sei dankbar',
    subtitle: 'Wer dankbar ist, dem wird Allah mehr geben.'
  ),
  (
    title: 'Geduld ist Stärke',
    subtitle: 'Allah ist mit den Geduldigen.'
  ),
  (
    title: 'Sprich Gutes',
    subtitle: 'Ein gutes Wort ist wie ein Baum mit festen Wurzeln.'
  ),
  (
    title: 'Vertraue auf Allah',
    subtitle: 'Tawakkul — plane, handle, und vertraue auf Sein Ergebnis.'
  ),
  (
    title: 'Hilf deinem Nächsten',
    subtitle: 'Wer einem Menschen hilft, dem hilft Allah.'
  ),
  (
    title: 'Sei demütig',
    subtitle: 'Demut erhöht den Rang bei Allah.'
  ),
  (
    title: 'Gedenke des Todes',
    subtitle: 'Er erinnert uns an das, was wirklich zählt.'
  ),
  (
    title: 'Bete mit Hingabe',
    subtitle: 'Das Gebet ist die Säule des Glaubens.'
  ),
  (
    title: 'Gib Sadaqa',
    subtitle: 'Jede Spende löscht Sünden wie Wasser Feuer löscht.'
  ),
  (
    title: 'Kontrolliere deinen Zorn',
    subtitle: 'Der Starke ist nicht der Ringer, sondern wer sich beherrscht.'
  ),
  (
    title: 'Bewahre deine Zunge',
    subtitle: 'Schweigen ist Gold — besonders wenn Worte verletzen.'
  ),
  (
    title: 'Pflege die Verwandtschaft',
    subtitle: 'Silat ar-Rahim bringt Segen ins Leben.'
  ),
  (
    title: 'Strebe nach Wissen',
    subtitle: 'Wissen zu suchen ist Pflicht für jeden Muslim.'
  ),
  (
    title: 'Sende Segen auf den Propheten',
    subtitle: 'Allahumma salli ala Muhammad — jeden Tag.'
  ),
  (
    title: 'Dhikr beruhigt das Herz',
    subtitle: 'Im Gedenken an Allah finden die Herzen Ruhe.'
  ),
  (
    title: 'Verzeihe anderen',
    subtitle: 'Verzeihung befreit dein Herz mehr als das des anderen.'
  ),
  (
    title: 'Nutze deine Zeit',
    subtitle: 'Jede Minute ist ein Geschenk — investiere sie weise.'
  ),
  (
    title: 'Beginne mit Bismillah',
    subtitle: 'Im Namen Allahs — lass alles gesegnet beginnen.'
  ),
  (
    title: 'Mache Dua',
    subtitle: 'Dua ist die Waffe des Gläubigen.'
  ),
  (
    title: 'Halte deine Versprechen',
    subtitle: 'Treue zum Wort ist ein Zeichen des Imans.'
  ),
  (
    title: 'Sei aufrichtig',
    subtitle: 'Ikhlas — handle nur um Allahs willen.'
  ),
  (
    title: 'Besuche die Kranken',
    subtitle: 'Es ist ein Recht des Muslims auf seinen Bruder.'
  ),
  (
    title: 'Lächle',
    subtitle: 'Ein Lächeln ist Sadaqa.'
  ),
  (
    title: 'Meide das Verbotene',
    subtitle: 'Was haram ist, schadet — auch wenn es kurzfristig reizt.'
  ),
  (
    title: 'Stehe in der Nacht auf',
    subtitle: 'Qiyam al-Layl — die beste Zeit für Dua.'
  ),
  (
    title: 'Reinige deine Absicht',
    subtitle: 'Taten werden nach Absichten beurteilt.'
  ),
  (
    title: 'Verbreite den Salam',
    subtitle: 'Assalamu alaikum — Frieden sei mit dir.'
  ),
];

final dailyReminderProvider =
    Provider<({String title, String subtitle})>((ref) {
  final dayOfYear = DateTime.now()
      .difference(DateTime(DateTime.now().year, 1, 1))
      .inDays;
  return _reminders[dayOfYear % _reminders.length];
});
