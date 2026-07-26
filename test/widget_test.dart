import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nur_app/app.dart';

void main() {
  testWidgets('App renders', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: NurApp()),
    );

    expect(find.text('Nur'), findsOneWidget);
    expect(find.text('Ready'), findsOneWidget);
  });
}
