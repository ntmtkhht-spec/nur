import 'package:flutter_test/flutter_test.dart';
import 'package:munir/core/providers/providers.dart';
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
        accuracyDegrees: 30.1,
      );

      expect(unknown.isUsable, isFalse);
      expect(imprecise.isUsable, isFalse);
    });

    // Regression: the gate used to sit at 15 degrees, which is the accuracy
    // a well calibrated phone reports. iOS says 10-15 and Android maps its
    // MEDIUM sensor status to 20, so the dial was hidden behind "please
    // calibrate" almost permanently.
    test('says nothing about the accuracy a phone reports all day', () {
      // 20 degrees is what an iPhone on a desk and an Android sensor at
      // MEDIUM both report. Asking for a figure of eight at this figure
      // meant asking permanently.
      const reading = QiblaCompassReading(
        trueHeading: 135,
        accuracyDegrees: 20,
      );

      expect(reading.isUsable, isTrue);
      expect(reading.needsCalibration, isFalse);
    });

    test('hints once the heading is genuinely coarse', () {
      const reading = QiblaCompassReading(
        trueHeading: 135,
        accuracyDegrees: 28,
      );

      expect(reading.isUsable, isTrue);
      expect(reading.needsCalibration, isTrue);
    });

    test('a hint stays up through the wobble that raised it', () {
      // Between the two thresholds: not coarse enough to raise the hint,
      // still coarse enough to keep one that is already showing, so it does
      // not blink while the phone lies still.
      const reading = QiblaCompassReading(
        trueHeading: 135,
        accuracyDegrees: 22,
      );

      expect(reading.needsCalibration, isFalse);
      expect(reading.keepsCalibrationHint, isTrue);
    });

    test('a hint comes down once the heading sharpens', () {
      const reading = QiblaCompassReading(
        trueHeading: 135,
        accuracyDegrees: 14,
      );

      expect(reading.keepsCalibrationHint, isFalse);
    });

    test('does not nag about a sharp heading', () {
      const reading = QiblaCompassReading(
        trueHeading: 135,
        accuracyDegrees: 10,
      );

      expect(reading.needsCalibration, isFalse);
    });

    test('never asks to calibrate a heading it will not show', () {
      const reading = QiblaCompassReading(
        trueHeading: 135,
        accuracyDegrees: 45,
      );

      expect(reading.isUsable, isFalse);
      expect(reading.needsCalibration, isFalse);
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

  group('Heading smoothing', () {
    test('adopts the first reading as-is', () {
      expect(smoothHeading(null, 137.4), closeTo(137.4, 0.001));
    });

    test('damps the sensor wobble instead of following it', () {
      final smoothed = smoothHeading(100, 108);

      expect(smoothed, greaterThan(100));
      expect(smoothed, lessThan(108));
    });

    // Regression: blending the raw numbers sent the needle 358 degrees the
    // wrong way round every time the heading crossed north.
    test('crosses north the short way', () {
      final smoothed = smoothHeading(359, 3);

      expect(
        normalizeRelativeDegrees(smoothed - 359),
        inInclusiveRange(0, 4),
      );
    });

    test('follows a real turn immediately', () {
      expect(smoothHeading(10, 190), closeTo(190, 0.001));
    });

    test('keeps every result inside one compass turn', () {
      expect(smoothHeading(1, 355), inInclusiveRange(0, 360));
      expect(smoothHeading(355, 1), inInclusiveRange(0, 360));
    });
  });

  group('Compass restart policy', () {
    test('ignores the metres of drift a stationary GPS produces', () {
      const before = LocationData(lat: 52.52, lng: 13.405);
      const after = LocationData(lat: 52.5203, lng: 13.4054);

      expect(isWorthRestartingCompass(before, after), isFalse);
    });

    test('restarts once the declination could have moved', () {
      const before = LocationData(lat: 52.52, lng: 13.405);
      const after = LocationData(lat: 52.9, lng: 13.405);

      expect(isWorthRestartingCompass(before, after), isTrue);
    });
  });

  group('Needle catch-up', () {
    test('finishes the turn after the sensor goes quiet', () {
      // A quarter turn, one event per degree, exactly as iOS delivers it.
      double? needle;
      for (var deg = 0; deg <= 90; deg++) {
        needle = smoothHeading(needle, deg.toDouble());
      }
      // Per-event smoothing alone stops short of the target.
      expect((90 - needle!).abs(), greaterThan(1.0));

      // The ticker keeps stepping once the events stop. A third of a second
      // at 60fps is all it takes.
      for (var frame = 0; frame < 20; frame++) {
        needle = stepHeadingTowards(needle!, 90, 1 / 60);
      }
      expect((90 - needle!).abs(), lessThan(0.2));
    });

    test('settles exactly rather than creeping', () {
      final settled = stepHeadingTowards(90, 90.05, 1 / 60);
      expect(settled, 90.05);
    });

    test('takes the short way around north', () {
      final stepped = stepHeadingTowards(359, 3, 1 / 60);
      expect(stepped > 359 || stepped < 4, isTrue,
          reason: 'went the long way: $stepped');
    });
  });
}
