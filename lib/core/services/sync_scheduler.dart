import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/surah/providers/quran_progress_provider.dart';
import '../../features/tasbih/providers/tasbih_provider.dart';
import '../providers/providers.dart';
import 'account_data_service.dart';
import 'auth_service.dart';
import 'sync_policy.dart';
import 'sync_service.dart';

/// Keeps the account's copy in step with the device without anyone pressing
/// the sync button.
///
/// Until this existed the app uploaded at exactly three moments: signing in,
/// signing out, and the button in settings. A week of prayers ticked off in
/// a tunnel or on a plane sat on the device until the user happened to press
/// that button — nothing was lost, but nothing was saved either, and a lost
/// phone took the week with it.
///
/// Reconnecting is deliberately not observed. Knowing a network exists is
/// not knowing Firestore can be reached: a captive portal, a hotel wifi or
/// an expired token all report a healthy connection and then fail the write.
/// So the scheduler asks the only authority that can actually answer — it
/// attempts the sync, and treats the result as the signal. On failure it
/// waits and attempts again, backing off (see [SyncPolicy]).
///
/// Firestore's own offline queue sits underneath all of this and is the
/// reason a failed attempt is not a lost one: a write made while offline is
/// kept locally and flushed when the connection returns, even across a
/// restart. The scheduler's job is to make sure the write is *attempted* in
/// the first place.
class SyncScheduler {
  SyncScheduler(this._ref);

  final Ref _ref;
  final SyncPolicy _policy = syncPolicy;

  AppLifecycleListener? _lifecycle;
  Timer? _debounce;
  Timer? _retry;
  bool _busy = false;
  bool _rerunWhenFree = false;
  int _failures = 0;

  /// Wires up the triggers. Called once, from [syncSchedulerProvider].
  void start() {
    // main() initialises Firebase before the app is built, so in the app this
    // is always false. It is true in widget tests, which mount the real app
    // without it — and every trigger below ends in a Firebase call, so
    // without this the tests would drown in errors from a service that is
    // not there.
    if (Firebase.apps.isEmpty) return;

    // Coming back to the app is the moment a device most often has a
    // connection again after not having one.
    _lifecycle = AppLifecycleListener(
      onResume: () => _request(pull: true),
      // Leaving the app should not strand a change that is still sitting in
      // the debounce window.
      onPause: _flushPendingChange,
    );

    // Signing in pulls and pushes on its own (see AccountService). This is
    // for the rest: a token that refreshed, or a session restored on launch.
    _ref.listen(authStateProvider, (previous, next) {
      if (next.value == null) {
        _cancelTimers();
        return;
      }
      _request(pull: true);
    });

    // Everything the sync carries. A change to any of it is worth uploading.
    _ref.listen(prayerTrackerProvider, (_, _) => _onLocalChange());
    _ref.listen(tasbihProvider, (_, _) => _onLocalChange());
    _ref.listen(quranReadingProgressProvider, (_, _) => _onLocalChange());
    _ref.listen(userNameProvider, (_, _) => _onLocalChange());

    // The launch itself: whatever was recorded offline last session goes up
    // now, and anything another device recorded comes down.
    _request(pull: true);
  }

  void _onLocalChange() {
    _debounce?.cancel();
    _debounce = Timer(SyncPolicy.debounce, () => _request(pull: false));
  }

  void _flushPendingChange() {
    if (_debounce?.isActive != true) return;
    _debounce!.cancel();
    _request(pull: false);
  }

  /// Runs a sync soon, but never from inside a provider build or a listener
  /// callback — both would be reading providers while they are changing.
  void _request({required bool pull}) {
    unawaited(Future.microtask(() => _run(pull: pull)));
  }

  Future<void> _run({required bool pull}) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final ownerUid = _ref.read(accountDataServiceProvider).ownerUid;
    if (!_policy.canSync(uid: uid, ownerUid: ownerUid, busy: _busy)) {
      // A tap that lands mid-sync must not be dropped: the run in flight
      // took its snapshot of the tracker before that tap existed, so it
      // would upload a state that is already out of date and nothing would
      // correct it until the next launch.
      if (_busy) _rerunWhenFree = true;
      return;
    }
    if (uid == null) return; // already covered by canSync; satisfies the type

    _busy = true;
    try {
      final sync = _ref.read(syncServiceProvider);
      if (pull) await sync.pull(uid);
      await sync.push(uid);

      _failures = 0;
      _retry?.cancel();
      _retry = null;
    } catch (e) {
      _failures++;
      _retry?.cancel();
      _retry = Timer(
        _policy.retryDelay(_failures),
        () => unawaited(_run(pull: pull)),
      );
      debugPrint('Auto-sync failed (attempt $_failures): $e');
    } finally {
      _busy = false;
      if (_rerunWhenFree) {
        _rerunWhenFree = false;
        _request(pull: false);
      }
    }
  }

  void _cancelTimers() {
    _debounce?.cancel();
    _debounce = null;
    _retry?.cancel();
    _retry = null;
    _failures = 0;
    _rerunWhenFree = false;
  }

  void dispose() {
    _cancelTimers();
    _lifecycle?.dispose();
    _lifecycle = null;
  }
}

/// Watched once, from the main shell in app.dart, the way the notification
/// scheduler is. Nothing reads its value.
final syncSchedulerProvider = Provider<SyncScheduler>((ref) {
  final scheduler = SyncScheduler(ref);
  ref.onDispose(scheduler.dispose);
  scheduler.start();
  return scheduler;
});
