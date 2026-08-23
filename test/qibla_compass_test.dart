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

  group('Qibla alignment', () {
    // Regression: the rule used to be `|relative| + accuracy <= 5`. iOS
    // reports a heading accuracy of 10-15 degrees even when well calibrated,
    // so the banner could never turn green on a real device.
    test('is reachable with a real-world heading accuracy', () {
      const reading = QiblaCompassReading(
        trueHeading: 135,
        accuracyDegrees: 15,
      );

      expect(reading.isUsable, isTrue);
      expect(isAlignedWithQibla(0), isTrue);
    });

    test('holds up to the tolerance on either side', () {
      expect(isAlignedWithQibla(qiblaAlignmentToleranceDegrees), isTrue);
      expect(isAlignedWithQibla(-qiblaAlignmentToleranceDegrees), isTrue);
    });

    test('does not claim alignment beyond the tolerance', () {
      expect(isAlignedWithQibla(qiblaAlignmentToleranceDegrees + 0.1), isFalse);
      expect(isAlignedWithQibla(-qiblaAlignmentToleranceDegrees - 0.1), isFalse);
      expect(isAlignedWithQibla(180), isFalse);
    });
  });
}
