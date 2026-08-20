import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../../l10n/app_localizations.dart';
import '../i18n/prayer_names.dart';
import '../models/prayer.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> _ensureInitialized() async {
    if (_initialized) return;
    tzdata.initializeTimeZones();
    tz.setLocalLocation(tz.local);

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
    );
    _initialized = true;
  }

  static Future<bool> requestPermission() async {
    await _ensureInitialized();

    final androidImpl = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidImpl != null) {
      final granted = await androidImpl.requestNotificationsPermission();
      return granted ?? false;
    }

    final iosImpl = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (iosImpl != null) {
      final granted = await iosImpl.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return true;
  }

  /// Requests Android's "exact alarms" access (Settings > Alarms &
  /// reminders on API 33+). Prayer reminders are time-sensitive — scheduled
  /// without this, Doze can push them minutes to hours late, which is why
  /// notifications felt unreliable. A no-op once granted, and on iOS /
  /// older Android where it isn't needed. Best called right after
  /// [requestPermission] succeeds, while the user is already in a
  /// "set up notifications" moment.
  static Future<void> requestExactAlarmPermission() async {
    await _ensureInitialized();
    final androidImpl = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidImpl == null) return;
    final can = await androidImpl.canScheduleExactNotifications();
    if (can != true) {
      await androidImpl.requestExactAlarmsPermission();
    }
  }

  /// Schedules every entry in [prayers] that is still ahead of now, across
  /// however many days it spans. Callers pass a multi-day window (see
  /// `notificationSchedulerProvider`) rather than just today: with only a
  /// single day scheduled, reminders went silent for good the first day the
  /// app wasn't opened, since nothing ever re-armed tomorrow's alarms.
  ///
  /// [languageCode] picks the texts; notifications are scheduled from
  /// background code where no BuildContext exists, so localizations are
  /// loaded directly instead of being read off the widget tree.
  static Future<void> scheduleMany(
    List<PrayerTime> prayers, {
    String languageCode = 'de',
    // Null means "all prayers" — the per-prayer settings toggle was never
    // wired to scheduling before, so it silently did nothing.
    Set<String>? enabledPrayers,
  }) async {
    await _ensureInitialized();
    final l10n = await AppLocalizations.delegate.load(Locale(languageCode));
    await _plugin.cancelAll();

    final androidImpl = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final canExact = androidImpl == null
        ? true
        : (await androidImpl.canScheduleExactNotifications() ?? false);
    // Falls back to inexact rather than failing outright when the user
    // hasn't granted exact-alarm access — late reminders still beat none.
    final scheduleMode = canExact
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        'adhan_channel',
        l10n.notificationChannelName,
        channelDescription: l10n.notificationChannelDescription,
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: const DarwinNotificationDetails(),
    );

    final now = DateTime.now();
    var id = 0;

    for (final prayer in prayers) {
      if (!prayer.isPrayer) continue;
      if (prayer.time.isBefore(now)) continue;
      if (enabledPrayers != null && !enabledPrayers.contains(prayer.name)) {
        continue;
      }

      await _plugin.zonedSchedule(
        id: id++,
        scheduledDate: tz.TZDateTime.from(prayer.time, tz.local),
        title: l10n.notificationPrayerTimeTitle(
          localizedPrayerName(l10n, prayer.name),
        ),
        body: _bodyFor(l10n, prayer.name),
        notificationDetails: details,
        androidScheduleMode: scheduleMode,
      );
    }
  }

  static String _bodyFor(AppLocalizations l10n, String prayerKey) {
    return switch (prayerKey) {
      'Fajr' => l10n.notificationBodyFajr,
      'Dhuhr' => l10n.notificationBodyDhuhr,
      'Asr' => l10n.notificationBodyAsr,
      'Maghrib' => l10n.notificationBodyMaghrib,
      'Isha' => l10n.notificationBodyIsha,
      _ => l10n.notificationBodyFajr,
    };
  }

  static Future<void> cancelAll() async {
    await _ensureInitialized();
    await _plugin.cancelAll();
  }
}
