import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:munir/core/providers/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ProviderContainer> containerWith(Map<String, Object> values) async {
  SharedPreferences.setMockInitialValues(values);
  final prefs = await SharedPreferences.getInstance();

  final container = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  group('parseTrackerKey', () {
    test('splits a well-formed key into its day and prayer', () {
      final parsed = parseTrackerKey('prayer_tracker_2026_8_25_Fajr');

      expect(parsed, isNotNull);
      expect(parsed!.day, DateTime(2026, 8, 25));
      expect(parsed.prayer, 'Fajr');
    });

    test('rejects a date that never existed', () {
      // DateTime(2026, 13, 1) silently becomes January 2027, and
      // DateTime(2026, 2, 30) becomes March. Accepting these would file an
      // entry under a day other than the one its key reads as.
      expect(parseTrackerKey('prayer_tracker_2026_13_1_Fajr'), isNull);
      expect(parseTrackerKey('prayer_tracker_2026_2_30_Fajr'), isNull);
      expect(parseTrackerKey('prayer_tracker_2026_0_10_Fajr'), isNull);
    });

    test('rejects anything that is not a tracker key', () {
      for (final key in [
        'user_name',
        'prayer_tracker_2026_8_25',
        'prayer_tracker_2026_8_25_Fajr_extra',
        'prayer_tracker_2026_8_25_Sonnenaufgang',
        'prayer_tracker_x_8_25_Fajr',
        'prayer_tracker_',
      ]) {
        expect(parseTrackerKey(key), isNull, reason: key);
      }
    });

    test('accepts a leap day and rejects one in a common year', () {
      expect(parseTrackerKey('prayer_tracker_2028_2_29_Isha'), isNotNull);
      expect(parseTrackerKey('prayer_tracker_2026_2_29_Isha'), isNull);
    });
  });

  group('PrayerTrackerNotifier.mergeRemote', () {
    test('takes a valid remote entry the device does not have', () async {
      final container = await containerWith({});

      container.read(prayerTrackerProvider.notifier).mergeRemote({
        'prayer_tracker_2026_8_25_Fajr': true,
      });

      expect(
        container.read(prayerTrackerProvider)['prayer_tracker_2026_8_25_Fajr'],
        isTrue,
      );
    });

    test('never un-ticks something recorded locally', () async {
      final container = await containerWith({
        'prayer_tracker_2026_8_25_Fajr': true,
      });

      container.read(prayerTrackerProvider.notifier).mergeRemote({
        'prayer_tracker_2026_8_25_Fajr': false,
      });

      expect(
        container.read(prayerTrackerProvider)['prayer_tracker_2026_8_25_Fajr'],
        isTrue,
      );
    });

    test('drops keys that do not parse instead of storing them', () async {
      // The remote document is only as well-formed as whatever last wrote to
      // it. A prefix check alone would copy these into SharedPreferences,
      // where they would sit forever counting towards nothing.
      final container = await containerWith({});

      container.read(prayerTrackerProvider.notifier).mergeRemote({
        'prayer_tracker_2026_13_40_Fajr': true,
        'prayer_tracker_junk': true,
        'prayer_tracker_2026_8_25_Sonnenaufgang': true,
        'unrelated_key': true,
      });

      expect(container.read(prayerTrackerProvider), isEmpty);
    });

    test('a merged junk-free document leaves the statistics intact', () async {
      final container = await containerWith({});

      container.read(prayerTrackerProvider.notifier).mergeRemote({
        for (final prayer in obligatoryPrayerNames)
          'prayer_tracker_2026_8_25_$prayer': true,
        'prayer_tracker_2026_99_99_Fajr': true,
      });

      final stats = computePrayerStats(
        tracker: container.read(prayerTrackerProvider),
        logicalDate: DateTime(2026, 8, 25),
      );

      expect(stats.totalPrayersLogged, obligatoryPrayerNames.length);
      expect(stats.daysTracked, 1);
    });
  });

  group('UserNameNotifier.update', () {
    test('trims what it stores', () async {
      final container = await containerWith({});

      container.read(userNameProvider.notifier).update('  Mouhmad  ');

      expect(container.read(userNameProvider), 'Mouhmad');
    });

    test('clamps a name longer than the rules would accept', () async {
      final container = await containerWith({});

      container.read(userNameProvider.notifier).update('a' * 5000);

      expect(container.read(userNameProvider).length, maxUserNameLength);
    });

    test('clamps on runes so a surrogate pair is not cut in half', () async {
      final container = await containerWith({});

      container.read(userNameProvider.notifier).update('🕌' * 300);

      final stored = container.read(userNameProvider);
      expect(stored.runes.length, maxUserNameLength);
      // A code-unit cut would leave a lone surrogate here.
      expect(stored.runes.every((r) => r == '🕌'.runes.first), isTrue);
    });
  });
}
