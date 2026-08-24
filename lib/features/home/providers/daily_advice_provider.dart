import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/daily_advice.dart';

/// The entry of the guide that belongs to [date].
///
/// Counted in whole days since the epoch rather than in days of the year, so
/// the rotation carries on across New Year instead of jumping back to an entry
/// that was already shown days earlier.
DailyAdvice adviceForDate(DateTime date) {
  final days = DateTime(date.year, date.month, date.day)
      .difference(DateTime(1970))
      .inDays;
  return dailyAdvices[days % dailyAdvices.length];
}

final dailyAdviceProvider = Provider<DailyAdvice>((ref) {
  return adviceForDate(DateTime.now());
});
