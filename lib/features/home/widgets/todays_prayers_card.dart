import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/navigation_provider.dart';
import '../../../core/providers/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';

/// Full-width card showing how many of today's prayers are done.
///
/// Sits where the six prayer time tiles used to be. Tapping it switches the
/// main shell over to the prayers tab.
class TodaysPrayersCard extends ConsumerWidget {
  const TodaysPrayersCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prayers = ref.watch(prayerTimesProvider);
    final tracker = ref.watch(prayerTrackerProvider);
    final logicalDate = ref.watch(logicalDateProvider);
    final streak = ref.watch(prayerTrackerProvider.notifier).currentStreak;
    final colors = AppColors.of(context);

    var completed = 0;
    var total = 0;
    for (final p in prayers) {
      if (!p.isPrayer) continue;
      total++;
      final key =
          'prayer_tracker_${logicalDate.year}_${logicalDate.month}_${logicalDate.day}_${p.name}';
      if (tracker[key] == true) completed++;
    }

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
            onTap: () => ref
                .read(mainTabIndexProvider.notifier)
                .select(prayersTabIndex),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  _ProgressRing(completed: completed, total: total),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Heute',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: colors.textDark,
                              ),
                            ),
                            if (streak > 0) ...[
                              const SizedBox(width: AppSpacing.xs),
                              _StreakBadge(streak: streak),
                            ],
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          'Gebete erledigt',
                          style: TextStyle(
                            fontSize: 13,
                            color: colors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: colors.textMuted,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressRing extends StatelessWidget {
  final int completed;
  final int total;

  const _ProgressRing({required this.completed, required this.total});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return SizedBox(
      width: 72,
      height: 72,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: CustomPaint(
              // A day without any prayer entries would divide by zero.
              painter: _ProgressRingPainter(
                progress: total == 0 ? 0 : completed / total,
              ),
            ),
          ),
          RichText(
            text: TextSpan(
              style: TextStyle(color: colors.textDark),
              children: [
                TextSpan(
                  text: '$completed',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                TextSpan(
                  text: ' / $total',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StreakBadge extends StatelessWidget {
  final int streak;

  const _StreakBadge({required this.streak});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: colors.accentGold.withValues(alpha: 0.1),
        borderRadius: AppRadius.circularSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.local_fire_department, size: 14, color: colors.accentGold),
          const SizedBox(width: 2),
          Text(
            '$streak',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: colors.accentGold,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  final double progress;

  _ProgressRingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - 8) / 2;
    const strokeWidth = 7.0;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = AppColors.accentGold.withValues(alpha: 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      Paint()
        ..color = AppColors.accentGold
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_ProgressRingPainter old) => old.progress != progress;
}
