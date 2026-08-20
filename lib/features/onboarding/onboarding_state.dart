import 'package:adhan_dart/adhan_dart.dart' as adhan;

import '../../core/services/calculation_method_by_country.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/providers.dart';

/// Transient wizard state for the onboarding flow. Nothing here is persisted
/// until [OnboardingNotifier.commit] writes it into the real app providers.
class OnboardingData {
  final String language;
  final String? city;
  final double? lat;
  final double? lng;
  final adhan.CalculationMethod calculationMethod;
  final adhan.Madhab madhab;
  final MuezzinVoice muezzinVoice;
  final bool notificationsEnabled;
  final String name;

  const OnboardingData({
    this.language = 'Deutsch',
    this.city,
    this.lat,
    this.lng,
    this.calculationMethod = adhan.CalculationMethod.muslimWorldLeague,
    this.madhab = adhan.Madhab.shafi,
    this.muezzinVoice = MuezzinVoice.misharyAlafasy,
    this.notificationsEnabled = false,
    this.name = '',
  });

  bool get hasLocation => lat != null && lng != null;

  OnboardingData copyWith({
    String? language,
    String? city,
    double? lat,
    double? lng,
    adhan.CalculationMethod? calculationMethod,
    adhan.Madhab? madhab,
    MuezzinVoice? muezzinVoice,
    bool? notificationsEnabled,
    String? name,
  }) {
    return OnboardingData(
      language: language ?? this.language,
      city: city ?? this.city,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      calculationMethod: calculationMethod ?? this.calculationMethod,
      madhab: madhab ?? this.madhab,
      muezzinVoice: muezzinVoice ?? this.muezzinVoice,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      name: name ?? this.name,
    );
  }
}

class OnboardingNotifier extends Notifier<OnboardingData> {
  @override
  OnboardingData build() => const OnboardingData();

  void setLanguage(String language) {
    state = state.copyWith(language: language);
  }

  void setLocation({
    required String city,
    required double lat,
    required double lng,
    String? isoCountryCode,
  }) {
    state = state.copyWith(
      city: city,
      lat: lat,
      lng: lng,
      // The calculation method is no longer asked for; it follows from the
      // country and stays changeable in Settings.
      calculationMethod: calculationMethodForCountry(isoCountryCode),
    );
  }

  void setCalculationMethod(adhan.CalculationMethod method) {
    state = state.copyWith(calculationMethod: method);
  }

  void setMadhab(adhan.Madhab madhab) {
    state = state.copyWith(madhab: madhab);
  }

  void setMuezzinVoice(MuezzinVoice voice) {
    state = state.copyWith(muezzinVoice: voice);
  }

  void setNotificationsEnabled(bool enabled) {
    state = state.copyWith(notificationsEnabled: enabled);
  }

  void setName(String name) {
    state = state.copyWith(name: name);
  }

  /// Persists the collected wizard data into the real app providers.
  /// Does not yet flip the onboarding-complete gate — call
  /// [finishOnboarding] for that once the completion screen is dismissed.
  Future<void> saveSettings() async {
    final data = state;

    ref.read(appLanguageProvider.notifier).update(data.language);

    if (data.hasLocation) {
      ref.read(locationProvider.notifier).setManual(
            LocationData(
              lat: data.lat!,
              lng: data.lng!,
              city: data.city ?? 'Standort',
            ),
          );
    }

    ref.read(calculationMethodProvider.notifier).update(data.calculationMethod);
    ref.read(madhabProvider.notifier).update(data.madhab);
    ref.read(muezzinVoiceProvider.notifier).update(data.muezzinVoice);
    ref
        .read(notificationsEnabledProvider.notifier)
        .set(data.notificationsEnabled);

    if (data.name.trim().isNotEmpty) {
      ref.read(userNameProvider.notifier).update(data.name.trim());
    }

    // Scheduling itself now happens reactively once `_MainShell` mounts
    // (see notificationSchedulerProvider) — it watches notificationsEnabled
    // and every input that can change prayer times, so it picks this up
    // automatically without a one-off call here.
  }

  /// Flips the onboarding-complete gate, swapping the app into [MainShell].
  void finishOnboarding() {
    ref.read(hasCompletedOnboardingProvider.notifier).complete();
  }
}

final onboardingProvider =
    NotifierProvider<OnboardingNotifier, OnboardingData>(
  OnboardingNotifier.new,
);
