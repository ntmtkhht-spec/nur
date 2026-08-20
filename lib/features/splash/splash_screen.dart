import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';

/// Continues the native splash, then hands off to [next].
///
/// The logo deliberately does NOT fade or scale in: the native splash (see
/// flutter_native_splash in pubspec.yaml) has already been showing that exact
/// logo on that exact background, so replaying an entrance for it reads as a
/// restart rather than a continuation. This screen opens on the native
/// splash's final frame and only animates what is genuinely new — a glow
/// sweep and the app name — before crossfading into the app.
class SplashScreen extends StatefulWidget {
  final Widget next;

  const SplashScreen({super.key, required this.next});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _logoScale;
  late final Animation<double> _glowScale;
  late final Animation<double> _glowOpacity;
  late final Animation<double> _textOpacity;
  bool _showNext = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // A breath, not an entrance: starts at 1.0 so the first frame matches the
    // native splash exactly.
    _logoScale = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.06), weight: 45),
      TweenSequenceItem(tween: Tween(begin: 1.06, end: 1.0), weight: 55),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _glowScale = Tween(begin: 0.5, end: 1.15).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.75, curve: Curves.easeOut),
      ),
    );
    _glowOpacity = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.5), weight: 35),
      TweenSequenceItem(tween: Tween(begin: 0.5, end: 0.0), weight: 65),
    ]).animate(_controller);

    _textOpacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
      ),
    );

    // A cold-started Android window runs its own open transition after
    // Flutter's first frame, and frame delivery can stay suspended for that
    // stretch. AnimationController advances on wall-clock time, so ticks
    // queued during the gap all land at once when it ends. Waiting for the
    // first frame plus a short settle keeps the animation from being skipped;
    // during this window the screen is identical to the native splash, so the
    // wait is invisible.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 250));
      if (!mounted) return;
      _controller.forward();
      Future.delayed(const Duration(milliseconds: 1450), () {
        if (mounted) setState(() => _showNext = true);
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // Crossfade rather than a hard swap: the app's own background is light,
    // so cutting straight from the dark splash flashes.
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 450),
      child: _showNext
          ? widget.next
          : Scaffold(
              key: const ValueKey('splash'),
              backgroundColor: AppColors.darkGreen,
              body: Center(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 340,
                          height: 340,
                          child: Stack(
                            alignment: Alignment.center,
                            // The glow briefly overshoots its base size; let
                            // it (and the logo's own breathing scale) spill
                            // past this box instead of getting a hard edge.
                            clipBehavior: Clip.none,
                            children: [
                              Opacity(
                                opacity: _glowOpacity.value,
                                child: Transform.scale(
                                  scale: _glowScale.value,
                                  child: Container(
                                    width: 300,
                                    height: 300,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: RadialGradient(
                                        colors: [
                                          AppColors.accentGold.withValues(
                                            alpha: 0.45,
                                          ),
                                          AppColors.accentGold.withValues(
                                            alpha: 0.0,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Transform.scale(
                                scale: _logoScale.value,
                                child: Image.asset(
                                  // 280 logical px: measured to match the
                                  // native splash's on-screen logo size
                                  // exactly, so there's no size pop when
                                  // this widget takes over from it.
                                  'assets/icon/splash_icon.png',
                                  width: 280,
                                  height: 280,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Opacity(
                          opacity: _textOpacity.value,
                          child: Text(
                            l10n.appName,
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
    );
  }
}
