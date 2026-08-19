import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/providers.dart';
import '../../../core/theme/app_tokens.dart';
import 'widgets/daily_reminder_banner.dart';
import 'widgets/greeting_header.dart';
import 'widgets/next_prayer_card.dart';
import 'widgets/quick_actions_grid.dart';
import 'widgets/todays_prayers_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationAsync = ref.watch(locationProvider);
    final hasLocationError = locationAsync.hasError;

    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.md),
            if (hasLocationError) ...[
              const _LocationWarningBanner(),
              const SizedBox(height: AppSpacing.md),
            ],
            const GreetingHeader(),
            const SizedBox(height: AppSpacing.xl),
            const NextPrayerCard(),
            const SizedBox(height: AppSpacing.lg),
            const TodaysPrayersCard(),
            const SizedBox(height: AppSpacing.lg),
            const QuickActionsGrid(),
            const SizedBox(height: AppSpacing.lg),
            const DailyReminderBanner(),
            const SizedBox(
              height: 120,
            ), // Bottom padding for bottom navigation bar
          ],
        ),
      ),
    );
  }
}

class _LocationWarningBanner extends ConsumerWidget {
  const _LocationWarningBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.1),
          border: Border.all(color: Colors.red.withValues(alpha: 0.5)),
          borderRadius: AppRadius.circularMd,
        ),
        child: Row(
          children: [
            Icon(Icons.location_off_outlined, color: Colors.red, size: 24),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                AppLocalizations.of(context).locationWarning,
                style: TextStyle(fontSize: 13, color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () {
                ref.read(locationProvider.notifier).detectViaGps();
              },
              child: Text(
                AppLocalizations.of(context).activate,
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
