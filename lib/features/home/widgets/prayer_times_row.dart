import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/prayer.dart';
import '../../../core/providers/providers.dart';
import '../../../core/theme/app_colors.dart';

class PrayerTimesRow extends ConsumerWidget {
  const PrayerTimesRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prayers = ref.watch(prayerTimesProvider);
    final nextIndex = ref.watch(nextPrayerIndexProvider);
    final completed = ref.watch(completedPrayersProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          for (var i = 0; i < prayers.length; i++) ...[
            if (i > 0) const SizedBox(width: 6),
            Expanded(
              child: _PrayerTimeItem(
                prayer: prayers[i],
                isActive: i == nextIndex,
                isCompleted: completed.contains(prayers[i].name),
                onTap: () {
                  ref
                      .read(completedPrayersProvider.notifier)
                      .toggle(prayers[i].name);
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
      'Dhuhr' => Icons.wb_sunny_outlined,
      'Asr' => Icons.mosque_outlined,
      'Maghrib' => Icons.wb_twilight,
      'Isha' => Icons.nightlight_round_outlined,
      _ => Icons.access_time,
    };
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? AppColors.accentGold : AppColors.cardBg,
          borderRadius: BorderRadius.circular(14),
          border: isCompleted && !isActive
              ? Border.all(
                  color: AppColors.primaryGreen.withValues(alpha: 0.4),
                  width: 1.5,
                )
              : null,
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
                  color: isActive ? AppColors.white : AppColors.textMuted,
                ),
                if (isCompleted)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              prayer.name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? AppColors.white : AppColors.textDark,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              prayer.formattedTime,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isActive ? AppColors.white : AppColors.primaryGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
