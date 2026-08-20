/// Feature switches that don't warrant a full remote-config setup.
class FeatureFlags {
  const FeatureFlags._();

  /// Sign in with Apple is implemented (see `AuthService.signInWithApple`)
  /// and required by App Store guideline 4.8 once Munir ships on iOS, but
  /// it needs a Mac to build, sign and actually test — unavailable right
  /// now. Google Play launches first; this stays off until iOS is back in
  /// scope. Flip to true once the flow has been tested on a real device.
  static const appleSignInEnabled = false;
}
