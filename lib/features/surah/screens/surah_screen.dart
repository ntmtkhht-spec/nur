import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/surah_provider.dart';
import '../providers/audio_player_provider.dart';
import '../widgets/verse_card.dart';
import '../widgets/audio_player_bottom_bar.dart';

class SurahScreen extends ConsumerStatefulWidget {
  final int surahNumber;

  const SurahScreen({
    super.key,
    this.surahNumber = 1, // Default to Al-Fatiha
  });

  @override
  ConsumerState<SurahScreen> createState() => _SurahScreenState();
}

class _SurahScreenState extends ConsumerState<SurahScreen> {
  bool _playlistInitialized = false;
  final ScrollController _scrollController = ScrollController();
  bool _showBackToTopButton = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.offset >= 400 && !_showBackToTopButton) {
        setState(() {
          _showBackToTopButton = true;
        });
      } else if (_scrollController.offset < 400 && _showBackToTopButton) {
        setState(() {
          _showBackToTopButton = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final surahAsyncValue = ref.watch(surahProvider(widget.surahNumber));
    final audioState = ref.watch(audioPlayerNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkGreen),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: surahAsyncValue.when(
          data: (surah) => Text(
            '${surah.englishName} · ${surah.name}',
            style: const TextStyle(
              color: AppColors.darkGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
          loading: () => const Text('Laden...'),
          error: (_, __) => const Text('Fehler'),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppColors.darkGreen),
            onPressed: () {},
          ),
        ],
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: surahAsyncValue.when(
        data: (surah) {
          if (!_playlistInitialized) {
            _playlistInitialized = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ref.read(audioPlayerNotifierProvider.notifier).initPlaylist(surah.ayahs);
            });
          }

          return Stack(
            children: [
              ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.only(top: 16, bottom: 200), // extra space for bottom bar
                itemCount: surah.ayahs.length,
                itemBuilder: (context, index) {
                  final ayah = surah.ayahs[index];
                  final isPlaying = audioState.currentAyahIndex == index;
                  return VerseCard(
                    ayah: ayah,
                    isPlaying: isPlaying,
                  );
                },
              ),
              const Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: AudioPlayerBottomBar(),
              ),
              if (_showBackToTopButton)
                Positioned(
                  right: 16,
                  bottom: 140, // sit right above the bottom bar
                  child: FloatingActionButton(
                    onPressed: _scrollToTop,
                    backgroundColor: AppColors.primaryGreen,
                    mini: true,
                    child: const Icon(Icons.arrow_upward, color: AppColors.white),
                  ),
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.darkGreen)),
        error: (error, stack) => Center(child: Text('Fehler beim Laden: $error')),
      ),
    );
  }
}
