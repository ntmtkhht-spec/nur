import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/providers.dart';
import '../models/ayah_model.dart';
import '../services/surah_service.dart';

final surahServiceProvider = Provider<SurahService>((ref) {
  return SurahService();
});

final surahProvider = FutureProvider.family<Surah, int>((
  ref,
  surahNumber,
) async {
  final service = ref.read(surahServiceProvider);
  final languageCode = ref.watch(appLanguageProvider);
  return service.getSurah(surahNumber, languageCode: languageCode);
});

final surahListProvider = FutureProvider<List<SurahInfo>>((ref) async {
  final service = ref.read(surahServiceProvider);
  return service.getAllSurahs();
});
