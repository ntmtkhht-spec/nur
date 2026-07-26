import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/prayer.dart';

class UserNameNotifier extends Notifier<String> {
  @override
  String build() => 'Mohammed';

  void update(String name) => state = name;
}

final userNameProvider =
    NotifierProvider<UserNameNotifier, String>(UserNameNotifier.new);

final hijriDateProvider = Provider<String>((ref) => '14 Muharram 1448');

final prayerTimesProvider = Provider<List<PrayerTime>>((ref) {
  return const [
    PrayerTime(name: 'Fajr', arabicName: 'الفجر', hour: 4, minute: 12),
    PrayerTime(name: 'Dhuhr', arabicName: 'الظهر', hour: 13, minute: 28),
    PrayerTime(name: 'Asr', arabicName: 'العصر', hour: 15, minute: 32),
    PrayerTime(name: 'Maghrib', arabicName: 'المغرب', hour: 21, minute: 44),
    PrayerTime(name: 'Isha', arabicName: 'العشاء', hour: 23, minute: 10),
  ];
});

final nextPrayerIndexProvider = Provider<int>((ref) {
  final prayers = ref.watch(prayerTimesProvider);
  final now = DateTime.now();
  for (var i = 0; i < prayers.length; i++) {
    if (prayers[i].todayAt().isAfter(now)) return i;
  }
  return 0;
});

class CompletedPrayersNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => {'Fajr', 'Dhuhr', 'Asr', 'Maghrib'};

  void toggle(String name) {
    if (state.contains(name)) {
      state = {...state}..remove(name);
    } else {
      state = {...state, name};
    }
  }
}

final completedPrayersProvider =
    NotifierProvider<CompletedPrayersNotifier, Set<String>>(
  CompletedPrayersNotifier.new,
);

final dailyReminderProvider =
    Provider<({String title, String subtitle})>((ref) {
  return (
    title: 'Erinnere dich an Allah',
    subtitle: 'Sei beständig, auch in kleinen Taten.',
  );
});
