import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

import '../../../core/theme/app_colors.dart';
import '../widgets/hero_badge.dart';

/// Slides are built per call because their texts come from localizations,
/// which are only available with a BuildContext.
List<({IconData icon, String title, String subtitle})> _slidesFor(
  AppLocalizations l10n,
) =>
    [
      (
        icon: Icons.mosque_outlined,
        title: l10n.featurePrayerTitle,
        subtitle: l10n.featurePrayerBody,
      ),
      (
        icon: Icons.auto_stories_outlined,
        title: l10n.featureQuranTitle,
        subtitle: l10n.featureQuranBody,
      ),
      (
        icon: Icons.explore_outlined,
        title: l10n.featureQiblaTitle,
        subtitle: l10n.featureQiblaBody,
      ),
    ];

const _slideCount = 3;

class FeatureIntroScreen extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const FeatureIntroScreen({
    super.key,
    required this.onNext,
    required this.onSkip,
  });

  @override
  State<FeatureIntroScreen> createState() => _FeatureIntroScreenState();
}

class _FeatureIntroScreenState extends State<FeatureIntroScreen> {
  final _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleNext() {
    if (_index < _slideCount - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      widget.onNext();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: widget.onSkip,
                    child: Text(
                      l10n.commonSkip,
                      style: TextStyle(fontSize: 14, color: AppColors.textMuted),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _slideCount,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) {
                  final slide = _slidesFor(l10n)[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        HeroBadge(icon: slide.icon, size: 190),
                        const SizedBox(height: 40),
                        Text(
                          slide.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          slide.subtitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            color: AppColors.textMuted,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_slideCount, (i) {
                final isActive = i == _index;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isActive ? 22 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: isActive
                        ? AppColors.accentGold
                        : AppColors.textMuted.withValues(alpha: 0.3),
                  ),
                );
              }),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 20, 28, 16),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _handleNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkGreen,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: Text(l10n.commonNext),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
