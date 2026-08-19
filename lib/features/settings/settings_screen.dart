import 'dart:io';

import 'package:adhan_dart/adhan_dart.dart' as adhan;
import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/i18n/prayer_names.dart';
import '../../core/providers/providers.dart';
import '../../core/services/sync_service.dart';
import '../../core/services/auth_service.dart';
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
  AppLocalizations get l10n => AppLocalizations.of(context);

  static const _muezzinLabels = {
    MuezzinVoice.misharyAlafasy: 'Mishary Alafasy',
    MuezzinVoice.makkahAdhan: 'Makkah Adhan',
    MuezzinVoice.silent: '',
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
          l10n.settingsTitle,
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
          _accountSection(),
          _prayerSection(),
          _notificationSection(),
          _appearanceSection(),
          _dataSection(),
          _legalSection(),
          const SizedBox(height: AppSpacing.lg),
          Center(
            child: Text(
              _version.isEmpty ? '' : 'Munir $_version',
              style: TextStyle(fontSize: 12, color: colors.textMuted),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------- prayer

  /// Signing in is optional: the app works fully without it, an account only
  /// adds cross-device backup. Both stores require the deletion entry below
  /// to be reachable from inside the app.
  Widget _accountSection() {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (user) => SettingsSection(
        title: l10n.settingsSectionAccount,
        children: user == null
            ? [
                SettingsTile(
                  icon: Icons.login,
                  label: l10n.settingsSignInGoogle,
                  subtitle: l10n.settingsSignInWhy,
                  showDivider: false,
                  onTap: _signIn,
                ),
              ]
            : [
                SettingsTile(
                  icon: Icons.account_circle_outlined,
                  label: l10n.settingsSignedInAs(user.email ?? ''),
                  onTap: null,
                ),
                SettingsTile(
                  icon: Icons.sync,
                  label: l10n.settingsSyncNow,
                  onTap: () => _sync(user.uid),
                ),
                SettingsTile(
                  icon: Icons.logout,
                  label: l10n.settingsSignOut,
                  onTap: _signOut,
                ),
                SettingsTile(
                  icon: Icons.person_remove_outlined,
                  label: l10n.settingsDeleteAccount,
                  subtitle: l10n.settingsDeleteAccountHint,
                  destructive: true,
                  showDivider: false,
                  onTap: _deleteAccount,
                ),
              ],
      ),
    );
  }

  Future<void> _signIn() async {
    try {
      final user = await ref.read(authServiceProvider).signInWithGoogle();
      if (user == null) return; // dismissed, not an error
      // Pull first so a fresh device inherits what is already stored, then
      // push so the server learns about anything recorded offline.
      await ref.read(syncServiceProvider).pull(user.uid);
      await ref.read(syncServiceProvider).push(user.uid);
      if (mounted) _toast(l10n.settingsSyncDone);
    } catch (e, stack) {
      // Surfaced in debug builds: a silent failure here is impossible to
      // diagnose otherwise (missing Google account on the device, wrong
      // SHA-1 in the Firebase project, provider not enabled).
      debugPrint('Google sign-in failed: $e');
      debugPrintStack(stackTrace: stack);
      if (mounted) _toast(l10n.settingsSignInFailed);
    }
  }

  Future<void> _sync(String uid) async {
    try {
      await ref.read(syncServiceProvider).pull(uid);
      await ref.read(syncServiceProvider).push(uid);
      if (mounted) _toast(l10n.settingsSyncDone);
    } catch (e) {
      debugPrint('Sync failed: $e');
      if (mounted) _toast(l10n.settingsSignInFailed);
    }
  }

  Future<void> _signOut() async {
    await ref.read(authServiceProvider).signOut();
  }

  Future<void> _deleteAccount() async {
    final confirmed = await _confirm(
      l10n.settingsDeleteAccount,
      l10n.settingsDeleteAccountConfirm,
      l10n.commonDelete,
    );
    if (confirmed != true) return;

    try {
      await ref.read(authServiceProvider).deleteAccount();
      if (mounted) _toast(l10n.settingsAccountDeleted);
    } catch (_) {
      if (mounted) _toast(l10n.settingsSignInFailed);
    }
  }

  Widget _prayerSection() {
    final method = ref.watch(calculationMethodProvider);
    final madhab = ref.watch(madhabProvider);
    final city = switch (ref.watch(locationProvider)) {
      AsyncData(:final value) => value.city,
      AsyncError() => 'nicht verfügbar',
      _ => 'wird ermittelt …',
    };

    return SettingsSection(
      title: l10n.settingsSectionPrayer,
      children: [
        SettingsTile(
          icon: Icons.place_outlined,
          label: l10n.settingsLocation,
          value: city,
          showDivider: false,
          onTap: () => ref.read(locationProvider.notifier).detectViaGps(),
          subtitle: l10n.settingsLocationHint,
        ),
        SettingsTile(
          icon: Icons.calculate_outlined,
          label: l10n.settingsCalculationMethod,
          value: method.shortLabel,
          onTap: () async {
            final picked = await showOptionPicker<adhan.CalculationMethod>(
              context: context,
              title: l10n.settingsCalculationMethod,
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
          label: l10n.settingsMadhab,
          value: madhab == adhan.Madhab.hanafi ? 'Hanafi' : 'Shafi',
          onTap: () async {
            final picked = await showOptionPicker<adhan.Madhab>(
              context: context,
              title: l10n.settingsMadhab,
              current: madhab,
              options: [
                (
                  value: adhan.Madhab.shafi,
                  label: 'Shafi',
                  subtitle: l10n.settingsMadhabShafiHint,
                ),
                (
                  value: adhan.Madhab.hanafi,
                  label: 'Hanafi',
                  subtitle: l10n.settingsMadhabHanafiHint,
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
      title: l10n.settingsNotifications,
      children: [
        SettingsTile(
          icon: Icons.notifications_outlined,
          label: l10n.settingsNotifications,
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
              label: localizedPrayerName(l10n, p.name),
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
          label: l10n.settingsAdhanVoice,
          value: _muezzinLabels[voice],
          onTap: () async {
            final picked = await showOptionPicker<MuezzinVoice>(
              context: context,
              title: l10n.settingsAdhanVoice,
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
      title: l10n.settingsSectionDisplay,
      children: [
        SettingsTile(
          icon: Icons.person_outline,
          label: l10n.settingsName,
          value: name.isEmpty ? l10n.settingsNotConfigured : name,
          showDivider: false,
          onTap: _editName,
        ),
        SettingsTile(
          icon: Icons.language_outlined,
          label: l10n.settingsLanguage,
          value: languageDisplayNames[language] ?? language,
          onTap: () async {
            final picked = await showOptionPicker<String>(
              context: context,
              title: l10n.settingsLanguage,
              current: language,
              options: [
                for (final code in supportedLanguageCodes)
                  (
                    value: code,
                    label: languageDisplayNames[code]!,
                    subtitle: null,
                  ),
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
        title: Text(l10n.settingsName),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(hintText: 'Dein Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop(controller.text.trim()),
            child: Text(l10n.commonSave),
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
      title: l10n.settingsSectionData,
      children: [
        SettingsTile(
          icon: Icons.travel_explore_outlined,
          label: l10n.settingsMosqueConsent,
          subtitle: l10n.settingsMosqueConsentHint,
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
          label: l10n.settingsClearMapCache,
          subtitle: l10n.settingsClearMapCacheHint,
          onTap: _clearMapCache,
        ),
        SettingsTile(
          icon: Icons.restart_alt,
          label: l10n.settingsResetTracker,
          subtitle: l10n.settingsResetTrackerHint,
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
    _toast(l10n.settingsClearMapCacheDone);
  }

  /// Shared confirmation for destructive actions. The reset dialog used to
  /// carry its own hardcoded German text.
  Future<bool?> _confirm(String title, String message, String confirmLabel) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.of(context).background,
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              confirmLabel,
              style: const TextStyle(color: Color(0xFFB3261E)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _resetTracker() async {
    final confirmed = await _confirm(
      l10n.settingsResetTracker,
      l10n.settingsResetTrackerConfirm,
      l10n.commonReset,
    );

    if (confirmed != true) return;
    await ref.read(prayerTrackerProvider.notifier).resetAll();
    if (!mounted) return;
    _toast(l10n.settingsResetTrackerDone);
  }

  // ----------------------------------------------------------------- legal

  Widget _legalSection() {
    return SettingsSection(
      title: l10n.settingsSectionLegal,
      children: [
        SettingsTile(
          icon: Icons.privacy_tip_outlined,
          label: l10n.settingsPrivacy,
          showDivider: false,
          // Both stores require this before release; the URL does not exist
          // yet, so say so rather than opening a dead link.
          onTap: () => _toast(l10n.settingsNotConfigured),
        ),
        SettingsTile(
          icon: Icons.info_outline,
          label: l10n.settingsImprint,
          onTap: () => _toast(l10n.settingsNotConfigured),
        ),
        SettingsTile(
          icon: Icons.source_outlined,
          label: l10n.settingsDataSources,
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
