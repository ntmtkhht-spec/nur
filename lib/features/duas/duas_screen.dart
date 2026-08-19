import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import 'data/duas.dart';

class DuasScreen extends StatefulWidget {
  const DuasScreen({super.key});

  @override
  State<DuasScreen> createState() => _DuasScreenState();
}

class _DuasScreenState extends State<DuasScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Dua> get _searchResults {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return const [];
    return duas.where((d) {
      return d.title.toLowerCase().contains(q) ||
          d.translation.toLowerCase().contains(q) ||
          d.transliteration.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = AppColors.of(context);
    final isSearching = _query.trim().isNotEmpty;
    final results = _searchResults;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(
          l10n.duasTitle,
          style: TextStyle(
            color: colors.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: colors.background,
        iconTheme: IconThemeData(color: colors.primaryGreen),
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.xs,
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: l10n.duasSearchHint,
                prefixIcon: Icon(Icons.search, color: colors.textMuted),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        icon: Icon(Icons.clear, color: colors.textMuted),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      ),
                filled: true,
                fillColor: colors.cardBg,
                border: OutlineInputBorder(
                  borderRadius: AppRadius.circularLg,
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            // Search overrides browsing: once the user is looking for a
            // specific dua, a flat filtered list beats digging through
            // category tiles.
            child: isSearching
                ? _SearchResults(results: results)
                : const _CategoryGrid(),
          ),
        ],
      ),
    );
  }
}

class _SearchResults extends StatelessWidget {
  final List<Dua> results;

  const _SearchResults({required this.results});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    if (results.isEmpty) {
      return Center(
        child: Text(
          'Keine Dua gefunden.',
          style: TextStyle(color: colors.textMuted),
        ),
      );
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xs,
        AppSpacing.lg,
        AppSpacing.xxl,
      ),
      itemCount: results.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, i) => _DuaCard(dua: results[i]),
    );
  }
}

/// Bento-style category overview: colourful icon tiles instead of a plain
/// list, so browsing 40 duas doesn't start with a wall of text.
class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.xxl,
      ),
      mainAxisSpacing: AppSpacing.sm,
      crossAxisSpacing: AppSpacing.sm,
      childAspectRatio: 1.1,
      children: [
        for (final category in DuaCategory.values)
          _CategoryTile(category: category),
      ],
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final DuaCategory category;

  const _CategoryTile({required this.category});

  /// Cycles through the app's existing palette instead of introducing new
  /// arbitrary colours, so the bento grid stays on-brand.
  Color _accentFor(AppColorsExtension colors) {
    final palette = [
      colors.primaryGreen,
      colors.accentGold,
      colors.darkGreen,
      colors.accentGold,
    ];
    return palette[category.index % palette.length];
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final accent = _accentFor(colors);
    final count = duas.where((d) => d.category == category).length;

    return Material(
      color: accent.withValues(alpha: 0.12),
      borderRadius: AppRadius.circularLg,
      child: InkWell(
        borderRadius: AppRadius.circularLg,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => _CategoryDuasScreen(category: category),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: Icon(category.icon, size: 22, color: accent),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: colors.textDark,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$count Duas',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colors.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryDuasScreen extends StatelessWidget {
  final DuaCategory category;

  const _CategoryDuasScreen({required this.category});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final items = duas.where((d) => d.category == category).toList();

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(
          category.label,
          style: TextStyle(
            color: colors.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: colors.background,
        iconTheme: IconThemeData(color: colors.primaryGreen),
        elevation: 0,
      ),
      body: ListView.separated(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.xs,
          AppSpacing.lg,
          AppSpacing.xxl,
        ),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, i) => _DuaCard(dua: items[i]),
      ),
    );
  }
}

class _DuaCard extends StatelessWidget {
  final Dua dua;

  const _DuaCard({required this.dua});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Container(
      decoration: BoxDecoration(
        color: colors.cardBg,
        borderRadius: AppRadius.circularLg,
        boxShadow: AppShadows.sm,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadius.circularLg,
        child: InkWell(
          borderRadius: AppRadius.circularLg,
          onLongPress: () {
            Clipboard.setData(ClipboardData(
              text: '${dua.title}\n\n${dua.arabic}\n\n'
                  '${dua.transliteration}\n\n${dua.translation}\n\n'
                  '(${dua.source})',
            ));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Dua kopiert'),
                duration: Duration(seconds: 1),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        dua.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: colors.textDark,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colors.accentGold.withValues(alpha: 0.15),
                        borderRadius: AppRadius.circularSm,
                      ),
                      child: Text(
                        dua.category.label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: colors.accentGold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    dua.arabic,
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      fontSize: 20,
                      height: 1.9,
                      fontWeight: FontWeight.w500,
                      color: colors.primaryGreen,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  dua.transliteration,
                  style: TextStyle(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: colors.textMuted,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  dua.translation,
                  style: TextStyle(
                    fontSize: 14,
                    color: colors.textDark,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  dua.source,
                  style: TextStyle(
                    fontSize: 11,
                    color: colors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
