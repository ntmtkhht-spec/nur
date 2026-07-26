import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'onboarding_state.dart';
import 'screens/adhan_screen.dart';
import 'screens/calculation_method_screen.dart';
import 'screens/completion_screen.dart';
import 'screens/feature_intro_screen.dart';
import 'screens/language_screen.dart';
import 'screens/location_screen.dart';
import 'screens/name_screen.dart';

/// Orchestrates the linear onboarding wizard:
/// Sprache -> Feature-Intro -> Standort -> Gebetszeiten -> Adhan -> Name -> Fertig.
class OnboardingFlow extends ConsumerStatefulWidget {
  const OnboardingFlow({super.key});

  @override
  ConsumerState<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends ConsumerState<OnboardingFlow> {
  static const _totalSteps = 6;

  int _step = 0;
  bool _showCompletion = false;

  void _goTo(int step) => setState(() => _step = step.clamp(0, _totalSteps - 1));

  void _next() {
    if (_step < _totalSteps - 1) {
      _goTo(_step + 1);
    } else {
      _finishWizard();
    }
  }

  void _finishWizard() {
    ref.read(onboardingProvider.notifier).saveSettings();
    setState(() => _showCompletion = true);
  }

  void _openApp() {
    ref.read(onboardingProvider.notifier).finishOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    if (_showCompletion) {
      return CompletionScreen(onOpenApp: _openApp);
    }

    return switch (_step) {
      0 => LanguageScreen(stepIndex: 0, onNext: _next),
      1 => FeatureIntroScreen(onNext: _next, onSkip: () => _goTo(2)),
      2 => LocationScreen(stepIndex: 2, onNext: _next, onSkip: _next),
      3 => CalculationMethodScreen(stepIndex: 3, onNext: _next),
      4 => AdhanScreen(stepIndex: 4, onNext: _next),
      _ => NameScreen(stepIndex: 5, onNext: _next),
    };
  }
}
