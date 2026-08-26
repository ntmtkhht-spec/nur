/// Schemes the app is willing to hand to the operating system for a mosque's
/// website.
///
/// Everything in an OSM entry is world-editable, so the `website` tag is
/// attacker-controlled data, not a trusted field. Handing it to `launchUrl`
/// as-is passes whatever scheme it carries — `intent:`, `file:`, some other
/// installed app's custom scheme — straight to the OS.
const _launchableWebsiteSchemes = {'http', 'https'};

/// The mosque's website as a URI worth opening, or null when the tag does not
/// hold one.
///
/// Rejecting outright rather than repairing: a tag that is not a web address
/// is not a web address with a typo, and the button is hidden instead.
Uri? launchableWebsiteUri(String? tag) {
  if (tag == null) return null;
  final trimmed = tag.trim();
  if (trimmed.isEmpty) return null;

  final parsed = Uri.tryParse(trimmed);
  if (parsed == null) return null;

  // The tag is often written bare ("example.org"), which parses as a relative
  // reference. Assuming https there keeps those entries usable; it cannot
  // smuggle a scheme past the check, because a string carrying one would have
  // parsed with it.
  if (!parsed.hasScheme) {
    final assumed = Uri.tryParse('https://$trimmed');
    if (assumed == null || assumed.host.isEmpty) return null;
    return assumed;
  }

  if (!_launchableWebsiteSchemes.contains(parsed.scheme)) return null;
  if (parsed.host.isEmpty) return null;
  return parsed;
}

/// The mosque's phone number as a `tel:` URI, or null when the tag holds no
/// dialable number.
///
/// Built through [Uri] rather than interpolated into a `tel:` string, and
/// reduced to digits first. `#` and `*` are dropped rather than escaped
/// because they are how MMI and USSD codes are dialled — a world-editable
/// tag has no business reaching the dialler with those in it. Separators and
/// extension characters are cosmetic and go with them.
Uri? launchablePhoneUri(String? tag) {
  if (tag == null) return null;

  // OSM packs several numbers into one tag separated by ";". Offer the first.
  final first = tag.split(';').first.trim();
  if (first.isEmpty) return null;

  final digits = first.replaceAll(RegExp(r'[^0-9]'), '');
  // Short enough to be a fragment of a tag rather than a number.
  if (digits.length < 3) return null;

  return Uri(scheme: 'tel', path: first.startsWith('+') ? '+$digits' : digits);
}

class Mosque {
  final int id;
  final String name;
  final double lat;
  final double lng;
  final String? street;
  final String? houseNumber;
  final String? postcode;
  final String? city;
  final String? website;
  final String? phone;
  final String? denomination;

  /// Straight-line distance from the user, in metres.
  final double distanceMeters;

  const Mosque({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.distanceMeters,
    this.street,
    this.houseNumber,
    this.postcode,
    this.city,
    this.website,
    this.phone,
    this.denomination,
  });

  /// Postal address assembled from whichever OSM address tags are present.
  /// Returns null when the entry carries no address at all.
  String? get address {
    final line1 = [
      if (street != null) street,
      if (houseNumber != null) houseNumber,
    ].join(' ').trim();

    final line2 = [
      if (postcode != null) postcode,
      if (city != null) city,
    ].join(' ').trim();

    final parts = [if (line1.isNotEmpty) line1, if (line2.isNotEmpty) line2];
    return parts.isEmpty ? null : parts.join(', ');
  }

  /// The website tag, once it has cleared [launchableWebsiteUri].
  Uri? get websiteUri => launchableWebsiteUri(website);

  /// The phone tag, once it has cleared [launchablePhoneUri].
  Uri? get phoneUri => launchablePhoneUri(phone);

  String get formattedDistance => distanceMeters < 1000
      ? '${distanceMeters.round()} m'
      : '${(distanceMeters / 1000).toStringAsFixed(1)} km';

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'lat': lat,
        'lng': lng,
        'distanceMeters': distanceMeters,
        'street': street,
        'houseNumber': houseNumber,
        'postcode': postcode,
        'city': city,
        'website': website,
        'phone': phone,
        'denomination': denomination,
      };

  factory Mosque.fromJson(Map<String, dynamic> json) => Mosque(
        id: json['id'] as int,
        name: json['name'] as String,
        lat: (json['lat'] as num).toDouble(),
        lng: (json['lng'] as num).toDouble(),
        distanceMeters: (json['distanceMeters'] as num).toDouble(),
        street: json['street'] as String?,
        houseNumber: json['houseNumber'] as String?,
        postcode: json['postcode'] as String?,
        city: json['city'] as String?,
        website: json['website'] as String?,
        phone: json['phone'] as String?,
        denomination: json['denomination'] as String?,
      );
}
