import 'package:flutter/material.dart';

/// Icon per prayer, keyed by [PrayerTime.name].
///
/// Shared so the home screen's progress row and the notification settings
/// show the same symbol for the same prayer.
const prayerIcons = <String, IconData>{
  'Fajr': Icons.wb_twilight,
  'Dhuhr': Icons.wb_sunny_outlined,
  'Asr': Icons.mosque_outlined,
  'Maghrib': Icons.wb_twilight_outlined,
  'Isha': Icons.nightlight_round,
};

/// Fallback for a name that is not in the map.
const fallbackPrayerIcon = Icons.circle_outlined;
