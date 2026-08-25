/// Feature switches that don't warrant a full remote-config setup.
class FeatureFlags {
  const FeatureFlags._();

  /// Sign in with Apple, shown next to Google on iOS.
  ///
  /// App Store guideline 4.8 requires it wherever a third-party login is
  /// offered, so an iOS build with the Google button and without this one is
  /// a rejection. It stayed off while iOS was out of scope.
  ///
  /// Android is unaffected either way: every use site is behind
  /// `Platform.isIOS && FeatureFlags.appleSignInEnabled`.
  ///
  /// The flag is only the app's half. Before an iOS submission the other half
  /// has to exist, or the button is worse than no button — it will fail at
  /// `signInWithCredential` and show the generic sign-in error:
  ///
  ///  * Apple enabled as a sign-in provider in the Firebase console,
  ///  * a Services ID and key configured under Sign in with Apple in the
  ///    Apple Developer portal, with the Firebase callback URL,
  ///  * the capability on the App ID — the entitlement is already in
  ///    `ios/Runner/Runner.entitlements` and wired into all three build
  ///    configurations,
  ///  * and the flow run once on a real device, which needs a Mac.
  static const appleSignInEnabled = true;
}
