import 'dart:convert';
import 'dart:math' as math;

import 'package:http/http.dart' as http;

import '../models/mosque.dart';

/// Overpass answered, but not with results.
///
/// Carries the status code instead of a ready-made sentence: 429 (too many
/// requests) and 504 (the public instance is overloaded) are the two the
/// user actually meets, and the screen is the place that knows which
/// language to say so in.
class OverpassException implements Exception {
  final int statusCode;

  const OverpassException(this.statusCode);

  /// The public instance is shared between tens of thousands of daily users
  /// and sheds load rather than queueing.
  bool get isOverloaded =>
      statusCode == 429 || statusCode == 503 || statusCode == 504;

  @override
  String toString() => 'OverpassException($statusCode)';
}

/// Looks up nearby mosques in OpenStreetMap via the Overpass API.
///
/// Note this is the one place in the app where the user's coordinates leave the
/// device: Overpass needs them to run the spatial query. Nothing else about the
/// user is sent, and no identifier is attached.
class OverpassService {
  static const _endpoint = 'https://overpass-api.de/api/interpreter';

  /// Overpass rejects requests without a User-Agent with HTTP 406.
  static const _userAgent = 'MunirApp/1.0 (Islamic prayer times app)';

  final http.Client _client;

  OverpassService({http.Client? client}) : _client = client ?? http.Client();

  /// [unnamedLabel] is the caller's localized stand-in for a mosque that
  /// OpenStreetMap has no name for. Passed in rather than hardcoded so this
  /// service stays free of UI language.
  Future<List<Mosque>> findNearby({
    required double lat,
    required double lng,
    required String unnamedLabel,
    int radiusMeters = 5000,
    int limit = 50,
  }) async {
    // Mosques are tagged as nodes, ways (building outlines) or relations, so all
    // three are queried. "out center" gives ways/relations a single coordinate.
    final query = '''
[out:json][timeout:25];
(
  node["amenity"="place_of_worship"]["religion"="muslim"](around:$radiusMeters,$lat,$lng);
  way["amenity"="place_of_worship"]["religion"="muslim"](around:$radiusMeters,$lat,$lng);
  relation["amenity"="place_of_worship"]["religion"="muslim"](around:$radiusMeters,$lat,$lng);
);
out center $limit;
''';

    final response = await _client
        .post(
          Uri.parse(_endpoint),
          headers: {
            'User-Agent': _userAgent,
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          body: {'data': query},
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode != 200) {
      throw OverpassException(response.statusCode);
    }

    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    final elements = (decoded['elements'] as List?) ?? const [];

    final results = <Mosque>[];
    for (final raw in elements) {
      final element = raw as Map<String, dynamic>;
      final tags = (element['tags'] as Map?)?.cast<String, dynamic>() ?? {};

      // Ways and relations report their position under "center".
      final center = (element['center'] as Map?)?.cast<String, dynamic>();
      final elementLat = (element['lat'] ?? center?['lat']) as num?;
      final elementLng = (element['lon'] ?? center?['lon']) as num?;
      if (elementLat == null || elementLng == null) continue;

      results.add(
        Mosque(
          id: (element['id'] as num).toInt(),
          name: (tags['name'] ?? tags['alt_name'] ?? unnamedLabel) as String,
          lat: elementLat.toDouble(),
          lng: elementLng.toDouble(),
          distanceMeters: _haversineMeters(
            lat,
            lng,
            elementLat.toDouble(),
            elementLng.toDouble(),
          ),
          street: tags['addr:street'] as String?,
          houseNumber: tags['addr:housenumber'] as String?,
          postcode: tags['addr:postcode'] as String?,
          city: tags['addr:city'] as String?,
          website: (tags['website'] ?? tags['contact:website']) as String?,
          phone: (tags['phone'] ?? tags['contact:phone']) as String?,
          denomination: tags['denomination'] as String?,
        ),
      );
    }

    results.sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
    return results;
  }

  static double _haversineMeters(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    const earthRadiusMeters = 6371000.0;
    double toRad(double d) => d * math.pi / 180.0;

    final dLat = toRad(lat2 - lat1);
    final dLng = toRad(lng2 - lng1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(toRad(lat1)) *
            math.cos(toRad(lat2)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    return earthRadiusMeters * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }
}
