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

  Map<String, dynamic> toJson() => {
    'numberInSurah': numberInSurah,
    'arabicText': arabicText,
    'transliteration': transliteration,
    'translation': translation,
    'audioUrl': audioUrl,
  };

  static Ayah fromJson(Object? value) {
    if (value is! Map) throw const FormatException('Invalid cached ayah');
    final number = value['numberInSurah'];
    final arabicText = value['arabicText'];
    final transliteration = value['transliteration'];
    final translation = value['translation'];
    final audioUrl = value['audioUrl'];
    if (number is! num ||
        number % 1 != 0 ||
        arabicText is! String ||
        transliteration is! String ||
        (translation != null && translation is! String) ||
        audioUrl is! String ||
        audioUrl.isEmpty) {
      throw const FormatException('Invalid cached ayah fields');
    }
    return Ayah(
      numberInSurah: number.toInt(),
      arabicText: arabicText,
      transliteration: transliteration,
      translation: translation as String?,
      audioUrl: audioUrl,
    );
  }
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

  Map<String, dynamic> toJson() => {
    'number': number,
    'name': name,
    'englishName': englishName,
    'translationSource': translationSource,
    'ayahs': ayahs.map((ayah) => ayah.toJson()).toList(),
  };

  static Surah fromJson(Object? value) {
    if (value is! Map) throw const FormatException('Invalid cached surah');
    final number = value['number'];
    final name = value['name'];
    final englishName = value['englishName'];
    final translationSource = value['translationSource'];
    final rawAyahs = value['ayahs'];
    if (number is! num ||
        number % 1 != 0 ||
        name is! String ||
        englishName is! String ||
        (translationSource != null && translationSource is! String) ||
        rawAyahs is! List ||
        rawAyahs.isEmpty) {
      throw const FormatException('Invalid cached surah fields');
    }
    final ayahs = rawAyahs.map(Ayah.fromJson).toList();
    for (var index = 0; index < ayahs.length; index++) {
      if (ayahs[index].numberInSurah != index + 1) {
        throw const FormatException('Cached ayah order is invalid');
      }
    }
    return Surah(
      number: number.toInt(),
      name: name,
      englishName: englishName,
      translationSource: translationSource as String?,
      ayahs: ayahs,
    );
  }
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

  Map<String, dynamic> toJson() => {
    'number': number,
    'name': name,
    'englishName': englishName,
    'englishNameTranslation': englishNameTranslation,
    'numberOfAyahs': numberOfAyahs,
    'revelationType': revelationType,
  };

  static SurahInfo fromJson(Object? value) {
    if (value is! Map) throw const FormatException('Invalid cached surah info');
    final number = value['number'];
    final name = value['name'];
    final englishName = value['englishName'];
    final englishNameTranslation = value['englishNameTranslation'];
    final numberOfAyahs = value['numberOfAyahs'];
    final revelationType = value['revelationType'];
    if (number is! num ||
        number % 1 != 0 ||
        name is! String ||
        englishName is! String ||
        englishNameTranslation is! String ||
        numberOfAyahs is! num ||
        numberOfAyahs % 1 != 0 ||
        revelationType is! String ||
        number.toInt() < 1 ||
        number.toInt() > 114 ||
        numberOfAyahs.toInt() < 1) {
      throw const FormatException('Invalid cached surah info fields');
    }
    return SurahInfo(
      number: number.toInt(),
      name: name,
      englishName: englishName,
      englishNameTranslation: englishNameTranslation,
      numberOfAyahs: numberOfAyahs.toInt(),
      revelationType: revelationType,
    );
  }
}
