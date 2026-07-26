import 'dart:math' as math;

import 'package:flutter/material.dart';
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
    final qiblaBearing = ref.watch(qiblaBearingProvider);
    final distanceKm = ref.watch(distanceToKaabaProvider);

    return SafeArea(
      child: Column(
        children: [
          _Header(onCalibrate: _showCalibrateHint),
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
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryGreen,
                    ),
                  );
                }

                final currentHeading = heading ?? 0;
                final relative = _relativeAngle(qiblaBearing - currentHeading);
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
      const SnackBar(
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
// Header
// ---------------------------------------------------------------------------

class _Header extends StatelessWidget {
  final VoidCallback onCalibrate;

  const _Header({required this.onCalibrate});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Row(
        children: [
          const SizedBox(width: 48),
          const Expanded(
            child: Center(
              child: Text(
                'Qibla',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.gps_fixed,
                color: AppColors.primaryGreen, size: 22),
            onPressed: onCalibrate,
          ),
        ],
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
    final relative = qiblaBearing - deviceHeading;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 8),
          _KaabaMarker(),
          const SizedBox(height: 6),
          _Compass(
            deviceHeading: deviceHeading,
            qiblaRelative: relative,
          ),
          const SizedBox(height: 24),
          _AlignmentBanner(aligned: aligned),
          const SizedBox(height: 14),
          Text(
            'Entfernung nach Mekka: ${_formatKm(distanceKm)} km',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textMuted,
            ),
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

class _KaabaMarker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 46,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.accentGold.withValues(alpha: 0.15),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
            border: Border.all(
              color: AppColors.accentGold.withValues(alpha: 0.4),
              width: 1,
            ),
          ),
          child: const Center(
            child: Icon(
              Icons.holiday_village_rounded,
              size: 26,
              color: AppColors.accentGold,
            ),
          ),
        ),
        CustomPaint(
          size: const Size(20, 12),
          painter: _TrianglePainter(color: AppColors.accentGold),
        ),
      ],
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;

  _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_TrianglePainter old) => old.color != color;
}

// ---------------------------------------------------------------------------
// Compass
// ---------------------------------------------------------------------------

class _Compass extends StatelessWidget {
  final double deviceHeading;
  final double qiblaRelative;

