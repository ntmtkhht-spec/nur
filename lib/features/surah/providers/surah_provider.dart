import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ayah_model.dart';
import '../services/surah_service.dart';

final surahServiceProvider = Provider<SurahService>((ref) {
  return SurahService();
});

final surahProvider = FutureProvider.family<Surah, int>((ref, surahNumber) async {
  final service = ref.read(surahServiceProvider);
  return service.getSurah(surahNumber);
});

final surahListProvider = FutureProvider<List<SurahInfo>>((ref) async {
  final service = ref.read(surahServiceProvider);
  return service.getAllSurahs();
});

