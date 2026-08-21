import 'package:flutter_test/flutter_test.dart';
import 'package:munir/features/surah/services/surah_service.dart';

void main() {
  test(
    'supported app languages use explicit published translation editions',
    () {
      expect(SurahService.translationSourceFor('de')?.edition, 'de.bubenheim');
      expect(SurahService.translationSourceFor('en')?.edition, 'en.sahih');
      expect(SurahService.translationSourceFor('fr')?.edition, 'fr.hamidullah');
      expect(SurahService.translationSourceFor('tr')?.edition, 'tr.diyanet');
    },
  );

  test(
    'Arabic uses the original text without pretending tafsir is a translation',
    () {
      expect(SurahService.translationSourceFor('ar'), isNull);
      expect(
        SurahService.translationSourceFor('de-DE')?.edition,
        'de.bubenheim',
      );
    },
  );
}
