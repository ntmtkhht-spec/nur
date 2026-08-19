import 'package:adhan_dart/adhan_dart.dart' as adhan;

/// Picks the calculation method a country's mosques commonly follow.
///
/// Asking a first-time user to choose between "Muslim World League" and "ISNA"
/// puts a question in front of them that they can only answer if they already
/// know the answer — and a wrong guess silently shifts their prayer times. The
/// country gives a far better default, and Settings still lets anyone change
/// it.
///
/// Keyed by ISO 3166-1 alpha-2 country code as returned by geocoding.
adhan.CalculationMethod calculationMethodForCountry(String? isoCountryCode) {
  return switch (isoCountryCode?.toUpperCase()) {
    // Diyanet publishes the official times in Türkiye.
    'TR' => adhan.CalculationMethod.turkiye,

    // Egyptian General Authority of Survey.
    'EG' || 'SY' || 'IQ' || 'JO' || 'LB' || 'SD' || 'LY' || 'YE' =>
      adhan.CalculationMethod.egyptian,

    // Umm al-Qura, used across Saudi Arabia.
    'SA' => adhan.CalculationMethod.ummAlQura,

    // Gulf states maintain their own tables.
    'AE' => adhan.CalculationMethod.dubai,
    'QA' => adhan.CalculationMethod.qatar,
    'KW' => adhan.CalculationMethod.kuwait,

    // University of Islamic Sciences, Karachi.
    'PK' || 'IN' || 'BD' || 'AF' || 'LK' || 'NP' =>
      adhan.CalculationMethod.karachi,

    // Islamic Society of North America.
    'US' || 'CA' => adhan.CalculationMethod.northAmerica,

    // Institute of Geophysics, University of Tehran.
    'IR' => adhan.CalculationMethod.tehran,

    // Majlis Ugama Islam Singapura and neighbours follow the same convention.
    'SG' || 'MY' || 'ID' || 'BN' => adhan.CalculationMethod.singapore,

    // Union des Organisations Islamiques de France.
    'FR' => adhan.CalculationMethod.france,

    // Muslim World League is the common European and default choice.
    _ => adhan.CalculationMethod.muslimWorldLeague,
  };
}
