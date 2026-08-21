import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/providers.dart';

/// The Quran contains 6,236 numbered ayat. Keeping the actual identifiers
/// instead of a made-up percentage makes the overall progress correct even
/// when a reader moves between surahs in a non-linear order.
const quranTotalAyahs = 6236;

class QuranReadingPosition {
  final int surahNumber;
  final int ayahNumber;
  final int updatedAtMs;

  const QuranReadingPosition({
    required this.surahNumber,
    required this.ayahNumber,
    required this.updatedAtMs,
  });

  String get ayahId => '$surahNumber:$ayahNumber';

  Map<String, dynamic> toJson() => {
    'surahNumber': surahNumber,
    'ayahNumber': ayahNumber,
    'updatedAtMs': updatedAtMs,
  };

  static QuranReadingPosition? fromJson(Object? value) {
    if (value is! Map) return null;
    final surah = value['surahNumber'];
    final ayah = value['ayahNumber'];
    final updatedAt = value['updatedAtMs'];
    if (surah is! num || ayah is! num || updatedAt is! num) return null;
    final result = QuranReadingPosition(
      surahNumber: surah.toInt(),
      ayahNumber: ayah.toInt(),
      updatedAtMs: updatedAt.toInt(),
    );
    if (result.surahNumber < 1 ||
        result.surahNumber > 114 ||
        result.ayahNumber < 1 ||
        result.updatedAtMs < 0) {
      return null;
    }
    return result;
  }
}

class QuranReadingProgress {
  final QuranReadingPosition? lastPosition;
  final Set<String> readAyahIds;

  const QuranReadingProgress({
    this.lastPosition,
    this.readAyahIds = const <String>{},
  });

  bool get hasActivity => lastPosition != null || readAyahIds.isNotEmpty;
  int get completedAyahCount => readAyahIds.length;
  double get completionFraction =>
      (completedAyahCount / quranTotalAyahs).clamp(0.0, 1.0);

  QuranReadingProgress copyWith({
    QuranReadingPosition? lastPosition,
    Set<String>? readAyahIds,
  }) {
    return QuranReadingProgress(
      lastPosition: lastPosition ?? this.lastPosition,
      readAyahIds: readAyahIds ?? this.readAyahIds,
    );
  }

  Map<String, dynamic> toJson() => {
    'version': 1,
    if (lastPosition != null) 'lastPosition': lastPosition!.toJson(),
    // Sorted output makes the persisted and synced representation stable,
    // which avoids meaningless writes when two devices have the same data.
    'readAyahIds': readAyahIds.toList()..sort(),
  };

  static QuranReadingProgress fromJson(Object? value) {
    if (value is! Map) return const QuranReadingProgress();
    final ids = <String>{};
    final rawIds = value['readAyahIds'];
    if (rawIds is List) {
      for (final raw in rawIds) {
        if (raw is String && _isValidAyahId(raw)) ids.add(raw);
      }
    }
    return QuranReadingProgress(
      lastPosition: QuranReadingPosition.fromJson(value['lastPosition']),
      readAyahIds: ids,
    );
  }

  static bool _isValidAyahId(String value) {
    final parts = value.split(':');
    if (parts.length != 2) return false;
    final surah = int.tryParse(parts[0]);
    final ayah = int.tryParse(parts[1]);
    return surah != null &&
        ayah != null &&
        surah >= 1 &&
        surah <= 114 &&
        ayah >= 1;
  }
}

class QuranReadingProgressNotifier extends Notifier<QuranReadingProgress> {
  static const _storageKey = 'quran_reading_progress_v1';

  @override
  QuranReadingProgress build() {
    final raw = ref.read(sharedPreferencesProvider).getString(_storageKey);
    if (raw == null) return const QuranReadingProgress();
    try {
      return QuranReadingProgress.fromJson(jsonDecode(raw));
    } on FormatException {
      return const QuranReadingProgress();
    }
  }

  Future<void> markRead({
    required int surahNumber,
    required int ayahNumber,
  }) async {
    if (surahNumber < 1 || surahNumber > 114 || ayahNumber < 1) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    final position = QuranReadingPosition(
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
      updatedAtMs: now,
    );
    final ids = {...state.readAyahIds, position.ayahId};
    await _replace(state.copyWith(lastPosition: position, readAyahIds: ids));
  }

  /// Unioning completed ayat means reading recorded on either device is never
  /// lost. The newest resume marker wins; an exact timestamp tie has a stable
  /// lexical tie-breaker, so every device reaches the same result.
  Future<void> mergeRemote(Map<String, dynamic> remote) async {
    final other = QuranReadingProgress.fromJson(remote);
    final mergedIds = {...state.readAyahIds, ...other.readAyahIds};
    final last = _newerPosition(state.lastPosition, other.lastPosition);
    await _replace(
      QuranReadingProgress(lastPosition: last, readAyahIds: mergedIds),
    );
  }

  Future<void> clear() => _replace(const QuranReadingProgress());

  QuranReadingPosition? _newerPosition(
    QuranReadingPosition? first,
    QuranReadingPosition? second,
  ) {
    if (first == null) return second;
    if (second == null) return first;
    if (first.updatedAtMs != second.updatedAtMs) {
      return first.updatedAtMs > second.updatedAtMs ? first : second;
    }
    return first.ayahId.compareTo(second.ayahId) >= 0 ? first : second;
  }

  Future<void> _replace(QuranReadingProgress next) async {
    state = next;
    await ref
        .read(sharedPreferencesProvider)
        .setString(_storageKey, jsonEncode(next.toJson()));
  }
}

final quranReadingProgressProvider =
    NotifierProvider<QuranReadingProgressNotifier, QuranReadingProgress>(
      QuranReadingProgressNotifier.new,
    );
