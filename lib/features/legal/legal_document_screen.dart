import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import 'legal_documents.dart';
import 'legal_profile.dart';

class LegalDocumentScreen extends StatelessWidget {
  final LegalDocument _document;

  const LegalDocumentScreen.imprint({super.key})
    : _document = LegalDocument.imprint;

  const LegalDocumentScreen.privacy({super.key})
    : _document = LegalDocument.privacy;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(
          _document.title,
          style: TextStyle(color: colors.textDark, fontWeight: FontWeight.bold),
        ),
        backgroundColor: colors.background,
        iconTheme: IconThemeData(color: colors.primaryGreen),
        elevation: 0,
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.xxl,
        ),
        children: [
          _IntroCard(document: _document),
          const SizedBox(height: AppSpacing.md),
          for (final section in _document.sections) ...[
            _LegalSectionView(section: section),
            const SizedBox(height: AppSpacing.md),
          ],
        ],
      ),
    );
  }
}

class _IntroCard extends StatelessWidget {
  final LegalDocument document;

  const _IntroCard({required this.document});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.cardBg,
        borderRadius: AppRadius.circularLg,
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LegalProfile.appName,
            style: TextStyle(
              color: colors.darkGreen,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Stand: ${LegalProfile.lastUpdated}',
            style: TextStyle(color: colors.textMuted, fontSize: 12),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            document.intro,
            style: TextStyle(
              color: colors.textMuted,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _LegalSectionView extends StatelessWidget {
  final LegalSection section;

  const _LegalSectionView({required this.section});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.cardBg,
        borderRadius: AppRadius.circularLg,
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section.title,
            style: TextStyle(
              color: colors.textDark,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final paragraph in section.paragraphs) ...[
            SelectableText(
              paragraph,
              style: TextStyle(
                color: colors.textDark,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          if (section.bullets.isNotEmpty)
            for (final bullet in section.bullets) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Icon(
                      Icons.circle,
                      size: 5,
                      color: colors.accentGold,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: SelectableText(
                      bullet,
                      style: TextStyle(
                        color: colors.textDark,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
            ],
        ],
      ),
    );
  }
}
