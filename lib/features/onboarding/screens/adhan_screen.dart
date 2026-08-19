import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/providers.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/theme/app_colors.dart';
import '../onboarding_state.dart';
import '../widgets/hero_badge.dart';
import '../widgets/onboarding_scaffold.dart';
import '../widgets/ornament_divider.dart';

/// Reciter names stay as they are; only the silent option is translated.
Map<MuezzinVoice, String> _voiceLabelsFor(AppLocalizations l10n) => {
  MuezzinVoice.misharyAlafasy: 'Mishary Alafasy',
  MuezzinVoice.makkahAdhan: 'Makkah Adhan',
  MuezzinVoice.silent: l10n.muezzinSilent,
};

class AdhanScreen extends ConsumerStatefulWidget {
  final int stepIndex;
  final VoidCallback onNext;

  const AdhanScreen({
    super.key,
    required this.stepIndex,
    required this.onNext,
  });

  @override
  ConsumerState<AdhanScreen> createState() => _AdhanScreenState();
}

class _AdhanScreenState extends ConsumerState<AdhanScreen> {
  bool _requesting = false;

  Future<void> _enableNotifications() async {
    // Resolved before awaiting: after the gap the widget may be gone.
    final l10n = AppLocalizations.of(context);
    setState(() => _requesting = true);

    final granted = await NotificationService.requestPermission();
    ref.read(onboardingProvider.notifier).setNotificationsEnabled(granted);

    if (mounted) {
      setState(() => _requesting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            granted
                ? l10n.onboardingAdhanEnabled
                : l10n.onboardingAdhanDenied,
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      widget.onNext();
    }
  }

  void _previewVoice(String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Vorschau für „$label" folgt bald.'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final selectedVoice = ref.watch(onboardingProvider).muezzinVoice;

    return OnboardingScaffold(
      currentStep: widget.stepIndex,
      onNext: widget.onNext,
      customButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _requesting ? null : _enableNotifications,
              icon: _requesting
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.white,
                      ),
                    )
                  : const Icon(Icons.notifications_active_outlined, size: 20),
              label: Text(l10n.onboardingAdhanEnable),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkGreen,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: widget.onNext,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Text(
                'Später',
                style: TextStyle(fontSize: 14, color: AppColors.textMuted),
              ),
            ),
          ),
        ],
      ),
      children: [
        SizedBox(height: 8),
        const HeroBadge(icon: Icons.notifications_none_rounded, size: 170),
        const SizedBox(height: 24),
        Text(
          l10n.onboardingAdhanHeading,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
        SizedBox(height: 8),
        Text(
          l10n.onboardingAdhanBody,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: AppColors.textMuted),
        ),
        SizedBox(height: 12),
        const OrnamentDivider(),
        const SizedBox(height: 20),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            l10n.onboardingMuezzinSection,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.accentGold,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 10),
        for (final voice in MuezzinVoice.values) ...[
          _VoiceTile(
            label: _voiceLabelsFor(l10n)[voice]!,
            isSelected: selectedVoice == voice,
            onTap: () =>
                ref.read(onboardingProvider.notifier).setMuezzinVoice(voice),
            onPlay: () => _previewVoice(_voiceLabelsFor(l10n)[voice]!),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _VoiceTile extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onPlay;

  const _VoiceTile({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
            GestureDetector(
              onTap: onPlay,
              child: Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.goldLight,
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  size: 20,
                  color: AppColors.darkGreen,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.accentGold, size: 22)
            else
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.textMuted.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
