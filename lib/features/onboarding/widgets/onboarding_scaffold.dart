import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

import '../../../core/theme/app_colors.dart';

class OnboardingScaffold extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  /// Defaults to the localized "next" label when null.
  final String? buttonLabel;

  /// Renders the primary button as a quiet text button. Used where advancing
  /// means opting out (e.g. continuing without a location), so the button
  /// does not compete with the action the screen actually offers.
  final bool buttonIsSecondary;
  final VoidCallback onNext;
  final VoidCallback? onSkip;
  final bool buttonEnabled;
  final Widget? customButton;
  final List<Widget> children;

  OnboardingScaffold({
    super.key,
    required this.currentStep,
    this.totalSteps = 4,
    this.buttonLabel,
    this.buttonIsSecondary = false,
    required this.onNext,
    this.onSkip,
    this.buttonEnabled = true,
    this.customButton,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar: dots + skip
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              // Stack, not Row: with the skip label as a row child the dots
              // would centre in the space left of it rather than on screen.
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Forces the stack to full width; without it the stack is
                  // only as wide as the dots and "skip" would sit on top of
                  // them instead of at the right edge.
                  const SizedBox(width: double.infinity, height: 24),
                  _PageDots(current: currentStep, total: totalSteps),
                  if (onSkip != null)
                    Positioned(
                      right: 0,
                      child: GestureDetector(
                        onTap: onSkip,
                        child: Text(
                          l10n.commonSkip,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Content, vertically centred. The minHeight constraint is what
            // makes centring work inside a scroll view: without it the column
            // shrinks to its children and sits at the top, and with a plain
            // Center it could no longer scroll once the content grows.
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: children,
                    ),
                  ),
                ),
              ),
            ),

            // Bottom button
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 8, 28, 16),
              child: customButton ??
                  (buttonIsSecondary
                      ? SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: TextButton(
                            onPressed: buttonEnabled ? onNext : null,
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.textMuted,
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            child: Text(buttonLabel ?? l10n.commonNext),
                          ),
                        )
                      : SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: buttonEnabled ? onNext : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkGreen,
                        disabledBackgroundColor:
                            AppColors.darkGreen.withValues(alpha: 0.4),
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: Text(buttonLabel ?? l10n.commonNext),
                    ),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}

class _PageDots extends StatelessWidget {
  final int current;
  final int total;

  const _PageDots({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(total, (i) {
        final isActive = i == current;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 10 : 8,
          height: isActive ? 10 : 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive
                ? AppColors.accentGold
                : AppColors.textMuted.withValues(alpha: 0.3),
          ),
        );
      }),
    );
  }
}
