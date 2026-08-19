import '../../l10n/app_localizations.dart';

/// Translates the internal prayer key stored in [PrayerTime.name].
///
/// Prayer times come from adhan_dart with fixed English keys ('Fajr', 'Asr',
/// …). Those keys drive the tracker storage and must not change, so the
/// display name is resolved here instead.
String localizedPrayerName(AppLocalizations l10n, String key) {
  return switch (key) {
    'Fajr' => l10n.prayerFajr,
    'Sonnenaufgang' || 'Sunrise' => l10n.prayerSunrise,
    'Dhuhr' => l10n.prayerDhuhr,
    'Asr' => l10n.prayerAsr,
    'Maghrib' => l10n.prayerMaghrib,
    'Isha' => l10n.prayerIsha,
    _ => key,
  };
}
