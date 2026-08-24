/// When the app may go looking for the phone's position again, and when the
/// answer is worth acting on.
///
/// Both questions are pure arithmetic, which is why they live here rather
/// than inside the notifier that has to talk to the GPS to ask them.
class LocationRefreshPolicy {
  const LocationRefreshPolicy();

  /// How far the phone has to have travelled before the stored position is
  /// replaced.
  ///
  /// Prayer times move with longitude at four minutes per degree, so five
  /// kilometres is worth about ten seconds — less than the minute the times
  /// are even displayed in. Walking across town therefore changes nothing,
  /// which matters: every position adopted here costs a reverse geocode and
  /// re-schedules a week of notifications.
  static const minimumMoveMetres = 5000.0;

  /// Shortest gap between two attempts to get a fix. Opening and closing the
  /// app ten times in a row should cost one GPS read, not ten.
  static const minimumGap = Duration(minutes: 15);

  /// How often to look while the app simply stays open. A train journey does
  /// not wait for the app to be backgrounded first.
  static const foregroundInterval = Duration(minutes: 30);

  /// Whether enough time has passed since [lastAttempt] to try again.
  bool dueAgain({required DateTime? lastAttempt, required DateTime now}) {
    if (lastAttempt == null) return true;

    final since = now.difference(lastAttempt);
    // A clock that moved backwards — a timezone flight, or the user setting
    // the date — would otherwise park the refresh until it caught up again.
    if (since.isNegative) return true;

    return since >= minimumGap;
  }

  /// Whether a fresh fix should replace what is stored.
  bool worthAdopting({
    required double movedMetres,
    required bool previousWasFallback,
    required bool previousCityUnresolved,
  }) {
    // Berlin-by-default, or a position that never got a name out of the
    // geocoder: any real fix is an improvement, however close by it is.
    if (previousWasFallback || previousCityUnresolved) return true;

    return movedMetres >= minimumMoveMetres;
  }
}

const locationRefreshPolicy = LocationRefreshPolicy();
