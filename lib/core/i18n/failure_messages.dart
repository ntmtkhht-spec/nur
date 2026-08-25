import '../../features/mosques/services/overpass_service.dart';
import '../../l10n/app_localizations.dart';
import '../providers/providers.dart';

/// Turns a thrown failure into a sentence in the app's current language.
///
/// Services and providers raise typed errors rather than pre-worded ones.
/// They used to throw `Exception('Standortdienste sind deaktiviert.')` and
/// the screens printed `e.toString()` with the `Exception: ` prefix stripped
/// off — which meant a German sentence reached the screen no matter which of
/// the five languages the app was running in, and any unexpected error
/// reached it as a Dart type name.
String describeLocationFailure(AppLocalizations l10n, Object error) {
  if (error is! LocationUnavailable) return l10n.commonLoadFailed;
  return switch (error.reason) {
    LocationFailure.servicesDisabled => l10n.locationServicesDisabled,
    LocationFailure.permissionDenied => l10n.locationPermissionDenied,
    LocationFailure.noFix => l10n.locationNoFix,
  };
}

/// The mosque search's failures, worded for the user.
///
/// The public Overpass instance sheds load rather than queueing, so being
/// turned away is an ordinary outcome and worth saying plainly instead of
/// showing a status code.
String describeMosqueFailure(AppLocalizations l10n, Object error) {
  if (error is OverpassException && error.isOverloaded) {
    return l10n.mosqueSearchBusy;
  }
  return l10n.mosqueSearchFailed;
}
