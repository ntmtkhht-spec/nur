import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';

/// Asks whether entries made before signing in belong to this account.
///
/// Shown once, on the first sign-in of an install that already has practice
/// recorded on it. Both sign-in paths — onboarding and settings — use this,
/// so the question is worded the same wherever it appears.
///
/// Returns true to adopt the entries, false to throw them away.
Future<bool> showAdoptLocalDataDialog(
  BuildContext context,
  int prayerCount,
) async {
  final l10n = AppLocalizations.of(context);
  final colors = AppColors.of(context);

  final adopt = await showDialog<bool>(
    context: context,
    // Dismissing by tapping outside would silently pick one of two very
    // different outcomes, so it has to be an actual choice.
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      backgroundColor: colors.background,
      title: Text(l10n.adoptLocalDataTitle),
      content: Text(
        prayerCount > 0
            ? l10n.adoptLocalDataBodyCounted(prayerCount)
            : l10n.adoptLocalDataBody,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            l10n.adoptLocalDataDiscard,
            style: const TextStyle(color: Color(0xFFB3261E)),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.adoptLocalDataKeep),
        ),
      ],
    ),
  );

  // Only reachable if the route was torn down while the dialog was open.
  // Keeping the entries is the recoverable outcome: they can still be
  // discarded later by resetting, while a silent wipe cannot be undone.
  return adopt ?? true;
}
