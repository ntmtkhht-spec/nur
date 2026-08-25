import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import '../../../l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../models/ayah_model.dart';
import '../providers/audio_player_provider.dart';
import '../providers/quran_audio_voice_provider.dart';

class AudioPlayerBottomBar extends ConsumerWidget {
  final String surahName;
  final List<Ayah> ayahs;

  const AudioPlayerBottomBar({
    super.key,
    required this.surahName,
    required this.ayahs,
  });

  static const _speeds = [0.75, 1.0, 1.25, 1.5, 2.0];

  static String _formatSpeed(double speed) {
    return speed % 1 == 0 ? '${speed.toInt()}' : '$speed';
  }

  void _openSpeedPicker(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(audioPlayerNotifierProvider.notifier);
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => Consumer(
        builder: (sheetContext, sheetRef, _) {
          final currentSpeed = sheetRef
              .watch(audioPlayerNotifierProvider)
              .speed;
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      AppLocalizations.of(sheetContext).quranPlaybackSpeed,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkGreen,
                      ),
                    ),
                  ),
                  for (final speed in _speeds)
                    ListTile(
                      title: Text('${_formatSpeed(speed)}x'),
                      trailing: speed == currentSpeed
                          ? const Icon(
                              Icons.check,
                              color: AppColors.primaryGreen,
                            )
                          : null,
                      onTap: () {
                        notifier.setSpeed(speed);
                        Navigator.of(sheetContext).pop();
                      },
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(audioPlayerProvider);
    final notifier = ref.read(audioPlayerNotifierProvider.notifier);
    final audioState = ref.watch(audioPlayerNotifierProvider);
    final audioVoice = ref.watch(quranAudioVoiceProvider);

    final index = audioState.currentAyahIndex;
    final ayahNumber = (index != null && index < ayahs.length)
        ? ayahs[index].numberInSurah
        : 1;

    // A failed load used to leave the bar looking idle and doing nothing.
    if (audioState.hasError) {
      return _ErrorBar(onRetry: () => notifier.retry(ayahs));
    }

    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 34),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.goldLight,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkGreen.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          StreamBuilder<PlayerState>(
            stream: player.playerStateStream,
            builder: (context, snapshot) {
              final playerState = snapshot.data;
              final processingState = playerState?.processingState;
              final playing = playerState?.playing;
              if (processingState == ProcessingState.loading ||
                  processingState == ProcessingState.buffering) {
                return _playPauseButton(
                  child: const CircularProgressIndicator(
                    color: AppColors.white,
                    strokeWidth: 2,
                  ),
                );
              } else if (playing != true) {
                return _playPauseButton(
                  icon: Icons.play_arrow_rounded,
                  onPressed: notifier.play,
                );
              } else if (processingState != ProcessingState.completed) {
                return _playPauseButton(
                  icon: Icons.pause_rounded,
                  onPressed: notifier.pause,
                );
              } else {
                return _playPauseButton(
                  icon: Icons.replay_rounded,
                  onPressed: () => player.seek(Duration.zero, index: 0),
                );
              }
            },
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$surahName, Aya $ayahNumber',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.darkGreen,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                Text(
                  audioVoice.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _openSpeedPicker(context, ref),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                '${_formatSpeed(audioState.speed)}x',
                style: const TextStyle(
                  color: AppColors.darkGreen,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            icon: const Icon(
              Icons.skip_previous_rounded,
              color: AppColors.darkGreen,
              size: 22,
            ),
            onPressed: () => notifier.seekToPrevious(),
          ),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            icon: const Icon(
              Icons.skip_next_rounded,
              color: AppColors.darkGreen,
              size: 22,
            ),
            onPressed: () => notifier.seekToNext(),
          ),
        ],
      ),
    );
  }

  Widget _playPauseButton({
    IconData? icon,
    VoidCallback? onPressed,
    Widget? child,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 44,
        height: 44,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.accentGold,
        ),
        child: Center(
          child: child ?? Icon(icon, color: AppColors.white, size: 26),
        ),
      ),
    );
  }
}

/// Replaces the player bar once the recitation could not be loaded.
///
/// Every ayah is streamed, so this is an ordinary outcome on a weak
/// connection — worth saying, and worth offering a second try for, rather
/// than leaving a bar that quietly refuses to play.
class _ErrorBar extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorBar({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 34),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.goldLight,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkGreen.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud_off, size: 20, color: AppColors.darkGreen),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.quranAudioFailed,
              style: const TextStyle(fontSize: 13, color: AppColors.textDark),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: Text(
              l10n.commonRetry,
              style: const TextStyle(
                color: AppColors.darkGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
