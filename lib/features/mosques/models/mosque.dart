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

    final parts = [
      if (line1.isNotEmpty) line1,
      if (line2.isNotEmpty) line2,
    ];
    return parts.isEmpty ? null : parts.join(', ');
  }

  String get formattedDistance => distanceMeters < 1000
      ? '${distanceMeters.round()} m'
      : '${(distanceMeters / 1000).toStringAsFixed(1)} km';
}
