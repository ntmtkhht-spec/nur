class PrayerTime {
  final String name;
  final String arabicName;
  final int hour;
  final int minute;

  const PrayerTime({
    required this.name,
    required this.arabicName,
    required this.hour,
    required this.minute,
  });

  String get formattedTime =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  DateTime todayAt() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute);
  }
}
