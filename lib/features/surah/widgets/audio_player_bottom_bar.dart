import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/audio_player_provider.dart';

class AudioPlayerBottomBar extends ConsumerWidget {
  const AudioPlayerBottomBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(audioPlayerProvider);
    final notifier = ref.read(audioPlayerNotifierProvider.notifier);

    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 24),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.darkGreen,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkGreen.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Mishary Alafasy',
                style: TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(
                  Icons.tune_rounded,
                  color: AppColors.white,
                  size: 20,
                ),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                iconSize: 32,
                icon: const Icon(
                  Icons.skip_previous_rounded,
                  color: AppColors.white,
                ),
                onPressed: () => notifier.seekToPrevious(),
              ),
              const SizedBox(width: 16),
              StreamBuilder<PlayerState>(
                stream: player.playerStateStream,
                builder: (context, snapshot) {
                  final playerState = snapshot.data;
                  final processingState = playerState?.processingState;
                  final playing = playerState?.playing;
                  if (processingState == ProcessingState.loading ||
                      processingState == ProcessingState.buffering) {
                    return Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.accentGold,
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.white,
                        ),
                      ),
                    );
                  } else if (playing != true) {
                    return _playPauseButton(
                      Icons.play_arrow_rounded,
                      notifier.play,
                    );
                  } else if (processingState != ProcessingState.completed) {
                    return _playPauseButton(
                      Icons.pause_rounded,
                      notifier.pause,
                    );
                  } else {
                    return _playPauseButton(
                      Icons.replay_rounded,
                      () => player.seek(Duration.zero, index: 0),
                    );
                  }
                },
              ),
              const SizedBox(width: 16),
              IconButton(
                iconSize: 32,
                icon: const Icon(
                  Icons.skip_next_rounded,
                  color: AppColors.white,
                ),
                onPressed: () => notifier.seekToNext(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          StreamBuilder<Duration>(
            stream: player.positionStream,
            builder: (context, snapshot) {
              final position = snapshot.data ?? Duration.zero;
              return StreamBuilder<Duration?>(
                stream: player.durationStream,
                builder: (context, durationSnapshot) {
                  final duration = durationSnapshot.data ?? Duration.zero;
                  return ProgressBar(
                    progress: position,
                    total: duration,
                    onSeek: notifier.seek,
                    barHeight: 3,
                    baseBarColor: AppColors.white.withValues(alpha: 0.3),
                    progressBarColor: AppColors.accentGold,
                    thumbColor: AppColors.accentGold,
                    thumbRadius: 6,
                    timeLabelTextStyle: const TextStyle(
                      color: AppColors.accentGold,
                      fontSize: 12,
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _playPauseButton(IconData icon, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 56,
        height: 56,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.accentGold,
        ),
        child: Icon(icon, color: AppColors.white, size: 36),
      ),
    );
  }
}
