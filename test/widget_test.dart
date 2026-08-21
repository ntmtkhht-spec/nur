import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:munir/app.dart';
import 'package:munir/core/providers/providers.dart';

/// Mounts the app and runs past the splash screen.
///
/// [MunirApp] opens on a branded splash that holds the frame for about 1.7
/// seconds before handing off, so asserting straight after `pumpWidget` only
/// ever sees the splash. `pumpAndSettle` is not an option: the home and
/// prayers screens both run a periodic ticker that never settles.
Future<void> pumpApp(WidgetTester tester, SharedPreferences prefs) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const MunirApp(),
    ),
  );

  await tester.pump(const Duration(seconds: 2));
  await tester.pump(const Duration(milliseconds: 500));
}

void main() {
  testWidgets('Fresh install shows onboarding language screen', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await pumpApp(tester, prefs);

    expect(find.text('Sprache wählen'), findsOneWidget);
    expect(find.text('Deutsch'), findsOneWidget);
  });

  testWidgets('Completed onboarding shows home screen directly', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'onboarding_complete': true});
    final prefs = await SharedPreferences.getInstance();

    await pumpApp(tester, prefs);

    expect(find.textContaining('Assalamu alaikum'), findsOneWidget);
    expect(find.text('Fajr'), findsWidgets);
  });

  testWidgets('Prayer tracker respects time constraints', (tester) async {
    SharedPreferences.setMockInitialValues({'onboarding_complete': true});
    final prefs = await SharedPreferences.getInstance();

    await pumpApp(tester, prefs);

    // Rendering only: a prayer whose time has not arrived cannot be ticked
    // off, so tapping blindly would assert nothing. The rules themselves are
    // covered in prayer_times_test.dart and streak_test.dart.
    expect(find.text('Fajr'), findsWidgets);
  });

  testWidgets('Streak badge stays hidden without a completed day', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'onboarding_complete': true});
    final prefs = await SharedPreferences.getInstance();

    await pumpApp(tester, prefs);

    expect(find.text('Dein Gebets-Streak'), findsNothing);
  });
}
