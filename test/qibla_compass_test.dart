import 'package:flutter_test/flutter_test.dart';
import 'package:munir/features/qibla/qibla_compass.dart';

void main() {
  group('Qibla compass quality gate', () {
    test('rejects a missing true-north heading', () {
      const reading = QiblaCompassReading(
        trueHeading: null,
        accuracyDegrees: 3,
      );

      expect(reading.isUsable, isFalse);
    });

    test('rejects an unknown or imprecise heading', () {
      const unknown = QiblaCompassReading(
        trueHeading: 135,
        accuracyDegrees: -1,
      );
      const imprecise = QiblaCompassReading(
        trueHeading: 135,
        accuracyDegrees: 15.1,
      );

      expect(unknown.isUsable, isFalse);
      expect(imprecise.isUsable, isFalse);
    });

    test('rejects a heading outside one full compass turn', () {
      const negative = QiblaCompassReading(
        trueHeading: -0.1,
        accuracyDegrees: 3,
      );
      const overflow = QiblaCompassReading(
        trueHeading: 360,
        accuracyDegrees: 3,
      );

      expect(negative.isUsable, isFalse);
      expect(overflow.isUsable, isFalse);
    });

    test('accepts a precise true-north heading', () {
      const reading = QiblaCompassReading(
        trueHeading: 135,
        accuracyDegrees: 10,
      );

      expect(reading.isUsable, isTrue);
    });
  });
}
