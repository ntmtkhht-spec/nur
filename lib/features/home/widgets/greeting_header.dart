import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../../core/providers/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../settings/settings_screen.dart';

/// Top of the home screen: greeting, date, location.
///
/// The greeting carries the top line: this screen should open warmly before it
/// becomes informational. Dates stay present, but deliberately secondary.
///
/// The Gregorian date and the city share one line instead of two, and the
/// calculation method is gone: "MWL" means nothing to a first-time user and
/// is one tap away in Settings.
class GreetingHeader extends ConsumerWidget {
  const GreetingHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final userName = ref.watch(userNameProvider);
    final hijriDate = ref.watch(hijriDateProvider);
    final colors = AppColors.of(context);

    final location = switch (ref.watch(locationProvider)) {
      AsyncData(:final value) => value,
      _ => null,
    };

    // Short form ("Wed, 19 Aug 2026"): the long weekday and month names ran
    // the line close to the settings button on narrow phones.
    final date = DateFormat.yMMMEd(
      Localizations.localeOf(context).toLanguageTag(),
    ).format(DateTime.now());

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName.trim().isEmpty
                      ? l10n.greetingNoName
                      : l10n.greeting(userName.trim()),
                  // A single line truncated the user's name too aggressively
                  // on narrow phones. Two lines preserve the greeting and
                  // keep the settings button in its own fixed column.
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                    color: colors.darkGreen,
                    height: 1.08,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  hijriDate,
                  // The Hijri string is Latin ("6 Rabi al-Awwal 1448"); under
                  // RTL its leading day number would jump to the end.
                  textDirection: TextDirection.ltr,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: colors.primaryGreen.withValues(alpha: 0.86),
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 3),
                InkWell(
                  borderRadius: AppRadius.circularSm,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: 3,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _MetaText(label: date, color: colors.textMuted),
                        if (location != null)
                          _MetaText(
                            icon: Icons.location_on_outlined,
                            label: location.city,
                            color: colors.textMuted,
                            emphasized: true,
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          // Entry point for every app-wide setting.
          Material(
            color: colors.goldLight.withValues(alpha: 0.5),
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const SettingsScreen())),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Icon(
                  Icons.settings_outlined,
                  size: 22,
                  color: colors.accentGold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaText extends StatelessWidget {
  final IconData? icon;
  final String label;
  final Color color;
  final bool emphasized;

  const _MetaText({
    this.icon,
    required this.label,
    required this.color,
    this.emphasized = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 11, color: color.withValues(alpha: 0.82)),
          const SizedBox(width: 3),
        ],
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 170),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: emphasized ? FontWeight.w500 : FontWeight.w400,
              color: color.withValues(alpha: 0.88),
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }
}
