import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/ayah_model.dart';

/// Device-level cache for Quran content.
///
/// Quran content is not personal data: it survives sign-out and account
/// changes so a shared device can still read offline. Every entry carries a
/// schema version and its exact language/audio key, preventing a stale or
/// mismatched edition from being shown as current content.
///
/// It lives in the cache directory, not application support. Everything here
/// can be fetched again from alquran.cloud, and Apple's data storage
/// guidelines are explicit that re-downloadable content must not sit in a
/// backed-up location — application support is backed up to iCloud, a
/// surah-per-file cache is not small, and apps have been rejected over
/// exactly this. Being purgeable under disk pressure costs nothing: every
/// read already treats a missing file as a cache miss and goes to the
/// network.
class QuranCacheStore {
  static const schemaVersion = 1;
  static const _directoryName = 'quran_cache_v1';

  final Future<Directory> Function() _directoryProvider;

  QuranCacheStore({Future<Directory> Function()? directoryProvider})
    : _directoryProvider = directoryProvider ?? _defaultDirectory;

  static Future<Directory> _defaultDirectory() async {
    final cache = await getApplicationCacheDirectory();
    return Directory('${cache.path}/$_directoryName');
  }

  Future<Surah?> readSurah({
    required int surahNumber,
    required String languageCode,
    required String audioEdition,
  }) async {
    final file = await _file(
      _surahFileName(surahNumber, languageCode, audioEdition),
    );
    if (!await file.exists()) return null;
    try {
      final payload = jsonDecode(await file.readAsString());
      if (payload is! Map ||
          payload['schemaVersion'] != schemaVersion ||
          payload['kind'] != 'surah' ||
          payload['surahNumber'] != surahNumber ||
          payload['languageCode'] != languageCode ||
          payload['audioEdition'] != audioEdition) {
        return null;
      }
      final surah = Surah.fromJson(payload['surah']);
      if (surah.number != surahNumber) return null;
      return surah;
    } catch (_) {
      // A partial write, old schema, or manually corrupted file is a cache
      // miss. The network path can safely replace it.
      return null;
    }
  }

  Future<void> writeSurah({
    required Surah surah,
    required String languageCode,
    required String audioEdition,
  }) async {
    final file = await _file(
      _surahFileName(surah.number, languageCode, audioEdition),
      createDirectory: true,
    );
    await _atomicWrite(
      file,
      jsonEncode({
        'schemaVersion': schemaVersion,
        'kind': 'surah',
        'surahNumber': surah.number,
        'languageCode': languageCode,
        'audioEdition': audioEdition,
        'fetchedAt': DateTime.now().toUtc().toIso8601String(),
        'surah': surah.toJson(),
      }),
    );
  }

  Future<List<SurahInfo>?> readSurahList() async {
    final file = await _file('surah_list.json');
    if (!await file.exists()) return null;
    try {
      final payload = jsonDecode(await file.readAsString());
      if (payload is! Map ||
          payload['schemaVersion'] != schemaVersion ||
          payload['kind'] != 'surah_list' ||
          payload['surahs'] is! List) {
        return null;
      }
      final surahs = (payload['surahs'] as List)
          .map(SurahInfo.fromJson)
          .toList();
      if (surahs.length != 114 ||
          surahs.asMap().entries.any(
            (entry) => entry.value.number != entry.key + 1,
          )) {
        return null;
      }
      return surahs;
    } catch (_) {
      return null;
    }
  }

  Future<void> writeSurahList(List<SurahInfo> surahs) async {
    if (surahs.length != 114 ||
        surahs.asMap().entries.any(
          (entry) => entry.value.number != entry.key + 1,
        )) {
      throw const FormatException('Refusing to cache incomplete surah list');
    }
    final file = await _file('surah_list.json', createDirectory: true);
    await _atomicWrite(
      file,
      jsonEncode({
        'schemaVersion': schemaVersion,
        'kind': 'surah_list',
        'fetchedAt': DateTime.now().toUtc().toIso8601String(),
        'surahs': surahs.map((surah) => surah.toJson()).toList(),
      }),
    );
  }

  Future<File> _file(String name, {bool createDirectory = false}) async {
    final directory = await _directoryProvider();
    if (createDirectory && !await directory.exists()) {
      await directory.create(recursive: true);
    }
    return File('${directory.path}/$name');
  }

  Future<void> _atomicWrite(File target, String content) async {
    final temporary = File(
      '${target.path}.tmp-${DateTime.now().microsecondsSinceEpoch}',
    );
    await temporary.writeAsString(content, flush: true);
    try {
      await temporary.rename(target.path);
    } on FileSystemException {
      // Some platforms do not replace an existing file on rename. Removing
      // the old complete file first still ensures readers see either a
      // complete old file or a complete new file, never partial JSON.
      if (await target.exists()) await target.delete();
      await temporary.rename(target.path);
    }
  }

  static String _surahFileName(
    int surahNumber,
    String languageCode,
    String audioEdition,
  ) {
    final safeLanguage = _safePart(languageCode);
    final safeAudio = _safePart(audioEdition);
    return 'surah_${surahNumber}_${safeLanguage}_$safeAudio.json';
  }

  static String _safePart(String value) =>
      value.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
}
