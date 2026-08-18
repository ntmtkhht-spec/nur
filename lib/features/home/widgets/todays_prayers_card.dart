import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/models/prayer.dart';
import '../../../core/providers/navigation_provider.dart';
import '../../../core/providers/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';

/// Full-width card showing today's five prayers as a row of check circles.
///
/// Sits where the six prayer time tiles used to be. Tapping it switches the
/// main shell over to the prayers tab.
class TodaysPrayersCard extends ConsumerWidget {
  const TodaysPrayersCard({super.key});

  static const _icons = <String, IconData>{
    'Fajr': Icons.wb_twilight,
    'Dhuhr': Icons.wb_sunny_outlined,
    'Asr': Icons.mosque_outlined,
    'Maghrib': Icons.wb_twilight_outlined,
    'Isha': Icons.nightlight_round,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(appStringsProvider);
    final logicalDate = ref.watch(logicalDateProvider);
    final tracker = ref.watch(prayerTrackerProvider);
    final colors = AppColors.of(context);

    // Only the five obligatory prayers belong on the progress row; sunrise is
    // a time marker, not something to tick off.
    final prayers =
        ref.watch(prayerTimesProvider).where((p) => p.isPrayer).toList();

    bool isDone(PrayerTime p) =>
        tracker['prayer_tracker_${logicalDate.year}_${logicalDate.month}_${logicalDate.day}_${p.name}'] ==
        true;

    final completed = prayers.where(isDone).length;
    final total = prayers.length;
    final percent = total == 0 ? 0 : (completed / total * 100).round();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Directionality(
        textDirection: strings.direction,
        child: Container(
          decoration: BoxDecoration(
            color: colors.cardBg,
            borderRadius: AppRadius.circularLg,
            boxShadow: AppShadows.sm,
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: AppRadius.circularLg,
            child: InkWell(
              borderRadius: AppRadius.circularLg,
              onTap: () => ref
                  .read(mainTabIndexProvider.notifier)
                  .select(prayersTabIndex),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Header(
                      strings: strings,
                      completed: completed,
                      total: total,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final p in prayers)
                          Flexible(
                            child: _PrayerCheck(
                              prayer: p,
                              done: isDone(p),
                              icon: _icons[p.name] ?? Icons.circle_outlined,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _OverallProgress(
                      strings: strings,
                      percent: percent,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final AppStrings strings;
  final int completed;
  final int total;

  const _Header({
    required this.strings,
    required this.completed,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    // No point repeating the Arabic heading when the app is already Arabic.
    final showArabicSubtitle =
        strings.todaysProgress != AppStrings.arabicTodaysProgress;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                strings.todaysProgress,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: colors.textDark,
                ),
              ),
              if (showArabicSubtitle) ...[
                const SizedBox(height: 2),
                Text(
                  AppStrings.arabicTodaysProgress,
                  style: TextStyle(
                    fontSize: 13,
                    color: colors.textMuted,
                  ),
                ),
              ],
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xxs,
          ),
          decoration: BoxDecoration(
            color: colors.darkGreen,
            borderRadius: AppRadius.circularSm,
          ),
          child: Text(
            '$completed/$total',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

class _PrayerCheck extends StatelessWidget {
  final PrayerTime prayer;
  final bool done;
  final IconData icon;

  const _PrayerCheck({
    required this.prayer,
    required this.done,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: done ? colors.darkGreen : colors.background,
            shape: BoxShape.circle,
            border: done
                ? null
                : Border.all(color: colors.textMuted.withValues(alpha: 0.3)),
          ),
          child: Icon(
            done ? Icons.check : icon,
            size: done ? 24 : 20,
            color: done ? Colors.white : colors.textMuted,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          prayer.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: done ? colors.darkGreen : colors.textDark,
          ),
        ),
        Text(
          prayer.arabicName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 11,
            color: colors.textMuted,
          ),
        ),
      ],
    );
  }
}

class _OverallProgress extends StatelessWidget {
  final AppStrings strings;
  final int percent;

  const _OverallProgress({required this.strings, required this.percent});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              strings.overallProgress,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: colors.textDark,
              ),
            ),
            Text(
              '$percent${strings.percentComplete}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: colors.darkGreen,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percent / 100,
            minHeight: 6,
            backgroundColor: colors.accentGold.withValues(alpha: 0.15),
            valueColor: AlwaysStoppedAnimation<Color>(colors.accentGold),
          ),
        ),
      ],
    );
  }
}
