import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'features/home/home_screen.dart';
import 'shared/widgets/app_bottom_nav.dart';

class NurApp extends StatelessWidget {
  const NurApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );

    return MaterialApp(
      title: 'Nur',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const _MainShell(),
    );
  }
}

class _MainShell extends StatefulWidget {
  const _MainShell();

  @override
  State<_MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<_MainShell> {
  int _currentIndex = 0;

  static const _placeholderLabels = ['Gebet', "Qur'an", 'Qibla', 'Mehr'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _currentIndex == 0
          ? const HomeScreen()
          : Center(
              child: Text(
                _placeholderLabels[_currentIndex - 1],
                style: const TextStyle(
                  fontSize: 18,
                  color: AppColors.textMuted,
                ),
              ),
            ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}
