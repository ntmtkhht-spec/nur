import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

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

  /// Signs in with Apple and links the result to Firebase.
  ///
  /// App Store guideline 4.8 requires this as an equal option next to
  /// Google, not just a formality: it's an actual sign-in path, not
  /// hidden behind extra taps.
  ///
  /// Returns null when the user cancelled the Apple sheet, which is a
  /// normal outcome and not an error.
  Future<User?> signInWithApple() async {
    final rawNonce = _generateNonce();
    final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

    final AuthorizationCredentialAppleID appleCredential;
    try {
      appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) return null;
      rethrow;
    }

    final credential = OAuthProvider('apple.com').credential(
      idToken: appleCredential.identityToken,
      rawNonce: rawNonce,
      accessToken: appleCredential.authorizationCode,
    );
    final result = await _auth.signInWithCredential(credential);

    // Apple only ever sends the name on the very first authorization; the
    // Firebase user has none of it unless it's copied over here.
    final fullName = [
      appleCredential.givenName,
      appleCredential.familyName,
    ].whereType<String>().where((s) => s.isNotEmpty).join(' ');
    if (fullName.isNotEmpty && result.user?.displayName == null) {
      await result.user?.updateDisplayName(fullName);
    }

    return result.user;
  }

  /// Cryptographically random nonce, verified end-to-end by Sign in with
  /// Apple so the ID token can't be replayed from a different sign-in.
  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  Future<void> signOut() async {
    await GoogleSignIn.instance.signOut();
    await _auth.signOut();
  }

  /// Deletes the account and everything stored under it.
  ///
  /// Both stores require this to be reachable from inside the app: App Store
  /// guideline 5.1.1(v) and Google Play's account deletion policy.
  ///
  /// The session is refreshed *before* anything is deleted. It used to be the
  /// other way round — Firestore first, so the documents could not outlive
  /// the account — but Firebase refuses `delete()` on a stale session, and by
  /// the time that refusal arrived the data was already gone. A user who then
  /// dismissed the sign-in sheet was left with an intact account and an empty
  /// one.
  Future<void> deleteAccount() async {
    var user = _auth.currentUser;
    if (user == null) return;

    final uid = user.uid;

    if (await _needsReauthentication(user)) {
      final usedApple = user.providerData.any(
        (p) => p.providerId == 'apple.com',
      );
      final refreshed = usedApple
          ? await signInWithApple()
          : await signInWithGoogle();
      if (refreshed == null) {
        throw FirebaseAuthException(
          code: 'requires-recent-login',
          message: 'Deleting the account needs a fresh sign-in.',
        );
      }
      // Signing in again can land on a different account — a second Google
      // account on the same device, say. Deleting that one would be deleting
      // a stranger's data on the strength of a tap meant for this one.
      if (refreshed.uid != uid) {
        throw FirebaseAuthException(
          code: 'user-mismatch',
          message: 'The account signed in again is not the one being deleted.',
        );
      }
      user = refreshed;
    }

    // Firestore first, now that the session is known to be fresh: once the
    // account is gone the security rules no longer match and the documents
    // would be orphaned.
    await _ref.read(userDocumentDeleterProvider)(uid);
    await user.delete();

    await GoogleSignIn.instance.signOut();
  }

  /// Whether Firebase will turn a deletion down for a stale session.
  ///
  /// Asked by attempting the token refresh the deletion itself would need, so
  /// the answer comes back without deleting anything first.
  Future<bool> _needsReauthentication(User user) async {
    try {
      await user.getIdToken(true);
      return false;
    } on FirebaseAuthException {
      return true;
    }
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
