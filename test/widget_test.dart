import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nur_app/app.dart';

void main() {
  testWidgets('Home screen renders greeting and prayer card', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: NurApp()));

    expect(find.textContaining('Assalamu alaikum'), findsOneWidget);
    expect(find.textContaining('Mohammed'), findsOneWidget);
    expect(find.text('NÄCHSTES GEBET'), findsOneWidget);
    expect(find.text('Fajr'), findsWidgets);
  });
}
