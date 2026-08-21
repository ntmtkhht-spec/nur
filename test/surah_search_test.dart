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
}
