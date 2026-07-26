import 'package:adhan_dart/adhan_dart.dart' as adhan;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../onboarding_state.dart';
import '../widgets/onboarding_scaffold.dart';
import '../widgets/ornament_divider.dart';

const _abbreviations = {
  adhan.CalculationMethod.muslimWorldLeague: 'MWL',
  adhan.CalculationMethod.northAmerica: 'ISNA',
  adhan.CalculationMethod.ummAlQura: 'UAQ',
  adhan.CalculationMethod.egyptian: 'Egypt',
  adhan.CalculationMethod.karachi: 'Karachi',
  adhan.CalculationMethod.turkiye: 'Diyanet',
};

String _methodLabel(adhan.CalculationMethod m) {
  final abbr = _abbreviations[m];
  return abbr != null ? '${m.displayName} ($abbr)' : m.displayName;
}

class CalculationMethodScreen extends ConsumerWidget {
  final int stepIndex;
  final VoidCallback onNext;

  const CalculationMethodScreen({
    super.key,
    required this.stepIndex,
    required this.onNext,
  });

  Future<void> _pickMethod(BuildContext context, WidgetRef ref) async {
    final current = ref.read(onboardingProvider).calculationMethod;

    final selected = await showModalBottomSheet<adhan.CalculationMethod>(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'Berechnungsmethode',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.55,
                ),
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final method in adhan.CalculationMethod.values)
                      ListTile(
                        title: Text(_methodLabel(method)),
                        trailing: method == current
                            ? const Icon(Icons.check, color: AppColors.primaryGreen)
                            : null,
                        onTap: () => Navigator.of(context).pop(method),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );

    if (selected != null) {
      ref.read(onboardingProvider.notifier).setCalculationMethod(selected);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(onboardingProvider);
    final locationAsync = ref.watch(locationProvider);
    final fallbackLocation = switch (locationAsync) {
      AsyncData(:final value) => value,
      _ => LocationData.fallback,
    };

    final effectiveLocation = data.hasLocation
        ? LocationData(lat: data.lat!, lng: data.lng!, city: data.city ?? '')
        : fallbackLocation;

    final preview = computePrayerTimes(
      location: effectiveLocation,
      method: data.calculationMethod,
      madhab: data.madhab,
    );

    return OnboardingScaffold(
      currentStep: stepIndex,
      onNext: onNext,
      children: [
        const SizedBox(height: 12),
        const Text(
          'Gebetszeiten anpassen',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Wähle die Methode, die deine Gemeinde nutzt.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: AppColors.textMuted),
        ),
        const SizedBox(height: 12),
        const OrnamentDivider(),
        const SizedBox(height: 24),
        const _SectionLabel('BERECHNUNGSMETHODE'),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () => _pickMethod(context, ref),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    size: 20, color: AppColors.darkGreen),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _methodLabel(data.calculationMethod),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down, color: AppColors.textMuted),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        const _SectionLabel('ASR-BERECHNUNG (MADHAB)'),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _MadhabButton(
                label: 'Standard',
                isSelected: data.madhab == adhan.Madhab.shafi,
                onTap: () => ref
                    .read(onboardingProvider.notifier)
                    .setMadhab(adhan.Madhab.shafi),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MadhabButton(
                label: 'Hanafi',
                isSelected: data.madhab == adhan.Madhab.hanafi,
                onTap: () => ref
                    .read(onboardingProvider.notifier)
                    .setMadhab(adhan.Madhab.hanafi),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              const Row(
                children: [
                  Icon(Icons.access_time, size: 18, color: AppColors.primaryGreen),
                  SizedBox(width: 8),
                  Text(
                    'Vorschau für heute',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const OrnamentDivider(),
              const SizedBox(height: 8),
              Row(
                children: [
                  for (final p in preview)
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            p.name,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            p.formattedTime,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.accentGold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _MadhabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _MadhabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.darkGreen : AppColors.cardBg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.balance,
              size: 18,
              color: isSelected ? AppColors.white : AppColors.textDark,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.white : AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
