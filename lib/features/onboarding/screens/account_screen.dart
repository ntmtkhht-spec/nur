import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/services/sync_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../widgets/hero_badge.dart';
import '../widgets/onboarding_scaffold.dart';

/// Last onboarding step: offers an account, does not demand one.
///
/// The offer is prominent — a filled button, with the benefit spelled out —
/// while skipping is a quiet text button. Making it mandatory would put a
/// login wall in front of an app whose prayer times, qibla and Qur'an all
/// work locally, which App Store guideline 5.1.1(v) does not allow.
class AccountScreen extends ConsumerStatefulWidget {
  final int stepIndex;
  final VoidCallback onNext;

  const AccountScreen({
    super.key,
    required this.stepIndex,
    required this.onNext,
  });

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  bool _busy = false;

  Future<void> _signIn() async {
    setState(() => _busy = true);
    try {
      final user = await ref.read(authServiceProvider).signInWithGoogle();
      if (user == null) return; // dismissed the picker
      // A returning user gets their history back before anything local is
      // pushed over it.
      await ref.read(syncServiceProvider).pull(user.uid);
      await ref.read(syncServiceProvider).push(user.uid);
      if (mounted) widget.onNext();
    } catch (e) {
      debugPrint('Onboarding sign-in failed: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).settingsSignInFailed),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return OnboardingScaffold(
      currentStep: widget.stepIndex,
      onNext: widget.onNext,
      buttonLabel: l10n.commonLater,
      // Skipping stays available but quiet; the real offer is the filled
      // button in the content below.
      buttonIsSecondary: true,
      children: [
        const HeroBadge(icon: Icons.cloud_done_outlined, size: 96),
        const SizedBox(height: 28),
        Text(
          l10n.onboardingAccountTitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          l10n.onboardingAccountBody,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textMuted,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: _busy ? null : _signIn,
            icon: _busy
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.login, size: 20),
            label: Text(l10n.settingsSignInGoogle),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.darkGreen,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
