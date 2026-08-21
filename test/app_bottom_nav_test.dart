import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:munir/l10n/app_localizations.dart';
import 'package:munir/shared/widgets/app_bottom_nav.dart';

void main() {
  testWidgets('renders the original app navigation destinations', (
    tester,
  ) async {
    var selected = -1;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('de'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Scaffold(
          bottomNavigationBar: AppBottomNav(
            currentIndex: 2,
            onTap: (index) => selected = index,
          ),
        ),
      ),
    );

    expect(find.text('Start'), findsOneWidget);
    expect(find.text('Gebet'), findsOneWidget);
    expect(find.text("Qur'an"), findsOneWidget);
    expect(find.text('Tasbih'), findsOneWidget);
    expect(find.text('Qibla'), findsOneWidget);
    expect(find.byType(BottomNavigationBar), findsNothing);
    expect(find.byIcon(Icons.menu_book_rounded), findsOneWidget);
    expect(find.byType(ImageIcon), findsOneWidget);
    await tester.tap(find.text("Qur'an"));
    expect(selected, 2);
  });
}
