import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import 'providers/mosques_provider.dart';
import '../../core/providers/providers.dart';
import 'widgets/mosque_card.dart';
import 'widgets/mosque_map.dart';

class MosquesScreen extends ConsumerStatefulWidget {
  const MosquesScreen({super.key});

  @override
  ConsumerState<MosquesScreen> createState() => _MosquesScreenState();
}

class _MosquesScreenState extends ConsumerState<MosquesScreen> {
  bool _showMap = false;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final hasConsent = ref.watch(mosqueSearchConsentProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(
          'Moscheen',
          style: TextStyle(
            color: colors.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: colors.background,
        iconTheme: IconThemeData(color: colors.primaryGreen),
        elevation: 0,
        actions: [
          if (hasConsent)
            IconButton(
              tooltip: _showMap ? 'Liste' : 'Karte',
              icon: Icon(
                _showMap ? Icons.view_list_outlined : Icons.map_outlined,
                color: colors.primaryGreen,
              ),
              onPressed: () => setState(() => _showMap = !_showMap),
            ),
          if (hasConsent)
            IconButton(
              tooltip: 'Aktualisieren',
              icon: Icon(Icons.refresh, color: colors.primaryGreen),
              // .refresh(), not invalidate(): invalidating just reruns build(),
              // which would hit the cache again and look like nothing happened.
              onPressed: () =>
                  ref.read(nearbyMosquesProvider.notifier).refresh(),
            ),
        ],
      ),
      body: hasConsent ? _MosqueResults(showMap: _showMap) : const _ConsentGate(),
    );
  }
}

/// Searching sends the user's coordinates to a third party, which the rest of
/// the app never does. That is asked for explicitly rather than assumed.
class _ConsentGate extends ConsumerWidget {
  const _ConsentGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.xl),
          Center(
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: colors.accentGold.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.travel_explore,
                size: 44,
                color: colors.accentGold,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Moscheen in der Nähe finden',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: colors.textDark,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Dafür wird dein aktueller Standort an OpenStreetMap gesendet, '
            'um die Umgebungssuche dort auszuführen.\n\n'
            'Das ist die einzige Funktion der App, bei der dein Standort das '
            'Gerät verlässt. Es werden keine weiteren Daten und keine Kennung '
            'übertragen.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: colors.textMuted,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: () =>
                  ref.read(mosqueSearchConsentProvider.notifier).grant(),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.darkGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.circularLg,
                ),
              ),
              child: const Text(
                'Einverstanden, Moscheen suchen',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Du kannst das jederzeit widerrufen.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: colors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _MosqueResults extends ConsumerWidget {
  final bool showMap;

  const _MosqueResults({required this.showMap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final mosquesAsync = ref.watch(nearbyMosquesProvider);
    final radius = ref.watch(mosqueRadiusProvider);
    // The map needs a centre even while the real position is still resolving;
    // same fallback the search itself uses.
    final location = switch (ref.watch(locationProvider)) {
      AsyncData(:final value) => value,
      _ => LocationData.fallback,
    };

    return Column(
      children: [
        _RadiusSlider(
          radius: radius,
          onChanged: (meters) =>
              ref.read(mosqueRadiusProvider.notifier).set(meters),
        ),
        const SizedBox(height: AppSpacing.lg),
        Expanded(
          child: switch (mosquesAsync) {
            AsyncLoading() => Center(
                child: CircularProgressIndicator(color: colors.primaryGreen),
              ),
            AsyncError(:final error) => _ErrorState(
                message: error.toString().replaceFirst('Exception: ', ''),
                onRetry: () =>
                    ref.read(nearbyMosquesProvider.notifier).refresh(),
              ),
            AsyncData(:final value) => value.isEmpty
                ? _EmptyState(radiusMeters: radius)
                : showMap
                ? MosqueMap(
                    mosques: value,
                    userLat: location.lat,
                    userLng: location.lng,
                    radiusMeters: radius,
                  )
                : ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.xs,
                      AppSpacing.lg,
                      AppSpacing.xxl,
                    ),
                    itemCount: value.length + 1,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.xs),
                    itemBuilder: (context, i) {
                      if (i == value.length) return const _Attribution();
                      return MosqueCard(mosque: value[i]);
                    },
                  ),
          },
        ),
      ],
    );
  }
}

/// Search radius picker.
///
/// The steps stay discrete rather than free-scrolling: results are cached per
/// (location, radius) and every distinct value is another Overpass query, so
/// a continuous slider would blow through both.
class _RadiusSlider extends StatelessWidget {
  final int radius;
  final ValueChanged<int> onChanged;

  static const _steps = [2000, 5000, 10000, 25000];

  const _RadiusSlider({required this.radius, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final index = _steps.indexOf(radius);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Umkreis',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colors.textMuted,
                ),
              ),
              Text(
                '${radius ~/ 1000} km',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: colors.darkGreen,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              activeTrackColor: colors.darkGreen,
              inactiveTrackColor: colors.accentGold.withValues(alpha: 0.2),
              thumbColor: colors.darkGreen,
              overlayColor: colors.darkGreen.withValues(alpha: 0.12),
              activeTickMarkColor: Colors.transparent,
              inactiveTickMarkColor: Colors.transparent,
              showValueIndicator: ShowValueIndicator.never,
            ),
            child: Slider(
              value: (index < 0 ? 1 : index).toDouble(),
              min: 0,
              max: (_steps.length - 1).toDouble(),
              divisions: _steps.length - 1,
              onChanged: (v) => onChanged(_steps[v.round()]),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final int radiusMeters;

  const _EmptyState({required this.radiusMeters});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 56, color: colors.textMuted),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Keine Moschee im Umkreis von '
              '${radiusMeters ~/ 1000} km gefunden.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: colors.textMuted),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Versuche einen größeren Radius. Die Daten stammen aus '
              'OpenStreetMap und sind je nach Region unterschiedlich '
              'vollständig.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: colors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off, size: 56, color: colors.textMuted),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Suche fehlgeschlagen',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: colors.textDark,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: colors.textMuted),
            ),
            const SizedBox(height: AppSpacing.md),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Erneut versuchen'),
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.primaryGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Attribution extends StatelessWidget {
  const _Attribution();

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Text(
        'Daten © OpenStreetMap-Mitwirkende (ODbL)',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 11, color: colors.textMuted),
      ),
    );
  }
}
