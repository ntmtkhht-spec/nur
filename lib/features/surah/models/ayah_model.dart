class Ayah {
  final int numberInSurah;
  final String arabicText;
  final String transliteration;
  final String? translation;
  final String audioUrl;

  Ayah({
    required this.numberInSurah,
    required this.arabicText,
    required this.transliteration,
    required this.translation,
    required this.audioUrl,
  });
}

class Surah {
  final int number;
  final String name;
  final String englishName;
  final String? translationSource;
  final List<Ayah> ayahs;

  Surah({
    required this.number,
    required this.name,
    required this.englishName,
    this.translationSource,
    required this.ayahs,
  });
}

class SurahInfo {
  final int number;
  final String name;
  final String englishName;
  final String englishNameTranslation;
  final int numberOfAyahs;
  final String revelationType;

  SurahInfo({
    required this.number,
    required this.name,
    required this.englishName,
    required this.englishNameTranslation,
    required this.numberOfAyahs,
    required this.revelationType,
  });
}
