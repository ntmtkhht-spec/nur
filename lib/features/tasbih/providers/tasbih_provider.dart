import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/providers.dart';

class Dhikr {
  final String text;
  final String arabic;
  final int target;
  const Dhikr({required this.text, required this.arabic, required this.target});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Dhikr &&
          runtimeType == other.runtimeType &&
          text == other.text &&
          arabic == other.arabic &&
          target == other.target;

  @override
  int get hashCode => text.hashCode ^ arabic.hashCode ^ target.hashCode;
}

const defaultDhikrs = [
  Dhikr(text: 'SubhanAllah', arabic: 'سبحان الله', target: 33),
  Dhikr(text: 'Alhamdulillah', arabic: 'الحمد لله', target: 33),
  Dhikr(text: 'Allahu Akbar', arabic: 'الله أكبر', target: 34),
  Dhikr(text: 'La ilaha illallah', arabic: 'لا إله إلا الله', target: 100),
];

class TasbihState {
  final int count;
  final int round;
  final Dhikr selectedDhikr;

  /// Every bead ever counted, across all dhikrs and all resets.
  ///
  /// Resetting the counter is a normal part of using a tasbih, so it must not
  /// wipe what the user has already done.
  final int lifetimeCount;

  const TasbihState({
    this.count = 0,
    this.round = 1,
    this.lifetimeCount = 0,
    required this.selectedDhikr,
  });

  TasbihState copyWith({
    int? count,
    int? round,
    int? lifetimeCount,
    Dhikr? selectedDhikr,
  }) {
    return TasbihState(
      count: count ?? this.count,
      round: round ?? this.round,
      lifetimeCount: lifetimeCount ?? this.lifetimeCount,
      selectedDhikr: selectedDhikr ?? this.selectedDhikr,
    );
  }
}

/// Counter state survives leaving the app.
///
/// Someone part way through a round of 100 who takes a call should come back
/// to their place, not to zero — the prayer tracker persists for the same
/// reason.
class TasbihNotifier extends Notifier<TasbihState> {
  static const _countKey = 'tasbih_count';
  static const _roundKey = 'tasbih_round';
  static const _lifetimeKey = 'tasbih_lifetime';
  static const _dhikrKey = 'tasbih_dhikr';

  @override
  TasbihState build() {
    final prefs = ref.read(sharedPreferencesProvider);

    final storedDhikr = prefs.getString(_dhikrKey);
    final dhikr = defaultDhikrs.firstWhere(
      (d) => d.text == storedDhikr,
      orElse: () => defaultDhikrs.first,
    );

    // A stored count above the target would leave the ring over-full; clamp
    // rather than trusting whatever is on disk.
    final storedCount = prefs.getInt(_countKey) ?? 0;

    return TasbihState(
      count: storedCount.clamp(0, dhikr.target),
      round: (prefs.getInt(_roundKey) ?? 1).clamp(1, 9999),
      lifetimeCount: prefs.getInt(_lifetimeKey) ?? 0,
      selectedDhikr: dhikr,
    );
  }

  void _persist(TasbihState next) {
    final prefs = ref.read(sharedPreferencesProvider);
    prefs.setInt(_countKey, next.count);
    prefs.setInt(_roundKey, next.round);
    prefs.setInt(_lifetimeKey, next.lifetimeCount);
    prefs.setString(_dhikrKey, next.selectedDhikr.text);
  }

  void increment() {
    int nextCount = state.count + 1;
    int nextRound = state.round;

    if (nextCount > state.selectedDhikr.target) {
      nextCount = 1;
      nextRound++;
    }

    final next = state.copyWith(
      count: nextCount,
      round: nextRound,
      lifetimeCount: state.lifetimeCount + 1,
    );
    state = next;
    _persist(next);
  }

  /// Clears the current round only. The lifetime total is a record of what
  /// was actually recited and is deliberately left alone.
  void reset() {
    final next = state.copyWith(count: 0, round: 1);
    state = next;
    _persist(next);
  }

  void setDhikr(Dhikr dhikr) {
    // Counting up to 33 and switching to a dhikr of 100 would carry a
    // meaningless position across, so the round starts over.
    final next = TasbihState(
      selectedDhikr: dhikr,
      lifetimeCount: state.lifetimeCount,
    );
    state = next;
    _persist(next);
  }
}

final tasbihProvider = NotifierProvider<TasbihNotifier, TasbihState>(() {
  return TasbihNotifier();
});
