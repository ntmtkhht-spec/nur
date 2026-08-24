/// The parts of automatic syncing that can be decided without a network:
/// whether a sync may run at all, and how long to wait before trying again
/// after one failed.
///
/// Kept apart from `SyncScheduler` because everything else that scheduler
/// does needs Firebase and a running app, and these two decisions are the
/// ones worth pinning down in a test.
class SyncPolicy {
  const SyncPolicy();

  /// How long the device waits after a local change before pushing it.
  ///
  /// Ticking off a whole day is five taps in a row; pushing each one would
  /// be five uploads for one outcome.
  static const debounce = Duration(seconds: 3);

  /// Waits between attempts once a sync has failed.
  ///
  /// Being offline is the ordinary reason for a failure and can last hours,
  /// so the gaps grow instead of the app retrying every half minute all
  /// afternoon on a plane. Waiting costs nothing: the entries stay on the
  /// device either way.
  static const retryDelays = <Duration>[
    Duration(seconds: 30),
    Duration(minutes: 2),
    Duration(minutes: 10),
    Duration(minutes: 30),
  ];

  /// How long to wait after [failures] consecutive failures, holding at the
  /// last step rather than growing without bound — a device that has been
  /// offline all day should still notice reconnecting within the half hour.
  Duration retryDelay(int failures) {
    if (failures < 1) return retryDelays.first;
    final index = failures - 1;
    return index < retryDelays.length
        ? retryDelays[index]
        : retryDelays.last;
  }

  /// Whether an automatic sync may run right now.
  ///
  /// [ownerUid] is the account the personal data on this device belongs to,
  /// as recorded by `AccountDataService`.
  bool canSync({
    required String? uid,
    required String? ownerUid,
    required bool busy,
  }) {
    // Signed out: there is no document to sync with.
    if (uid == null) return false;

    // One sync at a time. Two overlapping runs would push a half-merged
    // state, and the second would race the first's pull.
    if (busy) return false;

    // Data no account has claimed yet, or that a different account claimed,
    // is not this account's to upload. Sign-in settles that question — it
    // asks whether to adopt or discard, then records the owner. Until it
    // has, the scheduler stays out of it: uploading first would put the
    // previous owner of a passed-on phone into someone else's account.
    return ownerUid == uid;
  }
}

const syncPolicy = SyncPolicy();
