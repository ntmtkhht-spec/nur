import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../data/daily_advice.dart';
import '../providers/daily_advice_provider.dart';

/// The daily guide at the bottom of the home screen.
///
/// Replaces the old reminder banner, whose tap target led nowhere: it showed
/// the same one-liner again in a snackbar, so the arrow promised something the
/// card could not deliver. Here the card is a teaser for a real entry — the
/// arrow opens the reasoning, the source, and one concrete step for today.
class DailyAdviceCard extends ConsumerWidget {
  const DailyAdviceCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final advice = ref.watch(dailyAdviceProvider);
    final colors = AppColors.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Container(
        decoration: BoxDecoration(
          color: colors.white,
          borderRadius: AppRadius.circularLg,
          boxShadow: AppShadows.sm,
        ),
        clipBehavior: Clip.antiAlias,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => showDailyAdviceSheet(context, advice),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          // Mixed against white rather than the beige card
                          // this used to sit on, so it needs more gold to
                          // read as a tinted tile at all.
                          color: colors.accentGold.withValues(alpha: 0.18),
                          borderRadius: AppRadius.circularMd,
                        ),
                        child: Icon(
                          Icons.auto_stories_outlined,
                          size: 22,
                          color: colors.accentGold,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context).adviceSectionLabel,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.1,
                                color: colors.textMuted,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xxs),
                            Text(
                              advice.title,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: colors.darkGreen,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              advice.teaser,
                              style: TextStyle(
                                fontSize: 12,
                                height: 1.35,
                                color: colors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  // Says out loud what the arrow used to only hint at.
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        AppLocalizations.of(context).adviceReadMore,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: colors.primaryGreen,
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 18,
                        color: colors.primaryGreen,
                      ),
                    ],
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

/// Opens the full entry: why it matters, where it comes from, what to do today.
Future<void> showDailyAdviceSheet(BuildContext context, DailyAdvice advice) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      final colors = AppColors.of(context);

      return DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.35,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: colors.background,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.sm),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.textMuted.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.md,
                      AppSpacing.lg,
                      AppSpacing.xxl,
                    ),
                    children: [
                      Text(
                        AppLocalizations.of(context).adviceSectionLabel,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.1,
                          color: colors.textMuted,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        advice.title,
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w700,
                          color: colors.darkGreen,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        advice.body,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.55,
                          color: colors.textDark,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _ActionBox(action: advice.action),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Icon(
                            Icons.menu_book_outlined,
                            size: 15,
                            color: colors.textMuted,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Expanded(
                            child: Text(
                              advice.source,
                              style: TextStyle(
                                fontSize: 12,
                                color: colors.textMuted,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      // The entry changes on its own tomorrow — saying so
                      // stops the card from looking like a stuck banner.
                      Text(
                        AppLocalizations.of(context).adviceTomorrow,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

/// The one concrete step, set apart from the reasoning above it.
class _ActionBox extends StatelessWidget {
  const _ActionBox({required this.action});

  final String action;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.accentGold.withValues(alpha: 0.10),
        borderRadius: AppRadius.circularMd,
        border: Border.all(color: colors.accentGold.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 16,
                color: colors.accentGold,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                AppLocalizations.of(context).adviceActionLabel,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                  color: colors.accentGold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            action,
            style: TextStyle(
              fontSize: 14,
              height: 1.45,
              color: colors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}
