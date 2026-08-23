import 'dart:async';

import 'package:flutter/services.dart';

import '../../core/providers/providers.dart';

/// A true-north heading from the platform compass.
///
/// The Qibla bearing is calculated from geographical (not magnetic) north, so
/// the platform is responsible for applying the local magnetic declination.
/// A missing heading is deliberately represented as null rather than being
/// silently treated as north.
class QiblaCompassReading {
  final double? trueHeading;
  final double? accuracyDegrees;
  final String? unavailableReason;

  const QiblaCompassReading({
    required this.trueHeading,
    required this.accuracyDegrees,
    this.unavailableReason,
  });

  bool get isUsable =>
      trueHeading != null &&
      trueHeading!.isFinite &&
      trueHeading! >= 0 &&
      trueHeading! < 360 &&
      accuracyDegrees != null &&
      accuracyDegrees!.isFinite &&
      accuracyDegrees! >= 0 &&
      accuracyDegrees! <= 15;
}

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
/// [QiblaCompassReading.isUsable]'s job, and it already rejects anything worse
/// than 15 degrees; counting the same uncertainty twice only broke the result.
bool isAlignedWithQibla(double relativeDegrees) =>
    relativeDegrees.abs() <= qiblaAlignmentToleranceDegrees;

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
            unavailableReason: data['reason'] as String?,
          );
        });
  }
}
