import 'package:flutter_test/flutter_test.dart';
import 'package:munir/core/services/sync_policy.dart';

/// What the automatic sync decides before it touches the network.
///
/// The scheduler around this needs Firebase and a running app; these two
/// decisions do not, and they are the ones that can lose data or leak it.
void main() {
  const policy = SyncPolicy();

  group('who may be synced', () {
    test('signed out: nothing to sync with', () {
      expect(
        policy.canSync(uid: null, ownerUid: null, busy: false),
        isFalse,
      );
    });

    test('signed in and the data is this account\'s: goes ahead', () {
      expect(
        policy.canSync(uid: 'user-a', ownerUid: 'user-a', busy: false),
        isTrue,
      );
    });

    test('data nobody has claimed yet: left alone until sign-in asks', () {
      // Entries made before any account existed. Sign-in offers to adopt or
      // discard them; uploading them behind that question would decide it.
      expect(
        policy.canSync(uid: 'user-a', ownerUid: null, busy: false),
        isFalse,
      );
    });

    test('another account\'s data: never uploaded', () {
      // A passed-on phone. This is the leak the whole owner check exists for.
      expect(
        policy.canSync(uid: 'user-b', ownerUid: 'user-a', busy: false),
        isFalse,
      );
    });

    test('a sync already running: not started twice', () {
      expect(
        policy.canSync(uid: 'user-a', ownerUid: 'user-a', busy: true),
        isFalse,
      );
    });
  });

  group('backing off after a failure', () {
    test('the first retry is the shortest wait', () {
      expect(policy.retryDelay(1), SyncPolicy.retryDelays.first);
    });

    test('each further failure waits longer', () {
      for (var failures = 1; failures < SyncPolicy.retryDelays.length; failures++) {
        expect(
          policy.retryDelay(failures + 1),
          greaterThan(policy.retryDelay(failures)),
        );
      }
    });

    test('the wait stops growing so a reconnect is still noticed', () {
      // Offline all day: the gap holds at the last step rather than doubling
      // into hours, or the app would never notice the connection returning.
      expect(policy.retryDelay(50), SyncPolicy.retryDelays.last);
      expect(SyncPolicy.retryDelays.last, lessThanOrEqualTo(const Duration(minutes: 30)));
    });
  });
}
