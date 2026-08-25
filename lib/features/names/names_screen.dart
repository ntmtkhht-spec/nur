import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import 'data/divine_names.dart';

class NamesScreen extends StatefulWidget {
  const NamesScreen({super.key});

  @override
  State<NamesScreen> createState() => _NamesScreenState();
}

class _NamesScreenState extends State<NamesScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<DivineName> get _filtered {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return divineNames;
    return divineNames
        .where((n) =>
            n.transliteration.toLowerCase().contains(q) ||
            n.meaning.toLowerCase().contains(q) ||
            n.arabic.contains(q) ||
            n.number.toString() == q)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = AppColors.of(context);
    final results = _filtered;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(
          l10n.namesTitle,
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
                hintText: l10n.namesSearchHint,
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
            child: results.isEmpty
                ? Center(
                    child: Text(
                      AppLocalizations.of(context).namesNoMatch,
                      style: TextStyle(color: colors.textMuted),
                    ),
                  )
                : ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.xs,
                      AppSpacing.lg,
                      AppSpacing.xxl,
                    ),
                    itemCount: results.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.xs),
                    itemBuilder: (context, i) => _NameCard(name: results[i]),
                  ),
          ),
        ],
      ),
    );
  }
}

class _NameCard extends StatelessWidget {
  final DivineName name;

  const _NameCard({required this.name});

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
              text: '${name.transliteration} — ${name.meaning}',
            ));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Kopiert'),
                duration: Duration(seconds: 1),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colors.accentGold.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${name.number}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: colors.accentGold,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name.transliteration,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: colors.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        name.meaning,
                        style: TextStyle(
                          fontSize: 13,
                          color: colors.textMuted,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  name.arabic,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: colors.primaryGreen,
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
