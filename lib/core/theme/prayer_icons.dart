import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Icon per prayer, keyed by [PrayerTime.name].
///
/// Shared so the home screen's progress row and the notification settings
/// show the same symbol for the same prayer.
/// Asr and Maghrib come from Cupertino: Material carries neither a sun
/// behind a cloud nor a sun going down, and those two read the time of day
/// far better than a mosque and a second dusk symbol did.
const prayerIcons = <String, IconData>{
  'Fajr': Icons.wb_twilight,
  'Dhuhr': Icons.wb_sunny_outlined,
  'Asr': CupertinoIcons.cloud_sun,
  'Maghrib': CupertinoIcons.sunset,
  'Isha': Icons.nightlight_round,
};

/// Fallback for a name that is not in the map.
const fallbackPrayerIcon = Icons.circle_outlined;
