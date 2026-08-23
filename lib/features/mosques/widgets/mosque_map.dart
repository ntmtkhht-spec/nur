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

  /// Search radius in metres. Drives both the initial zoom and the circle
  /// drawn around the user, so the searched area is visible on the map rather
  /// than only implied by a number above it.
  final int radiusMeters;

  /// True while an Overpass query for this area is in flight. The radius
  /// circle pulses while it is, which is what shows *where* the app is
  /// currently searching rather than only *that* it is.
  final bool isSearching;

  const MosqueMap({
    super.key,
    required this.mosques,
    required this.userLat,
    required this.userLng,
    required this.radiusMeters,
    this.isSearching = false,
  });

  @override
  State<MosqueMap> createState() => _MosqueMapState();
}

class _MosqueMapState extends State<MosqueMap>
    with SingleTickerProviderStateMixin {
  final _controller = MapController();
  Mosque? _selected;

  /// The map controller can only be driven once [FlutterMap] has built its
  /// interactive viewer, and that happens during *layout*, not build. Calling
  /// [MapController.move] before then throws a `LateInitializationError` from
  /// inside flutter_map and takes the whole screen down, so every programmatic
  /// camera change waits on this flag.
  bool _mapReady = false;

  /// A recentre that arrived before the map was ready, replayed by
  /// [_onMapReady].
  bool _recenterPending = false;

  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  /// One client for the widget's lifetime. Building it inside [build] handed
  /// flutter_map a fresh [Dio] — and with it a fresh interceptor chain and
  /// connection pool — on every marker tap, none of which were ever closed.
  final _dio = Dio();

  /// Tiles are immutable, so caching them on disk turns every repeat visit
  /// into zero network requests. Without this the map refetches the same
  /// tiles on every open, which is what makes it feel slow.
  CacheStore? _tileCache;

  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    _openCache();
    if (widget.isSearching) _pulse.repeat(reverse: true);
  }

  Future<void> _openCache() async {
    final dir = await getTemporaryDirectory();
    final store = FileCacheStore('${dir.path}/map_tiles');
    if (_disposed || !mounted) {
      // Left the screen while the directory lookup was still running. Without
      // this the store is handed to nobody, and so closed by nobody.
      await store.close();
      return;
    }
    setState(() => _tileCache = store);
  }

  /// Roughly fits the search circle onto a phone screen.
  double get _zoomForRadius => switch (widget.radiusMeters) {
    <= 2000 => 13,
    <= 5000 => 12,
    <= 10000 => 11,
    _ => 9.5,
  };

  LatLng get _center => LatLng(widget.userLat, widget.userLng);

  @override
  void didUpdateWidget(MosqueMap old) {
    super.didUpdateWidget(old);

    // Widening the radius while the map is open would otherwise keep the old
    // zoom and push the new results off screen. The location changing matters
    // just as much: the map opens on the Berlin fallback while the real fix is
    // still resolving, and without this it would stay there with every pin off
    // screen.
    if (old.radiusMeters != widget.radiusMeters ||
        old.userLat != widget.userLat ||
        old.userLng != widget.userLng) {
      _recenter();
    }

    if (old.isSearching != widget.isSearching) {
      if (widget.isSearching) {
        _pulse.repeat(reverse: true);
      } else {
        _pulse.stop();
        _pulse.value = 0;
      }
    }
  }

  void _onMapReady() {
    _mapReady = true;
    if (_recenterPending) {
      _recenterPending = false;
      _recenter();
    }
  }

  /// Moves the camera back onto the user, deferred out of the build phase.
  ///
  /// [MapController.move] emits a map event synchronously, which marks
  /// flutter_map's own widgets dirty. Calling it from `didUpdateWidget` means
  /// mutating the tree while it is being built, so the move is posted to after
  /// the frame instead.
  void _recenter() {
    if (!_mapReady) {
      _recenterPending = true;
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_disposed || !mounted || !_mapReady) return;
      _controller.move(_center, _zoomForRadius);
    });
  }

  @override
  void dispose() {
    _disposed = true;
    _pulse.dispose();
    _controller.dispose();
    // Close the client before the store: pending tile requests run through the
    // cache interceptor, and pulling the store out from under them logs image
    // errors for tiles the user has already navigated away from.
    _dio.close();
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
            initialCenter: _center,
            initialZoom: _zoomForRadius,
            minZoom: 3,
            maxZoom: 18,
            onMapReady: _onMapReady,
            // Tapping empty map dismisses the detail sheet.
            onTap: (_, _) => setState(() => _selected = null),
          ),
          children: [
            TileLayer(
              // Use regular tiles even on dense screens: the retina variants
              // are much heavier and made the first map open feel sluggish.
              urlTemplate:
                  'https://basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.munir.app',
              maxNativeZoom: 20,
              // One ring of off-screen tiles is enough to cover a small pan;
              // the default keeps fetching tiles the user never sees.
              panBuffer: 1,
              tileProvider: _tileCache == null
                  ? NetworkTileProvider()
                  : CachedTileProvider(
                      maxStale: const Duration(days: 30),
                      store: _tileCache!,
                      dio: _dio,
                    ),
            ),
            _SearchRadiusCircle(
              center: _center,
              radiusMeters: widget.radiusMeters.toDouble(),
              pulse: _pulse,
              colors: colors,
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: _center,
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
            child: SafeArea(top: false, child: MosqueCard(mosque: selected)),
          ),
      ],
    );
  }
}

/// The area currently being searched, drawn to scale on the map.
///
/// Kept as its own widget so the pulse repaints the circle alone instead of
/// rebuilding [FlutterMap] and every tile and marker along with it.
class _SearchRadiusCircle extends StatelessWidget {
  final LatLng center;
  final double radiusMeters;
  final Animation<double> pulse;
  final AppColorsExtension colors;

  const _SearchRadiusCircle({
    required this.center,
    required this.radiusMeters,
    required this.pulse,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulse,
      builder: (context, _) {
        // Idle, the circle sits at its base opacity; while searching it
        // breathes up to roughly double that, which reads as activity without
        // obscuring the pins inside it.
        final t = Curves.easeInOut.transform(pulse.value);
        return CircleLayer(
          // Every circle here shares one centre, so the metres-to-pixels ratio
          // is identical for all of them.
          optimizeRadiusInMeters: true,
          circles: [
            CircleMarker(
              point: center,
              radius: radiusMeters,
              useRadiusInMeter: true,
              color: colors.primaryGreen.withValues(alpha: 0.06 + 0.06 * t),
              borderStrokeWidth: 2,
              borderColor: colors.primaryGreen.withValues(
                alpha: 0.35 + 0.35 * t,
              ),
            ),
          ],
        );
      },
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
