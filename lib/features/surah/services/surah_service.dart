import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/ayah_model.dart';
import 'quran_cache_store.dart';

class QuranTranslationSource {
  final String edition;
  final String credit;

  const QuranTranslationSource({required this.edition, required this.credit});
}

class SurahService {
  static const String _baseUrl = 'https://api.alquran.cloud/v1';
  static const _networkTimeout = Duration(seconds: 8);

  final QuranCacheStore _cache;
  final Set<String> _refreshesInFlight = <String>{};

  SurahService({QuranCacheStore? cache}) : _cache = cache ?? QuranCacheStore();

  /// Published translation editions exposed by Al Quran Cloud.
  static const Map<String, QuranTranslationSource> translationSources = {
    'de': QuranTranslationSource(
      edition: 'de.bubenheim',
      credit: 'Bubenheim & Elyas',
    ),
    'en': QuranTranslationSource(
      edition: 'en.sahih',
      credit: 'Saheeh International',
    ),
    'fr': QuranTranslationSource(
      edition: 'fr.hamidullah',
      credit: 'Muhammad Hamidullah',
    ),
    'tr': QuranTranslationSource(
      edition: 'tr.diyanet',
      credit: 'Diyanet İşleri Başkanlığı',
    ),
  };

  static QuranTranslationSource? translationSourceFor(String languageCode) {
    final normalized = languageCode.toLowerCase().split('-').first;
    return translationSources[normalized];
  }

  Future<List<SurahInfo>> getAllSurahs() async {
    final cached = await _cache.readSurahList();
    if (cached != null) {
      _refreshListInBackground();
      return cached;
    }
    return _fetchAndCacheList();
  }

