import 'package:adhan_dart/adhan_dart.dart' as adhan;
import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/providers.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/hero_badge.dart';
import '../widgets/ornament_divider.dart';

const _methodShortNames = {
  adhan.CalculationMethod.muslimWorldLeague: 'MWL',
  adhan.CalculationMethod.northAmerica: 'ISNA',
  adhan.CalculationMethod.ummAlQura: 'UAQ',
  adhan.CalculationMethod.egyptian: 'Egypt',
  adhan.CalculationMethod.karachi: 'Karachi',
  adhan.CalculationMethod.turkiye: 'Diyanet',
};

class CompletionScreen extends ConsumerStatefulWidget {
  final VoidCallback onOpenApp;

  const CompletionScreen({super.key, required this.onOpenApp});

  @override
  ConsumerState<CompletionScreen> createState() => _CompletionScreenState();
}

class _CompletionScreenState extends ConsumerState<CompletionScreen> {
  bool _scheduled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_scheduled) return;
    _scheduled = true;
    _scheduleIfEnabled();
  }

  Future<void> _scheduleIfEnabled() async {
    final enabled = ref.read(notificationsEnabledProvider);
    if (!enabled) return;
    final prayers = ref.read(prayerTimesProvider);
    await NotificationService.scheduleTodaysPrayers(
      prayers,
      languageCode: ref.read(appLanguageProvider),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final name = ref.watch(userNameProvider);
    final locationAsync = ref.watch(locationProvider);
    final city = switch (locationAsync) {
      AsyncData(:final value) => value.city,
      _ => 'Standort',
    };
    final method = ref.watch(calculationMethodProvider);
    final methodShort = _methodShortNames[method] ?? method.displayName;
    final notificationsEnabled = ref.watch(notificationsEnabledProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const Spacer(),
              HeroBadge(
                icon: Icons.check,
                size: 190,
                fillColor: AppColors.darkGreen,
              ),
              const SizedBox(height: 28),
              Text(
                name.isEmpty
              ? l10n.onboardingDoneHeading
              : l10n.onboardingDoneHeadingNamed(name),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.onboardingDoneCompanion,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: AppColors.textMuted),
              ),
              const SizedBox(height: 16),
              const OrnamentDivider(),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _SummaryChip(icon: Icons.location_on_outlined, label: city),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: _SummaryChip(icon: Icons.public, label: methodShort),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _SummaryChip(
                      icon: Icons.notifications_outlined,
                      label: notificationsEnabled ? l10n.onboardingAdhanOn : l10n.onboardingAdhanOff,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: widget.onOpenApp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkGreen,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                  ),
                  child: Text(l10n.onboardingOpenApp),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SummaryChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, size: 22, color: AppColors.darkGreen),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}
