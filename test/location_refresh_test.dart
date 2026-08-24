import 'package:flutter_test/flutter_test.dart';
import 'package:munir/core/services/location_refresh_policy.dart';

/// What the automatic location refresh decides before it turns on the GPS.
///
/// The refresh itself needs a device with a radio in it; these two decisions
/// are what keep it from draining the battery or from throwing away a
/// position the user chose by hand.
void main() {
  const policy = LocationRefreshPolicy();
  final noon = DateTime(2026, 8, 24, 12);

  group('when to ask the GPS again', () {
    test('never asked before: ask now', () {
      expect(policy.dueAgain(lastAttempt: null, now: noon), isTrue);
    });

    test('just asked: not again', () {
      // Opening and closing the app ten times should cost one GPS read.
      expect(
        policy.dueAgain(
          lastAttempt: noon.subtract(const Duration(minutes: 1)),
          now: noon,
        ),
        isFalse,
      );
    });

    test('the gap has passed: ask again', () {
      expect(
        policy.dueAgain(
          lastAttempt: noon.subtract(LocationRefreshPolicy.minimumGap),
          now: noon,
        ),
        isTrue,
      );
    });

    test('the clock moved backwards: ask rather than wait it out', () {
      // A flight west, or the user correcting the date. Without this the
      // refresh parks itself until the clock catches up again.
      expect(
        policy.dueAgain(
          lastAttempt: noon.add(const Duration(hours: 3)),
          now: noon,
        ),
        isTrue,
      );
    });
  });

  group('when a fresh fix is worth keeping', () {
    test('walking across town: kept as it was', () {
      // Every adopted fix re-geocodes and re-schedules a week of
      // notifications, and two kilometres is seconds of prayer time.
      expect(
        policy.worthAdopting(
          movedMetres: 2000,
          previousWasFallback: false,
          previousCityUnresolved: false,
        ),
        isFalse,
      );
    });

    test('travelled far enough to matter: adopted', () {
      expect(
        policy.worthAdopting(
          movedMetres: LocationRefreshPolicy.minimumMoveMetres,
          previousWasFallback: false,
          previousCityUnresolved: false,
        ),
        isTrue,
      );
    });

    test('still on the Berlin fallback: any real fix beats it', () {
      // Qibla must never point from a position the user never had.
      expect(
        policy.worthAdopting(
          movedMetres: 5,
          previousWasFallback: true,
          previousCityUnresolved: false,
        ),
        isTrue,
      );
    });

    test('position never got a name: taken as a chance to resolve one', () {
      // Stored as bare coordinates because the geocoder was unreachable.
      expect(
        policy.worthAdopting(
          movedMetres: 5,
          previousWasFallback: false,
          previousCityUnresolved: true,
        ),
        isTrue,
      );
    });
  });
}
