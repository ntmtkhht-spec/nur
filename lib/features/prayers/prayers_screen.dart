import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/i18n/prayer_names.dart';
import '../../l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hijri/hijri_calendar.dart';

import '../../core/models/prayer.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';

class PrayersScreen extends ConsumerStatefulWidget {
  const PrayersScreen({super.key});

  @override
  ConsumerState<PrayersScreen> createState() => _PrayersScreenState();
}

class _PrayersScreenState extends ConsumerState<PrayersScreen> {
  DateTime _selectedDate = DateTime.now();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Half a minute, not a second: the only thing that changes by the second
    // is the countdown, and that ticks inside [_CountdownDial] where the
    // rebuild costs one text and one arc. This timer exists for the slower
    // change — a prayer's time arriving and the list moving on to the next
    // one — and rebuilding the whole page for that once every 30s is cheap.
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  bool get _isToday {
    final now = DateTime.now();
    return _selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day;
  }

  void _shiftDate(int days) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
    });
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryGreen,
              onPrimary: Colors.white,
              onSurface: AppColors.textDark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  int _computeActiveIndex(List<PrayerTime> prayers) {
    final now = DateTime.now();
    var lastPassed = -1;
    for (var i = 0; i < prayers.length; i++) {
      if (!prayers[i].isPrayer) continue;
      if (prayers[i].time.isBefore(now)) lastPassed = i;
    }
    return lastPassed;
  }

  ({PrayerTime prayer, Duration remaining, Duration totalDuration})?
  _computeNext(List<PrayerTime> prayers) {
    final now = DateTime.now();
    for (var i = 0; i < prayers.length; i++) {
      final p = prayers[i];
      if (!p.isPrayer) continue;
      if (p.time.isAfter(now)) {
        DateTime previousTime;
        if (i > 0) {
          previousTime = prayers.reversed
              .firstWhere(
                (x) => x.isPrayer && x.time.isBefore(p.time),
                orElse: () => prayers[0],
              )
              .time;
          if (previousTime == p.time || previousTime.isAfter(p.time)) {
            previousTime = now.subtract(const Duration(hours: 4)); // fallback
          }
        } else {
          previousTime = now.subtract(const Duration(hours: 4)); // fallback
        }
        final totalDuration = p.time.difference(previousTime);
        return (
          prayer: p,
          remaining: p.time.difference(now),
          totalDuration: totalDuration,
        );
      }
    }
    return null;
  }

  /// The first prayer of the following day, so the last row of the list can
  /// say where its window ends instead of trailing off at midnight.
  DateTime? _nextDayFirstPrayer() {
    final tomorrow = ref.read(
      prayerTimesForDateProvider(_selectedDate.add(const Duration(days: 1))),
    );
    for (final p in tomorrow) {
      if (p.isPrayer) return p.time;
    }
    return null;
  }

  /// Pairs every entry with the moment its window closes: the next entry of
  /// the day, and for the last one the next day's first prayer.
  List<({PrayerTime prayer, DateTime? end})> _withWindows(
    List<PrayerTime> entries,
  ) {
    return [
      for (var i = 0; i < entries.length; i++)
        (
          prayer: entries[i],
          end: i < entries.length - 1
              ? entries[i + 1].time
              : _nextDayFirstPrayer(),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final prayers = ref.watch(prayerTimesForDateProvider(_selectedDate));
    final notifications = ref.watch(prayerNotificationsProvider);
    final tracker = ref.watch(prayerTrackerProvider);
    final streak = ref.watch(currentStreakProvider);
    final longestStreak = ref.watch(longestStreakProvider);
    final city = ref
        .watch(locationProvider)
        .maybeWhen(data: (d) => d.resolvedCity, orElse: () => null);

    final activeIndex = _isToday ? _computeActiveIndex(prayers) : -1;
    final next = _isToday ? _computeNext(prayers) : null;

    // Only the six entries the list shows: the five prayers plus sunrise,
    // which is a marker rather than a prayer.
    final entries = prayers
        .where(
          (p) => p.isPrayer || p.name == 'Sunrise' || p.name == 'Sonnenaufgang',
        )
        .toList();

    // The active index counts across all times, the list only across these.
    var adjustedActiveIndex = -1;
    if (activeIndex >= 0 && activeIndex < prayers.length) {
      final activeName = prayers[activeIndex].name;
      adjustedActiveIndex = entries.indexWhere((p) => p.name == activeName);
    }

    final fajr = entries.where((p) => p.name == 'Fajr').firstOrNull;
    final maghrib = entries.where((p) => p.name == 'Maghrib').firstOrNull;

    // One scroll view over the whole page: the card, the day picker and the
    // list travel together, so nothing is pinned out of reach on a short
    // screen.
    return SingleChildScrollView(
      child: Column(
        children: [
          _PrayersHeader(
            title: l10n.prayerTimesTitle,
            city: city,
            next: next,
            fajr: fajr,
            maghrib: maghrib,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              0,
            ),
            child: _DateSelector(
              date: _selectedDate,
              isToday: _isToday,
              onPrev: () => _shiftDate(-1),
              onNext: () => _shiftDate(1),
              onPickDate: _pickDate,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.xxl,
            ),
            child: Column(
              children: [
                if (streak > 0) ...[
                  _StreakBanner(streak: streak, longestStreak: longestStreak),
                  const SizedBox(height: 16),
                ],
                _PrayersList(
                  entries: _withWindows(entries),
                  activeIndex: adjustedActiveIndex,
                  notifications: notifications,
                  tracker: tracker,
                  date: _selectedDate,
                  onToggleNotification: (name) => ref
                      .read(prayerNotificationsProvider.notifier)
                      .toggle(name),
                  onToggleTracker: (name) => ref
                      .read(prayerTrackerProvider.notifier)
                      .toggle(_selectedDate, name),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header
// ---------------------------------------------------------------------------

/// The dark panel at the top: title, day picker, countdown dial and the two
/// ends of the day.
class _PrayersHeader extends StatelessWidget {
  final String title;
  final String? city;
  final ({PrayerTime prayer, Duration remaining, Duration totalDuration})? next;
  final PrayerTime? fajr;
  final PrayerTime? maghrib;

  const _PrayersHeader({
    required this.title,
    required this.city,
    required this.next,
    required this.fajr,
    required this.maghrib,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final topInset = MediaQuery.of(context).padding.top;

    // A card with air around it, like the ones on the home screen, rather
    // than a panel bolted to the top edge.
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        topInset + AppSpacing.sm,
        AppSpacing.lg,
        0,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
        decoration: BoxDecoration(
          // Both stops come off the same brand green the dark cards on the home
          // screen use, one darkened, so the panel belongs to the app rather
          // than introducing a green of its own.
          gradient: LinearGradient(
            colors: [
              colors.darkGreen,
              Color.lerp(colors.darkGreen, Colors.black, 0.45)!,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: AppRadius.circularXl,
          boxShadow: AppShadows.md,
        ),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 0.2,
              ),
            ),
            if (next != null) ...[
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final width = min(290.0, constraints.maxWidth);
                  return _CountdownDial(
                    width: width,
                    next: next!,
                    city: city,
                    colors: colors,
                  );
                },
              ),
            ],
            if (fajr != null && maghrib != null) ...[
              const SizedBox(height: 18),
              _DayEdges(fajr: fajr!, maghrib: maghrib!),
            ],
          ],
        ),
      ),
    );
  }
}

/// Half-ring countdown around a filled dome, in the manner of a sun crossing
/// the horizon: the gold sweeps left to right as the window to the next
/// prayer runs out.
class _CountdownDial extends StatefulWidget {
  final double width;
  final ({PrayerTime prayer, Duration remaining, Duration totalDuration}) next;
  final String? city;
  final AppColorsExtension colors;

  const _CountdownDial({
    required this.width,
    required this.next,
    required this.city,
    required this.colors,
  });

  @override
  State<_CountdownDial> createState() => _CountdownDialState();
}

class _CountdownDialState extends State<_CountdownDial> {
  Timer? _tick;

  /// Counted down here rather than re-read from the page: the second hand
  /// belongs to this widget, so the list and the cards around it are not
  /// rebuilt on its account.
  late Duration _remaining;

  @override
  void initState() {
    super.initState();
    _remaining = widget.next.remaining;
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _remaining = _remaining - const Duration(seconds: 1);
        if (_remaining.isNegative) _remaining = Duration.zero;
      });
    });
  }

  @override
  void didUpdateWidget(_CountdownDial old) {
    super.didUpdateWidget(old);
    // The page recomputed the target — take its figure over the local count,
    // which drifts by up to a second and stops at the changeover.
    if (widget.next.prayer.time != old.next.prayer.time ||
        (widget.next.remaining - _remaining).abs() >
            const Duration(seconds: 2)) {
      _remaining = widget.next.remaining;
    }
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final width = widget.width;
    final next = widget.next;
    final city = widget.city;
    final colors = widget.colors;

    final hours = _remaining.inHours.toString().padLeft(2, '0');
    final minutes = (_remaining.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (_remaining.inSeconds % 60).toString().padLeft(2, '0');

    final timeStr = hours != '00'
        ? '$hours:$minutes:$seconds'
        : '$minutes:$seconds';

    double progress = next.totalDuration.inSeconds <= 0
        ? 0.0
        : 1.0 - (_remaining.inSeconds / next.totalDuration.inSeconds);
    if (progress < 0.0) progress = 0.0;
    if (progress > 1.0) progress = 1.0;

    return SizedBox(
      width: width,
      height: width / 2,
      child: Stack(
        children: [
          Positioned.fill(
            child: RepaintBoundary(
              child: CustomPaint(
                painter: _DialPainter(progress: progress, colors: colors),
              ),
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                width * 0.16,
                0,
                width * 0.16,
                width * 0.04,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    city ?? l10n.nextPrayer,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.75),
                    ),
                  ),
                  const SizedBox(height: 1),
                  // Scales down once the countdown grows an hours part: at a
                  // fixed size "01:50:23" is half again as wide as "50:23"
                  // and spills out of the dome.
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      timeStr,
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.05,
                        letterSpacing: -1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 1),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '${next.prayer.arabicName} · ${localizedPrayerName(l10n, next.prayer.name)}',
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.goldLight,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DialPainter extends CustomPainter {
  final double progress;
  final AppColorsExtension colors;

  _DialPainter({required this.progress, required this.colors});

  static const _stroke = 12.0;
  static const _gap = 13.0;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final rOuter = size.width / 2 - _stroke / 2;
    final rDome = rOuter - _stroke / 2 - _gap;

    final arcRect = Rect.fromCircle(center: center, radius: rOuter);

    final track = Paint()
      ..color = Colors.white.withValues(alpha: 0.10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = _stroke
      ..strokeCap = StrokeCap.round;

    final sweep = Paint()
      // Halfway to the light gold, not all the way: the full pale tone
      // bleaches the far end of the arc out against the panel.
      ..shader = LinearGradient(
        colors: [
          colors.accentGold,
          Color.lerp(colors.accentGold, colors.goldLight, 0.45)!,
        ],
      ).createShader(arcRect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = _stroke
      ..strokeCap = StrokeCap.round;

    // Laid down first, a hair wider and blurred: the ring's own edge comes out
    // hard, so this pass gives it something to fade into before the crisp
    // stroke goes on top.
    final sweepHalo = Paint()
      ..isAntiAlias = true
      ..shader = sweep.shader
      ..style = PaintingStyle.stroke
      ..strokeWidth = _stroke + 1.5
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.0);

    canvas.drawArc(arcRect, pi, pi, false, track);
    if (progress > 0) {
      canvas.drawArc(arcRect, pi, pi * progress, false, sweepHalo);
      canvas.drawArc(arcRect, pi, pi * progress, false, sweep);
    }

    final domeRect = Rect.fromCircle(center: center, radius: rDome);
    // The brand's mid green fading into the dark one: the same pair the
    // rest of the app is built from, so the dome reads as part of it.
    final domeGradient = LinearGradient(
      colors: [colors.primaryGreen, colors.darkGreen],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    final dome = Paint()
      ..isAntiAlias = true
      ..shader = domeGradient.createShader(domeRect);

    canvas.drawArc(domeRect, pi, pi, true, dome);

    // Traced over the fill in its own colour and blurred by half a pixel: a
    // filled arc leaves the curve one row of half-covered pixels wide, which
    // reads as a staircase where dome and panel are this close in tone. The
    // blurred stroke spreads that row over two, and the step disappears.
    final domeEdge = Paint()
      ..isAntiAlias = true
      ..shader = domeGradient.createShader(domeRect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.8);

    canvas.drawArc(domeRect, pi, pi, true, domeEdge);
  }

  @override
  bool shouldRepaint(covariant _DialPainter old) =>
      old.progress != progress || old.colors != colors;
}

/// Fajr and Maghrib, the two ends of the fasting day, on the header's floor.
class _DayEdges extends StatelessWidget {
  final PrayerTime fajr;
  final PrayerTime maghrib;

  const _DayEdges({required this.fajr, required this.maghrib});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Row(
      children: [
        Expanded(
          child: _edge(
            icon: Icons.wb_twilight,
            label: localizedPrayerName(l10n, fajr.name),
            time: fajr.formattedTime,
            iconFirst: true,
          ),
        ),
        Container(
          width: 1,
          height: 34,
          color: Colors.white.withValues(alpha: 0.12),
        ),
        Expanded(
          child: _edge(
            icon: CupertinoIcons.sunset,
            label: localizedPrayerName(l10n, maghrib.name),
            time: maghrib.formattedTime,
            iconFirst: false,
          ),
        ),
      ],
    );
  }

  Widget _edge({
    required IconData icon,
    required String label,
    required String time,
    required bool iconFirst,
  }) {
    final texts = Column(
      crossAxisAlignment: iconFirst
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
        Text(
          time,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ],
    );

    final glyph = Icon(icon, size: 26, color: AppColors.accentGold);

    return Row(
      mainAxisAlignment: iconFirst
          ? MainAxisAlignment.start
          : MainAxisAlignment.end,
      children: iconFirst
          ? [glyph, const SizedBox(width: 10), Flexible(child: texts)]
          : [Flexible(child: texts), const SizedBox(width: 10), glyph],
    );
  }
}

class _DateSelector extends StatelessWidget {
  final DateTime date;
  final bool isToday;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onPickDate;

  const _DateSelector({
    required this.date,
    required this.isToday,
    required this.onPrev,
    required this.onNext,
    required this.onPickDate,
  });

  static const _months = [
    'Jan.',
    'Feb.',
    'März',
    'Apr.',
    'Mai',
    'Jun.',
    'Jul.',
    'Aug.',
    'Sep.',
    'Okt.',
    'Nov.',
    'Dez.',
  ];

  @override
  Widget build(BuildContext context) {
    final label = isToday
        ? 'Heute, ${date.day}. ${_months[date.month - 1]}'
        : '${date.day}. ${_months[date.month - 1]}';

    final hijri = HijriCalendar.fromDate(date);
    final hijriLabel = '${hijri.hDay} ${hijri.longMonthName} ${hijri.hYear}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        // Same corner as the prayer cards below it, so the column reads as
        // one stack rather than a pill sitting on top of a list.
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.textMuted.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          _chevron(Icons.chevron_left, onPrev),
          Expanded(
            child: GestureDetector(
              onTap: onPickDate,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      hijriLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          _chevron(Icons.chevron_right, onNext),
        ],
      ),
    );
  }

  Widget _chevron(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primaryGreen.withValues(alpha: 0.08),
        ),
        child: Icon(icon, size: 18, color: AppColors.primaryGreen),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// List
// ---------------------------------------------------------------------------

class _PrayersList extends StatelessWidget {
  final List<({PrayerTime prayer, DateTime? end})> entries;
  final int activeIndex;
  final Set<String> notifications;
  final Map<String, bool> tracker;
  final DateTime date;
  final ValueChanged<String> onToggleNotification;
  final ValueChanged<String> onToggleTracker;

  const _PrayersList({
    required this.entries,
    required this.activeIndex,
    required this.notifications,
    required this.tracker,
    required this.date,
    required this.onToggleNotification,
    required this.onToggleTracker,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < entries.length; i++) ...[
          _PrayerRow(
            prayer: entries[i].prayer,
            end: entries[i].end,
            isActive: i == activeIndex,
            isPast: i < activeIndex,
            notificationOn: notifications.contains(entries[i].prayer.name),
            isCompleted:
                tracker['prayer_tracker_${date.year}_${date.month}_${date.day}_${entries[i].prayer.name}'] ??
                false,
            onToggleNotification: () =>
                onToggleNotification(entries[i].prayer.name),
            onToggleTracker: () => onToggleTracker(entries[i].prayer.name),
          ),
          if (i < entries.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _PrayerRow extends StatelessWidget {
  final PrayerTime prayer;
  final DateTime? end;
  final bool isActive;
  final bool isPast;
  final bool notificationOn;
  final bool isCompleted;
  final VoidCallback onToggleNotification;
  final VoidCallback onToggleTracker;

  const _PrayerRow({
    required this.prayer,
    required this.end,
    required this.isActive,
    required this.isPast,
    required this.notificationOn,
    required this.isCompleted,
    required this.onToggleNotification,
    required this.onToggleTracker,
  });

  IconData get _icon {
    return switch (prayer.name) {
      'Fajr' => Icons.wb_twilight,
      'Sunrise' || 'Sonnenaufgang' => Icons.wb_sunny_outlined,
      'Dhuhr' => Icons.wb_sunny,
      'Asr' => CupertinoIcons.cloud_sun,
      'Maghrib' => CupertinoIcons.sunset,
      'Isha' => Icons.nightlight_round,
      _ => Icons.access_time,
    };
  }

  /// "05:12 – 06:44": when the window opens and when the next one takes over.
  String _window() {
    if (end == null) return prayer.formattedTime;
    final h = end!.hour.toString().padLeft(2, '0');
    final m = end!.minute.toString().padLeft(2, '0');
    return '${prayer.formattedTime} – $h:$m';
  }

  /// Sunrise as a divider rather than a row of its own: nothing is due then,
  /// so it marks where the night's prayer ends and the day's begin instead of
  /// asking to be read as a task.
  Widget _marker(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final faint = AppColors.textMuted.withValues(alpha: 0.55);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(Icons.wb_sunny_outlined, size: 13, color: faint),
          const SizedBox(width: 6),
          Text(
            localizedPrayerName(l10n, prayer.name),
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: faint,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 1,
              color: AppColors.textMuted.withValues(alpha: 0.15),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            prayer.formattedTime,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: faint,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // Sunrise is a moment on the timeline, not a prayer: no window, no bell.
    final isMarker = !prayer.isPrayer;
    if (isMarker) return _marker(context);

    // A prayer already behind us recedes as a whole card. Done in colour
    // rather than with an Opacity widget: that one costs a saveLayer per row
    // on every frame the list is scrolled.
    final Color tileBg = isActive
        ? AppColors.accentGold.withValues(alpha: 0.16)
        : (isPast
              ? AppColors.textMuted.withValues(alpha: 0.05)
              : AppColors.primaryGreen.withValues(alpha: 0.08));
    final Color tileFg = isActive
        ? AppColors.accentGold
        : (isPast
              ? AppColors.textMuted.withValues(alpha: 0.35)
              : AppColors.primaryGreen);
    final Color titleColor = isPast
        ? AppColors.textMuted.withValues(alpha: 0.45)
        : AppColors.textDark;
    final Color detailColor = isPast
        ? AppColors.textMuted.withValues(alpha: 0.4)
        : AppColors.textMuted;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 12,
        vertical: isMarker ? 8 : 12,
      ),
      decoration: BoxDecoration(
        color: isPast ? Colors.white.withValues(alpha: 0.45) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive
              ? AppColors.accentGold.withValues(alpha: 0.55)
              : AppColors.textMuted.withValues(alpha: isPast ? 0.05 : 0.10),
          width: isActive ? 1.5 : 1,
        ),
        boxShadow: isPast || isMarker
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(color: tileBg, shape: BoxShape.circle),
            child: Icon(_icon, size: 22, color: tileFg),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        localizedPrayerName(l10n, prayer.name),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: isMarker ? 14 : 16,
                          fontWeight: isActive
                              ? FontWeight.w800
                              : FontWeight.w700,
                          color: isMarker ? AppColors.textMuted : titleColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      prayer.arabicName,
                      style: TextStyle(
                        fontSize: 13,
                        color: isPast
                            ? detailColor
                            : AppColors.textMuted.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  isMarker ? prayer.formattedTime : _window(),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: detailColor,
                  ),
                ),
              ],
            ),
          ),
          if (!isMarker)
            GestureDetector(
              onTap: isPast ? onToggleTracker : onToggleNotification,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                child: isPast
                    ? Icon(
                        isCompleted
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        size: 24,
                        color: isCompleted
                            ? AppColors.primaryGreen.withValues(alpha: 0.5)
                            : AppColors.textMuted.withValues(alpha: 0.25),
                      )
                    : Icon(
                        notificationOn
                            ? Icons.notifications_active
                            : Icons.notifications_none_outlined,
                        size: 24,
                        color: notificationOn
                            ? AppColors.primaryGreen
                            : AppColors.textMuted.withValues(alpha: 0.5),
                      ),
              ),
            )
          else
            const SizedBox(width: 12),
        ],
      ),
    );
  }
}

class _StreakBanner extends StatelessWidget {
  final int streak;
  final int longestStreak;

  const _StreakBanner({required this.streak, required this.longestStreak});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = AppColors.of(context);
    // Only worth showing once it says something the current streak doesn't:
    // while the user is on their best run the two numbers are identical.
    final showBest = longestStreak > streak;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colors.accentGold.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.accentGold.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Icon(Icons.local_fire_department, color: colors.accentGold, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.streakTitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: colors.textDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  l10n.streakDays(streak),
                  style: TextStyle(
                    fontSize: 16,
                    color: colors.primaryGreen,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          if (showBest)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: colors.accentGold.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                l10n.streakBest(longestStreak),
                style: TextStyle(
                  fontSize: 12,
                  color: colors.textDark,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
