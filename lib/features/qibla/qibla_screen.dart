import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../core/providers/providers.dart';
import '../../core/theme/app_colors.dart';
import 'qibla_compass.dart';

class QiblaScreen extends ConsumerStatefulWidget {
  const QiblaScreen({super.key});

  @override
  ConsumerState<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends ConsumerState<QiblaScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locationAsync = ref.watch(locationProvider);

    final colors = AppColors.of(context);

    // Own Scaffold, so the screen works both as a bottom-nav tab and when
    // pushed from the home grid. Without one, a pushed route has no Material
    // ancestor: the background renders black and text falls back to Flutter's
    // monospace-with-yellow-underline style.
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(
          l10n.qiblaTitle,
          style: TextStyle(color: colors.textDark, fontWeight: FontWeight.bold),
        ),
        backgroundColor: colors.background,
        iconTheme: IconThemeData(color: colors.primaryGreen),
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Kompass kalibrieren',
            icon: Icon(Icons.gps_fixed, size: 22, color: colors.primaryGreen),
            onPressed: _showCalibrateHint,
          ),
        ],
      ),
      body: SafeArea(
        child: switch (locationAsync) {
          AsyncData(:final value) when !value.isFallback => _QiblaCompassView(
            location: value,
          ),
          AsyncData() => _CompassUnavailable(
            message:
                'Für eine genaue Qibla benötigst du deinen aktuellen Standort.',
          ),
          AsyncError() => _CompassUnavailable(
            message:
                'Der Standort ist nicht verfügbar. Bitte aktiviere ihn in den Einstellungen.',
          ),
          _ => Center(
            child: CircularProgressIndicator(color: colors.primaryGreen),
          ),
        },
      ),
    );
  }

  void _showCalibrateHint() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Bewege dein Gerät in einer Acht (∞), um den Kompass zu kalibrieren.',
        ),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 3),
      ),
    );
  }
}

class _QiblaCompassView extends StatefulWidget {
  final LocationData location;

  const _QiblaCompassView({required this.location});

  @override
  State<_QiblaCompassView> createState() => _QiblaCompassViewState();
}

