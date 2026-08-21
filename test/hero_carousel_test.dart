import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:munir/core/providers/providers.dart';
import 'package:munir/features/home/widgets/home_hero_carousel.dart';
import 'package:munir/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Which page the carousel is resting on.
double? currentPage(WidgetTester tester) {
  return tester.widget<PageView>(find.byType(PageView)).controller?.page;
}

Future<void> mountCarousel(
  WidgetTester tester, {
  bool reduceMotion = false,
}) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: MaterialApp(
        locale: const Locale('de'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: reduceMotion),
          child: const Scaffold(
            body: SingleChildScrollView(child: HomeHeroCarousel()),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

/// Waits out one dwell plus the slide that follows it.
Future<void> waitForAdvance(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 10));
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pump();
}

void main() {
  testWidgets('starts on the prayer card', (tester) async {
    await mountCarousel(tester);

    expect(currentPage(tester), 0);
  });

  testWidgets('moves on by itself after the dwell', (tester) async {
    await mountCarousel(tester);

    // Nothing should happen before the ten seconds are up.
    await tester.pump(const Duration(seconds: 9));
    expect(currentPage(tester), 0);

    await waitForAdvance(tester);
    expect(currentPage(tester), 1);
  });

  testWidgets('wraps back round to the first card', (tester) async {
    await mountCarousel(tester);

    await waitForAdvance(tester);
    expect(currentPage(tester), 1);

    await waitForAdvance(tester);
    expect(currentPage(tester), 0);
  });

  testWidgets('keeps going round', (tester) async {
    await mountCarousel(tester);

    for (final expected in [1, 0, 1, 0]) {
      await waitForAdvance(tester);
      expect(currentPage(tester), expected);
    }
  });

  testWidgets('a swipe buys a full dwell on the new page', (tester) async {
    await mountCarousel(tester);

    // Almost time to move on…
    await tester.pump(const Duration(seconds: 9));

    // …but the user swipes to the statistics themselves.
    await tester.fling(find.byType(PageView), const Offset(-400, 0), 1200);
    await tester.pumpAndSettle();
    expect(currentPage(tester), 1);

    // The remaining second of the old countdown must not drag them away
    // while they are still reading.
    await tester.pump(const Duration(seconds: 9));
    expect(currentPage(tester), 1);

    await waitForAdvance(tester);
    expect(currentPage(tester), 0);
  });

  testWidgets('stays put when the system asks for reduced motion', (
    tester,
  ) async {
    await mountCarousel(tester, reduceMotion: true);

    await waitForAdvance(tester);
    await waitForAdvance(tester);

    expect(currentPage(tester), 0);
  });
}
