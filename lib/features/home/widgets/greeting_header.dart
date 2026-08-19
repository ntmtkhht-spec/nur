import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../../l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../settings/settings_screen.dart';

class GreetingHeader extends ConsumerWidget {
  const GreetingHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final userName = ref.watch(userNameProvider);
    final hijriDate = ref.watch(hijriDateProvider);
    final locationAsync = ref.watch(locationProvider);
    final location = switch (locationAsync) {
      AsyncData(:final value) => value,
      _ => null,
    };
    final now = DateTime.now();
    final colors = AppColors.of(context);

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
                  // No hardcoded line break: it stranded short names on a line
                  // of their own. Let the text wrap only when it actually
                  // needs to. The name is also optional, so avoid leaving a
                  // dangling comma when it has not been set.
                  userName.trim().isEmpty
                      ? l10n.greetingNoName
                      : l10n.greeting(userName.trim()),
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: colors.textDark,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  hijriDate,
                  // The Hijri string is Latin ("6 Rabi al-Awwal 1448"); under
                  // RTL its leading day number would jump to the end.
                  textDirection: TextDirection.ltr,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: colors.primaryGreen,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatDate(context, now),
                  style: TextStyle(
                    fontSize: 14,
                    color: colors.textMuted,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                if (location != null)
                  InkWell(
                    borderRadius: AppRadius.circularSm,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Einstellungen für Standort öffnen...'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.location_on, size: 14, color: colors.textMuted),
                          const SizedBox(width: 4),
                          Text(
                            location.city,
                            style: TextStyle(
                              fontSize: 13,
                              color: colors.textMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Icon(Icons.calculate_outlined, size: 14, color: colors.textMuted),
                          const SizedBox(width: 4),
                          Text(
                            ref.watch(calculationMethodProvider).shortLabel,
                            style: TextStyle(
                              fontSize: 13,
                              color: colors.textMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.chevron_right, size: 16, color: colors.textMuted),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Entry point for every app-wide setting.
          Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              ),
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.cardBg,
                  border: Border.all(
                    color: colors.accentGold.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  Icons.settings_outlined,
                  color: colors.accentGold,
                  size: 26,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Weekday and month names come from intl so they follow the app locale;
  /// the hardcoded German list this replaced only ever produced German.
  String _formatDate(BuildContext context, DateTime d) =>
      DateFormat.yMMMMEEEEd(Localizations.localeOf(context).toLanguageTag())
          .format(d);
}
