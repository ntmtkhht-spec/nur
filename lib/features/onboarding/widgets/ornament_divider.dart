import 'dart:math';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class OrnamentDivider extends StatelessWidget {
  const OrnamentDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 24,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _diamond(),
          _line(),
          _ornament(),
          _line(),
          _diamond(),
        ],
      ),
    );
  }

  Widget _diamond() {
    return Transform.rotate(
      angle: pi / 4,
      child: Container(
        width: 5,
        height: 5,
        color: AppColors.accentGold.withValues(alpha: 0.6),
      ),
    );
  }

  Widget _line() {
    return Container(
      width: 50,
      height: 1,
      color: AppColors.accentGold.withValues(alpha: 0.3),
    );
  }

  Widget _ornament() {
    return Container(
      width: 28,
      height: 28,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: CustomPaint(painter: _OrnamentPainter()),
    );
  }
}

class _OrnamentPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final paint = Paint()
      ..color = AppColors.accentGold.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    canvas.drawCircle(center, 10, paint);

    for (var i = 0; i < 8; i++) {
      final angle = i * pi / 4;
      final outer = Offset(
        center.dx + cos(angle) * 10,
        center.dy + sin(angle) * 10,
      );
      final inner = Offset(
        center.dx + cos(angle) * 5,
        center.dy + sin(angle) * 5,
      );
      canvas.drawLine(inner, outer, paint);
    }

    canvas.drawCircle(center, 3, paint..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
