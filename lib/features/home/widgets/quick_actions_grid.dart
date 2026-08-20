import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../duas/duas_screen.dart';
import '../../mosques/mosques_screen.dart';
import '../../names/names_screen.dart';
import '../../qibla/qibla_screen.dart';

class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: SizedBox(
        height: 200,
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: _QuickActionTile(
                      icon: Icons.mosque_outlined,
                      label: AppLocalizations.of(context).quickMosques,
                      destination: (_) => const MosquesScreen(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Expanded(
                    child: _QuickActionTile(
                      assetPath: 'assets/images/icon_duas_generated.png',
                      label: AppLocalizations.of(context).quickDuas,
                      destination: (_) => const DuasScreen(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: _QuickActionTile(
                      assetPath: 'assets/images/icon_qibla_generated.png',
                      label: AppLocalizations.of(context).quickQibla,
                      destination: (_) => const QiblaScreen(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Expanded(
                    child: _QuickActionTile(
                      icon: Icons.all_inclusive_outlined,
                      label: AppLocalizations.of(context).quickNames,
                      destination: (_) => const NamesScreen(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final IconData? icon;
  final String? assetPath;
  final String label;

  /// Screen to push when tapped. Null keeps the "kommt bald" placeholder.
  final WidgetBuilder? destination;

  const _QuickActionTile({
    this.icon,
    this.assetPath,
    required this.label,
    this.destination,
  }) : assert(icon != null || assetPath != null);

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final iconWidget = assetPath == null
        ? Icon(icon!, size: 32, color: colors.darkGreen)
        : Image.asset(assetPath!, width: 36, height: 36, fit: BoxFit.contain);

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
          onTap: () {
            if (destination == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$label kommt bald!'),
                  duration: const Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                ),
              );
              return;
            }
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: destination!));
          },
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                iconWidget,
                const SizedBox(height: AppSpacing.xs),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colors.darkGreen,
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
