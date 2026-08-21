import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:munir/features/surah/models/ayah_model.dart';
import 'package:munir/features/surah/services/quran_cache_store.dart';

void main() {
  late Directory tempDirectory;
  late QuranCacheStore store;

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp('nur_quran_cache_');
    store = QuranCacheStore(directoryProvider: () async => tempDirectory);
  });

  tearDown(() async {
    if (await tempDirectory.exists()) {
      await tempDirectory.delete(recursive: true);
    }
  });

  test('round-trips a surah with its exact edition keys', () async {
    final surah = _sampleSurah();

    await store.writeSurah(
      surah: surah,
      languageCode: 'de',
      audioEdition: 'ar.alafasy',
    );

    final result = await store.readSurah(
      surahNumber: 1,
      languageCode: 'de',
      audioEdition: 'ar.alafasy',
    );
    expect(result?.toJson(), surah.toJson());
    expect(
      await store.readSurah(
        surahNumber: 1,
        languageCode: 'en',
        audioEdition: 'ar.alafasy',
      ),
      isNull,
    );
  });

  test('treats malformed or old cache files as misses', () async {
    await store.writeSurah(
      surah: _sampleSurah(),
      languageCode: 'de',
      audioEdition: 'ar.alafasy',
    );
    final file = File('${tempDirectory.path}/surah_1_de_ar.alafasy.json');
    await file.writeAsString(
      jsonEncode({
        'schemaVersion': QuranCacheStore.schemaVersion + 1,
        'kind': 'surah',
        'surahNumber': 1,
        'languageCode': 'de',
        'audioEdition': 'ar.alafasy',
        'surah': _sampleSurah().toJson(),
      }),
    );
    expect(
      await store.readSurah(
        surahNumber: 1,
        languageCode: 'de',
        audioEdition: 'ar.alafasy',
      ),
      isNull,
    );

    await file.writeAsString('{not-json');
    expect(
      await store.readSurah(
        surahNumber: 1,
        languageCode: 'de',
        audioEdition: 'ar.alafasy',
      ),
      isNull,
    );
  });

  test('only accepts a complete ordered surah list', () async {
    final list = List.generate(
      114,
      (index) => SurahInfo(
        number: index + 1,
        name: 'سورة ${index + 1}',
        englishName: 'Surah ${index + 1}',
        englishNameTranslation: 'Translation ${index + 1}',
        numberOfAyahs: 1,
        revelationType: 'Meccan',
      ),
    );
    await store.writeSurahList(list);
    expect((await store.readSurahList())!.length, 114);

    await expectLater(
      store.writeSurahList(list.sublist(0, 113)),
      throwsA(isA<FormatException>()),
    );
    final reordered = [...list];
    reordered[0] = list[1];
    expect(await store.readSurahList(), hasLength(114));
    await File('${tempDirectory.path}/surah_list.json').writeAsString(
      jsonEncode({
        'schemaVersion': QuranCacheStore.schemaVersion,
        'kind': 'surah_list',
        'surahs': reordered.map((item) => item.toJson()).toList(),
      }),
    );
    expect(await store.readSurahList(), isNull);
  });
}

Surah _sampleSurah() => Surah(
  number: 1,
  name: 'الفاتحة',
  englishName: 'Al-Faatiha',
  translationSource: 'Bubenheim & Elyas',
  ayahs: [
    Ayah(
      numberInSurah: 1,
      arabicText: 'بِسْمِ اللَّهِ',
      transliteration: 'Bismillah',
      translation: 'Im Namen Allahs',
      audioUrl: 'https://example.com/1.mp3',
    ),
  ],
);
