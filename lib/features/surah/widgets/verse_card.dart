import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../models/ayah_model.dart';
import '../providers/reading_prefs_provider.dart';
import 'ayah_number_ornament.dart';

class VerseCard extends ConsumerWidget {
  final Ayah ayah;
  final bool isAudioActive;

  const VerseCard({super.key, required this.ayah, this.isAudioActive = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(quranReadingPrefsProvider);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 30),
      decoration: BoxDecoration(
        // A light tint keeps the reading view continuous while making the
        // ayah currently spoken by the reciter easy to follow.
        color: isAudioActive
            ? AppColors.goldLight.withValues(alpha: 0.32)
            : Colors.transparent,
        border: const Border(
          bottom: BorderSide(color: AppColors.cardBg, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: '${ayah.arabicText} '),
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(start: 6),
                    child: AyahNumberOrnament(
                      number: ayah.numberInSurah,
                      size: 42,
                    ),
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontSize: 32 * prefs.arabicFontScale,
              height: 1.7,
              color: AppColors.textDark,
            ),
          ),
          if (prefs.showTransliteration) ...[
            const SizedBox(height: 18),
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
          if (prefs.showTranslation && ayah.translation != null) ...[
            const SizedBox(height: 12),
            Text(
              ayah.translation!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                height: 1.45,
                color: AppColors.textDark,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
