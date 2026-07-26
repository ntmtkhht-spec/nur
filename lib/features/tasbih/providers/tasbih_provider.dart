import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  const TasbihState({
    this.count = 0,
    this.round = 1,
    required this.selectedDhikr,
  });

  TasbihState copyWith({
    int? count,
    int? round,
    Dhikr? selectedDhikr,
  }) {
    return TasbihState(
      count: count ?? this.count,
      round: round ?? this.round,
      selectedDhikr: selectedDhikr ?? this.selectedDhikr,
    );
  }
}

class TasbihNotifier extends Notifier<TasbihState> {
  @override
  TasbihState build() {
    return TasbihState(selectedDhikr: defaultDhikrs.first);
  }

  void increment() {
    int nextCount = state.count + 1;
    int nextRound = state.round;

    if (nextCount > state.selectedDhikr.target) {
      nextCount = 1;
      nextRound++;
    }

    state = state.copyWith(count: nextCount, round: nextRound);
  }

  void reset() {
    state = state.copyWith(count: 0, round: 1);
  }

  void setDhikr(Dhikr dhikr) {
    state = TasbihState(selectedDhikr: dhikr); // resets when changed
  }
}

final tasbihProvider = NotifierProvider<TasbihNotifier, TasbihState>(() {
  return TasbihNotifier();
});
