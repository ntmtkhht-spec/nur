import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:munir/core/providers/providers.dart';
import 'package:munir/features/surah/providers/quran_progress_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<ProviderContainer> makeContainer(Map<String, Object> values) async {
    SharedPreferences.setMockInitialValues(values);
    final prefs = await SharedPreferences.getInstance();
    addTearDown(prefs.clear);
    return ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
  }

  test('reading an ayah persists the exact resume marker', () async {
    final container = await makeContainer({});
    addTearDown(container.dispose);

    await container
        .read(quranReadingProgressProvider.notifier)
        .markRead(surahNumber: 2, ayahNumber: 255);

    final progress = container.read(quranReadingProgressProvider);
    expect(progress.lastPosition?.surahNumber, 2);
    expect(progress.lastPosition?.ayahNumber, 255);
    expect(progress.readAyahIds, contains('2:255'));
  });

  test(
    'remote data unions read ayat and keeps the newest resume marker',
    () async {
      final container = await makeContainer({});
      addTearDown(container.dispose);
      final notifier = container.read(quranReadingProgressProvider.notifier);

      await notifier.mergeRemote({
        'readAyahIds': ['1:1', '2:1'],
        'lastPosition': {'surahNumber': 2, 'ayahNumber': 1, 'updatedAtMs': 100},
      });
      await notifier.mergeRemote({
        'readAyahIds': ['2:1', '2:2'],
        'lastPosition': {'surahNumber': 2, 'ayahNumber': 2, 'updatedAtMs': 200},
      });

      final progress = container.read(quranReadingProgressProvider);
      expect(progress.readAyahIds, {'1:1', '2:1', '2:2'});
      expect(progress.lastPosition?.ayahId, '2:2');
    },
  );

  test('plan pace uses all remaining ayat, not a daily dummy value', () {
    const progress = QuranReadingProgress(
      readAyahIds: {'1:1', '1:2', '1:3'},
      plan: QuranReadingPlan(
        createdAtMs: 0,
        targetDateMs: 1767312000000, // 2026-01-02 local midnight UTC
        updatedAtMs: 0,
      ),
    );

    final status = planStatus(progress, DateTime.utc(2026, 1, 1, 12));

    expect(status.remainingAyahs, quranTotalAyahs - 3);
    expect(status.remainingDays, 2);
    expect(status.ayahsPerDay, ((quranTotalAyahs - 3) / 2).ceil());
  });

  test('a reading plan is personal activity even before the first ayah', () {
    const progress = QuranReadingProgress(
      plan: QuranReadingPlan(createdAtMs: 1, targetDateMs: 2, updatedAtMs: 1),
    );

    expect(progress.hasActivity, isTrue);
  });
}
