import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nur_app/app.dart';
import 'package:nur_app/core/providers/providers.dart';

void main() {
  testWidgets('Fresh install shows onboarding language screen', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const NurApp(),
      ),
    );

    expect(find.text('Sprache wählen'), findsOneWidget);
    expect(find.text('Deutsch'), findsOneWidget);
  });

  testWidgets('Completed onboarding shows home screen directly', (tester) async {
    SharedPreferences.setMockInitialValues({'onboarding_complete': true});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const NurApp(),
      ),
    );

    expect(find.textContaining('Assalamu alaikum'), findsOneWidget);
    expect(find.text('NÄCHSTES GEBET'), findsOneWidget);
    expect(find.text('Fajr'), findsWidgets);
  });

  testWidgets('Prayer tracker persists completed prayers', (tester) async {
    SharedPreferences.setMockInitialValues({'onboarding_complete': true});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const NurApp(),
      ),
    );

    final fajrFinder = find.text('Fajr');
    expect(fajrFinder, findsWidgets);
    await tester.tap(fajrFinder.first);
    await tester.pump();

    final todayKey =
        'prayers_${DateTime.now().toIso8601String().substring(0, 10)}';
    expect(prefs.getString(todayKey), contains('Fajr'));
  });
}
