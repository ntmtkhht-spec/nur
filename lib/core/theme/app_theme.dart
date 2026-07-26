import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';

abstract final class AppTheme {
      static ThemeData get light => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.light.background,
        colorSchemeSeed: AppColors.light.darkGreen,
        brightness: Brightness.light,
        extensions: [AppColors.light],
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.light.background,
          elevation: 0,
          scrolledUnderElevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: AppColors.light.white,
          selectedItemColor: AppColors.light.darkGreen,
          unselectedItemColor: AppColors.light.textMuted,
          selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.dark.background,
        colorSchemeSeed: AppColors.dark.darkGreen,
        brightness: Brightness.dark,
        extensions: [AppColors.dark],
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.dark.background,
          elevation: 0,
          scrolledUnderElevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: AppColors.dark.white,
          selectedItemColor: AppColors.dark.accentGold,
          unselectedItemColor: AppColors.dark.textMuted,
          selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
      );
}
