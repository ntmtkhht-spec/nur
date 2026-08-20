import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../models/ayah_model.dart';

// Provides a single instance of AudioPlayer
final audioPlayerProvider = Provider<AudioPlayer>((ref) {
  final player = AudioPlayer();
  ref.onDispose(() => player.dispose());
  return player;
});

class AudioPlayerState {
  final int? currentAyahIndex;
  final double speed;

  AudioPlayerState({this.currentAyahIndex, this.speed = 1.0});

  AudioPlayerState copyWith({int? currentAyahIndex, double? speed}) {
    return AudioPlayerState(
      currentAyahIndex: currentAyahIndex ?? this.currentAyahIndex,
      speed: speed ?? this.speed,
    );
  }
}

class AudioPlayerNotifier extends Notifier<AudioPlayerState> {
  late final AudioPlayer _player;

  @override
  AudioPlayerState build() {
    _player = ref.watch(audioPlayerProvider);
    
    _player.currentIndexStream.listen((index) {
      if (index != null) {
        state = state.copyWith(currentAyahIndex: index);
      }
    });
    return AudioPlayerState();
  }
  Future<void> initPlaylist(List<Ayah> ayahs) async {
    final audioSources = ayahs.map((ayah) => AudioSource.uri(Uri.parse(ayah.audioUrl))).toList();
    // ignore: deprecated_member_use
    final playlist = ConcatenatingAudioSource(children: audioSources);
    await _player.setAudioSource(playlist);
    state = state.copyWith(currentAyahIndex: 0);
  }
  
  Future<void> play() => _player.play();
  Future<void> pause() => _player.pause();
  Future<void> seekToNext() => _player.seekToNext();
  Future<void> seekToPrevious() => _player.seekToPrevious();
  Future<void> seek(Duration position) => _player.seek(position);

  Future<void> setSpeed(double speed) async {
    await _player.setSpeed(speed);
    state = state.copyWith(speed: speed);
  }
}

final audioPlayerNotifierProvider = NotifierProvider<AudioPlayerNotifier, AudioPlayerState>(() {
  return AudioPlayerNotifier();
});
