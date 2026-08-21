import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/providers/navigation_provider.dart';
import 'l10n/app_localizations.dart';
import 'core/providers/providers.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'features/home/home_screen.dart';
import 'features/onboarding/onboarding_flow.dart';
import 'features/prayers/prayers_screen.dart';
import 'features/qibla/qibla_screen.dart';
import 'features/splash/splash_screen.dart';
import 'features/surah/screens/surah_list_screen.dart';
import 'features/tasbih/tasbih_screen.dart';
import 'shared/widgets/app_bottom_nav.dart';
import 'shared/widgets/prayer_celebration_overlay.dart';

class MunirApp extends ConsumerWidget {
  const MunirApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Text direction follows from the locale, so picking Arabic flips the
    // whole app to RTL without any per-widget handling.
    final languageCode = ref.watch(appLanguageProvider);

    return MaterialApp(
      title: 'Munir',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      themeMode: ThemeMode.light,
      locale: Locale(languageCode),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const SplashScreen(next: _RootGate()),
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

class _MainShell extends ConsumerWidget {
  const _MainShell();

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
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final currentIndex = ref.watch(mainTabIndexProvider);

    // Side-effect watch: keeps prayer notifications armed for the next
    // several days, re-running whenever location/method/madhab/language or
    // the notification toggle changes. See notificationSchedulerProvider.
    ref.watch(notificationSchedulerProvider);

    return Scaffold(
      backgroundColor: colors.background,
      // The celebration sits above every tab: the day can be finished from
      // the home card or the prayers list, and a milestone is reached once.
      body: Stack(
        children: [
          _bodyForIndex(currentIndex),
          const Positioned.fill(child: PrayerCelebrationOverlay()),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: currentIndex,
        onTap: (i) => ref.read(mainTabIndexProvider.notifier).select(i),
      ),
    );
  }
}
