import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:munir/core/providers/providers.dart';
import 'package:munir/features/tasbih/providers/tasbih_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tracker entries marking [day] as fully completed.
Map<String, Object> completedDayPrefs(DateTime day) {
  return {
    for (final prayer in obligatoryPrayerNames)
      'prayer_tracker_${day.year}_${day.month}_${day.day}_$prayer': true,
  };
}

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
  group('PrayerCelebrationNotifier', () {
    test('offers nothing while the day is unfinished', () async {
      final container = await containerWith({});

      expect(container.read(prayerCelebrationProvider), isNull);
    });

    test('raises a celebration once the day is complete', () async {
      // logicalDate falls back to today when no location is available.
      final today = DateTime.now();
      final container = await containerWith(completedDayPrefs(today));

      final celebration = container.read(prayerCelebrationProvider);

      expect(celebration, isNotNull);
      expect(celebration!.completed, obligatoryPrayerNames.length);
      expect(celebration.total, obligatoryPrayerNames.length);
      expect(celebration.streak, 1);
      expect(celebration.milestone, isNull);
    });

    test('does not raise the same day twice', () async {
      final today = DateTime.now();
      final container = await containerWith(completedDayPrefs(today));

      expect(container.read(prayerCelebrationProvider), isNotNull);
      container.read(prayerCelebrationProvider.notifier).acknowledge();
      expect(container.read(prayerCelebrationProvider), isNull);
    });

    test('stays silent for a day acknowledged in an earlier session', () async {
      final today = DateTime.now();
      final container = await containerWith({
        ...completedDayPrefs(today),
        'celebrated_day': '${today.year}_${today.month}_${today.day}',
      });

      expect(container.read(prayerCelebrationProvider), isNull);
    });

    test('reports the milestone when the streak closes one', () async {
      final today = DateTime.now();
      final values = <String, Object>{};
      // Seven consecutive days ending today is the first milestone.
      for (var back = 0; back < 7; back++) {
        final day = DateTime(today.year, today.month, today.day - back);
        values.addAll(completedDayPrefs(day));
      }

      final container = await containerWith(values);
      final celebration = container.read(prayerCelebrationProvider);

      expect(celebration, isNotNull);
      expect(celebration!.streak, 7);
      expect(celebration.milestone, 7);
    });
  });

  group('TasbihNotifier', () {
    test('restores counter, round and lifetime total', () async {
      final container = await containerWith({
        'tasbih_count': 12,
        'tasbih_round': 3,
        'tasbih_lifetime': 480,
        'tasbih_dhikr': 'Alhamdulillah',
      });

      final state = container.read(tasbihProvider);

      expect(state.count, 12);
      expect(state.round, 3);
      expect(state.lifetimeCount, 480);
      expect(state.selectedDhikr.text, 'Alhamdulillah');
    });

    test('clamps a stored counter above the target', () async {
      final container = await containerWith({
        'tasbih_count': 9999,
        'tasbih_dhikr': 'SubhanAllah', // target 33
      });

      expect(container.read(tasbihProvider).count, 33);
    });

    test('falls back to the first dhikr when the stored one is gone',
        () async {
      final container = await containerWith({'tasbih_dhikr': 'Removed'});

      expect(
        container.read(tasbihProvider).selectedDhikr,
        defaultDhikrs.first,
      );
    });

    test('reset clears the round but keeps the lifetime total', () async {
      final container = await containerWith({
        'tasbih_count': 20,
        'tasbih_round': 4,
        'tasbih_lifetime': 300,
      });

      container.read(tasbihProvider.notifier).reset();
      final state = container.read(tasbihProvider);

      expect(state.count, 0);
      expect(state.round, 1);
      expect(state.lifetimeCount, 300);
    });

    test('increment rolls into the next round and raises the total', () async {
      final container = await containerWith({
        'tasbih_count': 33,
        'tasbih_round': 1,
        'tasbih_lifetime': 33,
        'tasbih_dhikr': 'SubhanAllah', // target 33
      });

      container.read(tasbihProvider.notifier).increment();
      final state = container.read(tasbihProvider);

      expect(state.count, 1);
      expect(state.round, 2);
      expect(state.lifetimeCount, 34);
    });

    test('a remote total only wins when it is higher', () async {
      final container = await containerWith({'tasbih_lifetime': 500});
      final notifier = container.read(tasbihProvider.notifier);

      notifier.mergeRemoteLifetime(200);
      expect(container.read(tasbihProvider).lifetimeCount, 500);

      notifier.mergeRemoteLifetime(900);
      expect(container.read(tasbihProvider).lifetimeCount, 900);
    });
  });
}
