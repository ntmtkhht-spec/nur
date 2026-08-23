class LegalProfile {
  const LegalProfile._();

  static const appName = 'Munir';
  static const appStoreName = 'Munir - Prayer times, Qibla and Quran';

  static const operatorName = 'Mouhmad Khalel';
  static const operatorStreet = 'Artillerieweg 27B';
  static const operatorPostalCity = '26129 Oldenburg';
  static const operatorCountry = 'Deutschland';
  static const contactEmail = 'mouhmadkhalel@gmail.com';
  static const contactPhone = '+49 162 5151462';
  // Munir is offered by a private individual, so there is no legal
  // representative, register entry or VAT number to name — and § 18 Abs. 2
  // MStV does not apply either, since the app carries no journalistic
  // content. The imprint leaves those sections out rather than printing
  // "does not apply" over and over. Add the fields back here if that ever
  // changes.

  /// Published by `.github/workflows/pages.yml` from the same text the app
  /// shows, so these can never describe a different app than the screens do.
  /// Google Play requires both to be reachable publicly, without a login.
  static const siteUrl = 'https://ntmtkhht-spec.github.io/nur/';
  static const privacyPolicyUrl = '${siteUrl}index.html';
  static const imprintUrl = '${siteUrl}impressum.html';
  static const accountDeletionUrl = '${siteUrl}konto-loeschen.html';

  static const lastUpdated = '23. August 2026';
}
