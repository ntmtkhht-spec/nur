import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/i18n/prayer_names.dart';
import '../../../l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';

class NextPrayerCard extends ConsumerStatefulWidget {
  const NextPrayerCard({super.key});

  @override
  ConsumerState<NextPrayerCard> createState() => _NextPrayerCardState();
}

class _NextPrayerCardState extends ConsumerState<NextPrayerCard> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final prayer = ref.watch(nextPrayerProvider);
    final colors = AppColors.of(context);
    final currentPrayer = ref.watch(currentPrayerProvider);

    final remaining = prayer.time.difference(DateTime.now());
    final hours = remaining.inHours.abs();
    final minutes = (remaining.inMinutes % 60).abs();
    final seconds = (remaining.inSeconds % 60).abs();

    String countdownText;
    if (remaining.isNegative) {
      countdownText = l10n.nowLabel;
    } else if (hours > 0) {
      countdownText = l10n.inHoursMinutes(hours, minutes);
    } else {
      countdownText = l10n.inMinutesSeconds(minutes, seconds);
    }

    double progress = 0.0;
    if (currentPrayer != null) {
      final totalDuration = prayer.time.difference(currentPrayer.time).inSeconds;
      final elapsed = DateTime.now().difference(currentPrayer.time).inSeconds;
      if (totalDuration > 0) {
        progress = (elapsed / totalDuration).clamp(0.0, 1.0);
      }
    }

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
            Positioned.fill(
              child: Image.asset(
                'assets/images/ChatGPT Image 28. Juli 2026, 19_52_26.png',
                fit: BoxFit.cover,
                // bottomRight, not centerRight: the mosque skyline sits in
                // the bottom third of the source image. Centering vertically
                // cropped into the buildings and made the horizon float
                // awkwardly mid-card instead of grounding it at the card's
                // bottom edge.
                alignment: Alignment.bottomRight,
              ),
            ),
            // The artwork is a mosque skyline sitting on the card's dark
            // green base colour, so it reads as a subtle scene rather than a
            // photo pasted on top. A left-to-right fade keeps the text side
            // fully readable without hiding the artwork on the right.
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      colors.darkGreen,
                      colors.darkGreen.withValues(alpha: 0.55),
                      colors.darkGreen.withValues(alpha: 0.0),
                    ],
                    stops: const [0.0, 0.55, 1.0],
                  ),
                ),
              ),
            ),
            // Padding lives here, on the text layer only. It used to sit on
            // the outer Container, which pushed the Positioned.fill image
            // and gradient inward too — leaving a plain dark-green margin on
            // every side instead of the artwork reaching the card's edges.
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.nextPrayer.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.7),
                        letterSpacing: 1.5,
                      ),
                    ),
                    // Redundant once the heading itself is Arabic.
                    if (Localizations.localeOf(context).languageCode != 'ar')
                      Text(
                        prayer.arabicName,
                        style: const TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  localizedPrayerName(l10n, prayer.name),
                  style: const TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  countdownText,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  prayer.formattedTime,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: colors.accentGold,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                ClipRRect(
                  borderRadius: AppRadius.circularSm,
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(colors.accentGold),
                    minHeight: 6,
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
