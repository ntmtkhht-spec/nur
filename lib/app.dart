import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/providers/providers.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'features/home/home_screen.dart';
import 'features/onboarding/onboarding_flow.dart';
import 'features/prayers/prayers_screen.dart';
import 'features/qibla/qibla_screen.dart';
import 'features/surah/screens/surah_list_screen.dart';
import 'features/tasbih/tasbih_screen.dart';
import 'shared/widgets/app_bottom_nav.dart';

class NurApp extends StatelessWidget {
  const NurApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nur',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: const _RootGate(),
    );
  }
}

class _RootGate extends ConsumerWidget {
  const _RootGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasCompletedOnboarding = ref.watch(hasCompletedOnboardingProvider);
    return hasCompletedOnboarding ? const _MainShell() : const OnboardingFlow();
  }
}

class _MainShell extends StatefulWidget {
  const _MainShell();

  @override
  State<_MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<_MainShell> {
  int _currentIndex = 0;

  static const _placeholderLabels = ["Qur'an", 'Qibla'];

  Widget _bodyForIndex(int index) {
    return switch (index) {
      0 => const HomeScreen(),
      1 => const PrayersScreen(),
      2 => const SurahListScreen(), // Qur'an is golden center button
      3 => const TasbihScreen(),
      4 => const QiblaScreen(),
      _ => Center(
          child: Text(
            index == 2 ? _placeholderLabels[0] : _placeholderLabels[1],
            style: const TextStyle(
              fontSize: 18,
              color: AppColors.textMuted,
            ),
          ),
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    
    return Scaffold(
      backgroundColor: colors.background,
      body: _bodyForIndex(_currentIndex),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}
