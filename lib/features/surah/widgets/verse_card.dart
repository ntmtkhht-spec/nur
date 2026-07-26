import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../models/ayah_model.dart';

class VerseCard extends StatelessWidget {
  final Ayah ayah;
  final bool isPlaying;

  const VerseCard({
    Key? key,
    required this.ayah,
    this.isPlaying = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: isPlaying ? Border.all(color: AppColors.primaryGreen, width: 2) : Border.all(color: AppColors.cardBg, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Ayah Number Badge
          Align(
            alignment: Alignment.topRight,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.accentGold, width: 1.5),
              ),
              child: Center(
                child: Text(
                  '${ayah.numberInSurah}',
                  style: const TextStyle(
                    color: AppColors.accentGold,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
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
            style: const TextStyle(
              fontSize: 32,
              height: 1.6,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 24),
          // Transliteration
          Text(
            ayah.transliteration,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              fontStyle: FontStyle.italic,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 12),
          // Translation
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
      ),
    );
  }
}
