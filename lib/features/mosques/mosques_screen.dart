import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import 'models/mosque.dart';
import 'providers/mosques_provider.dart';
import '../../core/providers/providers.dart';
import 'widgets/mosque_map.dart';

class MosquesScreen extends ConsumerStatefulWidget {
  const MosquesScreen({super.key});

  @override
  ConsumerState<MosquesScreen> createState() => _MosquesScreenState();
}

class _MosquesScreenState extends ConsumerState<MosquesScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = AppColors.of(context);
    final hasConsent = ref.watch(mosqueSearchConsentProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(
          l10n.mosquesTitle,
          style: TextStyle(color: colors.textDark, fontWeight: FontWeight.bold),
        ),
        backgroundColor: colors.background,
        iconTheme: IconThemeData(color: colors.primaryGreen),
        elevation: 0,
        actions: [
          if (hasConsent)
            IconButton(
              tooltip: l10n.mosquesRefresh,
              icon: Icon(Icons.refresh, color: colors.primaryGreen),
              // .refresh(), not invalidate(): invalidating just reruns build(),
              // which would hit the cache again and look like nothing happened.
              onPressed: () =>
                  ref.read(nearbyMosquesProvider.notifier).refresh(),
            ),
        ],
      ),
      body: hasConsent ? const _MosqueResults() : const _ConsentGate(),
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
  const _MosqueResults();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mosquesAsync = ref.watch(nearbyMosquesProvider);
    final radius = ref.watch(mosqueRadiusProvider);
    final mosques = switch (mosquesAsync) {
      AsyncData(:final value) => value,
      _ => const <Mosque>[],
    };
    final isLoading = mosquesAsync is AsyncLoading;
    final errorMessage = switch (mosquesAsync) {
      AsyncError(:final error) => error.toString().replaceFirst(
        'Exception: ',
        '',
      ),
      _ => null,
    };
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
          child: Stack(
            children: [
              MosqueMap(
                mosques: mosques,
                userLat: location.lat,
                userLng: location.lng,
                radiusMeters: radius,
                isSearching: isLoading,
              ),
              if (isLoading)
                const Positioned(
                  top: AppSpacing.sm,
                  left: AppSpacing.md,
                  right: AppSpacing.md,
                  child: _MapStatusBanner.loading(),
                ),
              if (errorMessage != null)
                Positioned(
                  top: AppSpacing.sm,
                  left: AppSpacing.md,
                  right: AppSpacing.md,
                  child: _MapStatusBanner.error(
                    message: errorMessage,
                    onRetry: () =>
                        ref.read(nearbyMosquesProvider.notifier).refresh(),
                  ),
                ),
            ],
          ),
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
    final l10n = AppLocalizations.of(context);
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
                l10n.mosquesRadius,
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

class _MapStatusBanner extends StatelessWidget {
  final IconData icon;
  final String message;
  final VoidCallback? onRetry;
  final bool isLoading;

  const _MapStatusBanner.loading()
    : icon = Icons.travel_explore,
      message = 'Moscheen werden gesucht...',
      onRetry = null,
      isLoading = true;

  const _MapStatusBanner.error({
    required this.message,
    required VoidCallback this.onRetry,
  }) : icon = Icons.cloud_off,
       isLoading = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = AppColors.of(context);

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.94),
          borderRadius: AppRadius.circularMd,
          boxShadow: AppShadows.sm,
        ),
        child: Row(
          children: [
            if (isLoading)
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colors.primaryGreen,
                ),
              )
            else
              Icon(icon, size: 18, color: colors.textMuted),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: colors.textDark,
                ),
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(width: AppSpacing.xs),
              TextButton(
                onPressed: onRetry,
                style: TextButton.styleFrom(
                  foregroundColor: colors.primaryGreen,
                  visualDensity: VisualDensity.compact,
                ),
                child: Text(l10n.mosquesRetry),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
