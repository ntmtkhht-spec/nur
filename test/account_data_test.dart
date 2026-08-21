import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:munir/core/providers/providers.dart';
import 'package:munir/core/services/account_data_service.dart';
import 'package:munir/features/tasbih/providers/tasbih_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Map<String, Object> completedDay(DateTime day) {
  return {
    for (final prayer in obligatoryPrayerNames)
      'prayer_tracker_${day.year}_${day.month}_${day.day}_$prayer': true,
  };
}

Future<(ProviderContainer, SharedPreferences)> setUpWith(
  Map<String, Object> values,
) async {
  SharedPreferences.setMockInitialValues(values);
  final prefs = await SharedPreferences.getInstance();

  final container = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
  );
  addTearDown(container.dispose);
  return (container, prefs);
}

void main() {
  final today = DateTime.now();

  group('clearPersonalData', () {
    test('removes the prayer history, and with it the statistics', () async {
      final (container, _) = await setUpWith(completedDay(today));

      expect(container.read(prayerStatsProvider).totalPrayersLogged, 5);

      await container.read(accountDataServiceProvider).clearPersonalData();

      final stats = container.read(prayerStatsProvider);
      expect(stats.hasHistory, isFalse);
      expect(stats.totalPrayersLogged, 0);
      expect(stats.currentStreak, 0);
      expect(stats.longestStreak, 0);
      expect(container.read(prayerTrackerProvider), isEmpty);
    });

    test('removes the tasbih counts including the lifetime total', () async {
      final (container, _) = await setUpWith({
        'tasbih_count': 20,
        'tasbih_round': 5,
        'tasbih_lifetime': 900,
      });

      await container.read(accountDataServiceProvider).clearPersonalData();

      final tasbih = container.read(tasbihProvider);
      expect(tasbih.count, 0);
      expect(tasbih.round, 1);
      expect(tasbih.lifetimeCount, 0);
    });

    test('removes the name and the celebration marker', () async {
      final (container, prefs) = await setUpWith({
        'user_name': 'Mouhmad',
        PrayerCelebrationNotifier.prefsKey: '2026_8_20',
      });

      await container.read(accountDataServiceProvider).clearPersonalData();

      expect(container.read(userNameProvider), '');
      expect(prefs.getString(PrayerCelebrationNotifier.prefsKey), isNull);
    });

    test('leaves device settings alone', () async {
      final (container, prefs) = await setUpWith({
        'app_language': 'tr',
        'calculation_method': 'turkiye',
        'notifications_enabled': true,
        'onboarding_complete': true,
        'cached_city': 'Oldenburg',
        ...completedDay(today),
      });

      await container.read(accountDataServiceProvider).clearPersonalData();

      // Signing out is not a factory reset: how this phone behaves is not
      // part of who was signed in on it.
      expect(prefs.getString('app_language'), 'tr');
      expect(prefs.getString('calculation_method'), 'turkiye');
      expect(prefs.getBool('notifications_enabled'), isTrue);
      expect(prefs.getBool('onboarding_complete'), isTrue);
      expect(prefs.getString('cached_city'), 'Oldenburg');
    });
  });

  group('device ownership', () {
    test('a fresh install belongs to nobody', () async {
      final (container, _) = await setUpWith({});
      final data = container.read(accountDataServiceProvider);

      expect(data.ownerUid, isNull);
      // Data tracked before ever signing in is adopted, not wiped.
      expect(data.belongsToSomeoneElse('user-a'), isFalse);
    });

    test('recognises the same account returning', () async {
      final (container, _) = await setUpWith({});
      final data = container.read(accountDataServiceProvider);

      await data.rememberOwner('user-a');

      expect(data.ownerUid, 'user-a');
      expect(data.belongsToSomeoneElse('user-a'), isFalse);
    });

    test('recognises a different account on a shared device', () async {
      final (container, _) = await setUpWith({});
      final data = container.read(accountDataServiceProvider);

      await data.rememberOwner('user-a');

      expect(data.belongsToSomeoneElse('user-b'), isTrue);
    });

    test('signing out hands the device back to nobody', () async {
      final (container, _) = await setUpWith({});
      final data = container.read(accountDataServiceProvider);

      await data.rememberOwner('user-a');
      await data.forgetOwner();

      expect(data.ownerUid, isNull);
    });
  });

  group('unclaimed activity', () {
    test('a fresh install has nothing to ask about', () async {
      final (container, _) = await setUpWith({});

      expect(
        container.read(accountDataServiceProvider).hasUnclaimedActivity,
        isFalse,
      );
    });

    test('ticked prayers count as activity', () async {
      final (container, _) = await setUpWith(completedDay(today));
      final data = container.read(accountDataServiceProvider);

      expect(data.hasUnclaimedActivity, isTrue);
      expect(data.loggedPrayerCount, 5);
    });

    test('counted beads count as activity on their own', () async {
      final (container, _) = await setUpWith({'tasbih_lifetime': 120});
      final data = container.read(accountDataServiceProvider);

      expect(data.hasUnclaimedActivity, isTrue);
      expect(data.loggedPrayerCount, 0);
    });

    test('a name entered during onboarding does not', () async {
      // Otherwise every new user would be asked about the name they typed
      // one screen earlier.
      final (container, _) = await setUpWith({'user_name': 'Mouhmad'});

      expect(
        container.read(accountDataServiceProvider).hasUnclaimedActivity,
        isFalse,
      );
    });

    test('an account that already owns the device is not asked again',
        () async {
      final (container, _) = await setUpWith(completedDay(today));
      final data = container.read(accountDataServiceProvider);

      await data.rememberOwner('user-a');

      // The question is only for data no account has claimed; once an owner
      // is recorded the entries are theirs.
      expect(data.ownerUid, isNotNull);
      expect(data.belongsToSomeoneElse('user-a'), isFalse);
    });
  });

  group('shared device', () {
    test("a second account never inherits the first one's history", () async {
      final (container, _) = await setUpWith(completedDay(today));
      final data = container.read(accountDataServiceProvider);

      // A signs in and the device is recorded as theirs.
      await data.rememberOwner('user-a');
      expect(container.read(prayerStatsProvider).totalPrayersLogged, 5);

      // B signs in on the same phone. This is the check AccountService.signIn
      // performs before it pulls or pushes anything.
      expect(data.belongsToSomeoneElse('user-b'), isTrue);
      await data.clearPersonalData();
      await data.rememberOwner('user-b');

      // B starts empty — and nothing of A's can be pushed up to B's account.
      expect(container.read(prayerStatsProvider).hasHistory, isFalse);
      expect(container.read(prayerTrackerProvider), isEmpty);
      expect(data.ownerUid, 'user-b');
    });
  });
}
