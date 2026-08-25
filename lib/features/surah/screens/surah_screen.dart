import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../models/ayah_model.dart';
import '../providers/surah_provider.dart';
import '../providers/audio_player_provider.dart';
import '../providers/quran_audio_voice_provider.dart';
import '../providers/reading_prefs_provider.dart';
import '../providers/quran_progress_provider.dart';
import '../widgets/verse_card.dart';
import '../widgets/audio_player_bottom_bar.dart';

class SurahScreen extends ConsumerStatefulWidget {
  final int surahNumber;
  final int? initialAyahNumber;

  const SurahScreen({
    super.key,
    this.surahNumber = 1, // Default to Al-Fatiha
    this.initialAyahNumber,
  });

  @override
  ConsumerState<SurahScreen> createState() => _SurahScreenState();
}

class _SurahScreenState extends ConsumerState<SurahScreen> {
  bool _playlistInitialized = false;
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _ayahKeys = {};
  bool _showBackToTopButton = false;
  bool _didRestorePosition = false;
  int? _lastRecordedAyah;
  Surah? _activeSurah;

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

  GlobalKey _keyForAyah(int ayahNumber) =>
      _ayahKeys.putIfAbsent(ayahNumber, GlobalKey.new);

  void _scrollToAudioAyah(Surah? surah, int? index) {
    if (!mounted || surah == null || index == null) return;
    if (index < 0 || index >= surah.ayahs.length) return;

    final ayahNumber = surah.ayahs[index].numberInSurah;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      final target = _keyForAyah(ayahNumber).currentContext;
      if (target == null) {
        // ListView.builder may not have built a distant ayah yet. Jump close
        // to it first, then use the exact keyed context on the next frame.
        final approximate = (index * 280.0).clamp(
          0.0,
          _scrollController.position.maxScrollExtent,
        );
        _scrollController.jumpTo(approximate);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _ensureAudioAyahVisible(ayahNumber);
        });
        return;
      }
      _ensureAudioAyahVisible(ayahNumber);
    });
  }

  void _ensureAudioAyahVisible(int ayahNumber) {
    final target = _keyForAyah(ayahNumber).currentContext;
    if (target == null) return;
    Scrollable.ensureVisible(
      target,
      alignment: 0.18,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  void _restorePosition(Surah surah, int? ayahNumber) {
    if (_didRestorePosition || ayahNumber == null || ayahNumber < 1) return;
    _didRestorePosition = true;
    final targetIndex = (ayahNumber - 1).clamp(0, surah.ayahs.length - 1);
    final targetAyahNumber = surah.ayahs[targetIndex].numberInSurah;
    // ListView builds lazily. An approximate jump builds the target item, and
    // ensureVisible then places the exact ayah at the reading position.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      final approximate = (targetIndex * 280.0).clamp(
        0.0,
        _scrollController.position.maxScrollExtent,
      );
      _scrollController.jumpTo(approximate);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final target = _keyForAyah(targetAyahNumber).currentContext;
        if (target != null) {
          Scrollable.ensureVisible(
            target,
            alignment: 0.12,
            duration: const Duration(milliseconds: 220),
          );
        }
      });
    });
  }

  void _recordVisibleAyah(Surah surah) {
    if (!_scrollController.hasClients || surah.ayahs.isEmpty) return;
    const readingLine = 160.0;
    int? closestAyah;

    // The bottom audio bar and its safe-area padding can leave the final
    // ayah below the reading line. Reaching the actual end means the reader
    // has passed the complete surah, so the last ayah must count as read.
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 24) {
      closestAyah = surah.ayahs.last.numberInSurah;
    }

    var closestDistance = double.infinity;
    if (closestAyah == null) {
      for (final ayah in surah.ayahs) {
        final context = _ayahKeys[ayah.numberInSurah]?.currentContext;
        final renderBox = context?.findRenderObject() as RenderBox?;
        if (renderBox == null || !renderBox.attached) continue;
        final top = renderBox.localToGlobal(Offset.zero).dy;
        final distance = (top - readingLine).abs();
        if (distance < closestDistance) {
          closestDistance = distance;
          closestAyah = ayah.numberInSurah;
        }
      }
    }
    if (closestAyah == null || closestAyah == _lastRecordedAyah) return;
    _lastRecordedAyah = closestAyah;
    ref
        .read(quranReadingProgressProvider.notifier)
        .markRead(surahNumber: widget.surahNumber, ayahNumber: closestAyah);
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
            MaterialPageRoute(builder: (_) => SurahScreen(surahNumber: number)),
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
    ref.listen<AudioPlayerState>(audioPlayerNotifierProvider, (previous, next) {
      if (next.surahNumber != widget.surahNumber) return;
      if (previous?.currentAyahIndex == next.currentAyahIndex) return;
      _scrollToAudioAyah(_activeSurah, next.currentAyahIndex);
    });
    ref.listen<QuranAudioVoice>(quranAudioVoiceProvider, (previous, next) {
      if (previous?.identifier == next.identifier) return;
      // The surah provider reloads with the new audio edition. Rebuild the
      // playlist once that fresh data arrives instead of mixing voices.
      _playlistInitialized = false;
    });

    final surahAsyncValue = ref.watch(surahProvider(widget.surahNumber));
    final quranProgress = ref.watch(quranReadingProgressProvider);

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
                      surah.englishName,
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
          _activeSurah = surah;
          final audioState = ref.watch(audioPlayerNotifierProvider);
          final audioBelongsToThisSurah =
              audioState.surahNumber == widget.surahNumber;
          final resumeAyah =
              widget.initialAyahNumber ??
              (quranProgress.lastPosition?.surahNumber == widget.surahNumber
                  ? quranProgress.lastPosition?.ayahNumber
                  : null);
          _restorePosition(surah, resumeAyah);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _recordVisibleAyah(surah);
          });
          if (!_playlistInitialized) {
            _playlistInitialized = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ref
                  .read(audioPlayerNotifierProvider.notifier)
                  .initPlaylist(
                    surahNumber: widget.surahNumber,
                    ayahs: surah.ayahs,
                  );
            });
          }

          return NotificationListener<ScrollEndNotification>(
            onNotification: (_) {
              _recordVisibleAyah(surah);
              return false;
            },
            child: Stack(
              children: [
                ColoredBox(
                  color: AppColors.background,
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(
                      bottom: 120,
                    ), // extra space for bottom bar
                    // One past the last ayah: the colophon. Al Quran Cloud
                    // asks that a republished translation name its
                    // translator, and the translations themselves carry the
                    // same requirement — so the credit sits at the end of
                    // every surah rather than on a page nobody opens.
                    itemCount: surah.ayahs.length + 1,
                    itemBuilder: (context, index) {
                      if (index == surah.ayahs.length) {
                        return _SurahColophon(
                          translationSource: surah.translationSource,
                        );
                      }
                      final ayah = surah.ayahs[index];
                      return KeyedSubtree(
                        key: _keyForAyah(ayah.numberInSurah),
                        child: VerseCard(
                          ayah: ayah,
                          isAudioActive:
                              audioBelongsToThisSurah &&
                              audioState.isPlaying &&
                              audioState.currentAyahIndex == index,
                        ),
                      );
                    },
                  ),
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
            ),
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
    final audioVoice = ref.watch(quranAudioVoiceProvider);
    final audioVoiceNotifier = ref.read(quranAudioVoiceProvider.notifier);

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
            const SizedBox(height: 12),
            const Text(
              'Rezitationsstimme',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 5),
            Container(
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.cardBg),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<QuranAudioVoice>(
                  value: audioVoice,
                  isExpanded: true,
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: AppColors.darkGreen,
                  ),
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 14,
                  ),
                  items: [
                    for (final voice in QuranAudioVoice.available)
                      DropdownMenuItem(value: voice, child: Text(voice.name)),
                  ],
                  onChanged: (voice) {
                    if (voice != null) audioVoiceNotifier.setVoice(voice);
                  },
                ),
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


/// Source credit closing every surah.
///
/// Names the translator, which is the condition Al Quran Cloud attaches to
/// republishing a translation, and the service the Arabic text, the
/// transliteration and the recitations come from.
class _SurahColophon extends StatelessWidget {
  final String? translationSource;

  const _SurahColophon({required this.translationSource});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final credit = translationSource;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(
            height: 1,
            thickness: 1,
            color: AppColors.textMuted.withValues(alpha: 0.2),
          ),
          const SizedBox(height: AppSpacing.md),
          if (credit != null && credit.isNotEmpty) ...[
            Text(
              l10n.quranTranslationCredit(credit),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 4),
          ],
          Text(
            l10n.quranSourceCredit,
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
