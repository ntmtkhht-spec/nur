import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../models/ayah_model.dart';
import '../providers/quran_progress_provider.dart';
import '../providers/surah_provider.dart';
import 'surah_screen.dart';

class SurahListScreen extends ConsumerStatefulWidget {
  const SurahListScreen({super.key});

  @override
  ConsumerState<SurahListScreen> createState() => _SurahListScreenState();
}

class _SurahListScreenState extends ConsumerState<SurahListScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  late final TabController _tabController;
  bool _showBackToTopButton = false;
  bool _isSearching = false;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChanged);
    _searchController.addListener(() {
      setState(() => _query = _normalizeSearchText(_searchController.text));
    });
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
    _tabController
      ..removeListener(_handleTabChanged)
      ..dispose();
    _scrollController.dispose();
    _searchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _handleTabChanged() {
    if (!mounted) return;
    if (_tabController.index != 0 && _isSearching) {
      _closeSearch();
      return;
    }
    setState(() {});
  }

  void _openSearch() {
    setState(() => _isSearching = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _isSearching) {
        _searchFocusNode.requestFocus();
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    if (_isSearching) {
      _searchFocusNode.requestFocus();
    }
  }

  void _closeSearch() {
    _searchController.clear();
    _searchFocusNode.unfocus();
    if (mounted && _isSearching) {
      setState(() => _isSearching = false);
    }
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _openSurah(int number, {int? resumeAtAyah}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            SurahScreen(surahNumber: number, initialAyahNumber: resumeAtAyah),
      ),
    );
  }

  List<SurahInfo> _filterSurahs(List<SurahInfo> surahs) {
    if (_query.isEmpty) return surahs;
    return surahs.where((surah) {
      final searchableText = _normalizeSearchText(
        '${surah.number} ${surah.englishName} '
        '${surah.englishNameTranslation} ${surah.name}',
      );
      return searchableText.contains(_query);
    }).toList();
  }

  String _normalizeSearchText(String value) {
    return value
        .toLowerCase()
        // Ignore Arabic vowel marks so an unvocalised query still matches.
        .replaceAll(RegExp(r'[\u064B-\u065F\u0670\u06D6-\u06ED]'), '')
        // Treat spaces and hyphens alike (for example, "al baqara").
        .replaceAll(RegExp(r'[\s\-_]+'), '');
  }

  @override
  Widget build(BuildContext context) {
    final listAsyncValue = ref.watch(surahListProvider);
    final progress = ref.watch(quranReadingProgressProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          child: _isSearching
              ? TextField(
                  key: const ValueKey('quran-search-field'),
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  autofocus: true,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _searchFocusNode.unfocus(),
                  style: const TextStyle(color: AppColors.textDark),
                  decoration: InputDecoration(
                    hintText: 'Sura suchen',
                    prefixIcon: const Icon(
                      Icons.search,
                      size: 20,
                      color: AppColors.darkGreen,
                    ),
                    suffixIcon: IconButton(
                      tooltip: _searchController.text.isEmpty
                          ? 'Suche schließen'
                          : 'Suche leeren',
                      onPressed: _searchController.text.isEmpty
                          ? _closeSearch
                          : _clearSearch,
                      icon: const Icon(Icons.close, size: 18),
                    ),
                    filled: true,
                    fillColor: AppColors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: const BorderSide(color: AppColors.cardBg),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: const BorderSide(
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ),
                )
              : const Text(
                  "Qur'an",
                  key: ValueKey('quran-title'),
                  style: TextStyle(
                    color: AppColors.darkGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
        actions: [
          if (_tabController.index == 0)
            IconButton(
              tooltip: _isSearching ? 'Suche schließen' : 'Suren suchen',
              onPressed: _isSearching ? _closeSearch : _openSearch,
              icon: Icon(
                _isSearching ? Icons.close : Icons.search,
                color: AppColors.darkGreen,
              ),
            ),
        ],
        centerTitle: false,
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelColor: AppColors.darkGreen,
            unselectedLabelColor: AppColors.textMuted,
            indicatorColor: AppColors.primaryGreen,
            tabs: const [
              Tab(text: 'Lesen'),
              Tab(text: 'Fortschritt'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                listAsyncValue.when(
                  data: (surahs) => _ReadingList(
                    controller: _scrollController,
                    progress: progress,
                    surahs: _filterSurahs(surahs),
                    onOpen: _openSurah,
                  ),
                  loading: () => const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.darkGreen,
                    ),
                  ),
                  error: (error, stack) =>
                      Center(child: Text('Fehler beim Laden: $error')),
                ),
                listAsyncValue.when(
                  data: (surahs) => _ProgressTab(
                    progress: progress,
                    surahs: surahs,
                    onOpen: _openSurah,
                  ),
                  loading: () => const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.darkGreen,
                    ),
                  ),
                  error: (error, stack) =>
                      Center(child: Text('Fehler beim Laden: $error')),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _showBackToTopButton
          ? FloatingActionButton(
              onPressed: _scrollToTop,
              backgroundColor: AppColors.primaryGreen,
              child: const Icon(Icons.arrow_upward, color: AppColors.white),
            )
          : null,
    );
  }
}

class _ReadingList extends StatelessWidget {
  final ScrollController controller;
  final QuranReadingProgress progress;
  final List<SurahInfo> surahs;
  final void Function(int number, {int? resumeAtAyah}) onOpen;

  const _ReadingList({
    required this.controller,
    required this.progress,
    required this.surahs,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[
      if (progress.lastPosition != null)
        _ContinueReadingCard(position: progress.lastPosition!, onOpen: onOpen),
      if (surahs.isEmpty)
        const _NoSurahResults()
      else
        ...surahs.map(
          (surah) =>
              _SurahTile(surah: surah, onTap: () => onOpen(surah.number)),
        ),
    ];

    return ListView.separated(
      controller: controller,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        120,
      ),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (_, index) => items[index],
    );
  }
}

class _ContinueReadingCard extends ConsumerWidget {
  final QuranReadingPosition position;
  final void Function(int number, {int? resumeAtAyah}) onOpen;

  const _ContinueReadingCard({required this.position, required this.onOpen});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surahAsync = ref.watch(surahProvider(position.surahNumber));
    return Material(
      color: AppColors.white,
      borderRadius: AppRadius.circularLg,
      child: InkWell(
        borderRadius: AppRadius.circularLg,
        onTap: () =>
            onOpen(position.surahNumber, resumeAtAyah: position.ayahNumber),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: surahAsync.when(
            loading: () => const SizedBox(
              height: 54,
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primaryGreen),
              ),
            ),
            error: (_, _) => _ContinueReadingText(
              title: 'Weiterlesen',
              subtitle:
                  'Sura ${position.surahNumber} · Vers ${position.ayahNumber}',
              onTap: () => onOpen(
                position.surahNumber,
                resumeAtAyah: position.ayahNumber,
              ),
            ),
            data: (surah) {
              final ayah = position.ayahNumber <= surah.ayahs.length
                  ? surah.ayahs[position.ayahNumber - 1]
                  : null;
              return _ContinueReadingText(
                title: 'Weiterlesen · ${surah.englishName}',
                subtitle: ayah?.arabicText ?? 'Vers ${position.ayahNumber}',
                onTap: () => onOpen(
                  position.surahNumber,
                  resumeAtAyah: position.ayahNumber,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ContinueReadingText extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ContinueReadingText({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: const Icon(
            Icons.menu_book_outlined,
            color: AppColors.darkGreen,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textDirection: TextDirection.rtl,
                style: const TextStyle(color: AppColors.textMuted),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        const Icon(Icons.arrow_forward, color: AppColors.primaryGreen),
      ],
    );
  }
}

class _SurahTile extends StatelessWidget {
  final SurahInfo surah;
  final VoidCallback onTap;

  const _SurahTile({required this.surah, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final meta = '${surah.revelationType} - ${surah.numberOfAyahs} Verse';

    return Material(
      color: Colors.white,
      borderRadius: AppRadius.circularMd,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.circularMd,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              SizedBox.square(
                dimension: 48,
                child: Center(
                  child: Text(
                    '${surah.number}',
                    style: const TextStyle(
                      // The editorial serif gives the list numbers the same
                      // distinctive look as the earlier Quran layout.
                      fontFamily: 'serif',
                      color: AppColors.darkGreen,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      height: 1,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                flex: 4,
                child: SizedBox(
                  height: 40,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'surah${surah.number.toString().padLeft(3, '0')}',
                      maxLines: 1,
                      textDirection: TextDirection.ltr,
                      style: const TextStyle(
                        fontFamily: 'SurahNameV4',
                        color: AppColors.darkGreen,
                        fontSize: 38,
                        height: 1,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                flex: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      surah.englishName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      meta,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoSurahResults extends StatelessWidget {
  const _NoSurahResults();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Center(
        child: Text(
          'Keine Sura gefunden',
          style: TextStyle(color: AppColors.textMuted),
        ),
      ),
    );
  }
}

class _ProgressTab extends StatelessWidget {
  final QuranReadingProgress progress;
  final List<SurahInfo> surahs;
  final void Function(int number, {int? resumeAtAyah}) onOpen;

  const _ProgressTab({
    required this.progress,
    required this.surahs,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final progressPercent = (progress.completionFraction * 100).toStringAsFixed(
      1,
    );
    final readSurahs = surahs.where((surah) {
      final prefix = '${surah.number}:';
      return progress.readAyahIds.any((id) => id.startsWith(prefix));
    }).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
        120,
      ),
      children: [
        const Text(
          'Dein Fortschritt',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        _ProgressSummaryCard(
          completed: progress.completedAyahCount,
          percentage: progressPercent,
          fraction: progress.completionFraction,
        ),
        const SizedBox(height: AppSpacing.lg),
        if (readSurahs.isNotEmpty) ...[
          const Text(
            'Gelesene Suren',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          for (final surah in readSurahs) ...[
            _SurahProgressRow(
              surah: surah,
              completed: progress.readAyahIds
                  .where((id) => id.startsWith('${surah.number}:'))
                  .length,
              onTap: () => onOpen(surah.number),
            ),
            const SizedBox(height: AppSpacing.xs),
          ],
        ] else
          const _NoProgressYet(),
      ],
    );
  }
}

class _ProgressSummaryCard extends StatelessWidget {
  final int completed;
  final String percentage;
  final double fraction;

  const _ProgressSummaryCard({
    required this.completed,
    required this.percentage,
    required this.fraction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.circularLg,
        border: Border.all(color: AppColors.cardBg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$completed von $quranTotalAyahs Versen',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: LinearProgressIndicator(
              value: fraction,
              minHeight: 10,
              color: AppColors.primaryGreen,
              backgroundColor: AppColors.cardBg,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '$percentage % des Qur\'an gelesen',
            style: const TextStyle(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _SurahProgressRow extends StatelessWidget {
  final SurahInfo surah;
  final int completed;
  final VoidCallback onTap;

  const _SurahProgressRow({
    required this.surah,
    required this.completed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: AppRadius.circularMd,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.circularMd,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  surah.englishName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              Text(
                '$completed / ${surah.numberOfAyahs}',
                style: const TextStyle(color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoProgressYet extends StatelessWidget {
  const _NoProgressYet();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: AppSpacing.lg),
      child: Center(
        child: Text(
          'Dein Fortschritt erscheint hier, sobald du einen Vers gelesen hast.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textMuted),
        ),
      ),
    );
  }
}