class _QiblaCompassViewState extends State<_QiblaCompassView>
    with SingleTickerProviderStateMixin {
  StreamSubscription<QiblaCompassReading>? _subscription;

  /// Drives the needle between sensor events so it finishes a turn instead
  /// of stopping a few degrees short of it. Runs only while there is ground
  /// left to cover.
  late final Ticker _ticker = createTicker(_onTick);
  Duration _lastTick = Duration.zero;

  /// The heading the sensor last reported, which the needle is heading for.
  double? _targetHeading;

  /// The heading actually drawn: the raw sensor value eased along the
  /// shortest arc, so the needle points instead of twitching.
  double? _smoothedHeading;

  /// The last reading good enough to draw.
  ///
  /// Kept so that a single coarse or momentarily invalid event — which every
  /// platform emits while the phone is picked up or turned — does not tear
  /// the whole dial down and replace it with the calibration screen.
  QiblaCompassReading? _lastUsable;

  Object? _error;
  String? _unavailableReason;

  /// Held across readings so the hint has hysteresis: it goes up at one
  /// accuracy and only comes down at a better one.
  bool _calibrationHint = false;

  @override
  void initState() {
    super.initState();
    _subscribe();
  }

  @override
  void didUpdateWidget(_QiblaCompassView old) {
    super.didUpdateWidget(old);
    // The position feeds only the magnetic declination lookup, so a few
    // hundred metres of GPS drift is no reason to restart the sensor and
    // throw the user back to "calibrating".
    if (isWorthRestartingCompass(old.location, widget.location)) {
      _subscribe();
    }
  }

  void _subscribe() {
    _subscription?.cancel();
    _error = null;
    _subscription = QiblaCompass.trueNorthEvents(widget.location).listen(
      _onReading,
      onError: (Object e) {
        if (mounted) setState(() => _error = e);
      },
    );
  }

  void _onTick(Duration elapsed) {
    final target = _targetHeading;
    final current = _smoothedHeading;
    if (target == null || current == null) {
      _ticker.stop();
      return;
    }
    final dt = (elapsed - _lastTick).inMicroseconds / 1e6;
    _lastTick = elapsed;
    final next = stepHeadingTowards(current, target, dt);
    if (normalizeRelativeDegrees(next - current).abs() < 0.01) {
      _ticker.stop();
      if (next != current) setState(() => _smoothedHeading = next);
      return;
    }
    setState(() => _smoothedHeading = next);
  }

  void _startCatchUp() {
    if (_ticker.isTicking) return;
    _lastTick = Duration.zero;
    _ticker.start();
  }

  void _onReading(QiblaCompassReading reading) {
    if (!mounted) return;
    if (!reading.isUsable) {
      // Remember why, but keep showing the last good direction if there is
      // one; only a compass that never worked shows the bare hint screen.
      if (_unavailableReason != reading.unavailableReason) {
        setState(() => _unavailableReason = reading.unavailableReason);
      }
      return;
    }

    _targetHeading = reading.trueHeading;
    final smoothed = smoothHeading(_smoothedHeading, reading.trueHeading!);
    // Whatever this event does not cover, the ticker finishes.
    _startCatchUp();
    final movedEnough =
        _smoothedHeading == null ||
        normalizeRelativeDegrees(smoothed - _smoothedHeading!).abs() >= 0.2;
    final hint = _calibrationHint
        ? reading.keepsCalibrationHint
        : reading.needsCalibration;
    final qualityChanged =
        hint != _calibrationHint || _unavailableReason != null;
    if (!movedEnough && !qualityChanged) {
      _lastUsable = reading;
      return;
    }
    setState(() {
      _smoothedHeading = smoothed;
      _lastUsable = reading;
      _calibrationHint = hint;
      _unavailableReason = null;
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    if (_error != null && _smoothedHeading == null) {
      return const _CompassUnavailable(
        message: 'Kompass nicht verfügbar auf diesem Gerät.',
      );
    }

    final reading = _lastUsable;
    final heading = _smoothedHeading;
    if (reading == null || heading == null) {
      if (_unavailableReason != null) {
        return _CompassUnavailable(message: _unavailableReason!);
      }
      return Center(
        child: CircularProgressIndicator(color: colors.primaryGreen),
      );
    }

    final qiblaBearing = calculateQiblaBearing(widget.location);
    final distanceKm = calculateDistanceToKaabaKm(widget.location);
    final relative = normalizeRelativeDegrees(qiblaBearing - heading);

    return _QiblaBody(
      qiblaBearing: qiblaBearing,
      deviceHeading: heading,
      relative: relative,
      distanceKm: distanceKm,
      // Readings too coarse to trust never reach here, so the tolerance is
      // purely about where the device points.
      aligned: isAlignedWithQibla(relative),
      needsCalibration: _calibrationHint,
    );
  }
}

// ---------------------------------------------------------------------------
// Body
// ---------------------------------------------------------------------------

class _QiblaBody extends StatelessWidget {
  final double qiblaBearing;
  final double deviceHeading;
  final double relative;
  final double distanceKm;
  final bool aligned;
  final bool needsCalibration;

  const _QiblaBody({
    required this.qiblaBearing,
    required this.deviceHeading,
    required this.relative,
    required this.distanceKm,
    required this.aligned,
    required this.needsCalibration,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 14),
          _Compass(
            qiblaBearing: qiblaBearing,
            deviceHeading: deviceHeading,
            qiblaRelative: relative,
          ),
          const SizedBox(height: 24),
          _AlignmentBanner(aligned: aligned),
          if (needsCalibration) ...[
            const SizedBox(height: 10),
            const _CalibrationHint(),
          ],
          const SizedBox(height: 14),
          Text(
            'Entfernung nach Mekka: ${_formatKm(distanceKm)} km',
            style: const TextStyle(fontSize: 14, color: AppColors.textMuted),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  String _formatKm(double km) {
    final rounded = km.round();
    final s = rounded.toString();
    // Add German thousands separator (dot)
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}

// ---------------------------------------------------------------------------
// Compass
// ---------------------------------------------------------------------------

class _Compass extends StatelessWidget {
  final double qiblaBearing;
  final double deviceHeading;
  final double qiblaRelative;

  const _Compass({
    required this.qiblaBearing,
    required this.deviceHeading,
    required this.qiblaRelative,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = math.min(constraints.maxWidth, 380).toDouble();
        final markerSize = math.min(size * 0.14, 54.0);
        const markerGap = 8.0;
        return SizedBox(
          width: size,
          height: size + markerSize + markerGap,
          child: Column(
            children: [
              _KaabaMarker(size: markerSize),
              const SizedBox(height: markerGap),
              Stack(
                alignment: Alignment.center,
                children: [
                  Transform.rotate(
                    angle: -deviceHeading * math.pi / 180.0,
                    child: CustomPaint(
                      size: Size(size, size),
                      painter: _CompassDialPainter(),
                    ),
                  ),
                  Transform.rotate(
                    angle: qiblaRelative * math.pi / 180.0,
                    child: CustomPaint(
                      size: Size(size, size),
                      painter: _QiblaNeedlePainter(),
                    ),
                  ),
                  Positioned(
                    bottom: size * 0.16,
                    child: _BearingPill(
                      bearing: qiblaBearing,
                      cardinal: _cardinal(qiblaBearing),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String _cardinal(double rel) {
    // Kompass-Richtungsbeschreibung des Qibla-Bearing
    final normalized = (rel + 360) % 360;
    if (normalized < 22.5 || normalized >= 337.5) return 'N';
    if (normalized < 67.5) return 'NO';
    if (normalized < 112.5) return 'O';
    if (normalized < 157.5) return 'SO';
    if (normalized < 202.5) return 'S';
    if (normalized < 247.5) return 'SW';
    if (normalized < 292.5) return 'W';
    return 'NW';
  }
}

class _KaabaMarker extends StatelessWidget {
  final double size;

  const _KaabaMarker({required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        'assets/images/kaaba-qibla-icon.png',
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}

class _BearingPill extends StatelessWidget {
  final double bearing;
  final String cardinal;

  const _BearingPill({required this.bearing, required this.cardinal});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.goldLight),
      ),
      child: Text(
        '${bearing.round()}° $cardinal',
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: AppColors.darkGreen,
        ),
      ),
    );
  }
}

class _CompassDialPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final outerRadius = size.width / 2 - 2;
    final middleRadius = outerRadius * 0.78;
    final innerRadius = outerRadius * 0.48;

    final surface = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: 0.96),
          AppColors.goldLight.withValues(alpha: 0.34),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: outerRadius));
    canvas.drawCircle(center, outerRadius, surface);

    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = AppColors.accentGold.withValues(alpha: 0.42);
    canvas.drawCircle(center, outerRadius, ringPaint);
    canvas.drawCircle(
      center,
      middleRadius,
      ringPaint..color = AppColors.accentGold.withValues(alpha: 0.22),
    );
    canvas.drawCircle(
      center,
      innerRadius,
      ringPaint..color = AppColors.darkGreen.withValues(alpha: 0.08),
    );

    final tickPaint = Paint()
      ..color = AppColors.accentGold.withValues(alpha: 0.48)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1;
    for (var deg = 0; deg < 360; deg += 5) {
      final major = deg % 30 == 0;
      final tickLen = major ? 13.0 : 5.0;
      final angle = (deg - 90) * math.pi / 180.0;
      final outer = Offset(
        center.dx + math.cos(angle) * (outerRadius - 12),
        center.dy + math.sin(angle) * (outerRadius - 12),
      );
      final inner = Offset(
        center.dx + math.cos(angle) * (outerRadius - 12 - tickLen),
        center.dy + math.sin(angle) * (outerRadius - 12 - tickLen),
      );
      tickPaint.color = major
          ? AppColors.accentGold.withValues(alpha: 0.7)
          : AppColors.accentGold.withValues(alpha: 0.26);
      tickPaint.strokeWidth = major ? 1.8 : 1;
      canvas.drawLine(inner, outer, tickPaint);
    }

    const cardinals = {0: 'N', 90: 'O', 180: 'S', 270: 'W'};
    final cardinalStyle = TextStyle(
      fontSize: size.width * 0.045,
      color: AppColors.darkGreen.withValues(alpha: 0.74),
      fontWeight: FontWeight.w800,
    );
    cardinals.forEach((deg, letter) {
      final angle = (deg - 90) * math.pi / 180.0;
      final r = middleRadius + (outerRadius - middleRadius) * 0.32;
      final pos = Offset(
        center.dx + math.cos(angle) * r,
        center.dy + math.sin(angle) * r,
      );
      final tp = TextPainter(
        text: TextSpan(text: letter, style: cardinalStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
    });
  }

  @override
  bool shouldRepaint(_CompassDialPainter old) => false;
}

class _QiblaNeedlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;
    final needleLen = radius * 0.55;

    final needlePaint = Paint()
      ..color = AppColors.darkGreen
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      center,
      Offset(center.dx, center.dy - needleLen),
      needlePaint,
    );

    final headPath = Path()
      ..moveTo(center.dx, center.dy - needleLen - 14)
      ..lineTo(center.dx - 10, center.dy - needleLen + 4)
      ..lineTo(center.dx + 10, center.dy - needleLen + 4)
      ..close();
    canvas.drawPath(headPath, Paint()..color = AppColors.darkGreen);

    canvas.drawCircle(center, 8, Paint()..color = AppColors.accentGold);
    canvas.drawCircle(
      center,
      8,
      Paint()
        ..color = AppColors.darkGreen
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(_QiblaNeedlePainter old) => false;
}

// ---------------------------------------------------------------------------
// Banners
// ---------------------------------------------------------------------------

class _AlignmentBanner extends StatelessWidget {
  final bool aligned;

  const _AlignmentBanner({required this.aligned});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: aligned ? AppColors.darkGreen : AppColors.cardBg,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            aligned ? Icons.check_circle_outline : Icons.explore_outlined,
            color: aligned ? AppColors.white : AppColors.textMuted,
            size: 22,
          ),
          const SizedBox(width: 12),
          Text(
            aligned ? l10n.qiblaAligned : l10n.qiblaTurnToKaaba,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: aligned ? AppColors.white : AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}

/// Shown alongside a usable but coarse heading.
///
/// The direction under it is still good to within a quadrant, so the compass
/// stays on screen; this only says it could be sharper.
class _CalibrationHint extends StatelessWidget {
  const _CalibrationHint();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.goldLight.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        children: [
          Icon(Icons.gps_not_fixed, size: 18, color: AppColors.textMuted),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Richtung ist ungenau. Bewege dein Gerät in einer Acht (∞).',
              style: TextStyle(fontSize: 13, color: AppColors.textDark),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompassUnavailable extends StatelessWidget {
  final String message;

  const _CompassUnavailable({required this.message});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 40),
          const Icon(
            Icons.explore_off_outlined,
            size: 80,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: 20),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

// Ensure Geolocator import isn't tree-shaken away in case future users
// query permission from within this screen. (No-op.)
// ignore: unused_element
void _ensureGeolocatorLinked() => Geolocator.checkPermission();
