import Flutter
import CoreLocation
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private let qiblaHeadingHandler = QiblaHeadingStreamHandler()
  private var qiblaEventChannel: FlutterEventChannel?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    guard let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "QiblaHeading") else {
      return
    }
    let channel = FlutterEventChannel(
      name: "com.munir.app/qibla_heading",
      binaryMessenger: registrar.messenger()
    )
    channel.setStreamHandler(qiblaHeadingHandler)
    qiblaEventChannel = channel
  }
}

/// Delivers only a geographic (true-north) heading. Core Location can produce
/// a valid true heading only while this same manager receives location updates,
/// hence both services deliberately run together for the lifetime of the view.
private final class QiblaHeadingStreamHandler: NSObject, FlutterStreamHandler,
  CLLocationManagerDelegate {
  private let locationManager = CLLocationManager()
  private var eventSink: FlutterEventSink?

  /// When a heading last arrived that was worth drawing. See the guard in
  /// `didUpdateHeading` for why a single bad event is not reported.
  private var lastGoodHeadingAt: Date?

  override init() {
    super.init()
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    // Every change, not every whole degree: the needle is stepped on a clock
    // now, so a finer feed makes it smoother rather than busier.
    locationManager.headingFilter = kCLHeadingFilterNone
  }

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink)
    -> FlutterError? {
    eventSink = events
    lastGoodHeadingAt = nil
    guard CLLocationManager.headingAvailable() else {
      unavailable("Kompass wird auf diesem Gerät nicht unterstützt.")
      return nil
    }
    guard hasLocationPermission else {
      unavailable("Aktiviere den Standortzugriff für eine genaue Qibla.")
      return nil
    }
    // Core Location applies this orientation itself.  Do not correct the
    // resulting heading a second time in Dart/Swift: doing so moves the Qibla
    // by 90° or 180° after an interface rotation.
    updateHeadingOrientation()
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(interfaceOrientationDidChange),
      name: UIDevice.orientationDidChangeNotification,
      object: nil
    )
    UIDevice.current.beginGeneratingDeviceOrientationNotifications()
    locationManager.startUpdatingLocation()
    locationManager.startUpdatingHeading()
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    locationManager.stopUpdatingHeading()
    locationManager.stopUpdatingLocation()
    NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
    UIDevice.current.endGeneratingDeviceOrientationNotifications()
    eventSink = nil
    return nil
  }

  func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
    // `trueHeading` is negative until Core Location has a valid location fix.
    guard newHeading.headingAccuracy >= 0, newHeading.trueHeading >= 0 else {
      // A single bad event is ordinary — Core Location emits them whenever the
      // phone is picked up, turned, or passes something magnetic. Reporting
      // each one tore the dial down and put the calibration screen up in its
      // place, which is what made the compass ask to be calibrated every few
      // seconds. Only a run of them, with nothing good in between, means the
      // compass is actually unusable.
      if let last = lastGoodHeadingAt, Date().timeIntervalSince(last) < 6 { return }
      unavailable("Kompass wird kalibriert. Halte das Gerät flach und bewege es in einer Acht (∞).")
      return
    }
    lastGoodHeadingAt = Date()
    eventSink?([
      // `trueHeading` is already relative to the `headingOrientation` set
      // above, and is therefore directly comparable to the Qibla bearing.
      "trueHeading": normalized(newHeading.trueHeading),
      "accuracyDegrees": newHeading.headingAccuracy,
    ])
  }

  /// Lets iOS put up its own calibration HUD, but only when the compass has
  /// no usable reading at all.
  ///
  /// This used to ask for the HUD above 15 degrees of accuracy. An iPhone
  /// reports 15-25 as a matter of course — indoors, near a desk, holding the
  /// phone in one hand — so the system panel came up, dismissed itself once
  /// the figure of eight nudged the value under the line, and came straight
  /// back. That loop is the "calibrate every two seconds" the compass was
  /// stuck in. A negative accuracy means Core Location genuinely has nothing,
  /// and that is the only case worth taking the screen over; anything coarse
  /// but usable is covered by the app's own hint.
  func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
    guard let heading = manager.heading else { return false }
    return heading.headingAccuracy < 0
  }

  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    unavailable("Der Standort konnte nicht bestimmt werden.")
  }

  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    if status != .authorizedAlways && status != .authorizedWhenInUse {
      unavailable("Aktiviere den Standortzugriff für eine genaue Qibla.")
    }
  }

  private var hasLocationPermission: Bool {
    let status: CLAuthorizationStatus
    if #available(iOS 14.0, *) {
      status = locationManager.authorizationStatus
    } else {
      status = CLLocationManager.authorizationStatus()
    }
    return status == .authorizedAlways || status == .authorizedWhenInUse
  }

  private func unavailable(_ reason: String) {
    eventSink?(["reason": reason])
  }

  @objc private func interfaceOrientationDidChange() {
    updateHeadingOrientation()
  }

  private func updateHeadingOrientation() {
    let orientation: UIInterfaceOrientation
    if #available(iOS 13.0, *) {
      orientation = UIApplication.shared.connectedScenes
        .compactMap { $0 as? UIWindowScene }
        .first?.interfaceOrientation ?? .portrait
    } else {
      orientation = UIApplication.shared.statusBarOrientation
    }
    switch orientation {
    case .portraitUpsideDown:
      locationManager.headingOrientation = .portraitUpsideDown
    // UI and physical-device landscape names are opposite. For example, the
    // top edge of a landscape-left interface is the physical device's right.
    case .landscapeLeft:
      locationManager.headingOrientation = .landscapeRight
    case .landscapeRight:
      locationManager.headingOrientation = .landscapeLeft
    default:
      locationManager.headingOrientation = .portrait
    }
  }

  private func normalized(_ degrees: Double) -> Double {
    let remainder = degrees.truncatingRemainder(dividingBy: 360)
    return remainder < 0 ? remainder + 360 : remainder
  }
}
