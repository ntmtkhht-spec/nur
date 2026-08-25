import 'package:flutter/foundation.dart';
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
  final int? surahNumber;
  final int? currentAyahIndex;
  final double speed;
  final bool isPlaying;

  /// True once loading or playing the recitation has failed.
  ///
  /// Every ayah is streamed from a CDN, so a dropped connection or a single
  /// missing file is an ordinary outcome. It used to be an unhandled async
  /// error: the player went quiet and nothing on screen said why.
  final bool hasError;

  AudioPlayerState({
    this.surahNumber,
    this.currentAyahIndex,
    this.speed = 1.0,
    this.isPlaying = false,
    this.hasError = false,
  });

  AudioPlayerState copyWith({
    int? surahNumber,
    int? currentAyahIndex,
    double? speed,
    bool? isPlaying,
    bool? hasError,
  }) {
    return AudioPlayerState(
      surahNumber: surahNumber ?? this.surahNumber,
      currentAyahIndex: currentAyahIndex ?? this.currentAyahIndex,
      speed: speed ?? this.speed,
      isPlaying: isPlaying ?? this.isPlaying,
      hasError: hasError ?? this.hasError,
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
    _player.playingStream.listen((isPlaying) {
      state = state.copyWith(isPlaying: isPlaying);
    });
    // just_audio reports decoder and network failures here rather than by
    // completing a future, so without this listener a mid-surah drop-out
    // arrived as an unhandled error and the bar simply stopped responding.
    _player.playbackEventStream.listen(
      (_) {},
      onError: (Object e, StackTrace st) {
        debugPrint('Recitation playback failed: $e');
        state = state.copyWith(isPlaying: false, hasError: true);
      },
    );
    return AudioPlayerState();
  }

  /// Loads a surah's recitation. Reports failure through [state] rather than
  /// throwing: the caller runs this from a post-frame callback, where a
  /// thrown error has nobody to catch it.
  Future<void> initPlaylist({
    required int surahNumber,
    required List<Ayah> ayahs,
  }) async {
    final audioSources = ayahs
        .map((ayah) => AudioSource.uri(Uri.parse(ayah.audioUrl)))
        .toList();
    // ignore: deprecated_member_use
    final playlist = ConcatenatingAudioSource(children: audioSources);
    try {
      await _player.setAudioSource(playlist);
    } catch (e) {
      debugPrint('Recitation could not be loaded: $e');
      state = state.copyWith(
        surahNumber: surahNumber,
        currentAyahIndex: 0,
        isPlaying: false,
        hasError: true,
      );
      return;
    }
    state = state.copyWith(
      surahNumber: surahNumber,
      currentAyahIndex: 0,
      isPlaying: false,
      hasError: false,
    );
  }

  /// Retries whatever failed, from the top of the surah.
  Future<void> retry(List<Ayah> ayahs) {
    final surahNumber = state.surahNumber;
    if (surahNumber == null) return Future<void>.value();
    state = state.copyWith(hasError: false);
    return initPlaylist(surahNumber: surahNumber, ayahs: ayahs);
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

final audioPlayerNotifierProvider =
    NotifierProvider<AudioPlayerNotifier, AudioPlayerState>(() {
      return AudioPlayerNotifier();
    });
