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

  override init() {
    super.init()
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.headingFilter = 1
    locationManager.headingOrientation = .portrait
  }

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink)
    -> FlutterError? {
    eventSink = events
    guard CLLocationManager.headingAvailable() else {
      unavailable("Kompass wird auf diesem Gerät nicht unterstützt.")
      return nil
    }
    guard hasLocationPermission else {
      unavailable("Aktiviere den Standortzugriff für eine genaue Qibla.")
      return nil
    }
    locationManager.startUpdatingLocation()
    locationManager.startUpdatingHeading()
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    locationManager.stopUpdatingHeading()
    locationManager.stopUpdatingLocation()
    eventSink = nil
    return nil
  }

  func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
    // `trueHeading` is negative until Core Location has a valid location fix.
    guard newHeading.headingAccuracy >= 0, newHeading.trueHeading >= 0 else {
      unavailable("Kompass wird kalibriert. Halte das Gerät flach und bewege es in einer Acht (∞).")
      return
    }
    eventSink?([
      "trueHeading": normalized(newHeading.trueHeading + interfaceOrientationOffset()),
      "accuracyDegrees": newHeading.headingAccuracy,
    ])
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

  private func interfaceOrientationOffset() -> Double {
    let orientation: UIInterfaceOrientation
    if #available(iOS 13.0, *) {
      orientation = UIApplication.shared.connectedScenes
        .compactMap { $0 as? UIWindowScene }
        .first?.interfaceOrientation ?? .portrait
    } else {
      orientation = UIApplication.shared.statusBarOrientation
    }
    switch orientation {
    case .portraitUpsideDown: return 180
    case .landscapeLeft: return -90
    case .landscapeRight: return 90
    default: return 0
    }
  }

  private func normalized(_ degrees: Double) -> Double {
    let remainder = degrees.truncatingRemainder(dividingBy: 360)
    return remainder < 0 ? remainder + 360 : remainder
  }
}
