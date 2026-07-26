import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';

class NextPrayerCard extends ConsumerStatefulWidget {
  const NextPrayerCard({super.key});

  @override
  ConsumerState<NextPrayerCard> createState() => _NextPrayerCardState();
}

class _NextPrayerCardState extends ConsumerState<NextPrayerCard> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prayer = ref.watch(nextPrayerProvider);
    final colors = AppColors.of(context);
    final currentPrayer = ref.watch(currentPrayerProvider);

    final remaining = prayer.time.difference(DateTime.now());
    final hours = remaining.inHours.abs();
    final minutes = (remaining.inMinutes % 60).abs();
    final seconds = (remaining.inSeconds % 60).abs();

    String countdownText;
    if (remaining.isNegative) {
      countdownText = 'jetzt';
    } else if (hours > 0) {
      countdownText = 'in $hours Std $minutes Min';
    } else {
      countdownText = 'in $minutes Min ${seconds.toString().padLeft(2, '0')} Sek';
    }

    double progress = 0.0;
    if (currentPrayer != null) {
      final totalDuration = prayer.time.difference(currentPrayer.time).inSeconds;
      final elapsed = DateTime.now().difference(currentPrayer.time).inSeconds;
      if (totalDuration > 0) {
        progress = (elapsed / totalDuration).clamp(0.0, 1.0);
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: colors.darkGreen,
          borderRadius: AppRadius.circularXl,
          boxShadow: AppShadows.md,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(painter: _IslamicPatternPainter()),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'NÄCHSTES GEBET',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.7),
                        letterSpacing: 1.5,
                      ),
                    ),
                    Text(
                      prayer.arabicName,
                      style: const TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  prayer.name,
                  style: const TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  countdownText,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  prayer.formattedTime,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: colors.accentGold,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                ClipRRect(
                  borderRadius: AppRadius.circularSm,
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(colors.accentGold),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _IslamicPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final cx = size.width * 0.80;
    final cy = size.height * 0.28;

    for (final s in [40.0, 65.0, 90.0, 115.0]) {
      _drawRotatedSquare(canvas, cx, cy, s, 0, paint);
      _drawRotatedSquare(canvas, cx, cy, s, pi / 4, paint);
    }

    _drawRotatedSquare(canvas, cx, cy, 75, pi / 8, paint);
    _drawRotatedSquare(canvas, cx, cy, 100, pi / 8, paint);

    for (final r in [20.0, 45.0, 70.0, 95.0]) {
      canvas.drawCircle(Offset(cx, cy), r, paint);
    }

    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    for (var i = 0; i < 16; i++) {
      final angle = i * pi / 8;
      canvas.drawLine(
        Offset(cx + cos(angle) * 12, cy + sin(angle) * 12),
        Offset(cx + cos(angle) * 95, cy + sin(angle) * 95),
        linePaint,
      );
    }

    final dotPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..style = PaintingStyle.fill;

    for (var i = 0; i < 8; i++) {
      final angle = i * pi / 4;
      for (final r in [30.0, 55.0, 80.0]) {
        canvas.drawCircle(
          Offset(cx + cos(angle) * r, cy + sin(angle) * r),
          2.0,
          dotPaint,
        );
      }
    }
  }

  void _drawRotatedSquare(
    Canvas canvas, double cx, double cy, double size, double angle, Paint paint,
  ) {
    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(angle);
    final half = size / 2;
    canvas.drawRect(Rect.fromLTWH(-half, -half, size, size), paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
