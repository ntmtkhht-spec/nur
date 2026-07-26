class PrayerTime {
  final String name;
  final String arabicName;
  final DateTime time;
  final bool isPrayer;

  const PrayerTime({
    required this.name,
    required this.arabicName,
    required this.time,
    this.isPrayer = true,
  });

  String get formattedTime =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
}
