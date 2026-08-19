import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/i18n/prayer_names.dart';
import '../../l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hijri/hijri_calendar.dart';

import '../../core/models/prayer.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/app_colors.dart';

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
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
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

  @override
  Widget build(BuildContext context) {
    final prayers = ref.watch(prayerTimesForDateProvider(_selectedDate));
    final notifications = ref.watch(prayerNotificationsProvider);
    final tracker = ref.watch(prayerTrackerProvider);
    final streak = ref.watch(prayerTrackerProvider.notifier).currentStreak;

    final activeIndex = _isToday ? _computeActiveIndex(prayers) : -1;
    final next = _isToday ? _computeNext(prayers) : null;

    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  if (next != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: _NextPrayerBanner(next: next),
                    ),

                  const SizedBox(height: 12),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: GestureDetector(
                      onTap: _pickDate,
                      child: _DateSelector(
                        date: _selectedDate,
                        isToday: _isToday,
                        onPrev: () => _shiftDate(-1),
                        onNext: () => _shiftDate(1),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (streak > 0) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: _StreakBanner(streak: streak),
                    ),
                    const SizedBox(height: 16),
                  ],

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: _PrayersList(
                      prayers: prayers,
                      activeIndex: activeIndex,
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
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _NextPrayerBanner extends StatelessWidget {
  final ({PrayerTime prayer, Duration remaining, Duration totalDuration}) next;

  const _NextPrayerBanner({required this.next});

  @override
  Widget build(BuildContext context) {
    final hours = next.remaining.inHours.toString().padLeft(2, '0');
    final minutes = (next.remaining.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (next.remaining.inSeconds % 60).toString().padLeft(2, '0');

    final timeStr = hours != '00'
        ? '$hours:$minutes:$seconds'
        : '$minutes:$seconds';

    double progress =
        1.0 - (next.remaining.inSeconds / next.totalDuration.inSeconds);
    if (progress < 0.0) progress = 0.0;
    if (progress > 1.0) progress = 1.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF11422B), Color(0xFF092115)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF092115).withValues(alpha: 0.4),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'NÄCHSTES GEBET',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.accentGold.withValues(alpha: 0.8),
              fontWeight: FontWeight.w700,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: 180,
            height: 180,
            child: Stack(
              fit: StackFit.expand,
              alignment: Alignment.center,
              children: [
                // Inner glowing background
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accentGold.withValues(alpha: 0.05),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                ),
                // Custom Progress Arc
                CustomPaint(painter: _PremiumArcPainter(progress: progress)),
                // Time Text Inside
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Scales down once the countdown grows an hours part:
                    // at a fixed 42pt "01:50:23" is half again as wide as
                    // "50:23" and spills out of the ring.
                    SizedBox(
                      width: 150,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          timeStr,
                          style: const TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1.0,
                            letterSpacing: -1,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${next.prayer.arabicName} - ${localizedPrayerName(AppLocalizations.of(context), next.prayer.name)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.accentGold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumArcPainter extends CustomPainter {
  final double progress;

  _PremiumArcPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;
    const strokeWidth = 8.0;

    // Track
    final paintBg = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Progress
    final paintFg = Paint()
      ..shader = const SweepGradient(
        colors: [AppColors.accentGold, Color(0xFFFFE082)],
        startAngle: -pi / 2,
        endAngle: 3 * pi / 2,
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromCircle(center: center, radius: radius);

    // Draw background circle
    canvas.drawArc(rect, -pi / 2, 2 * pi, false, paintBg);

    // Draw foreground arc
    canvas.drawArc(rect, -pi / 2, 2 * pi * progress, false, paintFg);
  }

  @override
  bool shouldRepaint(covariant _PremiumArcPainter old) =>
      old.progress != progress;
}

class _DateSelector extends StatelessWidget {
  final DateTime date;
  final bool isToday;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const _DateSelector({
    required this.date,
    required this.isToday,
    required this.onPrev,
    required this.onNext,
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

    return Row(
      children: [
        GestureDetector(
          onTap: onPrev,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.textMuted.withValues(alpha: 0.2),
              ),
            ),
            child: const Icon(
              Icons.chevron_left,
              size: 16,
              color: AppColors.textDark,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            '|',
            style: TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
        ),
        Text(
          hijriLabel,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: onNext,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.textMuted.withValues(alpha: 0.2),
              ),
            ),
            child: const Icon(
              Icons.chevron_right,
              size: 16,
              color: AppColors.textDark,
            ),
          ),
        ),
      ],
    );
  }
}

class _PrayersList extends StatelessWidget {
  final List<PrayerTime> prayers;
  final int activeIndex;
  final Set<String> notifications;
  final Map<String, bool> tracker;
  final DateTime date;
  final ValueChanged<String> onToggleNotification;
  final ValueChanged<String> onToggleTracker;

  const _PrayersList({
    required this.prayers,
    required this.activeIndex,
    required this.notifications,
    required this.tracker,
    required this.date,
    required this.onToggleNotification,
    required this.onToggleTracker,
  });

  @override
  Widget build(BuildContext context) {
    // Only use the 6 main prayers for the list
    final filteredPrayers = prayers
        .where(
          (p) => p.isPrayer || p.name == 'Sunrise' || p.name == 'Sonnenaufgang',
        )
        .toList();

    // adjust activeIndex for the filtered list
    int adjustedActiveIndex = -1;
    if (activeIndex >= 0 && activeIndex < prayers.length) {
      final activeName = prayers[activeIndex].name;
      adjustedActiveIndex = filteredPrayers.indexWhere(
        (p) => p.name == activeName,
      );
    }

    return IntrinsicHeight(
      child: Stack(
        children: [
          // Timeline Line
          Positioned(
            left: 20,
            top: 24,
            bottom: 24,
            child: Container(
              width: 1,
              color: AppColors.textMuted.withValues(alpha: 0.3),
            ),
          ),

          Column(
            children: [
              for (var i = 0; i < filteredPrayers.length; i++) ...[
                _PrayerRow(
                  prayer: filteredPrayers[i],
                  isActive: i == adjustedActiveIndex,
                  isPast: i < adjustedActiveIndex,
                  notificationOn: notifications.contains(
                    filteredPrayers[i].name,
                  ),
                  isCompleted:
                      tracker['prayer_tracker_${date.year}_${date.month}_${date.day}_${filteredPrayers[i].name}'] ??
                      false,
                  onToggleNotification: () =>
                      onToggleNotification(filteredPrayers[i].name),
                  onToggleTracker: () =>
                      onToggleTracker(filteredPrayers[i].name),
                ),
                if (i < filteredPrayers.length - 1) const SizedBox(height: 12),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _PrayerRow extends StatelessWidget {
  final PrayerTime prayer;
  final bool isActive;
  final bool isPast;
  final bool notificationOn;
  final bool isCompleted;
  final VoidCallback onToggleNotification;
  final VoidCallback onToggleTracker;

  const _PrayerRow({
    required this.prayer,
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
      'Sunrise' || 'Sonnenaufgang' => Icons.wb_sunny,
      'Dhuhr' => Icons.wb_sunny,
      'Asr' => Icons.wb_sunny,
      'Maghrib' => Icons.wb_twilight,
      'Isha' => Icons.nightlight_round,
      _ => Icons.access_time,
    };
  }

  @override
  Widget build(BuildContext context) {
    final bool canComplete = prayer.isPrayer;

    if (!canComplete) {
      return Row(
        children: [
          Container(
            width: 40,
            alignment: Alignment.center,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: AppColors.background,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.textMuted.withValues(alpha: 0.4),
                  width: 2,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.wb_sunny_outlined,
                    size: 16,
                    color: AppColors.textMuted.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    // Two shares, not one: "Sonnenaufgang" broke mid-word in
                    // an equal split.
                    flex: 2,
                    child: Text(
                      localizedPrayerName(
                        AppLocalizations.of(context),
                        prayer.name,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textMuted.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      prayer.arabicName,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textMuted.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      prayer.formattedTime,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textMuted.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 44,
                  ), // alignment offset for the bell/check icon area
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        // Timeline Node
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.darkGreen
                : (isPast ? const Color(0xFF9E9E9E) : Colors.white),
            shape: BoxShape.circle,
            border: !isActive && !isPast
                ? Border.all(color: AppColors.textMuted.withValues(alpha: 0.2))
                : null,
          ),
          child: Icon(
            _icon,
            size: 20,
            color: isActive
                ? AppColors.accentGold
                : (isPast ? Colors.white : AppColors.textMuted),
          ),
        ),
        const SizedBox(width: 16),

        // Prayer Card
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              // Three states, not two: a prayer already behind us is dimmed
              // so the list reads at a glance as done / now / still ahead.
              color: isActive
                  ? AppColors.darkGreen
                  : (isPast ? AppColors.background : Colors.white),
              borderRadius: BorderRadius.circular(16),
              boxShadow: !isActive && !isPast
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [],
              border: !isActive
                  ? Border.all(
                      color: AppColors.textMuted.withValues(
                        alpha: isPast ? 0.06 : 0.1,
                      ),
                    )
                  : null,
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    localizedPrayerName(
                      AppLocalizations.of(context),
                      prayer.name,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                      color: isActive
                          ? Colors.white
                          : (isPast ? AppColors.textMuted : AppColors.textDark),
                    ),
                  ),
                ),

                Expanded(
                  flex: 2,
                  child: Text(
                    prayer.arabicName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: isActive
                          ? Colors.white.withValues(alpha: 0.9)
                          : AppColors.textMuted,
                    ),
                  ),
                ),

                Expanded(
                  flex: 2,
                  child: Text(
                    prayer.formattedTime,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                      color: isActive
                          ? Colors.white
                          : (isPast ? AppColors.textMuted : AppColors.textDark),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // Action Icon (Checkmark or Bell)
                if (canComplete)
                  GestureDetector(
                    onTap: isPast ? onToggleTracker : onToggleNotification,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      child: isPast
                          ? Icon(
                              isCompleted
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              size: 20,
                              color: isCompleted
                                  ? AppColors.darkGreen
                                  : AppColors.textMuted.withValues(alpha: 0.5),
                            )
                          : Icon(
                              notificationOn
                                  ? Icons.notifications_active
                                  : Icons.notifications_none_outlined,
                              size: 20,
                              color: isActive
                                  ? Colors.white
                                  : AppColors.textMuted,
                            ),
                    ),
                  )
                else
                  const SizedBox(width: 28),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StreakBanner extends StatelessWidget {
  final int streak;

  const _StreakBanner({required this.streak});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.accentGold.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accentGold.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.local_fire_department,
            color: AppColors.accentGold,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Dein Gebets-Streak',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '$streak Tage in Folge',
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
