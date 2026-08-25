import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/notification_service.dart';
import '../../../core/theme/app_colors.dart';
import '../onboarding_state.dart';
import '../widgets/hero_badge.dart';
import '../widgets/onboarding_scaffold.dart';

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
    // Same "setting up notifications" moment, so one more system prompt
    // here doesn't feel out of place. Without this, reminders fall back to
    // inexact delivery and can arrive minutes to hours late.
    if (granted) {
      await NotificationService.requestExactAlarmPermission();
    }

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



  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

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
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                l10n.commonLater,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textMuted,
                ),
              ),
            ),
          ),
        ],
      ),
      children: [
        SizedBox(height: 8),
        const HeroBadge(icon: Icons.notifications_none_rounded, size: 96),
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
      ],
    );
  }
}
