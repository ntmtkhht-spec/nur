import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../core/theme/app_colors.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      padding: const EdgeInsets.only(bottom: 24, top: 12, left: 16, right: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: _NavItem(
              icon: Icons.home_rounded,
              label: l10n.navHome,
              isActive: currentIndex == 0,
              onTap: () => onTap(0),
            ),
          ),
          Expanded(
            child: _NavItem(
              assetPath: 'assets/images/icon_prayer_ruku_generated.png',
              label: l10n.navPrayers,
              isActive: currentIndex == 1,
              onTap: () => onTap(1),
            ),
          ),
          Expanded(
            child: _CenterNavItem(
              label: l10n.navQuran,
              isActive: currentIndex == 2,
              onTap: () => onTap(2),
            ),
          ),
          Expanded(
            child: _NavItem(
              icon: Icons.track_changes_rounded,
              label: l10n.navTasbih,
              isActive: currentIndex == 3,
              onTap: () => onTap(3),
            ),
          ),
          Expanded(
            child: _NavItem(
              icon: Icons.explore_rounded,
              label: l10n.navQibla,
              isActive: currentIndex == 4,
              onTap: () => onTap(4),
            ),
          ),
        ],
      ),
    );
  }
}

class _CenterNavItem extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _CenterNavItem({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final labelColor = isActive
        ? AppColors.darkGreen
        : AppColors.textMuted.withValues(alpha: 0.8);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFDFB651), Color(0xFFC8A43E)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentGold.withValues(alpha: 0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.menu_book_rounded,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color: labelColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData? icon;
  final String? assetPath;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    this.icon,
    this.assetPath,
    required this.label,
    required this.isActive,
    required this.onTap,
  }) : assert(icon != null || assetPath != null);

  @override
  Widget build(BuildContext context) {
    final color = isActive
        ? AppColors.darkGreen
        : AppColors.textMuted.withValues(alpha: 0.8);

    final iconWidget = assetPath == null
        ? Icon(icon!, color: color, size: 28)
        : ImageIcon(AssetImage(assetPath!), color: color, size: 28);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: double.infinity,
        height: 64,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: double.infinity,
              height: 62,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.primaryGreen.withValues(alpha: 0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  iconWidget,
                  const SizedBox(height: 4),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
