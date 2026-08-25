import 'dart:async';

import 'package:flutter/services.dart';

import '../../core/providers/providers.dart';
import '../../l10n/app_localizations.dart';

/// Why the platform compass has nothing to show.
///
/// The platform code sends one of these codes rather than a sentence: it used
/// to send German text that Dart rendered unchanged, so an English, French,
/// Turkish or Arabic device got a German message. [describeQiblaUnavailable]
/// owns the wording.
enum QiblaUnavailableReason {
  unsupported,
  noLocationPermission,
  calibrating,
  noLocation;

  static QiblaUnavailableReason? fromCode(Object? code) {
    if (code is! String) return null;
    for (final reason in values) {
      if (reason.name == code) return reason;
    }
    return null;
  }
}

String describeQiblaUnavailable(
  AppLocalizations l10n,
  QiblaUnavailableReason reason,
) {
  return switch (reason) {
    QiblaUnavailableReason.unsupported => l10n.qiblaCompassUnsupported,
    QiblaUnavailableReason.noLocationPermission =>
      l10n.qiblaNoLocationForCompass,
    QiblaUnavailableReason.calibrating => l10n.qiblaCalibrating,
    QiblaUnavailableReason.noLocation => l10n.qiblaNoLocationFix,
  };
}

/// A true-north heading from the platform compass.
///
/// The Qibla bearing is calculated from geographical (not magnetic) north, so
/// the platform is responsible for applying the local magnetic declination.
/// A missing heading is deliberately represented as null rather than being
/// silently treated as north.
class QiblaCompassReading {
  final double? trueHeading;
  final double? accuracyDegrees;
  final QiblaUnavailableReason? unavailableReason;

  const QiblaCompassReading({
    required this.trueHeading,
    required this.accuracyDegrees,
    this.unavailableReason,
  });

  bool get _hasHeading =>
      trueHeading != null &&
      trueHeading!.isFinite &&
      trueHeading! >= 0 &&
      trueHeading! < 360;

  bool get _hasAccuracy =>
      accuracyDegrees != null &&
      accuracyDegrees!.isFinite &&
      accuracyDegrees! >= 0;

  bool get isUsable =>
      _hasHeading &&
      _hasAccuracy &&
      accuracyDegrees! <= qiblaMaxTrustedAccuracyDegrees;

  /// Whether the heading is worth showing but worth warning about.
  ///
  /// A usable reading that is this coarse still points the right way to
  /// within a quadrant, which is enough to pray by, but the user should know
  /// that a figure-of-eight would sharpen it.
  bool get needsCalibration =>
      isUsable && accuracyDegrees! > qiblaCalibrationHintAccuracyDegrees;
}

/// The worst heading accuracy that is still shown as a direction.
///
/// Anything coarser than this is a guess, not a bearing, and is replaced by
/// the calibration screen. It is deliberately not the same as
/// [qiblaCalibrationHintAccuracyDegrees]: the gate used to sit at 15 degrees,
/// which is the accuracy a *well* calibrated phone reports — iOS routinely
/// says 10-15 and Android maps its MEDIUM sensor status to 20 — so the
/// compass spent most of its life hidden behind "please calibrate" even
/// though the heading underneath it was fine.
const qiblaMaxTrustedAccuracyDegrees = 30.0;

/// Above this accuracy the direction is shown with a calibration hint.
const qiblaCalibrationHintAccuracyDegrees = 15.0;

/// How far off the Qibla the device may point and still count as facing it.
///
/// Wide enough to be reachable while holding a phone, narrow enough that the
/// Kaaba marker is visibly under the needle when it is met.
const qiblaAlignmentToleranceDegrees = 5.0;

/// Whether a heading [relativeDegrees] off the Qibla counts as facing it.
///
/// Sensor uncertainty is deliberately not subtracted from the tolerance here.
/// It used to be — the rule was `|relative| + accuracy <= 5` — but iOS reports
/// a heading accuracy of 10-15 degrees even on a well calibrated device, so no
/// real reading could ever satisfy it and the "aligned" state was unreachable.
/// Deciding whether a reading can be trusted at all is
/// [QiblaCompassReading.isUsable]'s job; counting the same uncertainty twice
/// only broke the result.
bool isAlignedWithQibla(double relativeDegrees) =>
    relativeDegrees.abs() <= qiblaAlignmentToleranceDegrees;

/// Wraps [degrees] into `[0, 360)`.
double normalizeDegrees(double degrees) {
  final wrapped = degrees % 360;
  return wrapped < 0 ? wrapped + 360 : wrapped;
}

/// Wraps [degrees] into `(-180, 180]`, i.e. the shortest turn either way.
double normalizeRelativeDegrees(double degrees) {
  var a = degrees % 360;
  if (a > 180) a -= 360;
  if (a < -180) a += 360;
  return a;
}

/// How much of each new heading is adopted per sensor event.
///
/// The raw magnetometer wobbles by a few degrees even when the phone is lying
/// still, which is what made the needle twitch rather than point.
const _headingSmoothingFactor = 0.25;

/// A turn larger than this is the user moving, not the sensor wobbling, and
/// is followed immediately instead of being eased into.
const _headingSnapDegrees = 40.0;

/// Eases [next] into [previous] along the shortest arc across 0/360.
///
/// Averaging the two numbers directly would sweep the needle the long way
/// round whenever the heading crosses north (359 -> 1 would read as a 358
/// degree turn), so the blend happens on the relative angle.
double smoothHeading(double? previous, double next) {
  if (previous == null || !previous.isFinite) return normalizeDegrees(next);
  final delta = normalizeRelativeDegrees(next - previous);
  if (delta.abs() >= _headingSnapDegrees) return normalizeDegrees(next);
  return normalizeDegrees(previous + delta * _headingSmoothingFactor);
}

/// Whether two positions are far enough apart to be worth restarting the
/// platform compass for.
///
/// The only thing the platform does with the position is look up the magnetic
/// declination, which moves by well under a tenth of a degree over this
/// distance. Resubscribing costs far more than it buys: every restart drops
/// the sensor back to "unknown accuracy" on Android and to a negative true
/// heading on iOS, which is exactly the flicker back to the calibration
/// screen that made the compass feel broken while walking around.
bool isWorthRestartingCompass(LocationData previous, LocationData next) {
  const thresholdDegrees = 0.05; // roughly 5 km
  return (previous.lat - next.lat).abs() > thresholdDegrees ||
      (previous.lng - next.lng).abs() > thresholdDegrees;
}

class QiblaCompass {
  static const _events = EventChannel('com.munir.app/qibla_heading');

  static Stream<QiblaCompassReading> trueNorthEvents(LocationData location) {
    return _events
        .receiveBroadcastStream(<String, double>{
          'latitude': location.lat,
          'longitude': location.lng,
        })
        .map((event) {
          final data = Map<Object?, Object?>.from(event as Map);
          final heading = data['trueHeading'];
          final accuracy = data['accuracyDegrees'];
          return QiblaCompassReading(
            // Platform code normalizes the value. Keep this guard here as
            // well so a malformed sensor event can never be rendered as a
            // convincing but false Qibla direction.
            trueHeading:
                heading is num &&
                    heading.isFinite &&
                    heading >= 0 &&
                    heading < 360
                ? heading.toDouble()
                : null,
            accuracyDegrees: accuracy is num ? accuracy.toDouble() : null,
            unavailableReason: QiblaUnavailableReason.fromCode(
              data['reason'],
            ),
          );
        });
  }
}
