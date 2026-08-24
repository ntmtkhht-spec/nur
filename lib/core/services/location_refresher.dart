import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/providers.dart';
import 'location_refresh_policy.dart';

/// Keeps the phone's position current on its own.
///
/// The position used to be read exactly when someone asked for it: during
/// onboarding, and afterwards only by tapping the location row in settings
/// or the warning banner on the home screen. Travel a few hundred kilometres
/// and the app went on showing the times for where you set out from, with
/// nothing on screen saying so — the times looked perfectly ordinary, they
/// were simply for the wrong place.
///
/// Three triggers, all cheap: launch, coming back to the app, and a slow
/// timer for journeys made with the app open. What each attempt costs is
/// held down by [LocationRefreshPolicy] — a low-accuracy fix at most every
/// quarter of an hour, and the result thrown away unless the phone has
/// actually moved somewhere the prayer times would notice.
class LocationRefresher {
  LocationRefresher(this._ref);

  final Ref _ref;
  final LocationRefreshPolicy _policy = locationRefreshPolicy;

  AppLifecycleListener? _lifecycle;
  Timer? _timer;
  DateTime? _lastAttempt;
  bool _busy = false;

  /// Wires up the triggers. Called once, from [locationRefresherProvider].
  void start() {
    _lifecycle = AppLifecycleListener(onResume: _maybeRefresh);
    _timer = Timer.periodic(
      LocationRefreshPolicy.foregroundInterval,
      (_) => _maybeRefresh(),
    );

    _maybeRefresh();
  }

  void _maybeRefresh() {
    if (_busy) return;
    if (!_policy.dueAgain(lastAttempt: _lastAttempt, now: DateTime.now())) {
      return;
    }

    // Counted before the attempt, not after: a fix that takes ten seconds to
    // fail is still a fix that was tried, and retrying it immediately would
    // be the same ten seconds of GPS again.
    _lastAttempt = DateTime.now();
    _busy = true;

    // Never awaited by a caller — this runs on a timer and on a lifecycle
    // callback, neither of which has anywhere to report to. refreshQuietly
    // swallows its own failures for the same reason.
    unawaited(
      Future(() => _ref.read(locationProvider.notifier).refreshQuietly())
          .whenComplete(() => _busy = false),
    );
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
    _lifecycle?.dispose();
    _lifecycle = null;
  }
}

/// Watched once, from the main shell in app.dart. Nothing reads its value.
final locationRefresherProvider = Provider<LocationRefresher>((ref) {
  final refresher = LocationRefresher(ref);
  ref.onDispose(refresher.dispose);
  refresher.start();
  return refresher;
});
