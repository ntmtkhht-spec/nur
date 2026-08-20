import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../models/ayah_model.dart';
import '../providers/reading_prefs_provider.dart';

class VerseCard extends ConsumerWidget {
  final int surahNumber;
  final Ayah ayah;
  final bool isPlaying;

  const VerseCard({
    super.key,
    required this.surahNumber,
    required this.ayah,
    this.isPlaying = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(quranReadingPrefsProvider);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: isPlaying
            ? Border.all(color: AppColors.primaryGreen, width: 2)
            : Border.all(color: AppColors.cardBg, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Aya reference (Sure:Vers), not just the bare number — easier to
          // place while scrolling a long surah.
          Align(
            alignment: Alignment.topRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.accentGold, width: 1.5),
              ),
              child: Text(
                '$surahNumber:${ayah.numberInSurah}',
                style: const TextStyle(
                  color: AppColors.accentGold,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Arabic Text
          Text(
            ayah.arabicText,
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontSize: 32 * prefs.arabicFontScale,
              height: 1.6,
              color: AppColors.textDark,
            ),
          ),
          if (prefs.showTransliteration) ...[
            const SizedBox(height: 24),
            Text(
              ayah.transliteration,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontStyle: FontStyle.italic,
                color: AppColors.textMuted,
              ),
            ),
          ],
          if (prefs.showTranslation) ...[
            const SizedBox(height: 12),
            Text(
              ayah.translation,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.darkGreen,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
