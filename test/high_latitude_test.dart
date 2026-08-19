import 'package:adhan_dart/adhan_dart.dart' as adhan;
import 'package:flutter_test/flutter_test.dart';
import 'package:munir/core/models/prayer.dart';
import 'package:munir/core/providers/providers.dart';

/// Berlin in July is the pathological case: at 52.5°N the sun never descends
/// 18° below the horizon, so MWL's Fajr/Isha angles are unreachable and both
/// times must come from the high-latitude fallback rule. A regression here
/// silently produces prayer times that are hours wrong.
void main() {
  const berlin = LocationData(lat: 52.52, lng: 13.405, city: 'Berlin');

  /// Local wall-clock minutes since midnight, for a fixed UTC offset.
  int localMinutes(DateTime t, int tzOffsetHours) {
    final l = t.toUtc().add(Duration(hours: tzOffsetHours));
    return l.hour * 60 + l.minute;
  }

  PrayerTime pick(List<PrayerTime> times, String name) =>
      times.firstWhere((p) => p.name == name);

  test('Berlin in July yields plausible Fajr and Isha', () {
    final times = computePrayerTimes(
      location: berlin,
      method: adhan.CalculationMethod.muslimWorldLeague,
      madhab: adhan.Madhab.shafi,
      date: DateTime(2026, 7, 26, 12),
      includeSunrise: true,
    );

    const cest = 2;
    final fajr = localMinutes(pick(times, 'Fajr').time, cest);
    final sunrise = localMinutes(pick(times, 'Sonnenaufgang').time, cest);
    final isha = localMinutes(pick(times, 'Isha').time, cest);

    // Published Berlin timetables for late July put Fajr near 02:50 and Isha
    // near 23:30. Assert a tolerant window around those rather than exact
    // values, so legitimate method tweaks don't fail the test.
    expect(fajr, inInclusiveRange(2 * 60, 4 * 60),
        reason: 'Fajr should fall between 02:00 and 04:00 local');
    expect(isha, inInclusiveRange(22 * 60, 23 * 60 + 59),
        reason: 'Isha should fall before midnight, not spill into the next day');

    // Ordering must hold, otherwise "next prayer" logic breaks.
    expect(fajr, lessThan(sunrise), reason: 'Fajr must precede sunrise');
    expect(isha, greaterThan(localMinutes(pick(times, 'Maghrib').time, cest)),
        reason: 'Isha must follow Maghrib');
  });

  test('low latitudes are unaffected by the high-latitude rule', () {
    // Where the true angle is reachable the rule is inert, so Makkah must be
    // identical regardless of which rule the app selects.
    const makkah = LocationData(lat: 21.42, lng: 39.83, city: 'Makkah');
    final viaApp = computePrayerTimes(
      location: makkah,
      method: adhan.CalculationMethod.ummAlQura,
      madhab: adhan.Madhab.shafi,
      date: DateTime(2026, 7, 26, 12),
    );

    final params = adhan.CalculationMethodParameters.ummAlQura();
    params.madhab = adhan.Madhab.shafi;
    params.highLatitudeRule = adhan.HighLatitudeRule.middleOfTheNight;
    final reference = adhan.PrayerTimes(
      date: DateTime(2026, 7, 26, 12),
      coordinates: adhan.Coordinates(makkah.lat, makkah.lng),
      calculationParameters: params,
    );

    expect(pick(viaApp, 'Fajr').time, reference.fajr.toLocal());
    expect(pick(viaApp, 'Isha').time, reference.isha.toLocal());
  });

  test('prayer times are returned in local time, not UTC', () {
    final times = computePrayerTimes(
      location: berlin,
      method: adhan.CalculationMethod.muslimWorldLeague,
      madhab: adhan.Madhab.shafi,
      date: DateTime(2026, 7, 26, 12),
    );

    for (final p in times) {
      expect(p.time.isUtc, isFalse,
          reason: '${p.name} must be converted via toLocal() before display');
    }
  });
}
