import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'onboarding_state.dart';
import 'screens/adhan_screen.dart';
import 'screens/language_screen.dart';
import 'screens/location_screen.dart';

/// Three steps: language, location, notifications — then straight into the
/// app.
///
/// It used to be nine screens including a feature carousel, a name prompt and
/// a calculation-method picker. Those asked for things the app either does
/// not need up front (the name is in Settings) or can derive itself (the
/// method follows from the country), and every extra screen is somewhere to
/// drop out.
class OnboardingFlow extends ConsumerStatefulWidget {
  const OnboardingFlow({super.key});

  @override
  ConsumerState<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends ConsumerState<OnboardingFlow> {
  static const _totalSteps = 3;

  int _step = 0;

  Future<void> _next() async {
    if (_step < _totalSteps - 1) {
      setState(() => _step++);
      return;
    }
    await ref.read(onboardingProvider.notifier).saveSettings();
    ref.read(onboardingProvider.notifier).finishOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    return switch (_step) {
      0 => LanguageScreen(stepIndex: 0, onNext: _next),
      1 => LocationScreen(stepIndex: 1, onNext: _next, onSkip: _next),
      _ => AdhanScreen(stepIndex: 2, onNext: _next),
    };
  }
}
