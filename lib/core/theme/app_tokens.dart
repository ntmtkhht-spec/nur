import 'package:flutter/material.dart';

abstract final class AppSpacing {
  static const double xxs = 4.0;
  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 20.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
}

abstract final class AppRadius {
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double pill = 999.0;

  static final BorderRadius circularSm = BorderRadius.circular(sm);
  static final BorderRadius circularMd = BorderRadius.circular(md);
  static final BorderRadius circularLg = BorderRadius.circular(lg);
  static final BorderRadius circularXl = BorderRadius.circular(xl);
}

abstract final class AppShadows {
  static final List<BoxShadow> sm = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  static final List<BoxShadow> md = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];
  
  static final List<BoxShadow> glowGold = [
    BoxShadow(
      color: const Color(0xFFC8A43E).withValues(alpha: 0.3),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];
}
