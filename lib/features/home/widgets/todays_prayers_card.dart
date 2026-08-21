import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/prayer_names.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/models/prayer.dart';
import '../../../core/providers/navigation_provider.dart';
import '../../../core/providers/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/prayer_icons.dart';
import '../../../core/theme/app_tokens.dart';

/// How a prayer is drawn in the progress row.
enum _PrayerState {
  /// Ticked off by the user.
  done,

  /// Its time has come and gone without being ticked off.
  open,

  /// Still ahead today.
  upcoming,
}

/// Full-width card showing today's five prayers as a row of check circles.
///
/// Sits where the six prayer time tiles used to be. Tapping a circle ticks the
/// prayer off, tapping anywhere else on the card opens the prayers tab.
class TodaysPrayersCard extends ConsumerStatefulWidget {
  const TodaysPrayersCard({super.key});

  @override
  ConsumerState<TodaysPrayersCard> createState() => _TodaysPrayersCardState();
}

class _TodaysPrayersCardState extends ConsumerState<TodaysPrayersCard> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    // Prayer times pass while the home screen sits open, so a circle has to be
    // able to move from "upcoming" to "open" without the user leaving the tab.
    _ticker = Timer.periodic(
      const Duration(seconds: 30),
      (_) => setState(() {}),
    );
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _showNotYetDue(BuildContext context, AppLocalizations strings) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(strings.prayerNotYetDue),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final logicalDate = ref.watch(logicalDateProvider);
    final tracker = ref.watch(prayerTrackerProvider);
    final colors = AppColors.of(context);
    final now = DateTime.now();

    // Only the five obligatory prayers belong on the progress row; sunrise is
    // a time marker, not something to tick off.
    final prayers = ref
        .watch(prayerTimesProvider)
        .where((p) => p.isPrayer)
        .toList();

    _PrayerState stateOf(PrayerTime p) {
      final done =
          tracker['prayer_tracker_${logicalDate.year}_${logicalDate.month}_${logicalDate.day}_${p.name}'] ==
          true;
      if (done) return _PrayerState.done;
      return p.time.isAfter(now) ? _PrayerState.upcoming : _PrayerState.open;
    }

    final completed = prayers
        .where((p) => stateOf(p) == _PrayerState.done)
        .length;
    final total = prayers.length;
    final percent = total == 0 ? 0 : (completed / total * 100).round();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
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
            onTap: () =>
                ref.read(mainTabIndexProvider.notifier).select(prayersTabIndex),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Header(
                    strings: strings,
                    completed: completed,
                    total: total,
                    streak: ref.watch(currentStreakProvider),
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
                            state: stateOf(p),
                            icon: prayerIcons[p.name] ?? fallbackPrayerIcon,
                            // A prayer whose time has not arrived yet cannot
                            // have been performed. Say so rather than leaving
                            // the tap to fall through to the card underneath,
                            // which would navigate away.
                            onTap: stateOf(p) == _PrayerState.upcoming
                                ? () => _showNotYetDue(context, strings)
                                : () => ref
                                      .read(prayerTrackerProvider.notifier)
                                      .toggle(logicalDate, p.name),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _OverallProgress(strings: strings, percent: percent),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final AppLocalizations strings;
  final int completed;
  final int total;
  final int streak;

  const _Header({
    required this.strings,
    required this.completed,
    required this.total,
    required this.streak,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    // No point repeating the Arabic heading when the app is already Arabic.
    // Skip the Arabic subtitle when the interface is already Arabic.
    final showArabicSubtitle =
        Localizations.localeOf(context).languageCode != 'ar';

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
                  'تقدم اليوم',
                  style: TextStyle(fontSize: 13, color: colors.textMuted),
                ),
              ],
            ],
          ),
        ),
        // The streak lives here rather than in its own row: it is the same
        // fact as the counter next to it, one day wider.
        if (streak > 0) ...[
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xxs,
            ),
            decoration: BoxDecoration(
              color: colors.accentGold.withValues(alpha: 0.16),
              borderRadius: AppRadius.circularSm,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.local_fire_department,
                  size: 14,
                  color: colors.accentGold,
                ),
                const SizedBox(width: 3),
                Text(
                  '$streak',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: colors.textDark,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
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
  final _PrayerState state;
  final IconData icon;

  final VoidCallback onTap;

  const _PrayerCheck({
    required this.prayer,
    required this.state,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    // Three states, three looks: done is solid green, open (time passed but
    // not ticked) is outlined in gold so it reads as "still to log", and
    // upcoming is faded back.
    final (
      Color fill,
      Color border,
      Color content,
      double borderWidth,
    ) = switch (state) {
      _PrayerState.done => (
        colors.darkGreen,
        colors.darkGreen,
        Colors.white,
        0.0,
      ),
      _PrayerState.open => (
        colors.accentGold.withValues(alpha: 0.12),
        colors.accentGold,
        colors.accentGold,
        2.0,
      ),
      _PrayerState.upcoming => (
        colors.background,
        colors.textMuted.withValues(alpha: 0.25),
        colors.textMuted.withValues(alpha: 0.6),
        1.0,
      ),
    };

    final labelColor = switch (state) {
      _PrayerState.done => colors.darkGreen,
      _PrayerState.open => colors.textDark,
      _PrayerState.upcoming => colors.textMuted,
    };

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // The card behind this has its own tap target for opening the prayers
        // tab; this InkWell sits on top so a tap on the circle toggles instead.
        InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: fill,
              shape: BoxShape.circle,
              border: borderWidth == 0
                  ? null
                  : Border.all(color: border, width: borderWidth),
            ),
            child: Icon(
              state == _PrayerState.done ? Icons.check : icon,
              size: state == _PrayerState.done ? 24 : 20,
              color: content,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          localizedPrayerName(AppLocalizations.of(context), prayer.name),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: labelColor,
          ),
        ),
        if (Localizations.localeOf(context).languageCode != 'ar')
          Text(
            prayer.arabicName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              color: state == _PrayerState.upcoming
                  ? colors.textMuted.withValues(alpha: 0.6)
                  : colors.textMuted,
            ),
          ),
      ],
    );
  }
}

class _OverallProgress extends StatelessWidget {
  final AppLocalizations strings;
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
              strings.percentComplete(percent),
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
