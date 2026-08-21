import 'package:flutter_test/flutter_test.dart';
import 'package:munir/core/providers/providers.dart';

/// Builds the flat tracker map the notifier stores in SharedPreferences.
Map<String, bool> trackerFor(
  List<DateTime> completeDays, {
  Map<DateTime, List<String>> partialDays = const {},
}) {
  final tracker = <String, bool>{};

  void put(DateTime day, String prayer) {
    tracker['prayer_tracker_${day.year}_${day.month}_${day.day}_$prayer'] =
        true;
  }

  for (final day in completeDays) {
    for (final prayer in obligatoryPrayerNames) {
      put(day, prayer);
    }
  }
  partialDays.forEach((day, prayers) {
    for (final prayer in prayers) {
      put(day, prayer);
    }
  });

  return tracker;
}

void main() {
  group('completedDaysFrom', () {
    test('counts a day only once all five obligatory prayers are ticked', () {
      final day = DateTime(2026, 8, 20);

      final partial = completedDaysFrom(
        trackerFor([], partialDays: {
          day: ['Fajr', 'Dhuhr', 'Asr', 'Maghrib'],
        }),
      );
      expect(partial, isEmpty);

      expect(completedDaysFrom(trackerFor([day])), {day});
    });

    test('sunrise does not substitute for a missing prayer', () {
      final day = DateTime(2026, 8, 20);

      final tracker = trackerFor([], partialDays: {
        day: ['Fajr', 'Sunrise', 'Dhuhr', 'Asr', 'Maghrib'],
      });

      expect(completedDaysFrom(tracker), isEmpty);
    });

    test('ignores unticked entries and foreign keys', () {
      final day = DateTime(2026, 8, 20);
      final tracker = trackerFor([day])
        ..['prayer_tracker_2026_8_19_Fajr'] = false
        ..['some_other_setting'] = true;

      expect(completedDaysFrom(tracker), {day});
    });
  });

  group('currentStreakFrom', () {
    test('counts consecutive complete days ending today', () {
      final days = [
        DateTime(2026, 8, 18),
        DateTime(2026, 8, 19),
        DateTime(2026, 8, 20),
      ];

      final streak = currentStreakFrom(
        completedDaysFrom(trackerFor(days)),
        DateTime(2026, 8, 20, 14, 30),
      );

      expect(streak, 3);
    });

    test('an unfinished today does not break the streak', () {
      final days = [DateTime(2026, 8, 18), DateTime(2026, 8, 19)];

      final streak = currentStreakFrom(
        completedDaysFrom(trackerFor(days)),
        DateTime(2026, 8, 20, 9, 0),
      );

      expect(streak, 2);
    });

    test('a missed yesterday does break it', () {
      final days = [DateTime(2026, 8, 17), DateTime(2026, 8, 18)];

      final streak = currentStreakFrom(
        completedDaysFrom(trackerFor(days)),
        DateTime(2026, 8, 20),
      );

      expect(streak, 0);
    });

    test('no history is a streak of zero, not a hang', () {
      expect(currentStreakFrom(const {}, DateTime(2026, 8, 20)), 0);
    });

    test('walks across a month boundary', () {
      final days = [
        DateTime(2026, 7, 30),
        DateTime(2026, 7, 31),
        DateTime(2026, 8, 1),
      ];

      final streak = currentStreakFrom(
        completedDaysFrom(trackerFor(days)),
        DateTime(2026, 8, 1),
      );

      expect(streak, 3);
    });

    test('walks across a year boundary', () {
      final days = [
        DateTime(2025, 12, 31),
        DateTime(2026, 1, 1),
      ];

      final streak = currentStreakFrom(
        completedDaysFrom(trackerFor(days)),
        DateTime(2026, 1, 1),
      );

      expect(streak, 2);
    });

    test('walks across a daylight-saving change', () {
      // German clocks go forward on the last Sunday in March; a plain
      // 24-hour subtraction can skip or repeat a calendar day here.
      final days = [
        DateTime(2026, 3, 28),
        DateTime(2026, 3, 29),
        DateTime(2026, 3, 30),
      ];

      final streak = currentStreakFrom(
        completedDaysFrom(trackerFor(days)),
        DateTime(2026, 3, 30, 3, 30),
      );

      expect(streak, 3);
    });
  });

  group('longestStreakFrom', () {
    test('is zero without history', () {
      expect(longestStreakFrom(const {}), 0);
    });

    test('finds the longest run, not the most recent one', () {
      final days = [
        // A four day run…
        DateTime(2026, 8, 1),
        DateTime(2026, 8, 2),
        DateTime(2026, 8, 3),
        DateTime(2026, 8, 4),
        // …a gap, then a shorter, more recent one.
        DateTime(2026, 8, 10),
        DateTime(2026, 8, 11),
      ];

      expect(longestStreakFrom(completedDaysFrom(trackerFor(days))), 4);
    });

    test('a single complete day is a streak of one', () {
      final days = [DateTime(2026, 8, 20)];

      expect(longestStreakFrom(completedDaysFrom(trackerFor(days))), 1);
    });
  });

  group('milestoneReachedAt', () {
    test('fires only on exact milestone lengths', () {
      expect(milestoneReachedAt(7), 7);
      expect(milestoneReachedAt(30), 30);
      expect(milestoneReachedAt(100), 100);
      expect(milestoneReachedAt(365), 365);
    });

    test('stays quiet in between', () {
      expect(milestoneReachedAt(0), isNull);
      expect(milestoneReachedAt(6), isNull);
      expect(milestoneReachedAt(8), isNull);
      expect(milestoneReachedAt(101), isNull);
    });
  });
}
