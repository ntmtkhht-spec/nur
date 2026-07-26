import 'dart:math';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Circular decorative badge with a radiating pattern behind a central icon.
/// Reused across onboarding screens to keep a consistent visual language.
class HeroBadge extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color? fillColor;

  const HeroBadge({
    super.key,
    required this.icon,
    this.size = 160,
    this.fillColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _RadialPatternPainter(),
          ),
          Container(
            width: size * 0.44,
            height: size * 0.44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: fillColor ?? AppColors.darkGreen,
              boxShadow: [
                BoxShadow(
                  color: AppColors.darkGreen.withValues(alpha: 0.25),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: AppColors.white,
              size: size * 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _RadialPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final maxR = size.shortestSide / 2;

    final ringPaint = Paint()
      ..color = AppColors.accentGold.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    for (final f in [0.62, 0.78, 0.94]) {
      canvas.drawCircle(center, maxR * f, ringPaint);
    }

    final linePaint = Paint()
      ..color = AppColors.accentGold.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (var i = 0; i < 8; i++) {
      final angle = i * pi / 4;
      canvas.drawLine(
        Offset(
          center.dx + cos(angle) * maxR * 0.62,
          center.dy + sin(angle) * maxR * 0.62,
        ),
        Offset(
          center.dx + cos(angle) * maxR * 0.94,
          center.dy + sin(angle) * maxR * 0.94,
        ),
        linePaint,
      );
    }

    final dotPaint = Paint()
      ..color = AppColors.accentGold.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    for (var i = 0; i < 8; i++) {
      final angle = i * pi / 4 + pi / 8;
      canvas.drawCircle(
        Offset(
          center.dx + cos(angle) * maxR * 0.94,
          center.dy + sin(angle) * maxR * 0.94,
        ),
        2.2,
        dotPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
