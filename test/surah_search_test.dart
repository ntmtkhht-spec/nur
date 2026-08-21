import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:munir/core/providers/providers.dart';
import 'package:munir/features/surah/models/ayah_model.dart';
import 'package:munir/features/surah/providers/surah_provider.dart';
import 'package:munir/features/surah/screens/surah_list_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Finder searchField() => find.byWidgetPredicate(
    (widget) =>
        widget is TextField && widget.decoration?.hintText == 'Sura suchen',
  );

  testWidgets('Quran search opens in the app bar and filters surahs', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    addTearDown(prefs.clear);

    final surahs = [
      SurahInfo(
        number: 1,
        name: 'سُورَةُ ٱلْفَاتِحَةِ',
        englishName: 'Al-Faatiha',
        englishNameTranslation: 'The Opening',
        numberOfAyahs: 7,
        revelationType: 'Meccan',
      ),
      SurahInfo(
        number: 2,
        name: 'سُورَةُ ٱلْبَقَرَةِ',
        englishName: 'Al-Baqarah',
        englishNameTranslation: 'The Cow',
        numberOfAyahs: 286,
        revelationType: 'Medinan',
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          surahListProvider.overrideWith((ref) async => surahs),
        ],
        child: const MaterialApp(home: SurahListScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byTooltip('Suren suchen'), findsOneWidget);
    expect(find.text('Al-Faatiha'), findsOneWidget);
    expect(find.text('Al-Baqarah'), findsOneWidget);
    final numberStyle = tester.widget<Text>(find.text('1')).style;
    expect(numberStyle?.fontFamily, 'serif');

    await tester.tap(find.byTooltip('Suren suchen'));
    await tester.pumpAndSettle();
    expect(searchField(), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'baq');
    await tester.pump();
    expect(find.text('Al-Baqarah'), findsOneWidget);
    expect(find.text('Al-Faatiha'), findsNothing);

    await tester.tap(find.byTooltip('Suche leeren'));
    await tester.pump();
    expect(find.text('Al-Faatiha'), findsOneWidget);
    expect(find.text('Al-Baqarah'), findsOneWidget);

    await tester.tap(find.byTooltip('Suche schließen').last);
    await tester.pumpAndSettle();
    expect(searchField(), findsNothing);
    expect(find.byTooltip('Suren suchen'), findsOneWidget);
  });

  testWidgets(
    'started surahs show in a two-column section without continue tile',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        'quran_reading_progress_v1': jsonEncode({
          'version': 1,
          'readAyahIds': ['1:1'],
          'lastPosition': {'surahNumber': 1, 'ayahNumber': 1, 'updatedAtMs': 1},
        }),
      });
      final prefs = await SharedPreferences.getInstance();
      addTearDown(prefs.clear);

      final surahInfo = SurahInfo(
        number: 1,
        name: 'سُورَةُ ٱلْفَاتِحَةِ',
        englishName: 'Al-Faatiha',
        englishNameTranslation: 'The Opening',
        numberOfAyahs: 7,
        revelationType: 'Meccan',
      );
      final surah = Surah(
        number: 1,
        name: surahInfo.name,
        englishName: surahInfo.englishName,
        ayahs: [
          Ayah(
            numberInSurah: 1,
            arabicText: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
            transliteration: 'Bismillaahir Rahmaanir Raheem',
            translation: 'Im Namen Allahs, des Allerbarmers, des Barmherzigen.',
            audioUrl: 'https://example.test/1.mp3',
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            surahListProvider.overrideWith((ref) async => [surahInfo]),
            surahProvider(1).overrideWith((ref) async => surah),
          ],
          child: const MaterialApp(home: SurahListScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Begonnene Suren'), findsOneWidget);
      expect(find.text('Weiterlesen · Al-Faatiha'), findsNothing);
      expect(find.text('1/7 Verse gelesen'), findsOneWidget);
    },
  );

  testWidgets(
    'completed surahs leave the started section and are labelled in progress',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        'quran_reading_progress_v1': jsonEncode({
          'version': 1,
          'readAyahIds': List<String>.generate(7, (index) => '1:${index + 1}'),
          'lastPosition': {'surahNumber': 1, 'ayahNumber': 7, 'updatedAtMs': 1},
        }),
      });
      final prefs = await SharedPreferences.getInstance();
      addTearDown(prefs.clear);

      final surahInfo = SurahInfo(
        number: 1,
        name: 'سُورَةُ ٱلْفَاتِحَةِ',
        englishName: 'Al-Faatiha',
        englishNameTranslation: 'The Opening',
        numberOfAyahs: 7,
        revelationType: 'Meccan',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            surahListProvider.overrideWith((ref) async => [surahInfo]),
          ],
          child: const MaterialApp(home: SurahListScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Begonnene Suren'), findsNothing);
      await tester.tap(find.text('Fortschritt'));
      await tester.pumpAndSettle();
      expect(find.text('7 / 7'), findsOneWidget);
      expect(find.text('Abgeschlossen'), findsOneWidget);
    },
  );
}
