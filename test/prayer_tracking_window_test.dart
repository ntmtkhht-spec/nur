import 'package:flutter_test/flutter_test.dart';
import 'package:munir/core/models/prayer.dart';
import 'package:munir/features/prayers/prayers_screen.dart';

PrayerTime prayerAt(String name, DateTime time, {bool isPrayer = true}) {
  return PrayerTime(name: name, arabicName: '', time: time, isPrayer: isPrayer);
}

void main() {
  final day = DateTime(2026, 8, 26);
  final now = DateTime(2026, 8, 26, 21, 30);

  group('canTrackPrayer', () {
    test('a prayer whose time has passed today can be ticked off', () {
      expect(
        canTrackPrayer(
          prayer: prayerAt('Maghrib', DateTime(2026, 8, 26, 20, 15)),
          isSelectedDayToday: true,
          now: now,
        ),
        isTrue,
      );
    });

    test('the prayer currently in its window can be ticked off', () {
      // Isha started an hour ago and stays the current prayer for the rest of
      // the evening. Keying off "before the active prayer" made it the one
      // prayer of the day that could never be recorded from this screen.
      expect(
        canTrackPrayer(
          prayer: prayerAt('Isha', DateTime(2026, 8, 26, 20, 30)),
          isSelectedDayToday: true,
          now: now,
        ),
        isTrue,
      );
    });

    test('a prayer still ahead today cannot be ticked off', () {
      expect(
        canTrackPrayer(
          prayer: prayerAt('Isha', DateTime(2026, 8, 26, 22, 45)),
          isSelectedDayToday: true,
          now: now,
        ),
        isFalse,
      );
    });

    test('every prayer of an earlier day can be ticked off', () {
      for (final time in [
        DateTime(2026, 8, 25, 5, 0),
        DateTime(2026, 8, 25, 22, 45),
      ]) {
        expect(
          canTrackPrayer(
            prayer: prayerAt('Isha', time),
            isSelectedDayToday: false,
            now: now,
          ),
          isTrue,
        );
      }
    });

    test('sunrise is never trackable', () {
      expect(
        canTrackPrayer(
          prayer: prayerAt(
            'Sonnenaufgang',
            DateTime(2026, 8, 26, 6, 20),
            isPrayer: false,
          ),
          isSelectedDayToday: true,
          now: now,
        ),
        isFalse,
      );
      expect(
        canTrackPrayer(
          prayer: prayerAt('Sonnenaufgang', day, isPrayer: false),
          isSelectedDayToday: false,
          now: now,
        ),
        isFalse,
      );
    });
  });
}
