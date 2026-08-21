import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../l10n/app_localizations.dart';
import 'next_prayer_card.dart';
import 'prayer_stats_card.dart';

/// The two hero cards at the top of the home screen: what is next, and what
/// has been done so far.
///
/// A carousel rather than two stacked cards — the statistics are worth a look
/// now and then, not on every glance at the prayer time.
class HomeHeroCarousel extends StatefulWidget {
  const HomeHeroCarousel({super.key});

  @override
  State<HomeHeroCarousel> createState() => _HomeHeroCarouselState();
}

class _HomeHeroCarouselState extends State<HomeHeroCarousel> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // PageView needs a bounded height, and both pages have to live inside it.
    // Tying that to the text scale keeps the taller of the two from
    // overflowing when the system font is turned up.
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);
    final height = 258.0 * textScale.clamp(1.0, 1.45);

    return Column(
      children: [
        SizedBox(
          height: height,
          child: PageView(
            controller: _controller,
            onPageChanged: (index) => setState(() => _page = index),
            children: const [NextPrayerCard(), PrayerStatsCard()],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        _Dots(
          count: 2,
          active: _page,
          onTap: (index) => _controller.animateToPage(
            index,
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOut,
          ),
          labels: [l10n.nextPrayer, l10n.statsTitle],
        ),
      ],
    );
  }
}

class _Dots extends StatelessWidget {
  final int count;
  final int active;
  final ValueChanged<int> onTap;
  final List<String> labels;

  const _Dots({
    required this.count,
    required this.active,
    required this.onTap,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var index = 0; index < count; index++)
          Semantics(
            label: labels[index],
            selected: index == active,
            button: true,
            child: GestureDetector(
              onTap: () => onTap(index),
              behavior: HitTestBehavior.opaque,
              // The dot itself stays small; the padding gives it a tap
              // target big enough to actually hit.
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xxs,
                  vertical: AppSpacing.xs,
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  width: index == active ? 20 : 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: index == active
                        ? colors.darkGreen
                        : colors.textMuted.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
