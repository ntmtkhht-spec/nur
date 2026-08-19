import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';

import '../../../core/providers/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../onboarding_state.dart';
import '../widgets/hero_badge.dart';
import '../widgets/onboarding_scaffold.dart';
import '../widgets/ornament_divider.dart';

class LocationScreen extends ConsumerStatefulWidget {
  final int stepIndex;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const LocationScreen({
    super.key,
    required this.stepIndex,
    required this.onNext,
    required this.onSkip,
  });

  @override
  ConsumerState<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends ConsumerState<LocationScreen> {
  final _searchController = TextEditingController();
  bool _isDetecting = false;
  bool _isSearching = false;
  String? _errorText;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _detectGps() async {
    setState(() {
      _isDetecting = true;
      _errorText = null;
    });

    try {
      final data = await ref.read(locationProvider.notifier).detectViaGps();
      ref.read(onboardingProvider.notifier).setLocation(
            city: data.city,
            lat: data.lat,
            lng: data.lng,
          );
    } catch (e) {
      setState(() => _errorText = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isDetecting = false);
    }
  }

  Future<void> _searchCity() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isSearching = true;
      _errorText = null;
    });

    final l10n = AppLocalizations.of(context);
    try {
      final results = await Geocoding().locationFromAddress(query);
      if (results.isEmpty) {
        setState(() => _errorText = l10n.onboardingLocationNotFound);
        return;
      }
      final result = results.first;
      ref.read(onboardingProvider.notifier).setLocation(
            city: query,
            lat: result.latitude,
            lng: result.longitude,
          );
    } catch (_) {
      setState(() => _errorText = 'Suche fehlgeschlagen. Prüfe deine Verbindung.');
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final data = ref.watch(onboardingProvider);
    final hasLocation = data.hasLocation;

    return OnboardingScaffold(
      currentStep: widget.stepIndex,
      onNext: widget.onNext,
      onSkip: widget.onSkip,
      buttonLabel: hasLocation ? 'Weiter' : l10n.onboardingLocationSkip,
      children: [
        SizedBox(height: 12),
        const HeroBadge(icon: Icons.location_on_outlined, size: 170),
        const SizedBox(height: 28),
        Text(
          hasLocation
              ? l10n.onboardingLocationDetected(data.city ?? '')
              : l10n.onboardingLocationQuestion,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.onboardingLocationWhy,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, color: AppColors.textMuted, height: 1.4),
        ),
        const SizedBox(height: 12),
        const OrnamentDivider(),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: _isDetecting ? null : _detectGps,
            icon: _isDetecting
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.white,
                    ),
                  )
                : const Icon(Icons.my_location, size: 20),
            label: Text(_isDetecting ? 'Suche Standort…' : l10n.onboardingLocationDetect),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.darkGreen,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: Divider(color: AppColors.textMuted.withValues(alpha: 0.3))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(l10n.commonOr,
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
            ),
            Expanded(child: Divider(color: AppColors.textMuted.withValues(alpha: 0.3))),
          ],
        ),
        SizedBox(height: 16),
        TextField(
          controller: _searchController,
          onSubmitted: (_) => _searchCity(),
          decoration: InputDecoration(
            hintText: l10n.onboardingLocationSearch,
            prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
            suffixIcon: _isSearching
                ? const Padding(
                    padding: EdgeInsets.all(14),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.arrow_forward, color: AppColors.darkGreen),
                    onPressed: _searchCity,
                  ),
            filled: true,
            fillColor: AppColors.cardBg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        if (_errorText != null) ...[
          const SizedBox(height: 10),
          Text(
            _errorText!,
            style: const TextStyle(color: Colors.redAccent, fontSize: 13),
          ),
        ],
        const SizedBox(height: 20),
        // Deliberately not "verlässt niemals dein Gerät": the mosque finder
        // does send coordinates to OpenStreetMap, and it asks separately
        // before doing so. Promising more than the app delivers would be a lie
        // in exactly the place users check for one.
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 2),
              child: Icon(Icons.lock_outline,
                  size: 14, color: AppColors.textMuted),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                l10n.onboardingLocationPrivacy,
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted, height: 1.4),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
