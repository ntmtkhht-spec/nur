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

  /// [languageCode] picks the texts; notifications are scheduled from
  /// background code where no BuildContext exists, so localizations are
  /// loaded directly instead of being read off the widget tree.
  static Future<void> scheduleTodaysPrayers(
    List<PrayerTime> prayers, {
    String languageCode = 'de',
  }) async {
    await _ensureInitialized();
    final l10n = await AppLocalizations.delegate.load(Locale(languageCode));
    await _plugin.cancelAll();

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

    for (var i = 0; i < prayers.length; i++) {
      final prayer = prayers[i];
      if (prayer.time.isBefore(now)) continue;

      final scheduled = tz.TZDateTime.from(prayer.time, tz.local);

      await _plugin.zonedSchedule(
        id: i,
        scheduledDate: scheduled,
        title: l10n.notificationPrayerTimeTitle(
          localizedPrayerName(l10n, prayer.name),
        ),
        body: l10n.notificationPrayerTimeBody,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }

  static Future<void> cancelAll() async {
    await _ensureInitialized();
    await _plugin.cancelAll();
  }
}
