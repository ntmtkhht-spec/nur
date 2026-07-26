import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ayah_model.dart';

class SurahService {
  static const String _baseUrl = 'https://api.alquran.cloud/v1';

  Future<List<SurahInfo>> getAllSurahs() async {
    final response = await http.get(Uri.parse('$_baseUrl/surah'));
    
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final List<dynamic> data = json['data'];
      
      return data.map((surah) => SurahInfo(
        number: surah['number'],
        name: surah['name'],
        englishName: surah['englishName'],
        englishNameTranslation: surah['englishNameTranslation'],
        numberOfAyahs: surah['numberOfAyahs'],
        revelationType: surah['revelationType'],
      )).toList();
    } else {
      throw Exception('Failed to load Surahs list');
    }
  }

  Future<Surah> getSurah(int surahNumber) async {
    // We request 4 editions: Arabic text, German translation, Audio, and English Transliteration
    final response = await http.get(Uri.parse('$_baseUrl/surah/$surahNumber/editions/quran-uthmani,de.aburida,ar.alafasy,en.transliteration'));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final List<dynamic> data = json['data'];

      if (data.length < 4) {
        throw Exception('Invalid data from API: Not enough editions returned');
      }

      final arabicEdition = data[0];
      final germanEdition = data[1];
      final audioEdition = data[2];
      final transliterationEdition = data[3];

      final String name = arabicEdition['name'];
      final String englishName = arabicEdition['englishName'];
      
      final List<dynamic> arabicAyahs = arabicEdition['ayahs'];
      final List<dynamic> germanAyahs = germanEdition['ayahs'];
      final List<dynamic> audioAyahs = audioEdition['ayahs'];
      final List<dynamic> transliterationAyahs = transliterationEdition['ayahs'];

      List<Ayah> ayahs = [];
      for (int i = 0; i < arabicAyahs.length; i++) {
        // Remove bismillah from the first ayah of Al-Fatiha except for the audio
        String arabicText = arabicAyahs[i]['text'];
        String translation = germanAyahs[i]['text'];
        String transliteration = transliterationAyahs[i]['text'];
        
        ayahs.add(Ayah(
          numberInSurah: arabicAyahs[i]['numberInSurah'],
          arabicText: arabicText,
          transliteration: transliteration,
          translation: translation,
          audioUrl: audioAyahs[i]['audio'],
        ));
      }

      return Surah(
        number: surahNumber,
        name: name,
        englishName: englishName,
        ayahs: ayahs,
      );
    } else {
      throw Exception('Failed to load Surah');
    }
  }
}
