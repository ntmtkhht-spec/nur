import 'package:flutter_test/flutter_test.dart';
import 'package:munir/core/providers/providers.dart';

void main() {
  group('Qibla bearing', () {
    test('Berlin points south-east towards Makkah', () {
      final berlin = LocationData(lat: 52.5200, lng: 13.4050, city: 'Berlin');

      expect(calculateQiblaBearing(berlin), closeTo(136.7, 0.5));
    });

    test('New York points north-east towards Makkah', () {
      final newYork = LocationData(
        lat: 40.7128,
        lng: -74.0060,
        city: 'New York',
      );

      expect(calculateQiblaBearing(newYork), closeTo(58.5, 0.5));
    });

    test('Istanbul points south-south-east towards Makkah', () {
      final istanbul = LocationData(
        lat: 41.0082,
        lng: 28.9784,
        city: 'Istanbul',
      );

      expect(calculateQiblaBearing(istanbul), closeTo(151.6, 0.5));
    });
  });

  group('Distance to Kaaba', () {
    test('Berlin is about 4,130 km from the Kaaba', () {
      final berlin = LocationData(lat: 52.5200, lng: 13.4050, city: 'Berlin');

      expect(calculateDistanceToKaabaKm(berlin), closeTo(4130, 5));
    });
  });
}
