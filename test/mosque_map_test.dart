import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:munir/core/theme/app_theme.dart';
import 'package:munir/features/mosques/models/mosque.dart';
import 'package:munir/features/mosques/widgets/mosque_map.dart';

Widget _wrap(Widget child) =>
    MaterialApp(theme: AppTheme.light, home: Scaffold(body: child));

Widget _map({int radiusMeters = 5000, double lat = 52.52, double lng = 13.405}) =>
    _wrap(
      MosqueMap(
        mosques: const <Mosque>[],
        userLat: lat,
        userLng: lng,
        radiusMeters: radiusMeters,
      ),
    );

void main() {
  testWidgets('draws the search radius to scale around the user', (
    tester,
  ) async {
    await tester.pumpWidget(_map(radiusMeters: 10000));
    await tester.pump();

    final layer = tester.widget<CircleLayer>(find.byType(CircleLayer));
    expect(layer.circles, hasLength(1));
    expect(layer.circles.single.useRadiusInMeter, isTrue);
    expect(layer.circles.single.radius, 10000);
    expect(layer.circles.single.point.latitude, 52.52);
  });

  testWidgets('radius circle follows the slider', (tester) async {
    await tester.pumpWidget(_map(radiusMeters: 2000));
    await tester.pump();
    await tester.pumpWidget(_map(radiusMeters: 25000));
    await tester.pump();

    expect(
      tester.widget<CircleLayer>(find.byType(CircleLayer)).circles.single.radius,
      25000,
    );
  });

  // Regression: the radius/location change used to drive MapController.move()
  // straight from didUpdateWidget. flutter_map only wires up its interactive
  // viewer during layout, so a rebuild that landed before the map's first
  // layout threw a LateInitializationError and killed the screen.
  testWidgets('survives a radius change before the map has been laid out', (
    tester,
  ) async {
    await tester.pumpWidget(
      _map(radiusMeters: 5000),
      duration: Duration.zero,
      phase: EnginePhase.build,
    );
    await tester.pumpWidget(_map(radiusMeters: 25000));
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.byType(FlutterMap), findsOneWidget);
  });

  testWidgets('survives the location moving off the fallback', (tester) async {
    await tester.pumpWidget(_map());
    await tester.pump();
    await tester.pumpWidget(_map(lat: 48.137, lng: 11.575));
    await tester.pump();

    expect(tester.takeException(), isNull);
  });

  testWidgets('disposes cleanly right after being built', (tester) async {
    await tester.pumpWidget(_map());
    await tester.pumpWidget(_wrap(const SizedBox()));
    await tester.pump();

    expect(tester.takeException(), isNull);
  });
}
