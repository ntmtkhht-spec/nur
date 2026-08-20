import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/providers.dart';

class QuranReadingPrefs {
  final bool showTransliteration;
  final bool showTranslation;
  final double arabicFontScale;

  const QuranReadingPrefs({
    this.showTransliteration = true,
    this.showTranslation = true,
    this.arabicFontScale = 1.0,
  });

  QuranReadingPrefs copyWith({
    bool? showTransliteration,
    bool? showTranslation,
    double? arabicFontScale,
  }) {
    return QuranReadingPrefs(
      showTransliteration: showTransliteration ?? this.showTransliteration,
      showTranslation: showTranslation ?? this.showTranslation,
      arabicFontScale: arabicFontScale ?? this.arabicFontScale,
    );
  }
}

class QuranReadingPrefsNotifier extends Notifier<QuranReadingPrefs> {
  static const _kTransliteration = 'quran_show_transliteration';
  static const _kTranslation = 'quran_show_translation';
  static const _kFontScale = 'quran_arabic_font_scale';

  @override
  QuranReadingPrefs build() {
    final prefs = ref.read(sharedPreferencesProvider);
    return QuranReadingPrefs(
      showTransliteration: prefs.getBool(_kTransliteration) ?? true,
      showTranslation: prefs.getBool(_kTranslation) ?? true,
      arabicFontScale: prefs.getDouble(_kFontScale) ?? 1.0,
    );
  }

  void setShowTransliteration(bool value) {
    ref.read(sharedPreferencesProvider).setBool(_kTransliteration, value);
    state = state.copyWith(showTransliteration: value);
  }

  void setShowTranslation(bool value) {
    ref.read(sharedPreferencesProvider).setBool(_kTranslation, value);
    state = state.copyWith(showTranslation: value);
  }

  void setArabicFontScale(double value) {
    ref.read(sharedPreferencesProvider).setDouble(_kFontScale, value);
    state = state.copyWith(arabicFontScale: value);
  }
}

final quranReadingPrefsProvider =
    NotifierProvider<QuranReadingPrefsNotifier, QuranReadingPrefs>(
      QuranReadingPrefsNotifier.new,
    );
