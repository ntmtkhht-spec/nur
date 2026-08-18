import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/providers.dart';

/// Translations for the strings the home screen's progress card needs.
///
/// The app stores a language preference from onboarding but is otherwise
/// hardcoded German, so this is deliberately small: it covers the widgets that
/// have been translated so far rather than pretending to be a full
/// localisation layer. Add fields here as more screens are translated.
///
/// [appLanguageProvider] stores the display name shown in onboarding
/// ('Deutsch', 'English', 'Türkçe', 'العربية'), so that is what we key on.
@immutable
class AppStrings {
  /// Heading of the daily prayer progress card.
  final String todaysProgress;

  /// Label in front of the percentage bar.
  final String overallProgress;

  /// Suffix after the percentage, e.g. "80 % erledigt".
  final String percentComplete;

  /// Shown when a prayer that has not started yet is tapped.
  final String prayerNotYetDue;

  /// Written direction for this language.
  final TextDirection direction;

  const AppStrings({
    required this.todaysProgress,
    required this.overallProgress,
    required this.percentComplete,
    required this.prayerNotYetDue,
    this.direction = TextDirection.ltr,
  });

  static const _de = AppStrings(
    todaysProgress: 'Heutiger Fortschritt',
    overallProgress: 'Gesamtfortschritt',
    percentComplete: '% erledigt',
    prayerNotYetDue: 'Dieses Gebet liegt noch vor dir.',
  );

  static const _en = AppStrings(
    todaysProgress: "Today's Progress",
    overallProgress: 'Overall Progress',
    percentComplete: '% Complete',
    prayerNotYetDue: 'This prayer is still ahead.',
  );

  static const _tr = AppStrings(
    todaysProgress: 'Bugünkü İlerleme',
    overallProgress: 'Genel İlerleme',
    percentComplete: '% Tamamlandı',
    prayerNotYetDue: 'Bu namazın vakti henüz gelmedi.',
  );

  static const _ar = AppStrings(
    todaysProgress: 'تقدم اليوم',
    overallProgress: 'التقدم العام',
    percentComplete: '٪ مكتمل',
    prayerNotYetDue: 'لم يحن وقت هذه الصلاة بعد.',
    direction: TextDirection.rtl,
  );

  /// Arabic heading shown as a subtitle underneath the translated one, the
  /// way the prayer names carry their Arabic spelling everywhere else.
  static const arabicTodaysProgress = 'تقدم اليوم';

  static AppStrings forLanguage(String language) => switch (language) {
        'English' => _en,
        'Türkçe' => _tr,
        'العربية' => _ar,
        _ => _de,
      };
}

final appStringsProvider = Provider<AppStrings>((ref) {
  return AppStrings.forLanguage(ref.watch(appLanguageProvider));
});
