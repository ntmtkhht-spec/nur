import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../duas/duas_screen.dart';
import '../../mosques/mosques_screen.dart';
import '../../names/names_screen.dart';
import '../../qibla/qibla_screen.dart';

/// The four shortcuts under the prayer card, as one continuous strip.
///
/// Was a two-by-two grid of separate cards, which read as four unrelated
/// things stacked into a block and took 200 points of height to say very
/// little. One row on one surface says what it is — a row of shortcuts —
/// and leaves the screen to the cards that carry actual content.
class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Container(
        height: 92,
        decoration: BoxDecoration(
          color: colors.white,
          borderRadius: AppRadius.circularLg,
          // Outlined rather than raised: the two cards around it carry
          // content and keep the shadow, this one only points elsewhere.
          border: Border.all(color: colors.textMuted.withValues(alpha: 0.18)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            Expanded(
              child: _QuickAction(
                icon: Icons.mosque_outlined,
                label: l10n.quickMosques,
                destination: (_) => const MosquesScreen(),
              ),
            ),
            const _Separator(),
            Expanded(
              child: _QuickAction(
                icon: Icons.explore_outlined,
                label: l10n.quickQibla,
                destination: (_) => const QiblaScreen(),
              ),
            ),
            const _Separator(),
            Expanded(
              child: _QuickAction(
                assetPath: 'assets/images/icon_duas_generated.png',
                label: l10n.quickDuas,
                destination: (_) => const DuasScreen(),
              ),
            ),
            const _Separator(),
            Expanded(
              child: _QuickAction(
                icon: Icons.all_inclusive_outlined,
                label: l10n.quickNames,
                destination: (_) => const NamesScreen(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Hairline between two shortcuts. Short of full height so the strip still
/// reads as one surface rather than four columns.
class _Separator extends StatelessWidget {
  const _Separator();

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Container(
      width: 1,
      height: 44,
      color: colors.textMuted.withValues(alpha: 0.18),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData? icon;
  final String? assetPath;
  final String label;

  /// Screen to push when tapped. Null keeps the "kommt bald" placeholder.
  final WidgetBuilder? destination;

  const _QuickAction({
    this.icon,
    this.assetPath,
    required this.label,
    this.destination,
  }) : assert(icon != null || assetPath != null);

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final iconWidget = assetPath == null
        ? Icon(icon!, size: 26, color: colors.darkGreen)
        : Image.asset(assetPath!, width: 28, height: 28, fit: BoxFit.contain);

    return Material(
      color: Colors.transparent,
      child: InkWell(
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
          Navigator.of(context).push(MaterialPageRoute(builder: destination!));
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            iconWidget,
            const SizedBox(height: AppSpacing.xxs),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: colors.darkGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
