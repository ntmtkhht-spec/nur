import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../models/ayah_model.dart';
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

  void _openSurah(int number) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SurahScreen(surahNumber: number)),
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
      body: listAsyncValue.when(
        data: (surahs) {
          final filtered = _filterSurahs(surahs);

          return ListView.separated(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.xs,
              AppSpacing.md,
              120,
            ),
            itemCount: filtered.isEmpty ? 3 : filtered.length + 2,
            separatorBuilder: (context, index) {
              if (index < 1) return const SizedBox(height: AppSpacing.md);
              return const SizedBox(height: AppSpacing.xs);
            },
            itemBuilder: (context, index) {
              if (index == 0) {
                return _QuranSearch(
                  controller: _searchController,
                  onClear: () => _searchController.clear(),
                );
              }

              if (index == 1) {
                return _QuickAccess(onOpen: _openSurah);
              }

              if (filtered.isEmpty) {
                return const _NoSurahResults();
              }

              final surah = filtered[index - 2];
              return _SurahTile(
                surah: surah,
                onTap: () => _openSurah(surah.number),
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
                  color: AppColors.goldLight.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Center(
                  child: Text(
                    '${surah.number}',
                    style: const TextStyle(
                      color: AppColors.accentGold,
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
