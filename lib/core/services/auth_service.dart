import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Sign-in is optional throughout the app.
///
/// Prayer times, qibla and the Qur'an work without an account; an account
/// only adds syncing the prayer tracker and settings across devices. App
/// Store guideline 5.1.1(v) requires exactly this — an app without
/// significant account-based features must be usable without a login.
class AuthService {
  AuthService(this._ref);

  final Ref _ref;

  FirebaseAuth get _auth => FirebaseAuth.instance;

  /// Web client id from google-services.json (client_type 3). Android needs
  /// it to request an ID token that Firebase will accept.
  static const _serverClientId =
      '755498766182-k7m0kn6p1o2o0rhgulqdb7cffmt82s10.apps.googleusercontent.com';

  static bool _googleInitialized = false;

  Future<void> _ensureGoogleReady() async {
    if (_googleInitialized) return;
    await GoogleSignIn.instance.initialize(serverClientId: _serverClientId);
    _googleInitialized = true;
  }

  /// Signs in with Google and links the result to Firebase.
  ///
  /// Returns null when the user dismissed the picker, which is a normal
  /// outcome and not an error.
  Future<User?> signInWithGoogle() async {
    await _ensureGoogleReady();

    final GoogleSignInAccount account;
    try {
      account = await GoogleSignIn.instance.authenticate();
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return null;
      rethrow;
    }

    final idToken = account.authentication.idToken;
    if (idToken == null) {
      throw StateError('Google returned no ID token');
    }

    // Firebase verifies the token's signature, issuer and audience server
    // side, so nothing here has to trust the client.
    final credential = GoogleAuthProvider.credential(idToken: idToken);
    final result = await _auth.signInWithCredential(credential);
    return result.user;
  }

  Future<void> signOut() async {
    await GoogleSignIn.instance.signOut();
    await _auth.signOut();
  }

  /// Deletes the account and everything stored under it.
  ///
  /// Both stores require this to be reachable from inside the app: App Store
  /// guideline 5.1.1(v) and Google Play's account deletion policy.
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) return;

    // Firestore data first: once the account is gone the security rules no
    // longer match and the documents would be orphaned.
    await _ref.read(userDocumentDeleterProvider)(user.uid);

    try {
      await user.delete();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        // Firebase refuses to delete on a stale session; sign in again and
        // retry rather than leaving a half-deleted account behind.
        final refreshed = await signInWithGoogle();
        if (refreshed == null) rethrow;
        await refreshed.delete();
      } else {
        rethrow;
      }
    }

    await GoogleSignIn.instance.signOut();
  }
}

/// Injected so the auth service does not depend on Firestore directly.
final userDocumentDeleterProvider =
    Provider<Future<void> Function(String uid)>((ref) {
  throw UnimplementedError('Overridden in providers.dart');
});

final authServiceProvider = Provider<AuthService>(AuthService.new);

/// Emits the signed-in user, or null while signed out.
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});
