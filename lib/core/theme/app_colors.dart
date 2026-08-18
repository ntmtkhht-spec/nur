import 'package:flutter/material.dart';

class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  final Color darkGreen;
  final Color primaryGreen;
  final Color accentGold;
  final Color goldLight;
  final Color background;
  final Color cardBg;
  final Color textDark;
  final Color textMuted;
  final Color white;

  const AppColorsExtension({
    required this.darkGreen,
    required this.primaryGreen,
    required this.accentGold,
    required this.goldLight,
    required this.background,
    required this.cardBg,
    required this.textDark,
    required this.textMuted,
    required this.white,
  });

  @override
  ThemeExtension<AppColorsExtension> copyWith({
    Color? darkGreen,
    Color? primaryGreen,
    Color? accentGold,
    Color? goldLight,
    Color? background,
    Color? cardBg,
    Color? textDark,
    Color? textMuted,
    Color? white,
  }) {
    return AppColorsExtension(
      darkGreen: darkGreen ?? this.darkGreen,
      primaryGreen: primaryGreen ?? this.primaryGreen,
      accentGold: accentGold ?? this.accentGold,
      goldLight: goldLight ?? this.goldLight,
      background: background ?? this.background,
      cardBg: cardBg ?? this.cardBg,
      textDark: textDark ?? this.textDark,
      textMuted: textMuted ?? this.textMuted,
      white: white ?? this.white,
    );
  }

  @override
  ThemeExtension<AppColorsExtension> lerp(ThemeExtension<AppColorsExtension>? other, double t) {
    if (other is! AppColorsExtension) {
      return this;
    }
    return AppColorsExtension(
      darkGreen: Color.lerp(darkGreen, other.darkGreen, t)!,
      primaryGreen: Color.lerp(primaryGreen, other.primaryGreen, t)!,
      accentGold: Color.lerp(accentGold, other.accentGold, t)!,
      goldLight: Color.lerp(goldLight, other.goldLight, t)!,
      background: Color.lerp(background, other.background, t)!,
      cardBg: Color.lerp(cardBg, other.cardBg, t)!,
      textDark: Color.lerp(textDark, other.textDark, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      white: Color.lerp(white, other.white, t)!,
    );
  }
}

abstract final class AppColors {
  // Legacy static references for non-context usages
  static const darkGreen = Color(0xFF1B4332);
  static const primaryGreen = Color(0xFF2D6A4F);
  static const accentGold = Color(0xFFC8A43E);
  static const goldLight = Color(0xFFF5E6C4);
  static const background = Color(0xFFF8F4EE);
  static const cardBg = Color(0xFFEDE8DF);
  static const textDark = Color(0xFF1C1C1E);
  static const textMuted = Color(0xFF8A8580);
  static const white = Color(0xFFFFFFFF);
  
  static AppColorsExtension get light => const AppColorsExtension(
    darkGreen: Color(0xFF1B4332),
    primaryGreen: Color(0xFF2D6A4F),
    accentGold: Color(0xFFC8A43E), // Needs good contrast
    goldLight: Color(0xFFF5E6C4),
    background: Color(0xFFF8F4EE),
    cardBg: Color(0xFFEDE8DF),
    textDark: Color(0xFF1C1C1E),
    textMuted: Color(0xFF8A8580),
    white: Color(0xFFFFFFFF),
  );

  static AppColorsExtension of(BuildContext context) {
    return Theme.of(context).extension<AppColorsExtension>() ?? light;
  }
}