  Future<List<SurahInfo>> _fetchAndCacheList() async {
    final response = await http
        .get(Uri.parse('$_baseUrl/surah'))
        .timeout(_networkTimeout);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final data = json['data'];
      if (data is! List || data.length != 114) {
        throw Exception('Invalid Quran API response: surah list');
      }
      final surahs = data
          .map(
            (surah) => SurahInfo(
              number: surah['number'],
              name: surah['name'],
              englishName: surah['englishName'],
              englishNameTranslation: surah['englishNameTranslation'],
              numberOfAyahs: surah['numberOfAyahs'],
              revelationType: surah['revelationType'],
            ),
          )
          .toList();
      if (surahs.asMap().entries.any(
        (entry) => entry.value.number != entry.key + 1,
      )) {
        throw Exception('Invalid Quran API response: surah order');
      }
      try {
        await _cache.writeSurahList(surahs);
      } catch (_) {
        // A cache write must never make valid network data unusable.
      }
      return surahs;
    } else {
      throw Exception('Failed to load Surahs list');
    }
  }

  Future<Surah> getSurah(
    int surahNumber, {
    String languageCode = 'de',
    String audioEdition = 'ar.alafasy',
  }) async {
    final cached = await _cache.readSurah(
      surahNumber: surahNumber,
      languageCode: languageCode,
      audioEdition: audioEdition,
    );
    if (cached != null) {
      _refreshSurahInBackground(
        surahNumber: surahNumber,
        languageCode: languageCode,
        audioEdition: audioEdition,
      );
      return cached;
    }
    return _fetchAndCacheSurah(
      surahNumber,
      languageCode: languageCode,
      audioEdition: audioEdition,
    );
  }

  Future<Surah> _fetchAndCacheSurah(
    int surahNumber, {
    required String languageCode,
    required String audioEdition,
  }) async {
    if (surahNumber < 1 || surahNumber > 114) {
      throw ArgumentError.value(surahNumber, 'surahNumber');
    }

    final translationSource = translationSourceFor(languageCode);
    final requestedEditions = [
      'quran-uthmani',
      if (translationSource != null) translationSource.edition,
      audioEdition,
      'en.transliteration',
    ];
    final response = await http
        .get(
          Uri.parse(
            '$_baseUrl/surah/$surahNumber/editions/${requestedEditions.join(',')}',
          ),
        )
        .timeout(_networkTimeout);

    if (response.statusCode != 200) {
      throw Exception('Failed to load Surah');
    }

    final json = jsonDecode(response.body);
    final data = json['data'];
    if (data is! List) {
      throw Exception('Invalid data from API: Missing editions');
    }

    final editions = <String, Map<String, dynamic>>{};
    for (final rawEdition in data) {
      if (rawEdition is! Map) continue;
      final edition = rawEdition['edition'];
      final identifier = edition is Map ? edition['identifier'] : null;
      if (identifier is String) {
        editions[identifier] = Map<String, dynamic>.from(rawEdition);
      }
    }

    Map<String, dynamic> editionFor(String identifier) {
      final edition = editions[identifier];
      if (edition == null) {
        throw Exception('Missing Quran edition: $identifier');
      }
      return edition;
    }

    final arabicEdition = editionFor('quran-uthmani');
    final audioEditionData = editionFor(audioEdition);
    final transliterationEdition = editionFor('en.transliteration');
    final translationEdition = translationSource == null
        ? null
        : editionFor(translationSource.edition);

    final name = _requiredString(arabicEdition['name'], 'Arabic surah name');
    final englishName = _requiredString(
      arabicEdition['englishName'],
      'English surah name',
    );

    final arabicAyahs = _indexAyahs(arabicEdition, 'Arabic');
    final audioAyahs = _indexAyahs(audioEditionData, 'audio');
    final transliterationAyahs = _indexAyahs(
      transliterationEdition,
      'transliteration',
    );
    final translationAyahs = translationEdition == null
        ? null
        : _indexAyahs(translationEdition, translationSource!.credit);

    _assertAligned(arabicAyahs, audioAyahs, 'audio');
    _assertAligned(arabicAyahs, transliterationAyahs, 'transliteration');
    if (translationAyahs != null) {
      _assertAligned(arabicAyahs, translationAyahs, translationSource!.credit);
    }

    final ayahNumbers = arabicAyahs.keys.toList()..sort();
    final ayahs = <Ayah>[];
    for (final ayahNumber in ayahNumbers) {
      final arabicAyah = arabicAyahs[ayahNumber]!;
      final audioAyah = audioAyahs[ayahNumber]!;
      final transliterationAyah = transliterationAyahs[ayahNumber]!;
      final translationAyah = translationAyahs?[ayahNumber];
      ayahs.add(
        Ayah(
          numberInSurah: ayahNumber,
          arabicText: _text(arabicAyah, 'Arabic'),
          transliteration: _text(transliterationAyah, 'transliteration'),
          translation: translationAyah == null
              ? null
              : _text(translationAyah, translationSource!.credit),
          audioUrl: _audio(audioAyah),
        ),
      );
    }

    final surah = Surah(
      number: surahNumber,
      name: name,
      englishName: englishName,
      translationSource: translationSource?.credit,
      ayahs: ayahs,
    );
    try {
      await _cache.writeSurah(
        surah: surah,
        languageCode: languageCode,
        audioEdition: audioEdition,
      );
    } catch (_) {
      // The fetched content remains usable even if the device cache is full
      // or temporarily unavailable.
    }
    return surah;
  }

  void _refreshListInBackground() {
    if (!_refreshesInFlight.add('list')) return;
    unawaited(() async {
      try {
        await _fetchAndCacheList();
      } catch (_) {
        // Cached content is intentionally retained while offline.
      } finally {
        _refreshesInFlight.remove('list');
      }
    }());
  }

  void _refreshSurahInBackground({
    required int surahNumber,
    required String languageCode,
    required String audioEdition,
  }) {
    final key = 'surah:$surahNumber:$languageCode:$audioEdition';
    if (!_refreshesInFlight.add(key)) return;
    unawaited(() async {
      try {
        await _fetchAndCacheSurah(
          surahNumber,
          languageCode: languageCode,
          audioEdition: audioEdition,
        );
      } catch (_) {
        // Cached content is intentionally retained while offline.
      } finally {
        _refreshesInFlight.remove(key);
      }
    }());
  }

  static Map<int, Map<String, dynamic>> _indexAyahs(
    Map<String, dynamic> edition,
    String label,
  ) {
    final rawAyahs = edition['ayahs'];
    if (rawAyahs is! List || rawAyahs.isEmpty) {
      throw Exception('Missing ayahs in Quran edition: $label');
    }
    final indexed = <int, Map<String, dynamic>>{};
    for (final rawAyah in rawAyahs) {
      if (rawAyah is! Map || rawAyah['numberInSurah'] is! num) {
        throw Exception('Invalid ayah numbering in Quran edition: $label');
      }
      final number = (rawAyah['numberInSurah'] as num).toInt();
      if (number < 1 || indexed.containsKey(number)) {
        throw Exception('Duplicate ayah numbering in Quran edition: $label');
      }
      indexed[number] = Map<String, dynamic>.from(rawAyah);
    }
    return indexed;
  }

  static void _assertAligned(
    Map<int, Map<String, dynamic>> arabic,
    Map<int, Map<String, dynamic>> other,
    String label,
  ) {
    if (arabic.length != other.length ||
        !arabic.keys.toSet().containsAll(other.keys)) {
      throw Exception('Ayah count mismatch between Arabic and $label');
    }
    for (final entry in arabic.entries) {
      final otherAyah = other[entry.key];
      if (otherAyah == null ||
          otherAyah['number'] != entry.value['number'] ||
          otherAyah['numberInSurah'] != entry.value['numberInSurah']) {
        throw Exception('Ayah order mismatch between Arabic and $label');
      }
    }
  }

  static String _text(Map<String, dynamic> ayah, String label) {
    return _requiredString(ayah['text'], 'text ($label)');
  }

  static String _audio(Map<String, dynamic> ayah) {
    return _requiredString(
      ayah['audio'],
      'audio ayah ${ayah['numberInSurah']}',
    );
  }

  static String _requiredString(Object? value, String label) {
    if (value is! String || value.trim().isEmpty) {
      throw Exception('Missing $label in Quran API response');
    }
    return value;
  }
}
