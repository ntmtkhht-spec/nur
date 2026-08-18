import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:http_cache_file_store/http_cache_file_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cache/flutter_map_cache.dart';
import 'package:latlong2/latlong.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../models/mosque.dart';
import 'mosque_card.dart';

/// Map view of the mosques the search returned.
///
/// Tiles are CARTO's "Positron" style: OSM data rendered in a pale, low-detail
/// palette, which keeps the mosque pins readable instead of competing with
/// road colours. Free and no API key, same as the raw OSM tiles, and it wants
/// the same thing in return — attribution, set at the bottom of the stack.
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
  final _controller = MapController();
  Mosque? _selected;

  /// Tiles are immutable, so caching them on disk turns every repeat visit
  /// into zero network requests. Without this the map refetches the same
  /// tiles on every open, which is what makes it feel slow.
  CacheStore? _tileCache;

  @override
  void initState() {
    super.initState();
    _openCache();
  }

  Future<void> _openCache() async {
    final dir = await getTemporaryDirectory();
    if (!mounted) return;
    setState(() {
      _tileCache = FileCacheStore('${dir.path}/map_tiles');
    });
  }

  /// Roughly fits the search circle onto a phone screen.
  double get _zoomForRadius => switch (widget.radiusMeters) {
        <= 2000 => 13,
        <= 5000 => 12,
        <= 10000 => 11,
        _ => 9.5,
      };

  @override
  void didUpdateWidget(MosqueMap old) {
    super.didUpdateWidget(old);
    // Widening the radius while the map is open would otherwise keep the old
    // zoom and push the new results off screen.
    if (old.radiusMeters != widget.radiusMeters) {
      _controller.move(
        LatLng(widget.userLat, widget.userLng),
        _zoomForRadius,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _tileCache?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final selected = _selected;

    return Stack(
      children: [
        FlutterMap(
          mapController: _controller,
          options: MapOptions(
            initialCenter: LatLng(widget.userLat, widget.userLng),
            initialZoom: _zoomForRadius,
            minZoom: 3,
            maxZoom: 18,
            // Tapping empty map dismisses the detail sheet.
            onTap: (_, _) => setState(() => _selected = null),
          ),
          children: [
            TileLayer(
              // @2x tiles are ~76 KB against ~28 KB for the plain ones, so
              // only ask for them where the extra pixels are actually visible.
              urlTemplate: MediaQuery.devicePixelRatioOf(context) >= 2
                  ? 'https://basemaps.cartocdn.com/light_all/{z}/{x}/{y}@2x.png'
                  : 'https://basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.nur.nurApp',
              maxNativeZoom: 20,
              // One ring of off-screen tiles is enough to cover a small pan;
              // the default keeps fetching tiles the user never sees.
              panBuffer: 1,
              tileProvider: _tileCache == null
                  ? NetworkTileProvider()
                  : CachedTileProvider(
                      maxStale: const Duration(days: 30),
                      store: _tileCache!,
                      dio: Dio(),
                    ),
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
          '© OpenStreetMap, © CARTO',
          style: TextStyle(fontSize: 10, color: Colors.black87),
        ),
      ),
    );
  }
}
