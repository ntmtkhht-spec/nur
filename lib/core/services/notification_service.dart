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

  /// How long before the next prayer the catch-up reminder goes out.
  static const catchUpLeadTime = Duration(minutes: 30);

  /// Order the five obligatory prayers run in, used to build stable ids.
  static const _prayerOrder = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

  /// Keeps catch-up ids clear of the prayer-time ones.
  static const _catchUpIdOffset = 100000000;

  /// A notification id that can be recomputed later from the same day and
  /// prayer.
  ///
  /// Sequential ids would do for scheduling, but a catch-up reminder has to
  /// be cancellable the moment its prayer is ticked off, and that happens
  /// far away from the loop that created it.
  static int notificationId(
    DateTime day,
    String prayerName, {
    required bool catchUp,
  }) {
    // Built straight from the calendar date rather than a day count: an
    // elapsed-days figure loses an hour at each daylight-saving change, and
    // two calendar days then round to the same number — which handed two
    // prayers the same id and let one silently replace the other.
    final dayNumber = (day.year * 100 + day.month) * 100 + day.day;
    final prayerIndex = _prayerOrder.indexOf(prayerName);
    final base = dayNumber * 10 + (prayerIndex < 0 ? 9 : prayerIndex);
    return catchUp ? base + _catchUpIdOffset : base;
  }

  /// Drops the catch-up reminder for one prayer.
  ///
  /// Called when the prayer is ticked off: the reminder was scheduled ahead
  /// of time and cannot re-check that on its own when it fires.
  static Future<void> cancelCatchUp(DateTime day, String prayerName) async {
    await _ensureInitialized();
    await _plugin.cancel(
      id: notificationId(day, prayerName, catchUp: true),
    );
  }

  static Future<void> _ensureInitialized() async {
    if (_initialized) return;
    tzdata.initializeTimeZones();
    tz.setLocalLocation(tz.local);

    // Not the launcher icon: Android builds the small notification icon from
    // the alpha channel alone and paints it in one colour, so a full-colour
    // launcher icon arrives as a featureless blob. ic_notification is the
    // arch drawn as a white silhouette for exactly this.
    const androidSettings = AndroidInitializationSettings(
      '@drawable/ic_notification',
    );
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
    bool catchUpEnabled = true,
    // Lets the catch-up reminder skip a prayer that is already ticked off.
    // Passed as a predicate so this stays clear of how the tracker stores
    // its entries.
    bool Function(DateTime day, String prayerName)? isPrayerLogged,
    // The place the times were calculated for. Shown on every reminder so a
    // stale or wrong location is visible in the notification itself rather
    // than only after opening the app and wondering why Asr felt early.
    String? city,
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
        // Tints the silhouette and the surrounding dot in the app's green
        // rather than the system default, so the reminder is recognisable
        // in a crowded notification shade.
        color: Color(0xFF16402D),
        colorized: false,
      ),
      iOS: const DarwinNotificationDetails(),
    );

    final catchUpDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        // Its own channel so it can be silenced from the system settings
        // without losing the prayer times themselves.
        'adhan_catchup_channel',
        l10n.notificationCatchUpChannelName,
        channelDescription: l10n.notificationCatchUpChannelDescription,
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        color: Color(0xFF16402D),
        colorized: false,
      ),
      iOS: const DarwinNotificationDetails(),
    );

    final now = DateTime.now();
    final obligatory = prayers.where((p) => p.isPrayer).toList();

    for (var i = 0; i < obligatory.length; i++) {
      final prayer = obligatory[i];
      final enabled =
          enabledPrayers == null || enabledPrayers.contains(prayer.name);

      if (enabled && prayer.time.isAfter(now)) {
        await _plugin.zonedSchedule(
          id: notificationId(prayer.time, prayer.name, catchUp: false),
          scheduledDate: tz.TZDateTime.from(prayer.time, tz.local),
          title: l10n.notificationPrayerTimeTitle(
            localizedPrayerName(l10n, prayer.name),
            prayer.formattedTime,
          ),
          body: _withLocation(l10n, _bodyFor(l10n, prayer.name), city),
          notificationDetails: details,
          androidScheduleMode: scheduleMode,
        );
      }

      if (!catchUpEnabled) continue;
      // Isha is left out on purpose: the next prayer is the following
      // morning's Fajr, so this would fire in the middle of the night.
      if (prayer.name == 'Isha') continue;
      // Someone who silenced this prayer does not want to be asked about it
      // half an hour later either.
      if (!enabled) continue;
      if (i + 1 >= obligatory.length) continue;
      if (isPrayerLogged?.call(prayer.time, prayer.name) ?? false) continue;

      final next = obligatory[i + 1];
      final catchUpAt = next.time.subtract(catchUpLeadTime);
      // Nothing to remind about once the window has already closed.
      if (!catchUpAt.isAfter(now)) continue;
      if (!catchUpAt.isAfter(prayer.time)) continue;

      await _plugin.zonedSchedule(
        id: notificationId(prayer.time, prayer.name, catchUp: true),
        scheduledDate: tz.TZDateTime.from(catchUpAt, tz.local),
        title: l10n.notificationCatchUpTitle(
          localizedPrayerName(l10n, prayer.name),
        ),
        body: _withLocation(
          l10n,
          l10n.notificationCatchUpBody(
            localizedPrayerName(l10n, next.name),
            next.formattedTime,
          ),
          city,
        ),
        notificationDetails: catchUpDetails,
        androidScheduleMode: scheduleMode,
      );
    }
  }

  /// Appends the place the times were calculated for, when one is known.
  ///
  /// A blank line keeps it readable as a footnote rather than running it into
  /// the reminder's own sentence.
  static String _withLocation(
    AppLocalizations l10n,
    String body,
    String? city,
  ) {
    if (city == null || city.isEmpty) return body;
    return '$body\n\n${l10n.notificationLocationLine(city)}';
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
