import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';

class QuickActionsGrid extends ConsumerWidget {
  const QuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prayers = ref.watch(prayerTimesProvider);
    final tracker = ref.watch(prayerTrackerProvider);
    final logicalDate = ref.watch(logicalDateProvider);
    
    int completedCount = 0;
    int totalPrayers = 0;
    for (final p in prayers) {
      if (p.isPrayer) {
        totalPrayers++;
        if (tracker['prayer_tracker_${logicalDate.year}_${logicalDate.month}_${logicalDate.day}_${p.name}'] == true) {
          completedCount++;
        }
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: SizedBox(
        height: 200,
        child: Row(
          children: [
            Expanded(
              child: _TodaysPrayersCard(
                completed: completedCount,
                total: totalPrayers,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: _QuickActionTile(
                      icon: Icons.mosque_outlined,
                      label: "Moscheen",
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Expanded(
                    child: _QuickActionTile(
                      icon: Icons.front_hand_outlined,
                      label: 'Duas',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: _QuickActionTile(
                      icon: Icons.explore_outlined,
                      label: 'Qibla',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Expanded(
                    child: _QuickActionTile(
                      icon: Icons.all_inclusive_outlined,
                      label: '99 Namen',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TodaysPrayersCard extends ConsumerWidget {
  final int completed;
  final int total;

  const _TodaysPrayersCard({required this.completed, required this.total});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streak = ref.watch(prayerTrackerProvider.notifier).currentStreak;
    final colors = AppColors.of(context);

    return Container(
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
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (context) => const Padding(
                padding: EdgeInsets.all(24.0),
                child: SafeArea(
                  child: Text('7-Tage-Historie (Demnächst)'),
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Heutige\nGebete',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: colors.textDark,
                        height: 1.2,
                      ),
                    ),
                    if (streak > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: AppSpacing.xxs),
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
                      ),
                  ],
                ),
          const Spacer(),
          Center(
            child: SizedBox(
              width: 70,
              height: 70,
              child: CustomPaint(
                painter: _ProgressRingPainter(
                  progress: completed / total,
                ),
              ),
            ),
          ),
          const Spacer(),
          Center(
            child: RichText(
              text: TextSpan(
                style: TextStyle(color: colors.textDark),
                children: [
                  TextSpan(
                    text: '$completed',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  TextSpan(
                    text: ' / $total',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Center(
            child: Text(
              'Gebete\nerledigt',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: colors.textMuted,
                height: 1.3,
              ),
            ),
          ),
          ],
        ),
      ),
      ),
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
    final radius = (size.shortestSide - 10) / 2;
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

class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String label;

  const _QuickActionTile({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Container(
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
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$label kommt bald!'),
                duration: const Duration(seconds: 1),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 32, color: colors.darkGreen),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colors.darkGreen,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
