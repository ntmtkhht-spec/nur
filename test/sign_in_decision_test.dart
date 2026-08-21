import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:munir/core/providers/providers.dart';
import 'package:munir/core/services/account_data_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// What [AccountService.signIn] decides before it touches the network.
///
/// The service itself needs Firebase to run, so the branch it takes is
/// reproduced here against the real [AccountDataService] — that decision is
/// the part which keeps one person's practice out of another's account.
enum SignInOutcome { adoptSilently, ask, clearWithoutAsking }

SignInOutcome decideFor(AccountDataService data, String uid) {
  if (data.belongsToSomeoneElse(uid)) return SignInOutcome.clearWithoutAsking;
  if (data.ownerUid == null && data.hasUnclaimedActivity) {
    return SignInOutcome.ask;
  }
  return SignInOutcome.adoptSilently;
}

Map<String, Object> completedDay(DateTime day) {
  return {
    for (final prayer in obligatoryPrayerNames)
      'prayer_tracker_${day.year}_${day.month}_${day.day}_$prayer': true,
  };
}

Future<AccountDataService> serviceWith(Map<String, Object> values) async {
  SharedPreferences.setMockInitialValues(values);
  final prefs = await SharedPreferences.getInstance();

  final container = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
  );
  addTearDown(container.dispose);
  return container.read(accountDataServiceProvider);
}

void main() {
  final today = DateTime.now();

  group('what happens on sign-in', () {
    test('nothing tracked yet: straight through, no question', () async {
      final data = await serviceWith({});

      expect(decideFor(data, 'user-a'), SignInOutcome.adoptSilently);
    });

    test('tracked before signing in: the user is asked', () async {
      // The case that used to adopt silently.
      final data = await serviceWith(completedDay(today));

      expect(decideFor(data, 'user-a'), SignInOutcome.ask);
    });

    test('same account returning: no question, entries stay', () async {
      final data = await serviceWith(completedDay(today));
      await data.rememberOwner('user-a');

      expect(decideFor(data, 'user-a'), SignInOutcome.adoptSilently);
    });

    test('a different account: cleared outright, nothing to decide', () async {
      final data = await serviceWith(completedDay(today));
      await data.rememberOwner('user-a');

      // No question here — the entries demonstrably belong to user-a, so
      // offering to add them to user-b's account would be offering a leak.
      expect(decideFor(data, 'user-b'), SignInOutcome.clearWithoutAsking);
    });
  });

  group('discarding at the prompt', () {
    test('leaves nothing behind for the new account to push up', () async {
      final data = await serviceWith(completedDay(today));
      expect(decideFor(data, 'user-b'), SignInOutcome.ask);

      // The user says these are not theirs.
      await data.clearPersonalData();
      await data.rememberOwner('user-b');

      expect(data.loggedPrayerCount, 0);
      expect(data.hasUnclaimedActivity, isFalse);
      expect(data.ownerUid, 'user-b');
    });
  });

  group('adopting at the prompt', () {
    test('keeps the entries and hands the device to the account', () async {
      final data = await serviceWith(completedDay(today));
      expect(decideFor(data, 'user-a'), SignInOutcome.ask);

      // The user says these are theirs; nothing is cleared.
      await data.rememberOwner('user-a');

      expect(data.loggedPrayerCount, 5);
      expect(data.ownerUid, 'user-a');
      // And the question does not come back next time.
      expect(decideFor(data, 'user-a'), SignInOutcome.adoptSilently);
    });
  });
}
