import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/providers.dart';
import '../models/mosque.dart';
import '../services/overpass_service.dart';

final overpassServiceProvider =
    Provider<OverpassService>((ref) => OverpassService());

/// Whether the user has agreed to send their coordinates to OpenStreetMap.
/// Searching cannot happen before this is true — see the consent gate on the
/// mosques screen.
class MosqueSearchConsentNotifier extends Notifier<bool> {
  static const _key = 'mosque_search_consent';

  @override
  bool build() =>
      ref.read(sharedPreferencesProvider).getBool(_key) ?? false;

  void grant() {
    ref.read(sharedPreferencesProvider).setBool(_key, true);
    state = true;
  }

  void revoke() {
    ref.read(sharedPreferencesProvider).setBool(_key, false);
    state = false;
  }
}

final mosqueSearchConsentProvider =
    NotifierProvider<MosqueSearchConsentNotifier, bool>(
  MosqueSearchConsentNotifier.new,
);

/// Search radius in metres, adjustable from the mosques screen.
class MosqueRadiusNotifier extends Notifier<int> {
  @override
  int build() => 5000;

  void set(int meters) => state = meters;
}

final mosqueRadiusProvider =
    NotifierProvider<MosqueRadiusNotifier, int>(MosqueRadiusNotifier.new);

/// Nearby mosques for the current location and radius.
///
/// This performs a network request that includes the user's coordinates, so it
/// is deliberately not eager: the screen only watches it once the user has
/// confirmed the search.
final nearbyMosquesProvider = FutureProvider<List<Mosque>>((ref) async {
  final locationAsync = ref.watch(locationProvider);
  final location = switch (locationAsync) {
    AsyncData(:final value) => value,
    _ => LocationData.fallback,
  };
  final radius = ref.watch(mosqueRadiusProvider);

  return ref.read(overpassServiceProvider).findNearby(
        lat: location.lat,
        lng: location.lng,
        radiusMeters: radius,
      );
});
