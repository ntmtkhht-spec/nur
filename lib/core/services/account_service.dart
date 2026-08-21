import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'account_data_service.dart';
import 'auth_service.dart';
import 'sync_service.dart';

/// Raised when signing out could not save the local entries first.
///
/// Signing out clears this device, so it only goes ahead once the entries
/// are safely in the account. Offering to sign out anyway would be offering
/// to throw the entries away.
class SignOutNotSyncedException implements Exception {
  final Object cause;
  const SignOutNotSyncedException(this.cause);

  @override
  String toString() => 'Sign-out could not upload local data: $cause';
}

/// The three account moments in one place: signing in, signing out, deleting.
///
/// Each of them has to move local data as well as talk to Firebase, and the
/// order matters. Leaving that to the screens meant every new sign-in button
/// had to remember the whole dance — the onboarding and settings screens
/// already carried two separate copies of it.
class AccountService {
  AccountService(this._ref);

  final Ref _ref;

  AuthService get _auth => _ref.read(authServiceProvider);
  SyncService get _sync => _ref.read(syncServiceProvider);
  AccountDataService get _data => _ref.read(accountDataServiceProvider);

  /// Signs in and puts this device's data in step with the account.
  ///
  /// [onUnclaimedActivity] is called when the device holds entries that were
  /// made before any account existed, and is given the number of prayers
  /// recorded. Returning false throws them away instead of adopting them.
  ///
  /// Returns null when the user dismissed the provider's sheet.
  Future<User?> signIn(
    Future<User?> Function() signInWithProvider, {
    required Future<bool> Function(int prayerCount) onUnclaimedActivity,
  }) async {
    final user = await signInWithProvider();
    if (user == null) return null;

    if (_data.belongsToSomeoneElse(user.uid)) {
      // Known to be another account's. Nothing to ask about.
      await _data.clearPersonalData();
    } else if (_data.ownerUid == null && _data.hasUnclaimedActivity) {
      // Entries exist but no account ever claimed them. Usually this is the
      // same person finally signing in, and adopting is exactly what they
      // want. On a passed-on phone it is the previous owner's practice
      // record, which must not end up in someone else's account. Nothing in
      // the data says which, so the person holding the account decides.
      final adopt = await onUnclaimedActivity(_data.loggedPrayerCount);
      if (!adopt) await _data.clearPersonalData();
    }

    // Pull first so a device inherits what is already stored, then push so
    // the account learns about anything recorded offline — which is what
    // adopts the entries kept above.
    await _sync.pull(user.uid);
    await _sync.push(user.uid);
    await _data.rememberOwner(user.uid);

    return user;
  }

  /// Saves what is on this device, then hands it back to nobody.
  ///
  /// Clearing is the point: on a shared phone the next person must not find
  /// the previous one's history sitting there. Everything cleared here comes
  /// back on the next sign-in, which is why the upload has to succeed first.
  ///
  /// Throws [SignOutNotSyncedException] when the upload failed, and nothing
  /// is cleared. Signing out offline is refused rather than offered with a
  /// warning — the only thing such an offer could do is lose entries.
  Future<void> signOut() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid != null) {
      try {
        await _sync.push(uid);
      } catch (e) {
        throw SignOutNotSyncedException(e);
      }
    }

    await _data.clearPersonalData();
    await _data.forgetOwner();
    await _auth.signOut();
  }

  /// Deletes the account, its stored data and this device's copy.
  ///
  /// Nothing is uploaded first — the point is to be rid of it.
  Future<void> deleteAccount() async {
    await _auth.deleteAccount();
    await _data.clearPersonalData();
    await _data.forgetOwner();
  }
}

final accountServiceProvider = Provider<AccountService>(AccountService.new);
