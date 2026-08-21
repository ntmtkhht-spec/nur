import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../l10n/app_localizations.dart';

/// Shows the daily and milestone praise over whatever screen is open.
///
/// Sits in the app shell rather than in a screen: the last prayer of the day
/// can be ticked off on the home card or on the prayers tab, and the
/// celebration has to follow the user either way.
class PrayerCelebrationOverlay extends ConsumerStatefulWidget {
  const PrayerCelebrationOverlay({super.key});

  @override
  ConsumerState<PrayerCelebrationOverlay> createState() =>
      _PrayerCelebrationOverlayState();
}

class _PrayerCelebrationOverlayState
    extends ConsumerState<PrayerCelebrationOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _cleanup;

  /// Held separately from the provider so the banner can play its exit
  /// animation after the pending celebration has been acknowledged.
  PrayerDayCelebration? _showing;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1900),
    );
  }

  @override
  void dispose() {
    _cleanup?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _play(PrayerDayCelebration celebration) {
    // A milestone is rarer and carries more text, so it stays up longer.
    final isMilestone = celebration.milestone != null;
    final visible = Duration(milliseconds: isMilestone ? 2900 : 1900);

    _cleanup?.cancel();
    setState(() => _showing = celebration);

    _controller.duration = visible;
    _controller.forward(from: 0);

    // Acknowledged as soon as it is on screen: leaving it pending until the
    // animation ends would replay it if the app is closed in between.
    ref.read(prayerCelebrationProvider.notifier).acknowledge();

    _cleanup = Timer(visible + const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _showing = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<PrayerDayCelebration?>(prayerCelebrationProvider, (
      previous,
      next,
    ) {
      if (next != null) _play(next);
    });

    final showing = _showing;
    if (showing == null) return const SizedBox.shrink();

    final strings = AppLocalizations.of(context);
    final colors = AppColors.of(context);
    final milestone = showing.milestone;

    return IgnorePointer(
      child: _PraiseBanner(
        controller: _controller,
        colors: colors,
        title: milestone == null
            ? strings.praiseTitle
            : strings.streakMilestoneTitle,
        body: milestone == null
            ? strings.praiseAllPrayers(showing.completed, showing.total)
            : strings.streakMilestoneBody(milestone),
      ),
    );
  }
}

class _PraiseBanner extends StatelessWidget {
  final Animation<double> controller;
  final AppColorsExtension colors;
  final String title;
  final String body;

  const _PraiseBanner({
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
                      constraints: const BoxConstraints(maxWidth: 260),
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
