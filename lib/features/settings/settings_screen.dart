import 'dart:io';

import 'package:adhan_dart/adhan_dart.dart' as adhan;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/providers/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/prayer_icons.dart';
import '../../core/theme/app_tokens.dart';
import '../mosques/providers/mosques_provider.dart';
import 'widgets/option_picker.dart';
import 'widgets/settings_tile.dart';

/// Every app-wide setting in one place, reachable from the gear icon on the
/// home screen.
///
/// The account section is deliberately absent until sign-in actually exists —
/// see docs/plan-login-und-einstellungen.md. A button that does nothing is
/// worse than no button.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  static const _muezzinLabels = {
    MuezzinVoice.misharyAlafasy: 'Mishary Alafasy',
    MuezzinVoice.makkahAdhan: 'Makkah Adhan',
    MuezzinVoice.silent: 'Nur Vibration / stumm',
  };

  /// Methods worth offering. The package knows more, but a list of thirty
  /// entries helps nobody pick the right one.
  static const _methods = [
    adhan.CalculationMethod.muslimWorldLeague,
    adhan.CalculationMethod.turkiye,
    adhan.CalculationMethod.egyptian,
    adhan.CalculationMethod.karachi,
    adhan.CalculationMethod.ummAlQura,
    adhan.CalculationMethod.northAmerica,
    adhan.CalculationMethod.dubai,
    adhan.CalculationMethod.qatar,
    adhan.CalculationMethod.kuwait,
    adhan.CalculationMethod.singapore,
    adhan.CalculationMethod.france,
    adhan.CalculationMethod.moonsightingCommittee,
  ];

  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() => _version = '${info.version} (${info.buildNumber})');
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(
          'Einstellungen',
          style: TextStyle(color: colors.textDark, fontWeight: FontWeight.bold),
        ),
        backgroundColor: colors.background,
        iconTheme: IconThemeData(color: colors.primaryGreen),
        elevation: 0,
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
        children: [
          _prayerSection(),
          _notificationSection(),
          _appearanceSection(),
          _dataSection(),
          _legalSection(),
          const SizedBox(height: AppSpacing.lg),
          Center(
            child: Text(
              _version.isEmpty ? '' : 'Nur App $_version',
              style: TextStyle(fontSize: 12, color: colors.textMuted),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------- prayer

  Widget _prayerSection() {
    final method = ref.watch(calculationMethodProvider);
    final madhab = ref.watch(madhabProvider);
    final city = switch (ref.watch(locationProvider)) {
      AsyncData(:final value) => value.city,
      AsyncError() => 'nicht verfügbar',
      _ => 'wird ermittelt …',
    };

    return SettingsSection(
      title: 'Gebet',
      children: [
        SettingsTile(
          icon: Icons.place_outlined,
          label: 'Standort',
          value: city,
          showDivider: false,
          onTap: () => ref.read(locationProvider.notifier).detectViaGps(),
          subtitle: 'Tippen, um neu zu bestimmen',
        ),
        SettingsTile(
          icon: Icons.calculate_outlined,
          label: 'Berechnungsmethode',
          value: method.shortLabel,
          onTap: () async {
            final picked = await showOptionPicker<adhan.CalculationMethod>(
              context: context,
              title: 'Berechnungsmethode',
              current: method,
              options: [
                for (final m in _methods)
                  (value: m, label: m.shortLabel, subtitle: null),
              ],
            );
            if (picked != null) {
              ref.read(calculationMethodProvider.notifier).update(picked);
            }
          },
        ),
        SettingsTile(
          icon: Icons.balance_outlined,
          label: 'Rechtsschule',
          value: madhab == adhan.Madhab.hanafi ? 'Hanafi' : 'Shafi',
          onTap: () async {
            final picked = await showOptionPicker<adhan.Madhab>(
              context: context,
              title: 'Rechtsschule',
              current: madhab,
              options: const [
                (
                  value: adhan.Madhab.shafi,
                  label: 'Shafi',
                  subtitle: 'Auch Maliki und Hanbali — früheres Asr',
                ),
                (
                  value: adhan.Madhab.hanafi,
                  label: 'Hanafi',
                  subtitle: 'Späteres Asr',
                ),
              ],
            );
            if (picked != null) {
              ref.read(madhabProvider.notifier).update(picked);
            }
          },
        ),
      ],
    );
  }

  // --------------------------------------------------------- notifications

  Widget _notificationSection() {
    final enabled = ref.watch(notificationsEnabledProvider);
    final perPrayer = ref.watch(prayerNotificationsProvider);
    final voice = ref.watch(muezzinVoiceProvider);
    final prayers =
        ref.watch(prayerTimesProvider).where((p) => p.isPrayer).toList();

    return SettingsSection(
      title: 'Benachrichtigungen',
      children: [
        SettingsTile(
          icon: Icons.notifications_outlined,
          label: 'Benachrichtigungen',
          showDivider: false,
          trailing: Switch(
            value: enabled,
            onChanged: (v) =>
                ref.read(notificationsEnabledProvider.notifier).set(v),
          ),
        ),
        // Per-prayer switches only matter while the master switch is on.
        if (enabled)
          for (final p in prayers)
            SettingsTile(
              icon: prayerIcons[p.name] ?? fallbackPrayerIcon,
              label: p.name,
              subtitle: p.arabicName,
              trailing: Switch(
                value: perPrayer.contains(p.name),
                onChanged: (_) => ref
                    .read(prayerNotificationsProvider.notifier)
                    .toggle(p.name),
              ),
            ),
        SettingsTile(
          icon: Icons.volume_up_outlined,
          label: 'Adhan-Stimme',
          value: _muezzinLabels[voice],
          onTap: () async {
            final picked = await showOptionPicker<MuezzinVoice>(
              context: context,
              title: 'Adhan-Stimme',
              current: voice,
              options: [
                for (final v in MuezzinVoice.values)
                  (value: v, label: _muezzinLabels[v]!, subtitle: null),
              ],
            );
            if (picked != null) {
              ref.read(muezzinVoiceProvider.notifier).update(picked);
            }
          },
        ),
      ],
    );
  }

  // ------------------------------------------------------------ appearance

  Widget _appearanceSection() {
    final name = ref.watch(userNameProvider);
    final language = ref.watch(appLanguageProvider);

    return SettingsSection(
      title: 'Darstellung',
      children: [
        SettingsTile(
          icon: Icons.person_outline,
          label: 'Name',
          value: name.isEmpty ? 'nicht gesetzt' : name,
          showDivider: false,
          onTap: _editName,
        ),
        SettingsTile(
          icon: Icons.language_outlined,
          label: 'Sprache',
          value: language,
          // Honest about the state of things: only part of the app follows
          // this today, see lib/core/i18n/app_strings.dart.
          subtitle: 'Bisher nur teilweise übersetzt',
          onTap: () async {
            final picked = await showOptionPicker<String>(
              context: context,
              title: 'Sprache',
              current: language,
              options: const [
                (value: 'Deutsch', label: 'Deutsch', subtitle: null),
                (value: 'English', label: 'English', subtitle: null),
                (value: 'Türkçe', label: 'Türkçe', subtitle: null),
                (value: 'العربية', label: 'العربية', subtitle: null),
              ],
            );
            if (picked != null) {
              ref.read(appLanguageProvider.notifier).update(picked);
            }
          },
        ),
      ],
    );
  }

  Future<void> _editName() async {
    final controller = TextEditingController(text: ref.read(userNameProvider));
    final colors = AppColors.of(context);

    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.background,
        title: const Text('Name'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(hintText: 'Dein Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Speichern'),
          ),
        ],
      ),
    );

    if (name != null) {
      ref.read(userNameProvider.notifier).update(name);
    }
  }

  // ------------------------------------------------------------------ data

  Widget _dataSection() {
    final consent = ref.watch(mosqueSearchConsentProvider);

    return SettingsSection(
      title: 'Daten',
      children: [
        SettingsTile(
          icon: Icons.travel_explore_outlined,
          label: 'Moscheesuche erlauben',
          subtitle: 'Sendet deine Koordinaten an OpenStreetMap',
          showDivider: false,
          trailing: Switch(
            value: consent,
            onChanged: (v) {
              final notifier = ref.read(mosqueSearchConsentProvider.notifier);
              if (v) {
                notifier.grant();
              } else {
                notifier.revoke();
              }
            },
          ),
        ),
        SettingsTile(
          icon: Icons.map_outlined,
          label: 'Kartenspeicher leeren',
          subtitle: 'Gespeicherte Kartenkacheln entfernen',
          onTap: _clearMapCache,
        ),
        SettingsTile(
          icon: Icons.restart_alt,
          label: 'Gebets-Verlauf zurücksetzen',
          subtitle: 'Löscht alle abgehakten Gebete und die Serie',
          destructive: true,
          onTap: _resetTracker,
        ),
      ],
    );
  }

  Future<void> _clearMapCache() async {
    final dir = Directory('${(await getTemporaryDirectory()).path}/map_tiles');
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
    if (!mounted) return;
    _toast('Kartenspeicher geleert.');
  }

  Future<void> _resetTracker() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.of(context).background,
        title: const Text('Verlauf zurücksetzen?'),
        content: const Text(
          'Alle abgehakten Gebete und deine Serie werden gelöscht. '
          'Das lässt sich nicht rückgängig machen.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Löschen',
              style: TextStyle(color: Color(0xFFB3261E)),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    await ref.read(prayerTrackerProvider.notifier).resetAll();
    if (!mounted) return;
    _toast('Verlauf zurückgesetzt.');
  }

  // ----------------------------------------------------------------- legal

  Widget _legalSection() {
    return SettingsSection(
      title: 'Rechtliches',
      children: [
        SettingsTile(
          icon: Icons.privacy_tip_outlined,
          label: 'Datenschutzerklärung',
          showDivider: false,
          // Both stores require this before release; the URL does not exist
          // yet, so say so rather than opening a dead link.
          onTap: () => _toast('Noch nicht hinterlegt.'),
        ),
        SettingsTile(
          icon: Icons.info_outline,
          label: 'Impressum',
          onTap: () => _toast('Noch nicht hinterlegt.'),
        ),
        SettingsTile(
          icon: Icons.source_outlined,
          label: 'Datenquellen',
          subtitle: 'OpenStreetMap, CARTO, alquran.cloud',
          onTap: () => launchUrl(
            Uri.parse('https://www.openstreetmap.org/copyright'),
            mode: LaunchMode.externalApplication,
          ),
        ),
      ],
    );
  }
}
