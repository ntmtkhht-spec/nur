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
      accuracyDegrees != null &&
      accuracyDegrees!.isFinite &&
      accuracyDegrees! >= 0 &&
      accuracyDegrees! <= 15;
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
            trueHeading: heading is num ? heading.toDouble() : null,
            accuracyDegrees: accuracy is num ? accuracy.toDouble() : null,
            unavailableReason: data['reason'] as String?,
          );
        });
  }
}
