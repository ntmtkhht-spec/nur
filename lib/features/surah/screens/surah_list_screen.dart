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

class _SurahListScreenState extends ConsumerState<SurahListScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _showBackToTopButton = false;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.trim().toLowerCase());
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
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
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
      return surah.number.toString() == _query ||
          surah.englishName.toLowerCase().contains(_query) ||
          surah.englishNameTranslation.toLowerCase().contains(_query) ||
          surah.name.contains(_query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final listAsyncValue = ref.watch(surahListProvider);
    final progress = ref.watch(quranReadingProgressProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "Qur'an",
          style: TextStyle(
            color: AppColors.darkGreen,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(
              labelColor: AppColors.darkGreen,
              unselectedLabelColor: AppColors.textMuted,
              indicatorColor: AppColors.primaryGreen,
              tabs: [
                Tab(text: 'Lesen'),
                Tab(text: 'Fortschritt'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  listAsyncValue.when(
                    data: (surahs) => _ReadingList(
                      controller: _scrollController,
                      progress: progress,
                      surahs: _filterSurahs(surahs),
                      onOpen: _openSurah,
                      search: _QuranSearch(
                        controller: _searchController,
                        onClear: () => _searchController.clear(),
                      ),
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
  final Widget search;

  const _ReadingList({
    required this.controller,
    required this.progress,
    required this.surahs,
    required this.onOpen,
    required this.search,
  });

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[
      if (progress.lastPosition != null)
        _ContinueReadingCard(position: progress.lastPosition!, onOpen: onOpen),
      search,
      _QuickAccess(onOpen: (number) => onOpen(number)),
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

class _QuranSearch extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onClear;

  const _QuranSearch({required this.controller, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Sura suchen',
        prefixIcon: const Icon(Icons.search, size: 20),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                onPressed: onClear,
                icon: const Icon(Icons.close, size: 18),
              ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: AppColors.cardBg),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.primaryGreen),
        ),
      ),
    );
  }
}

class _QuickAccess extends StatelessWidget {
  final ValueChanged<int> onOpen;

  const _QuickAccess({required this.onOpen});

  static const _items = [
    (number: 67, label: 'Al Mulk'),
    (number: 36, label: 'Ya Sin'),
    (number: 18, label: 'Al Kahf'),
    (number: 2, label: 'Al Baqara'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Schnellzugriff',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final item in _items) ...[
                ActionChip(
                  onPressed: () => onOpen(item.number),
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: AppColors.primaryGreen),
                  label: Text(item.label),
                  labelStyle: const TextStyle(
                    color: AppColors.darkGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
              ],
            ],
          ),
        ),
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
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Center(
                  child: Text(
                    '${surah.number}',
                    style: const TextStyle(
                      color: AppColors.darkGreen,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
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
              const SizedBox(width: AppSpacing.sm),
              Flexible(
                child: Text(
                  surah.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                    color: AppColors.darkGreen,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
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

class _ProgressTab extends ConsumerWidget {
  final QuranReadingProgress progress;
  final List<SurahInfo> surahs;
  final void Function(int number, {int? resumeAtAyah}) onOpen;

  const _ProgressTab({
    required this.progress,
    required this.surahs,
    required this.onOpen,
  });

  Future<void> _pickPlanDate(BuildContext context, WidgetRef ref) async {
    final now = DateTime.now();
    final existing = progress.plan == null
        ? now.add(const Duration(days: 30))
        : DateTime.fromMillisecondsSinceEpoch(progress.plan!.targetDateMs);
    final picked = await showDatePicker(
      context: context,
      initialDate: existing.isBefore(now)
          ? now.add(const Duration(days: 1))
          : existing,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 20),
      helpText: 'Ziel für deinen Leseplan',
    );
    if (picked == null) return;
    await ref.read(quranReadingProgressProvider.notifier).setPlanTarget(picked);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = planStatus(progress, DateTime.now());
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
        _ReadingPlanCard(
          plan: progress.plan,
          status: status,
          onPickDate: () => _pickPlanDate(context, ref),
          onRemove: () =>
              ref.read(quranReadingProgressProvider.notifier).removePlan(),
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

class _ReadingPlanCard extends StatelessWidget {
  final QuranReadingPlan? plan;
  final QuranPlanStatus status;
  final VoidCallback onPickDate;
  final VoidCallback onRemove;

  const _ReadingPlanCard({
    required this.plan,
    required this.status,
    required this.onPickDate,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = MaterialLocalizations.of(context);
    final target = plan == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(plan!.targetDateMs);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.circularLg,
        border: Border.all(color: AppColors.cardBg),
      ),
      child: plan == null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Leseplan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                const Text(
                  'Lege einen Zieltermin fest. Dein Tagesziel wird aus deinem echten Gesamtfortschritt berechnet.',
                  style: TextStyle(color: AppColors.textMuted, height: 1.35),
                ),
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton.icon(
                  onPressed: onPickDate,
                  icon: const Icon(Icons.calendar_month_outlined),
                  label: const Text('Leseplan erstellen'),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Leseplan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Ziel: ${dateFormat.formatMediumDate(target!)}',
                  style: const TextStyle(color: AppColors.textMuted),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  status.isOverdue
                      ? '${status.remainingAyahs} Verse noch offen · Zieltermin überschritten'
                      : '${status.remainingAyahs} Verse übrig · ${status.ayahsPerDay} Verse pro Tag',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkGreen,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    TextButton(
                      onPressed: onPickDate,
                      child: const Text('Ziel ändern'),
                    ),
                    TextButton(
                      onPressed: onRemove,
                      child: const Text('Plan entfernen'),
                    ),
                  ],
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
