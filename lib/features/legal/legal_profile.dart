class LegalProfile {
  const LegalProfile._();

  static const appName = 'Munir';
  static const appStoreName = 'Munir - Prayer times, Qibla and Quran';

  // Replace every bracketed value before submitting to App Store Connect or
  // Google Play Console. Store reviewers can reject legal pages with blanks.
  static const operatorName = '[VOLLSTAENDIGER NAME / FIRMA]';
  static const operatorStreet = '[STRASSE UND HAUSNUMMER]';
  static const operatorPostalCity = '[PLZ UND ORT]';
  static const operatorCountry = 'Deutschland';
  static const contactEmail = '[E-MAIL-ADRESSE]';
  static const contactPhone = '[TELEFONNUMMER, FALLS VORHANDEN]';
  static const representedBy = '[VERTRETUNGSBERECHTIGTE PERSON, FALLS FIRMA]';
  static const registerEntry =
      '[HANDELSREGISTER / REGISTERNUMMER, FALLS VORHANDEN]';
  static const vatId = '[UST-ID, FALLS VORHANDEN]';
  static const editorialResponsible =
      '[NAME UND ANSCHRIFT DER VERANTWORTLICHEN PERSON NACH § 18 ABS. 2 MSTV, FALLS ERFORDERLICH]';

  static const privacyPolicyUrl =
      '[OEFFENTLICHE DATENSCHUTZ-URL FUER APP STORE UND GOOGLE PLAY]';
  static const accountDeletionUrl =
      '[OEFFENTLICHE URL ZUR KONTO- UND DATENLOESCHUNG FUER GOOGLE PLAY]';

  static const lastUpdated = '20. August 2026';

  static const hasPlaceholders = true;
}
