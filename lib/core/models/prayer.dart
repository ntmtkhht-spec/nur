class PrayerTime {
  final String name;
  final String arabicName;
  final DateTime time;

  const PrayerTime({
    required this.name,
    required this.arabicName,
    required this.time,
  });

  String get formattedTime =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
}
