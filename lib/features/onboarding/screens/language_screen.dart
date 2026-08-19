import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../onboarding_state.dart';
import '../widgets/onboarding_scaffold.dart';
import '../widgets/ornament_divider.dart';

/// Flags per locale code; the labels come from [languageDisplayNames] so the
/// picker and the settings screen can never drift apart.
const _flags = {
  'de': '🇩🇪',
  'en': '🇬🇧',
  'tr': '🇹🇷',
  'ar': '🇸🇦',
  'fr': '🇫🇷',
};

class LanguageScreen extends ConsumerWidget {
  final int stepIndex;
  final VoidCallback onNext;

  const LanguageScreen({
    super.key,
    required this.stepIndex,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final selected = ref.watch(onboardingProvider).language;

    return OnboardingScaffold(
      currentStep: stepIndex,
      onNext: onNext,
      children: [
        SizedBox(height: 24),
        const OrnamentDivider(),
        const SizedBox(height: 20),
        Text(
          l10n.onboardingLanguageTitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
        SizedBox(height: 8),
        Text(
          l10n.onboardingLanguageSubtitle,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: AppColors.textMuted),
        ),
        const SizedBox(height: 28),
        for (final code in supportedLanguageCodes) ...[
          _LanguageTile(
            flag: _flags[code] ?? '',
            label: languageDisplayNames[code]!,
            isSelected: selected == code,
            onTap: () {
              ref.read(onboardingProvider.notifier).setLanguage(code);
              // Apply straight away: otherwise the remaining onboarding
              // steps stay in the previous language until the very end.
              ref.read(appLanguageProvider.notifier).update(code);
            },
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final String flag;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.flag,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primaryGreen : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ),
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.accentGold : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? AppColors.accentGold
                      : AppColors.textMuted.withValues(alpha: 0.4),
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 16, color: AppColors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
