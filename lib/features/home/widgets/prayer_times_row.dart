import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/prayer.dart';
import '../../../core/providers/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';

class PrayerTimesRow extends ConsumerWidget {
  const PrayerTimesRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prayers = ref.watch(prayerTimesProvider);
    final currentPrayer = ref.watch(currentPrayerProvider);
    final tracker = ref.watch(prayerTrackerProvider);
    final logicalDate = ref.watch(logicalDateProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          for (var i = 0; i < prayers.length; i++) ...[
            if (i > 0) const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: _PrayerTimeItem(
                prayer: prayers[i],
                isActive: prayers[i].name == currentPrayer?.name,
                isCompleted: tracker['prayer_tracker_${logicalDate.year}_${logicalDate.month}_${logicalDate.day}_${prayers[i].name}'] ?? false,
                onTap: () {
                  if (!prayers[i].isPrayer) {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => const Padding(
                        padding: EdgeInsets.all(24.0),
                        child: SafeArea(
                          child: Text('Wecker / Benachrichtigungen für Sonnenaufgang (Demnächst)'),
                        ),
                      ),
                    );
                    return;
                  }
                  
                  if (DateTime.now().isAfter(prayers[i].time) || DateTime.now().isAtSameMomentAs(prayers[i].time)) {
                    ref
                        .read(prayerTrackerProvider.notifier)
                        .toggle(logicalDate, prayers[i].name);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Das Gebet ${prayers[i].name} hat noch nicht begonnen.'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PrayerTimeItem extends StatelessWidget {
  final PrayerTime prayer;
  final bool isActive;
  final bool isCompleted;
  final VoidCallback onTap;

  const _PrayerTimeItem({
    required this.prayer,
    required this.isActive,
    required this.isCompleted,
    required this.onTap,
  });

  IconData get _icon {
    return switch (prayer.name) {
      'Fajr' => Icons.wb_twilight_outlined,
      'Sonnenaufgang' => Icons.wb_sunny_outlined,
      'Dhuhr' => Icons.light_mode_outlined,
      'Asr' => Icons.mosque_outlined,
      'Maghrib' => Icons.wb_twilight,
      'Isha' => Icons.nightlight_round_outlined,
      _ => Icons.access_time,
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: isActive ? colors.accentGold : colors.cardBg,
          borderRadius: AppRadius.circularMd,
          border: isCompleted && !isActive
              ? Border.all(
                  color: colors.primaryGreen.withValues(alpha: 0.4),
                  width: 1.5,
                )
              : null,
          boxShadow: isActive ? AppShadows.glowGold : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.topRight,
              children: [
                Icon(
                  _icon,
                  size: 22,
                  color: isActive ? colors.white : colors.textMuted,
                ),
                if (isCompleted)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: colors.primaryGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              prayer.name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? colors.white : colors.textDark,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              prayer.formattedTime,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isActive ? colors.white : colors.primaryGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
