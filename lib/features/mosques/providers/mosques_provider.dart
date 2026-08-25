import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

/// Nearby mosques for the current location and radius, backed by a
/// SharedPreferences cache.
///
/// Overpass is slow (the public instance often takes 10-20s) and mosque
/// locations barely change, so refetching on every screen visit — including
/// every app restart, since results only lived in memory before — bought
/// nothing but latency. Results are now cached on disk per (location, radius)
/// for 24h; opening the screen again reads that cache and returns instantly.
/// The refresh button bypasses it explicitly via [refresh].
class NearbyMosquesNotifier extends AsyncNotifier<List<Mosque>> {
  static const _cacheTtl = Duration(hours: 24);
  static const _cacheKeyPrefix = 'mosque_cache_v1_';

  /// Stand-in name for a mosque OpenStreetMap has no name for. Set from the
  /// screen, which is where a BuildContext and therefore the active language
  /// is available.
  static String unnamedLabel = 'Mosque';

  @override
  Future<List<Mosque>> build() async {
    // ref.watch belongs in build(): it's what makes this rebuild when the
    // user's location or the chosen radius changes. refresh() below uses
    // ref.read of the same providers instead, since watching from an
    // imperative method outside build() isn't valid Riverpod usage.
    final locationAsync = ref.watch(locationProvider);
    final location = switch (locationAsync) {
      AsyncData(:final value) => value,
      _ => LocationData.fallback,
    };
    final radius = ref.watch(mosqueRadiusProvider);
    return _loadCachedOrFetch(location, radius);
  }

  /// Forces a live Overpass query regardless of cache freshness, e.g. for the
  /// manual refresh button.
  Future<void> refresh() async {
    final locationAsync = ref.read(locationProvider);
    final location = switch (locationAsync) {
      AsyncData(:final value) => value,
      _ => LocationData.fallback,
    };
    final radius = ref.read(mosqueRadiusProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchAndCache(location, radius));
  }

  Future<List<Mosque>> _loadCachedOrFetch(
    LocationData location,
    int radius,
  ) async {
    final cached = _readCache(location, radius);
    if (cached != null) return cached;
    return _fetchAndCache(location, radius);
  }

  Future<List<Mosque>> _fetchAndCache(
    LocationData location,
    int radius,
  ) async {
    final mosques = await ref.read(overpassServiceProvider).findNearby(
          lat: location.lat,
          lng: location.lng,
          radiusMeters: radius,
          unnamedLabel: unnamedLabel,
        );
    _writeCache(location, radius, mosques);
    return mosques;
  }

  /// Rounded to ~111m so GPS jitter between visits doesn't miss the cache.
  String _cacheKey(LocationData location, int radius) {
    final lat = location.lat.toStringAsFixed(3);
    final lng = location.lng.toStringAsFixed(3);
    return '$_cacheKeyPrefix${lat}_${lng}_$radius';
  }

  List<Mosque>? _readCache(LocationData location, int radius) {
    final raw = ref
        .read(sharedPreferencesProvider)
        .getString(_cacheKey(location, radius));
    if (raw == null) return null;

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final fetchedAt = DateTime.parse(decoded['fetchedAt'] as String);
      if (DateTime.now().difference(fetchedAt) > _cacheTtl) return null;

      return (decoded['mosques'] as List)
          .map((m) => Mosque.fromJson(m as Map<String, dynamic>))
          .toList();
    } catch (_) {
      // Corrupt or outdated cache shape — treat as a miss.
      return null;
    }
  }

  void _writeCache(LocationData location, int radius, List<Mosque> mosques) {
    final payload = jsonEncode({
      'fetchedAt': DateTime.now().toIso8601String(),
      'mosques': mosques.map((m) => m.toJson()).toList(),
    });
    final prefs = ref.read(sharedPreferencesProvider);
    prefs.setString(_cacheKey(location, radius), payload);
    _pruneCache(prefs);
  }

  /// How many (place, radius) results to keep.
  ///
  /// Every distinct rounded position and radius used to add a key that
  /// nothing ever removed — the 24-hour TTL stops a stale entry being *used*,
  /// not stored. SharedPreferences is read into memory in full at launch, so
  /// somebody who travels was paying for every town they had passed through,
  /// on every start, forever.
  static const _maxCachedSearches = 12;

  void _pruneCache(SharedPreferences prefs) {
    final keys = prefs.getKeys().where((k) => k.startsWith(_cacheKeyPrefix));
    if (keys.length <= _maxCachedSearches) return;

    // Oldest first, by the timestamp already stored in each entry. An entry
    // that will not parse has no usable timestamp and no usable content, so
    // it sorts to the front and goes first.
    final dated = <({String key, DateTime fetchedAt})>[];
    for (final key in keys) {
      DateTime fetchedAt;
      try {
        final decoded = jsonDecode(prefs.getString(key)!) as Map;
        fetchedAt = DateTime.parse(decoded['fetchedAt'] as String);
      } catch (_) {
        fetchedAt = DateTime.fromMillisecondsSinceEpoch(0);
      }
      dated.add((key: key, fetchedAt: fetchedAt));
    }
    dated.sort((a, b) => a.fetchedAt.compareTo(b.fetchedAt));

    for (final entry in dated.take(dated.length - _maxCachedSearches)) {
      prefs.remove(entry.key);
    }
  }

  /// Drops every stored search. Offered next to the map-tile cache in
  /// settings, which used to clear the tiles alone and leave these behind.
  static void clearCache(SharedPreferences prefs) {
    for (final key in prefs.getKeys().toList()) {
      if (key.startsWith(_cacheKeyPrefix)) prefs.remove(key);
    }
  }
}

final nearbyMosquesProvider =
    AsyncNotifierProvider<NearbyMosquesNotifier, List<Mosque>>(
  NearbyMosquesNotifier.new,
);
