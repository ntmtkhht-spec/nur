import 'dart:async';

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
  static const _pageCount = 2;

  /// How long a page stays before the carousel moves on by itself.
  static const _dwell = Duration(seconds: 10);

  static const _slide = Duration(milliseconds: 420);

  /// The carousel only ever moves forward, so the same two cards are handed
  /// out over and over from a long strip of positions rather than sliding
  /// back to the start. Pages are built on demand, so the length costs
  /// nothing; at one turn every ten seconds it lasts weeks of uninterrupted
  /// use, far past any session.
  static const _strip = 100000;

  /// Starts halfway along, on an even position so the first card shows.
  static const _origin = _strip ~/ 2;

  final _controller = PageController(initialPage: _origin);
  int _page = _origin;
  Timer? _advance;

  /// False while the system asks for reduced motion, which is exactly the
  /// setting a carousel that moves on its own is meant to respect.
  bool _autoPlay = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final shouldPlay = !reduceMotion;
    if (shouldPlay == _autoPlay && _advance != null) return;

    _autoPlay = shouldPlay;
    _autoPlay ? _restartDwell() : _advance?.cancel();
  }

  @override
  void dispose() {
    _advance?.cancel();
    _controller.dispose();
    super.dispose();
  }

  /// Starts the wait before the next page.
  ///
  /// A one-shot timer restarted after every page change, rather than a
  /// periodic one: swiping by hand should buy a full dwell on the page just
  /// opened, not whatever is left of a tick that has been running since.
  void _restartDwell() {
    _advance?.cancel();
    if (!_autoPlay) return;

    _advance = Timer(_dwell, () {
      if (!mounted || !_controller.hasClients) return;
      // Always one step onward — the next position simply holds the other
      // card, so the movement never reverses.
      _controller.animateToPage(
        _page + 1,
        duration: _slide,
        curve: Curves.easeInOut,
      );
    });
  }

  /// Moves to whichever upcoming position carries [card].
  ///
  /// Forward as well, so tapping a dot looks like the carousel turning on
  /// its own rather than snapping backwards.
  void _goToCard(int card) {
    final steps = (card - _page % _pageCount + _pageCount) % _pageCount;
    if (steps == 0) return;

    _controller.animateToPage(
      _page + steps,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
    );
  }

  /// Keeps the timer from firing mid-drag, which would fight the finger on
  /// the screen.
  bool _onScroll(ScrollNotification notification) {
    if (notification is ScrollStartNotification) {
      _advance?.cancel();
    } else if (notification is ScrollEndNotification) {
      _restartDwell();
    }
    return false;
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
          child: NotificationListener<ScrollNotification>(
            onNotification: _onScroll,
            child: PageView.builder(
              controller: _controller,
              itemCount: _strip,
              onPageChanged: (index) {
                setState(() => _page = index);
                _restartDwell();
              },
              itemBuilder: (context, index) => switch (index % _pageCount) {
                0 => const NextPrayerCard(),
                _ => const PrayerStatsCard(),
              },
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        _Dots(
          count: _pageCount,
          active: _page % _pageCount,
          onTap: _goToCard,
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
