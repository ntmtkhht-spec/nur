import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/navigation_provider.dart';
import '../../../core/providers/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../duas/duas_screen.dart';

class DailyReminderBanner extends ConsumerWidget {
  const DailyReminderBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reminder = ref.watch(dailyReminderProvider);
    final colors = AppColors.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: colors.cardBg,
          borderRadius: AppRadius.circularLg,
          boxShadow: AppShadows.sm,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: AppRadius.circularLg,
            onTap: () => _openReminderTarget(context, ref, reminder),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: colors.accentGold.withValues(alpha: 0.12),
                    borderRadius: AppRadius.circularMd,
                  ),
                  child: const Center(
                    child: Text('🏮', style: TextStyle(fontSize: 24)),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reminder.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: colors.darkGreen,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        reminder.subtitle,
                        style: TextStyle(fontSize: 12, color: colors.textMuted),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: colors.textMuted,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openReminderTarget(
    BuildContext context,
    WidgetRef ref,
    ({String title, String subtitle}) reminder,
  ) {
    switch (reminder.title) {
      case 'Mache Dua':
      case 'Stehe in der Nacht auf':
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const DuasScreen()));
      case 'Lies den Quran':
        ref.read(mainTabIndexProvider.notifier).select(2);
      case 'Bete mit Hingabe':
        ref.read(mainTabIndexProvider.notifier).select(prayersTabIndex);
      case 'Dhikr beruhigt das Herz':
      case 'Erinnere dich an Allah':
        ref.read(mainTabIndexProvider.notifier).select(3);
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(reminder.subtitle),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }
}
