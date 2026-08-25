import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/prayer_names.dart';
import '../../../core/providers/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../l10n/app_localizations.dart';

/// Second page of the home carousel: what the tracker actually recorded.
///
/// Every figure is measured from the stored prayer entries — nothing here is
/// a placeholder or a rounded-up guess.
class PrayerStatsCard extends ConsumerWidget {
  const PrayerStatsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = AppColors.of(context);
    final stats = ref.watch(prayerStatsProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: colors.darkGreen,
          borderRadius: AppRadius.circularXl,
          boxShadow: AppShadows.md,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Same artwork as the next-prayer card so the two read as one
            // card that turned over, not two unrelated panels.
            Positioned.fill(
              child: Image.asset(
                'assets/images/card_texture.png',
                fit: BoxFit.cover,
                alignment: Alignment.bottomRight,
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      colors.darkGreen,
                      colors.darkGreen.withValues(alpha: 0.82),
                      colors.darkGreen.withValues(alpha: 0.35),
                    ],
                    stops: const [0.0, 0.6, 1.0],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: stats.hasHistory
                  ? _Figures(stats: stats, l10n: l10n, colors: colors)
                  : _Empty(l10n: l10n),
            ),
          ],
        ),
      ),
    );
  }
}

class _Figures extends StatelessWidget {
  final PrayerStats stats;
  final AppLocalizations l10n;
  final AppColorsExtension colors;

  const _Figures({
    required this.stats,
    required this.l10n,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final weakest = stats.weakestPrayer;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l10n.statsTitle.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.7),
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _Figure(
                icon: Icons.local_fire_department,
                value: '${stats.currentStreak}',
                label: l10n.statsStreakLabel,
                accent: colors.accentGold,
              ),
            ),
            Expanded(
              child: _Figure(
                icon: Icons.emoji_events_outlined,
                value: '${stats.longestStreak}',
                label: l10n.statsBestLabel,
                accent: colors.accentGold,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _Figure(
                icon: Icons.calendar_month_outlined,
                value: l10n.statsWeekValue(stats.completeDaysLastWeek),
                label: l10n.statsWeekLabel,
                accent: colors.accentGold,
              ),
            ),
            Expanded(
              child: _Figure(
                icon: Icons.check_circle_outline,
                value: '${stats.totalPrayersLogged}',
                label: l10n.statsTotalLabel,
                accent: colors.accentGold,
              ),
            ),
          ],
        ),
        // Only once there is enough history for the answer to be honest.
        if (weakest != null) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            l10n.statsWeakest(localizedPrayerName(l10n, weakest)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colors.accentGold,
            ),
          ),
        ],
      ],
    );
  }
}

class _Figure extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color accent;

  const _Figure({
    required this.icon,
    required this.value,
    required this.label,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 15, color: accent),
            const SizedBox(width: AppSpacing.xxs),
            Flexible(
              child: FittedBox(
                alignment: Alignment.centerLeft,
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
              ),
            ),
          ],
        ),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.72),
          ),
        ),
      ],
    );
  }
}

class _Empty extends StatelessWidget {
  final AppLocalizations l10n;

  const _Empty({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l10n.statsTitle.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.7),
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          l10n.statsEmpty,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            height: 1.4,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
      ],
    );
  }
}
