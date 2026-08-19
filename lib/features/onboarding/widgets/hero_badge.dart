import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Plain circular badge holding a single icon.
///
/// [size] is the diameter of the circle itself.
class HeroBadge extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color? fillColor;

  const HeroBadge({
    super.key,
    required this.icon,
    this.size = 96,
    this.fillColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
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
        size: size * 0.45,
      ),
    );
  }
}
