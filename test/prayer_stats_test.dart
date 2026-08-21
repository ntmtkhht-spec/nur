import 'package:flutter_test/flutter_test.dart';
import 'package:munir/core/providers/providers.dart';

DateTime dayBefore(DateTime today, int back) =>
    DateTime(today.year, today.month, today.day - back);

/// Tracker entries for [prayers] on [day]; defaults to a fully complete day.
Map<String, bool> entries(DateTime day, {Iterable<String>? prayers}) {
  return {
    for (final prayer in prayers ?? obligatoryPrayerNames)
      'prayer_tracker_${day.year}_${day.month}_${day.day}_$prayer': true,
  };
}

void main() {
  final today = DateTime(2026, 8, 20);

  group('computePrayerStats', () {
    test('reports nothing to show on an untouched tracker', () {
      final stats = computePrayerStats(tracker: const {}, logicalDate: today);

      expect(stats.hasHistory, isFalse);
      expect(stats.currentStreak, 0);
      expect(stats.longestStreak, 0);
      expect(stats.completeDaysLastWeek, 0);
      expect(stats.totalPrayersLogged, 0);
      expect(stats.weakestPrayer, isNull);
    });

    test('counts every logged prayer, not only complete days', () {
      final tracker = {
        ...entries(today, prayers: ['Fajr', 'Dhuhr']),
        ...entries(dayBefore(today, 1)),
      };

      final stats = computePrayerStats(tracker: tracker, logicalDate: today);

      expect(stats.totalPrayersLogged, 7);
      expect(stats.daysTracked, 2);
    });

    test('sunrise never counts towards the total', () {
      final tracker = entries(today, prayers: ['Fajr', 'Sunrise']);

      final stats = computePrayerStats(tracker: tracker, logicalDate: today);

      expect(stats.totalPrayersLogged, 1);
    });

    test('the weekly figure counts complete days in the last seven', () {
      final tracker = {
        ...entries(today),
        ...entries(dayBefore(today, 2)),
        ...entries(dayBefore(today, 6)),
        // Outside the window.
        ...entries(dayBefore(today, 9)),
        // Inside the window but unfinished.
        ...entries(dayBefore(today, 3), prayers: ['Fajr']),
      };

      final stats = computePrayerStats(tracker: tracker, logicalDate: today);

      expect(stats.completeDaysLastWeek, 3);
    });

    test('streaks match the dedicated streak helpers', () {
      final tracker = {
        for (var back = 0; back < 4; back++) ...entries(dayBefore(today, back)),
      };

      final stats = computePrayerStats(tracker: tracker, logicalDate: today);

      expect(stats.currentStreak, 4);
      expect(stats.longestStreak, 4);
    });
  });

  group('weakest prayer', () {
    test('stays silent below a week of history', () {
      final tracker = {
        for (var back = 1; back <= 5; back++)
          ...entries(dayBefore(today, back), prayers: ['Dhuhr', 'Asr']),
      };

      final stats = computePrayerStats(tracker: tracker, logicalDate: today);

      expect(stats.weakestPrayer, isNull);
    });

    test('names the prayer missed most often', () {
      final tracker = <String, bool>{};
      for (var back = 1; back <= 10; back++) {
        // Everything except Fajr, which slips every single day.
        tracker.addAll(
          entries(
            dayBefore(today, back),
            prayers: ['Dhuhr', 'Asr', 'Maghrib', 'Isha'],
          ),
        );
      }

      final stats = computePrayerStats(tracker: tracker, logicalDate: today);

      expect(stats.weakestPrayer, 'Fajr');
    });

    test('stays silent when nothing was missed', () {
      final tracker = <String, bool>{};
      for (var back = 1; back <= 10; back++) {
        tracker.addAll(entries(dayBefore(today, back)));
      }

      final stats = computePrayerStats(tracker: tracker, logicalDate: today);

      expect(stats.weakestPrayer, isNull);
    });

    test('ignores today, which is still in progress', () {
      final tracker = <String, bool>{};
      // Ten complete days behind us…
      for (var back = 1; back <= 10; back++) {
        tracker.addAll(entries(dayBefore(today, back)));
      }
      // …and a today that has only just started.
      tracker.addAll(entries(today, prayers: ['Fajr']));

      final stats = computePrayerStats(tracker: tracker, logicalDate: today);

      expect(stats.weakestPrayer, isNull);
    });

    test('ignores days older than the window', () {
      final tracker = <String, bool>{};
      // Long ago, Fajr was always missed…
      for (var back = 40; back <= 60; back++) {
        tracker.addAll(
          entries(
            dayBefore(today, back),
            prayers: ['Dhuhr', 'Asr', 'Maghrib', 'Isha'],
          ),
        );
      }
      // …but recently everything is on time.
      for (var back = 1; back <= 10; back++) {
        tracker.addAll(entries(dayBefore(today, back)));
      }

      final stats = computePrayerStats(tracker: tracker, logicalDate: today);

      expect(stats.weakestPrayer, isNull);
    });
  });
}
