import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:munir/core/models/prayer.dart';
import 'package:munir/core/providers/providers.dart';
import 'package:munir/l10n/app_localizations.dart';

void main() {
  test('a prayer time renders as a 24h clock reading', () {
    final asr = PrayerTime(
      name: 'Asr',
      arabicName: 'العصر',
      time: DateTime(2026, 8, 23, 17, 20),
    );

    expect(asr.formattedTime, '17:20');
  });

  test('German notification texts carry the time and the place', () async {
    final l10n = await AppLocalizations.delegate.load(const Locale('de'));

    expect(l10n.notificationPrayerTimeTitle('Asr', '17:20'), contains('17:20'));
    expect(l10n.notificationPrayerTimeTitle('Asr', '17:20'), contains('Asr'));
    expect(l10n.notificationLocationLine('Oldenburg'), contains('Oldenburg'));
    expect(l10n.notificationCatchUpBody('Maghrib', '20:41'), contains('20:41'));
  });

  // A translation that drops the placeholder would silently ship a reminder
  // without the one thing this is for, and only in that language.
  test('every locale keeps the time and city placeholders', () async {
    for (final locale in AppLocalizations.supportedLocales) {
      final l10n = await AppLocalizations.delegate.load(locale);
      final reason = 'locale ${locale.languageCode}';

      expect(
        l10n.notificationPrayerTimeTitle('Asr', '17:20'),
        contains('17:20'),
        reason: reason,
      );
      expect(
        l10n.notificationCatchUpBody('Maghrib', '20:41'),
        contains('20:41'),
        reason: reason,
      );
      expect(
        l10n.notificationLocationLine('Oldenburg'),
        contains('Oldenburg'),
        reason: reason,
      );
    }
  });

  group('LocationData.resolvedCity', () {
    test('returns a real city name', () {
      const location = LocationData(lat: 53.14, lng: 8.21, city: 'Oldenburg');

      expect(location.resolvedCity, 'Oldenburg');
    });

    test('withholds the unresolved placeholder', () {
      // Reverse geocoding gave nothing, so 'Standort' is a label, not a place.
      const location = LocationData(lat: 53.14, lng: 8.21);

      expect(location.city, 'Standort');
      expect(location.resolvedCity, isNull);
    });

    test('withholds an empty city', () {
      const location = LocationData(lat: 53.14, lng: 8.21, city: '');

      expect(location.resolvedCity, isNull);
    });

    test('keeps the fallback city, which is a real place', () {
      expect(LocationData.fallback.resolvedCity, 'Berlin');
    });
  });
}
