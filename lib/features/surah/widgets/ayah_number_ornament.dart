import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class AyahNumberOrnament extends StatelessWidget {
  final int number;
  final double size;

  const AyahNumberOrnament({super.key, required this.number, this.size = 48});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Vers $number',
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(
          painter: const _AyahNumberOrnamentPainter(AppColors.darkGreen),
          child: Center(
            child: Text(
              '$number',
              style: TextStyle(
                color: AppColors.darkGreen,
                fontSize: size * (number >= 100 ? 0.21 : 0.25),
                fontWeight: FontWeight.w800,
                height: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AyahNumberOrnamentPainter extends CustomPainter {
  final Color color;

  const _AyahNumberOrnamentPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final outerRadius = math.min(size.width, size.height) / 2 - 3;
    const pointCount = 16;
    final points = <Offset>[];

    for (var index = 0; index < pointCount; index++) {
      final angle = -math.pi / 2 + index * 2 * math.pi / pointCount;
      final radius = index.isEven ? outerRadius : outerRadius - 3;
      points.add(
        center + Offset(math.cos(angle) * radius, math.sin(angle) * radius),
      );
    }

    Offset midpoint(Offset first, Offset second) =>
        Offset((first.dx + second.dx) / 2, (first.dy + second.dy) / 2);

    final outline = Path()
      ..moveTo(
        midpoint(points.last, points.first).dx,
        midpoint(points.last, points.first).dy,
      );
    for (var index = 0; index < points.length; index++) {
      final point = points[index];
      final next = points[(index + 1) % points.length];
      final end = midpoint(point, next);
      outline.quadraticBezierTo(point.dx, point.dy, end.dx, end.dy);
    }
    outline.close();

    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.35
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(outline, stroke);
    canvas.drawCircle(center, outerRadius - 5.5, stroke..strokeWidth = 1);

    final accent = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(center.dx, center.dy - outerRadius + 1.5),
      2.2,
      accent,
    );
    canvas.drawCircle(
      Offset(center.dx, center.dy + outerRadius - 1.5),
      2.2,
      accent,
    );
  }

  @override
  bool shouldRepaint(covariant _AyahNumberOrnamentPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
