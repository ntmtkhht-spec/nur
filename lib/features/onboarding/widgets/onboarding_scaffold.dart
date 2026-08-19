import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

import '../../../core/theme/app_colors.dart';

class OnboardingScaffold extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  /// Defaults to the localized "next" label when null.
  final String? buttonLabel;
  final VoidCallback onNext;
  final VoidCallback? onSkip;
  final bool buttonEnabled;
  final Widget? customButton;
  final List<Widget> children;

  OnboardingScaffold({
    super.key,
    required this.currentStep,
    this.totalSteps = 6,
    this.buttonLabel,
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
              child: Row(
                children: [
                  const Spacer(),
                  _PageDots(current: currentStep, total: totalSteps),
                  const Spacer(),
                  if (onSkip != null)
                    GestureDetector(
                      onTap: onSkip,
                      child: Text(
                        l10n.commonSkip,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textMuted,
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 80),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  children: children,
                ),
              ),
            ),

            // Bottom button
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 8, 28, 16),
              child: customButton ??
                  SizedBox(
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
                  ),
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
