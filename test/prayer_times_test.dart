import 'package:adhan_dart/adhan_dart.dart' as adhan;
import 'package:flutter_test/flutter_test.dart';
import 'package:munir/core/providers/providers.dart';

void main() {
  group('Prayer Times Logic Tests', () {
    // Oldenburg coordinates (approx. 53.14 N, 8.21 E)
    final oldenburg = LocationData(
      lat: 53.1439,
      lng: 8.2139,
      city: 'Oldenburg',
    );

    test('High Latitude Summer (Germany)', () {
      // June 1st in Germany (High latitude, midnight rule)
      final summerDate = DateTime(2026, 6, 1, 12);

      final prayers = computePrayerTimes(
        location: oldenburg,
        method: adhan.CalculationMethod.muslimWorldLeague,
        madhab: adhan.Madhab.hanafi,
        date: summerDate,
      );

      final fajr = prayers.firstWhere((p) => p.name == 'Fajr');

      // Without high latitude rule, fajr would wrap around to 23:00+ or be null.
      // With the rule, Fajr should be around 2-3 AM in summer.
      expect(fajr.time.hour, greaterThanOrEqualTo(1));
      expect(fajr.time.hour, lessThan(4));
    });

    test('Midnight boundary check', () {
      // Test that after Isha, the logical date calculation handles tomorrow properly.
      // E.g. at 23:30, the "next prayer" should be Fajr of tomorrow.
      // This is tested in Provider logic, but we can verify computePrayerTimes can fetch tomorrow easily.
      final date = DateTime(2026, 6, 1, 23, 30);
      final tomorrow = date.add(const Duration(days: 1));

      final prayers = computePrayerTimes(
        location: oldenburg,
        method: adhan.CalculationMethod.muslimWorldLeague,
        madhab: adhan.Madhab.hanafi,
        date: tomorrow,
      );

      final nextFajr = prayers.firstWhere((p) => p.name == 'Fajr');
      expect(nextFajr.time.day, equals(tomorrow.day));
      expect(nextFajr.time.isAfter(date), isTrue);
    });

    test('DST Switches (Winter to Summer)', () {
      // Last Sunday in March: March 29, 2026
      // Time jumps from 02:00 -> 03:00
      final dstDate = DateTime(2026, 3, 29, 12);

      final prayers = computePrayerTimes(
        location: oldenburg,
        method: adhan.CalculationMethod.muslimWorldLeague,
        madhab: adhan.Madhab.hanafi,
        date: dstDate,
      );

      // Ensure it calculates properly without crashing.
      expect(prayers.length, equals(5));
      expect(prayers.firstWhere((p) => p.name == 'Dhuhr').time.hour, isNotNull);
    });

    test('DST Switches (Summer to Winter)', () {
      // Last Sunday in October: October 25, 2026
      // Time jumps from 03:00 -> 02:00
      final dstDate = DateTime(2026, 10, 25, 12);

      final prayers = computePrayerTimes(
        location: oldenburg,
        method: adhan.CalculationMethod.muslimWorldLeague,
        madhab: adhan.Madhab.hanafi,
        date: dstDate,
      );

      expect(prayers.length, equals(5));
      expect(prayers.firstWhere((p) => p.name == 'Dhuhr').time.hour, isNotNull);
    });
  });
}
