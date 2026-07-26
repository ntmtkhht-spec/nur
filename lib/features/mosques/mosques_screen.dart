import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import 'models/mosque.dart';
import 'providers/mosques_provider.dart';

class MosquesScreen extends ConsumerWidget {
  const MosquesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              tooltip: 'Aktualisieren',
              icon: Icon(Icons.refresh, color: colors.primaryGreen),
              onPressed: () => ref.invalidate(nearbyMosquesProvider),
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
    final colors = AppColors.of(context);
    final mosquesAsync = ref.watch(nearbyMosquesProvider);
    final radius = ref.watch(mosqueRadiusProvider);

    return Column(
      children: [
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            children: [
              for (final meters in [2000, 5000, 10000, 25000])
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.xs),
                  child: GestureDetector(
                    onTap: () =>
                        ref.read(mosqueRadiusProvider.notifier).set(meters),
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: radius == meters
                            ? colors.darkGreen
                            : colors.cardBg,
                        borderRadius: AppRadius.circularXl,
                      ),
                      child: Text(
                        '${meters ~/ 1000} km',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: radius == meters
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: radius == meters
                              ? Colors.white
                              : colors.textDark,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: switch (mosquesAsync) {
            AsyncLoading() => Center(
                child: CircularProgressIndicator(color: colors.primaryGreen),
              ),
            AsyncError(:final error) => _ErrorState(
                message: error.toString().replaceFirst('Exception: ', ''),
                onRetry: () => ref.invalidate(nearbyMosquesProvider),
              ),
            AsyncData(:final value) => value.isEmpty
                ? _EmptyState(radiusMeters: radius)
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
                      return _MosqueCard(mosque: value[i]);
                    },
                  ),
          },
        ),
      ],
    );
  }
}

class _MosqueCard extends StatelessWidget {
  final Mosque mosque;

  const _MosqueCard({required this.mosque});

  Future<void> _open(BuildContext context, Uri uri) async {
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Konnte nicht geöffnet werden.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final address = mosque.address;

    return Container(
      decoration: BoxDecoration(
        color: colors.cardBg,
        borderRadius: AppRadius.circularLg,
        boxShadow: AppShadows.sm,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.mosque, size: 22, color: colors.primaryGreen),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mosque.name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: colors.textDark,
                      ),
                    ),
                    if (address != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        address,
                        style: TextStyle(
                          fontSize: 13,
                          color: colors.textMuted,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: colors.accentGold.withValues(alpha: 0.15),
                  borderRadius: AppRadius.circularSm,
                ),
                child: Text(
                  mosque.formattedDistance,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: colors.accentGold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              _ActionButton(
                icon: Icons.directions_outlined,
                label: 'Route',
                onTap: () => _open(
                  context,
                  Uri.parse(
                    'geo:${mosque.lat},${mosque.lng}?q=${mosque.lat},${mosque.lng}'
                    '(${Uri.encodeComponent(mosque.name)})',
                  ),
                ),
              ),
              if (mosque.website != null)
                _ActionButton(
                  icon: Icons.language,
                  label: 'Website',
                  onTap: () => _open(context, Uri.parse(mosque.website!)),
                ),
              if (mosque.phone != null)
                _ActionButton(
                  icon: Icons.call_outlined,
                  label: 'Anrufen',
                  onTap: () => _open(
                    context,
                    Uri.parse('tel:${mosque.phone}'),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.xs),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: AppRadius.circularSm,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 15, color: colors.primaryGreen),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: colors.primaryGreen,
                ),
              ),
            ],
          ),
        ),
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
