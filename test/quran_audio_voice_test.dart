import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:munir/core/providers/providers.dart';
import 'package:munir/features/surah/providers/quran_audio_voice_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('selected Quran voice is restored and persisted', () async {
    SharedPreferences.setMockInitialValues({
      'quran_audio_voice_v1': 'ar.husary',
    });
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);

    expect(container.read(quranAudioVoiceProvider).identifier, 'ar.husary');

    final voice = QuranAudioVoice.available.first;
    container.read(quranAudioVoiceProvider.notifier).setVoice(voice);
    expect(prefs.getString('quran_audio_voice_v1'), voice.identifier);
    expect(container.read(quranAudioVoiceProvider), voice);
  });
}
