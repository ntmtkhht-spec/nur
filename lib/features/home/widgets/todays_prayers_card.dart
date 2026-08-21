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

class _TodaysPrayersCardState extends ConsumerState<TodaysPrayersCard>
    with SingleTickerProviderStateMixin {
  Timer? _ticker;
  Timer? _celebrationCleanup;
  late final AnimationController _celebrationController;
  int? _lastCompleted;
  String? _lastLogicalDateKey;
  String? _celebratedDateKey;
  bool _showCompletionPraise = false;

  /// Set when the day that was just completed also closed a streak
  /// milestone, so the banner can say so instead of the usual daily line.
  int? _praiseMilestone;

  @override
  void initState() {
    super.initState();
    _celebrationController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 1900),
        )..addStatusListener((status) {
          if (status == AnimationStatus.completed && mounted) {
            setState(() => _showCompletionPraise = false);
          }
        });
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
    _celebrationCleanup?.cancel();
    _celebrationController.dispose();
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

  void _maybeCelebrateCompletion({
    required DateTime logicalDate,
    required int completed,
    required int total,
    required int streak,
  }) {
    final dateKey =
        '${logicalDate.year}_${logicalDate.month}_${logicalDate.day}';

    if (_lastLogicalDateKey != dateKey) {
      _lastLogicalDateKey = dateKey;
      _lastCompleted = completed;
      return;
    }

    final reachedFullProgress =
        total > 0 &&
        completed == total &&
        (_lastCompleted ?? completed) < total;
    _lastCompleted = completed;

    if (!reachedFullProgress || _celebratedDateKey == dateKey) return;

    _celebratedDateKey = dateKey;
    // Completing the day is what moves the streak, so a milestone can only
    // ever be closed at this exact moment.
    final milestone = milestoneReachedAt(streak);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _celebrationCleanup?.cancel();
      setState(() {
        _praiseMilestone = milestone;
        _showCompletionPraise = true;
      });
      // The controller drives the fade, so it has to outlast the same
      // beat the cleanup timer is waiting for.
      _celebrationController.duration = Duration(
        milliseconds: milestone == null ? 1900 : 2900,
      );
      _celebrationController.forward(from: 0);
      // A milestone is rarer and carries more text, so it stays up longer.
      _celebrationCleanup = Timer(
        Duration(milliseconds: milestone == null ? 2200 : 3200),
        () {
          if (mounted) setState(() => _showCompletionPraise = false);
        },
      );
    });
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
    _maybeCelebrateCompletion(
      logicalDate: logicalDate,
      completed: completed,
      total: total,
      streak: ref.watch(currentStreakProvider),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
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
                                // A prayer whose time has not arrived yet
                                // cannot have been performed. Say so rather
                                // than leaving the tap to fall through to the
                                // card underneath, which would navigate away.
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
          if (_showCompletionPraise)
            Positioned.fill(
              child: IgnorePointer(
                child: _CompletionPraise(
                  controller: _celebrationController,
                  colors: colors,
                  title: _praiseMilestone == null
                      ? strings.praiseTitle
                      : strings.streakMilestoneTitle,
                  body: _praiseMilestone == null
                      ? strings.praiseAllPrayers(completed, total)
                      : strings.streakMilestoneBody(_praiseMilestone!),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CompletionPraise extends StatelessWidget {
  final Animation<double> controller;
  final AppColorsExtension colors;
  final String title;
  final String body;

  const _CompletionPraise({
    required this.controller,
    required this.colors,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final t = controller.value;
        final enter = Curves.easeOutBack.transform((t / 0.34).clamp(0.0, 1.0));
        final exit =
            1 - Curves.easeIn.transform(((t - 0.74) / 0.26).clamp(0.0, 1.0));
        final sparkle = Curves.easeOut.transform((t / 0.55).clamp(0.0, 1.0));

        return Opacity(
          opacity: (enter * exit).clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, -8 * enter),
            child: Transform.scale(
              scale: 0.86 + (0.14 * enter),
              child: Center(
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    for (final particle in _praiseParticles)
                      Transform.translate(
                        offset: Offset(
                          particle.dx * sparkle,
                          particle.dy * sparkle,
                        ),
                        child: Transform.rotate(
                          angle: particle.angle * sparkle,
                          child: Icon(
                            Icons.auto_awesome,
                            size: particle.size,
                            color: colors.accentGold.withValues(
                              alpha: 0.85 * exit,
                            ),
                          ),
                        ),
                      ),
                    Container(
                      constraints: const BoxConstraints(maxWidth: 230),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: colors.darkGreen,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(
                          color: colors.accentGold.withValues(alpha: 0.55),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: colors.darkGreen.withValues(alpha: 0.24),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Colors.white,
                            size: 22,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Flexible(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    height: 1.05,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  body,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

const _praiseParticles = [
  _PraiseParticle(dx: -92, dy: -44, size: 15, angle: -0.4),
  _PraiseParticle(dx: -68, dy: 38, size: 12, angle: 0.8),
  _PraiseParticle(dx: 76, dy: -50, size: 16, angle: 0.5),
  _PraiseParticle(dx: 88, dy: 34, size: 13, angle: -0.7),
];

class _PraiseParticle {
  final double dx;
  final double dy;
  final double size;
  final double angle;

  const _PraiseParticle({
    required this.dx,
    required this.dy,
    required this.size,
    required this.angle,
  });
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