  const _Compass({
    required this.deviceHeading,
    required this.qiblaRelative,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = math.min(constraints.maxWidth, 380).toDouble();
        return SizedBox(
          width: size,
          height: size,
          child: Stack(
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
                bottom: size * 0.32,
                child: Text(
                  '${qiblaRelative.abs().round()}° ${_cardinal(qiblaRelative)}',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkGreen,
                  ),
                ),
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

class _CompassDialPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final outerRadius = size.width / 2;
    final innerRadius = outerRadius * 0.72;

    // Outer ring background
    canvas.drawCircle(
      center,
      outerRadius,
      Paint()..color = AppColors.accentGold.withValues(alpha: 0.08),
    );

    // Outer ring border
    canvas.drawCircle(
      center,
      outerRadius,
      Paint()
        ..color = AppColors.accentGold.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Inner ring border
    canvas.drawCircle(
      center,
      innerRadius,
      Paint()
        ..color = AppColors.accentGold.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    // Tick marks around outer ring
    final tickPaint = Paint()
      ..color = AppColors.accentGold.withValues(alpha: 0.65)
      ..strokeWidth = 1;
    for (var deg = 0; deg < 360; deg += 2) {
      final major = deg % 30 == 0;
      final medium = deg % 10 == 0;
      final tickLen = major ? 12.0 : (medium ? 7.0 : 3.5);
      final angle = (deg - 90) * math.pi / 180.0;
      final outer = Offset(
        center.dx + math.cos(angle) * (outerRadius - 6),
        center.dy + math.sin(angle) * (outerRadius - 6),
      );
      final inner = Offset(
        center.dx + math.cos(angle) * (outerRadius - 6 - tickLen),
        center.dy + math.sin(angle) * (outerRadius - 6 - tickLen),
      );
      tickPaint.color = major
          ? AppColors.accentGold.withValues(alpha: 0.9)
          : AppColors.accentGold.withValues(alpha: 0.55);
      tickPaint.strokeWidth = major ? 2 : 1;
      canvas.drawLine(inner, outer, tickPaint);
    }

    // Degree labels: 0, 30, 60, 90, ...
    final labelStyle = TextStyle(
      fontSize: size.width * 0.038,
      color: AppColors.accentGold.withValues(alpha: 0.9),
      fontWeight: FontWeight.w600,
    );
    for (var deg = 0; deg < 360; deg += 30) {
      final angle = (deg - 90) * math.pi / 180.0;
      final r = outerRadius - 34;
      final pos = Offset(
        center.dx + math.cos(angle) * r,
        center.dy + math.sin(angle) * r,
      );
      final label = deg == 0
          ? '0'
          : deg == 273
              ? '273'
              : deg.toString();
      final tp = TextPainter(
        text: TextSpan(text: label, style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
    }

    // Cardinal Arabic letters: ش (N), خ (E), ج (S), غ (W)
    const cardinals = {
      0: 'ش',
      90: 'خ',
      180: 'ج',
      270: 'غ',
    };
    final arabicStyle = TextStyle(
      fontSize: size.width * 0.07,
      color: AppColors.darkGreen,
      fontWeight: FontWeight.w700,
    );
    cardinals.forEach((deg, letter) {
      final angle = (deg - 90) * math.pi / 180.0;
      final r = innerRadius + (outerRadius - innerRadius) * 0.15;
      final pos = Offset(
        center.dx + math.cos(angle) * r,
        center.dy + math.sin(angle) * r,
      );
      final tp = TextPainter(
        text: TextSpan(text: letter, style: arabicStyle),
        textDirection: TextDirection.rtl,
      )..layout();
      tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
    });

    // Inner Islamic star pattern (decorative)
    _drawStarPattern(canvas, center, innerRadius * 0.9);
  }

  void _drawStarPattern(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = AppColors.accentGold.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (final r in [radius * 0.4, radius * 0.6, radius * 0.8]) {
      _drawEightPointStar(canvas, center, r, paint);
    }
  }

  void _drawEightPointStar(
    Canvas canvas, Offset center, double radius, Paint paint,
  ) {
    _drawSquare(canvas, center, radius, 0, paint);
    _drawSquare(canvas, center, radius, math.pi / 4, paint);
  }

  void _drawSquare(
    Canvas canvas, Offset center, double r, double rotation, Paint paint,
  ) {
    final path = Path();
    for (var i = 0; i < 4; i++) {
      final angle = rotation + i * math.pi / 2;
      final p = Offset(
        center.dx + math.cos(angle) * r,
        center.dy + math.sin(angle) * r,
      );
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
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

    // Needle
    final needlePaint = Paint()
      ..color = AppColors.darkGreen
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      center,
      Offset(center.dx, center.dy - needleLen),
      needlePaint,
    );

    // Arrow head (triangle)
    final headPath = Path()
      ..moveTo(center.dx, center.dy - needleLen - 14)
      ..lineTo(center.dx - 10, center.dy - needleLen + 4)
      ..lineTo(center.dx + 10, center.dy - needleLen + 4)
      ..close();
    canvas.drawPath(headPath, Paint()..color = AppColors.darkGreen);

    // Center dot
    canvas.drawCircle(
      center,
      8,
      Paint()..color = AppColors.accentGold,
    );
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: aligned
            ? AppColors.darkGreen
            : AppColors.cardBg,
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
            aligned
                ? 'Ausgerichtet — Richtung Mekka'
                : 'Drehe dich zur Kaaba',
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
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Distanz: $distanceKm km',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textMuted,
            ),
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
