import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:munir/features/home/data/daily_advice.dart';
import 'package:munir/l10n/app_localizations.dart';
import 'package:munir/features/home/providers/daily_advice_provider.dart';
import 'package:munir/features/home/widgets/daily_advice_card.dart';

void main() {
  group('daily advice rotation', () {
    test('gives the same entry all day and a different one tomorrow', () {
      final morning = DateTime(2026, 3, 12, 6, 30);
      final evening = DateTime(2026, 3, 12, 23, 59);
      final tomorrow = DateTime(2026, 3, 13, 6, 30);

      expect(adviceForDate(evening).title, adviceForDate(morning).title);
      expect(
        adviceForDate(tomorrow).title,
        isNot(adviceForDate(morning).title),
      );
    });

    test('keeps rotating across the turn of the year', () {
      // The old day-of-year rotation jumped back here, repeating entries the
      // user had just seen.
      final lastDay = DateTime(2026, 12, 31);
      final newYear = DateTime(2027, 1, 1);

      expect(adviceForDate(newYear).title, isNot(adviceForDate(lastDay).title));
    });

    test('walks the whole collection before repeating', () {
      final start = DateTime(2026, 1, 1);
      final seen = <String>{
        for (var day = 0; day < dailyAdvices.length; day++)
          adviceForDate(start.add(Duration(days: day))).title,
      };

      expect(seen.length, dailyAdvices.length);
    });
  });

  group('daily advice entries', () {
    test('every entry carries teaser, body, source and an action', () {
      for (final advice in dailyAdvices) {
        expect(advice.title, isNotEmpty);
        expect(advice.teaser, isNotEmpty);
        // The body is what makes opening the card worthwhile — a one-liner
        // there would put us back at the banner this replaced.
        expect(advice.body.length, greaterThan(120), reason: advice.title);
        expect(advice.source, isNotEmpty, reason: advice.title);
        expect(advice.action, isNotEmpty, reason: advice.title);
      }
    });

    test('no title appears twice', () {
      final titles = dailyAdvices.map((advice) => advice.title).toSet();

      expect(titles.length, dailyAdvices.length);
    });
  });

  testWidgets('card opens the full entry', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          // The card and its sheet read their labels off AppLocalizations, so
          // the delegates have to be here the way the real app supplies them.
          locale: const Locale('de'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const Scaffold(body: DailyAdviceCard()),
        ),
      ),
    );

    final advice = adviceForDate(DateTime.now());
    expect(find.text(advice.title), findsOneWidget);
    expect(find.text(advice.body), findsNothing);

    await tester.tap(find.text('Weiterlesen'));
    await tester.pumpAndSettle();

    expect(find.text(advice.body), findsOneWidget);
    expect(find.text(advice.action), findsOneWidget);

    // The source sits past the fold on a short sheet, so scroll to it.
    await tester.scrollUntilVisible(find.text(advice.source), 100);
    expect(find.text(advice.source), findsOneWidget);
  });
}
