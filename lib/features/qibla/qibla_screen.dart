import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../core/providers/providers.dart';
import '../../core/theme/app_colors.dart';

class QiblaScreen extends ConsumerStatefulWidget {
  const QiblaScreen({super.key});

  @override
  ConsumerState<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends ConsumerState<QiblaScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final qiblaBearing = ref.watch(qiblaBearingProvider);
    final distanceKm = ref.watch(distanceToKaabaProvider);

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
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<CompassEvent?>(
                stream: FlutterCompass.events,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return _CompassUnavailable(
                      message: 'Kompass nicht verfügbar auf diesem Gerät.',
                    );
                  }
                  if (FlutterCompass.events == null) {
                    return _CompassUnavailable(
                      message: 'Kompass wird nicht unterstützt.',
                    );
                  }

                  final heading = snapshot.data?.heading;
                  if (heading == null && !snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: colors.primaryGreen,
                      ),
                    );
                  }

                  final currentHeading = heading ?? 0;
                  final relative = _relativeAngle(
                    qiblaBearing - currentHeading,
                  );
                  final aligned = relative.abs() <= 5;

                  return _QiblaBody(
                    qiblaBearing: qiblaBearing,
                    deviceHeading: currentHeading,
                    distanceKm: distanceKm,
                    aligned: aligned,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  static double _relativeAngle(double raw) {
    var a = raw % 360;
    if (a > 180) a -= 360;
    if (a < -180) a += 360;
    return a;
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

// ---------------------------------------------------------------------------
// Body
// ---------------------------------------------------------------------------

class _QiblaBody extends StatelessWidget {
  final double qiblaBearing;
  final double deviceHeading;
  final double distanceKm;
  final bool aligned;

  const _QiblaBody({
    required this.qiblaBearing,
    required this.deviceHeading,
    required this.distanceKm,
    required this.aligned,
  });

  @override
  Widget build(BuildContext context) {
    final relative = _normalizeRelative(qiblaBearing - deviceHeading);

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

  double _normalizeRelative(double raw) {
    var a = raw % 360;
    if (a > 180) a -= 360;
    if (a < -180) a += 360;
    return a;
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

    const cardinals = {0: 'N', 90: 'E', 180: 'S', 270: 'W'};
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

class _CompassUnavailable extends StatelessWidget {
  final String message;

  const _CompassUnavailable({required this.message});

  @override
  Widget build(BuildContext context) {
    final distanceKm = 0.0;
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
          const SizedBox(height: 8),
          Text(
            'Distanz: $distanceKm km',
            style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
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
