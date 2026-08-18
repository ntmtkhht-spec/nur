import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../models/mosque.dart';
import 'mosque_card.dart';

/// OpenStreetMap view of the mosques the search returned.
///
/// Tiles come from the public OSM servers, which is free and needs no API key
/// — the mosque data itself already comes from OSM via Overpass. Their tile
/// usage policy requires an identifying user agent and visible attribution,
/// both of which are set below.
class MosqueMap extends StatefulWidget {
  final List<Mosque> mosques;

  /// Where the user is; the map opens centred here.
  final double userLat;
  final double userLng;

  /// Search radius in metres, used to pick a sensible initial zoom.
  final int radiusMeters;

  const MosqueMap({
    super.key,
    required this.mosques,
    required this.userLat,
    required this.userLng,
    required this.radiusMeters,
  });

  @override
  State<MosqueMap> createState() => _MosqueMapState();
}

class _MosqueMapState extends State<MosqueMap> {
  Mosque? _selected;

  /// Roughly fits the search circle onto a phone screen.
  double get _initialZoom => switch (widget.radiusMeters) {
        <= 2000 => 13,
        <= 5000 => 12,
        <= 10000 => 11,
        _ => 9.5,
      };

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final selected = _selected;

    return Stack(
      children: [
        FlutterMap(
          options: MapOptions(
            initialCenter: LatLng(widget.userLat, widget.userLng),
            initialZoom: _initialZoom,
            minZoom: 3,
            maxZoom: 18,
            // Tapping empty map dismisses the detail sheet.
            onTap: (_, _) => setState(() => _selected = null),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.nur.nurApp',
              maxNativeZoom: 19,
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: LatLng(widget.userLat, widget.userLng),
                  width: 22,
                  height: 22,
                  child: _UserDot(color: colors.primaryGreen),
                ),
                for (final m in widget.mosques)
                  Marker(
                    point: LatLng(m.lat, m.lng),
                    width: 40,
                    height: 40,
                    child: GestureDetector(
                      onTap: () => setState(() => _selected = m),
                      child: _MosquePin(
                        selected: selected?.id == m.id,
                        colors: colors,
                      ),
                    ),
                  ),
              ],
            ),
            const _MapAttribution(),
          ],
        ),
        if (selected != null)
          Positioned(
            left: AppSpacing.md,
            right: AppSpacing.md,
            bottom: AppSpacing.md,
            child: SafeArea(
              top: false,
              child: MosqueCard(mosque: selected),
            ),
          ),
      ],
    );
  }
}

class _MosquePin extends StatelessWidget {
  final bool selected;
  final AppColorsExtension colors;

  const _MosquePin({required this.selected, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: selected ? colors.accentGold : colors.darkGreen,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: AppShadows.sm,
      ),
      child: const Icon(Icons.mosque, size: 18, color: Colors.white),
    );
  }
}

class _UserDot extends StatelessWidget {
  final Color color;

  const _UserDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: AppShadows.sm,
      ),
    );
  }
}

/// Required by the OSM tile usage policy.
class _MapAttribution extends StatelessWidget {
  const _MapAttribution();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Container(
        color: Colors.white.withValues(alpha: 0.75),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: const Text(
          '© OpenStreetMap',
          style: TextStyle(fontSize: 10, color: Colors.black87),
        ),
      ),
    );
  }
}
