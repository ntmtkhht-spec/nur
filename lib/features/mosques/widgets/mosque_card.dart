import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../models/mosque.dart';

class MosqueCard extends StatelessWidget {
  final Mosque mosque;

  const MosqueCard({super.key, required this.mosque});

  Uri get _directionsUri => Uri.https('www.google.com', '/maps/dir/', {
    'api': '1',
    'destination': '${mosque.lat},${mosque.lng}',
    'travelmode': 'walking',
  });

  Future<void> _open(BuildContext context, Uri uri) async {
    final ok = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    ).catchError((_) => false);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).mosquesCouldNotOpen),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final address = mosque.address;

    return Container(
      decoration: BoxDecoration(
        color: colors.cardBg,
        borderRadius: AppRadius.circularLg,
        boxShadow: AppShadows.sm,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.mosque, size: 22, color: colors.primaryGreen),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mosque.name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: colors.textDark,
                      ),
                    ),
                    if (address != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        address,
                        style: TextStyle(
                          fontSize: 13,
                          color: colors.textMuted,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: colors.accentGold.withValues(alpha: 0.15),
                  borderRadius: AppRadius.circularSm,
                ),
                child: Text(
                  mosque.formattedDistance,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: colors.accentGold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              _ActionButton(
                icon: Icons.directions_outlined,
                label: AppLocalizations.of(context).mosquesRoute,
                onTap: () => _open(context, _directionsUri),
              ),
              if (mosque.website != null)
                _ActionButton(
                  icon: Icons.language,
                  label: AppLocalizations.of(context).mosquesWebsite,
                  onTap: () => _open(context, Uri.parse(mosque.website!)),
                ),
              if (mosque.phone != null)
                _ActionButton(
                  icon: Icons.call_outlined,
                  label: AppLocalizations.of(context).mosquesCall,
                  onTap: () => _open(context, Uri.parse('tel:${mosque.phone}')),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.xs),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: AppRadius.circularSm,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 15, color: colors.primaryGreen),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: colors.primaryGreen,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
