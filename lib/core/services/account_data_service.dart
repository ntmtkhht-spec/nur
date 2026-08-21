import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/surah/providers/quran_progress_provider.dart';
import '../../features/tasbih/providers/tasbih_provider.dart';
import '../providers/providers.dart';

/// Owns the line between data that belongs to a person and data that belongs
/// to the device.
///
/// Personal — prayer history, tasbih counts, the name — follows the account.
/// Device settings — language, calculation method, madhhab, reminder
/// switches, the location cache — stay put, because they describe how this
/// phone should behave rather than who is holding it.
///
/// Without this split a shared device leaks: signing out used to leave one
/// person's entries in place, and the next sign-in merged them into the new
/// account and pushed the mixture to that account's document.
class AccountDataService {
  AccountDataService(this._ref);

  final Ref _ref;

  /// Which account the personal data currently on this device belongs to.
  /// Absent while nobody has ever signed in on this install.
  static const _accountKey = 'synced_account_uid';

  String? get ownerUid =>
      _ref.read(sharedPreferencesProvider).getString(_accountKey);

  Future<void> rememberOwner(String uid) =>
      _ref.read(sharedPreferencesProvider).setString(_accountKey, uid);

  Future<void> forgetOwner() =>
      _ref.read(sharedPreferencesProvider).remove(_accountKey);

  /// Removes everything tied to a person, leaving device settings alone.
  Future<void> clearPersonalData() async {
    await _ref.read(prayerTrackerProvider.notifier).resetAll();
    await _ref.read(tasbihProvider.notifier).clear();
    await _ref.read(quranReadingProgressProvider.notifier).clear();
    _ref.read(userNameProvider.notifier).update('');
    await _ref
        .read(sharedPreferencesProvider)
        .remove(PrayerCelebrationNotifier.prefsKey);
  }

  /// True when the device still holds personal data from a different account.
  bool belongsToSomeoneElse(String uid) {
    final owner = ownerUid;
    return owner != null && owner != uid;
  }

  int get loggedPrayerCount =>
      _ref.read(prayerStatsProvider).totalPrayersLogged;

  /// Records built up on this device without any account behind them.
  ///
  /// Deliberately ignores the name: it is entered during onboarding, moments
  /// before the sign-in step, so counting it would ask every new user about
  /// something they just typed themselves. Only accumulated practice —
  /// prayers ticked off, beads counted — is worth a question.
  bool get hasUnclaimedActivity {
    if (loggedPrayerCount > 0) return true;
    if (_ref.read(tasbihProvider).lifetimeCount > 0) return true;
    return _ref.read(quranReadingProgressProvider).hasActivity;
  }
}

final accountDataServiceProvider = Provider<AccountDataService>(
  AccountDataService.new,
);
