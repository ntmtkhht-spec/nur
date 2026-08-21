import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/providers.dart';

class QuranAudioVoice {
  final String identifier;
  final String name;

  const QuranAudioVoice({required this.identifier, required this.name});

  static const available = <QuranAudioVoice>[
    QuranAudioVoice(identifier: 'ar.alafasy', name: 'Mishary Alafasy'),
    QuranAudioVoice(
      identifier: 'ar.abdulbasitmurattal',
      name: 'Abdul Basit (Murattal)',
    ),
    QuranAudioVoice(identifier: 'ar.husary', name: 'Mahmoud Khalil Al-Husary'),
  ];

  static QuranAudioVoice fromIdentifier(String? identifier) {
    return available.firstWhere(
      (voice) => voice.identifier == identifier,
      orElse: () => available.first,
    );
  }
}

class QuranAudioVoiceNotifier extends Notifier<QuranAudioVoice> {
  static const _storageKey = 'quran_audio_voice_v1';

  @override
  QuranAudioVoice build() {
    final identifier = ref
        .read(sharedPreferencesProvider)
        .getString(_storageKey);
    return QuranAudioVoice.fromIdentifier(identifier);
  }

  void setVoice(QuranAudioVoice voice) {
    ref
        .read(sharedPreferencesProvider)
        .setString(_storageKey, voice.identifier);
    state = voice;
  }
}

final quranAudioVoiceProvider =
    NotifierProvider<QuranAudioVoiceNotifier, QuranAudioVoice>(
      QuranAudioVoiceNotifier.new,
    );
