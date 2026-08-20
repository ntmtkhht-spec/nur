import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../models/ayah_model.dart';
import '../providers/surah_provider.dart';
import '../providers/audio_player_provider.dart';
import '../providers/reading_prefs_provider.dart';
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

  // Jumping between suras used to mean: back to the list, scroll, find it,
  // tap. This lets you switch straight from the reading screen.
  void _openSurahPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => _SurahPickerSheet(
        currentSurahNumber: widget.surahNumber,
        onSelect: (number) {
          Navigator.of(sheetContext).pop();
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => SurahScreen(surahNumber: number),
            ),
          );
        },
      ),
    );
  }

  // The gear icon had no handler; it now opens the reading preferences that
  // VerseCard reads (transliteration, translation, Arabic text size).
  void _openReadingSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _ReadingSettingsSheet(),
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
        title: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => _openSurahPicker(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
            child: surahAsyncValue.when(
              data: (surah) => Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      '${surah.englishName} · ${surah.name}',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.darkGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    color: AppColors.darkGreen,
                    size: 20,
                  ),
                ],
              ),
              loading: () => const Text('Laden...'),
              error: (_, _) => const Text('Fehler'),
            ),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.settings_outlined,
              color: AppColors.darkGreen,
            ),
            onPressed: () => _openReadingSettings(context),
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
              ref
                  .read(audioPlayerNotifierProvider.notifier)
                  .initPlaylist(surah.ayahs);
            });
          }

          return Stack(
            children: [
              ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.only(
                  top: 16,
                  bottom: 120,
                ), // extra space for bottom bar
                itemCount: surah.ayahs.length,
                itemBuilder: (context, index) {
                  final ayah = surah.ayahs[index];
                  final isPlaying = audioState.currentAyahIndex == index;
                  return VerseCard(
                    surahNumber: widget.surahNumber,
                    ayah: ayah,
                    isPlaying: isPlaying,
                  );
                },
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: AudioPlayerBottomBar(
                  surahName: surah.englishName,
                  ayahs: surah.ayahs,
                ),
              ),
              if (_showBackToTopButton)
                Positioned(
                  right: 16,
                  // Above the (now single-row) audio bar: its own height —
                  // padding + play button + margin — runs to about 84 from
                  // the screen bottom.
                  bottom: 110,
                  child: FloatingActionButton(
                    onPressed: _scrollToTop,
                    backgroundColor: AppColors.primaryGreen,
                    mini: true,
                    child: const Icon(
                      Icons.arrow_upward,
                      color: AppColors.white,
                    ),
                  ),
                ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.darkGreen),
        ),
        error: (error, stack) =>
            Center(child: Text('Fehler beim Laden: $error')),
      ),
    );
  }
}

class _SurahPickerSheet extends ConsumerStatefulWidget {
  final int currentSurahNumber;
  final ValueChanged<int> onSelect;

  const _SurahPickerSheet({
    required this.currentSurahNumber,
    required this.onSelect,
  });

  @override
  ConsumerState<_SurahPickerSheet> createState() => _SurahPickerSheetState();
}

class _SurahPickerSheetState extends ConsumerState<_SurahPickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<SurahInfo> _filter(List<SurahInfo> surahs) {
    if (_query.isEmpty) return surahs;
    return surahs.where((surah) {
      return surah.number.toString() == _query ||
          surah.englishName.toLowerCase().contains(_query) ||
          surah.englishNameTranslation.toLowerCase().contains(_query) ||
          surah.name.contains(_query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final listAsyncValue = ref.watch(surahListProvider);
    final mediaQuery = MediaQuery.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: mediaQuery.viewInsets.bottom),
      child: SizedBox(
        height: mediaQuery.size.height * 0.75,
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textMuted.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                controller: _searchController,
                autofocus: false,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Sura suchen',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Expanded(
              child: listAsyncValue.when(
                data: (surahs) {
                  final filtered = _filter(surahs);
                  if (filtered.isEmpty) {
                    return const Center(
                      child: Text(
                        'Keine Sura gefunden',
                        style: TextStyle(color: AppColors.textMuted),
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final surah = filtered[index];
                      final isCurrent =
                          surah.number == widget.currentSurahNumber;
                      return ListTile(
                        selected: isCurrent,
                        selectedTileColor: AppColors.goldLight.withValues(
                          alpha: 0.4,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        leading: Text(
                          '${surah.number}',
                          style: const TextStyle(
                            color: AppColors.accentGold,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        title: Text(
                          surah.englishName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                        subtitle: Text(surah.englishNameTranslation),
                        trailing: Text(
                          surah.name,
                          textDirection: TextDirection.rtl,
                          style: const TextStyle(
                            color: AppColors.darkGreen,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onTap: () => widget.onSelect(surah.number),
                      );
                    },
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.darkGreen),
                ),
                error: (error, stack) =>
                    Center(child: Text('Fehler beim Laden: $error')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReadingSettingsSheet extends ConsumerWidget {
  const _ReadingSettingsSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(quranReadingPrefsProvider);
    final notifier = ref.read(quranReadingPrefsProvider.notifier);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textMuted.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Leseansicht',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.darkGreen,
              ),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              activeThumbColor: AppColors.primaryGreen,
              title: const Text('Umschrift anzeigen'),
              value: prefs.showTransliteration,
              onChanged: notifier.setShowTransliteration,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              activeThumbColor: AppColors.primaryGreen,
              title: const Text('Übersetzung anzeigen'),
              value: prefs.showTranslation,
              onChanged: notifier.setShowTranslation,
            ),
            const SizedBox(height: 8),
            const Text(
              'Textgröße (Arabisch)',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
            ),
            Slider(
              value: prefs.arabicFontScale,
              min: 0.75,
              max: 1.5,
              divisions: 15,
              activeColor: AppColors.primaryGreen,
              label: '${(prefs.arabicFontScale * 100).round()}%',
              onChanged: notifier.setArabicFontScale,
            ),
          ],
        ),
      ),
    );
  }
}
