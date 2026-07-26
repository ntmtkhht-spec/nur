import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/prayer.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/app_colors.dart';
import '../onboarding/widgets/ornament_divider.dart';

const _methodShortLabels = {
  'muslimWorldLeague': 'MWL Methode',
  'northAmerica': 'ISNA Methode',
  'ummAlQura': 'UAQ Methode',
  'egyptian': 'Egypt Methode',
  'karachi': 'Karachi Methode',
  'turkiye': 'Diyanet Methode',
};

class PrayersScreen extends ConsumerStatefulWidget {
  const PrayersScreen({super.key});

  @override
  ConsumerState<PrayersScreen> createState() => _PrayersScreenState();
}

class _PrayersScreenState extends ConsumerState<PrayersScreen> {
  late DateTime _selectedDate;
  Timer? _countdownTicker;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    _countdownTicker = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _countdownTicker?.cancel();
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

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final locationAsync = ref.watch(locationProvider);
    final city = switch (locationAsync) {
      AsyncData(:final value) => value.city,
      _ => LocationData.fallback.city,
    };
    final method = ref.watch(calculationMethodProvider);
    final methodLabel =
        _methodShortLabels[method.name] ?? '${method.displayName} Methode';

    final prayers = ref.watch(prayerTimesForDateProvider(_selectedDate));
    final notifications = ref.watch(prayerNotificationsProvider);

    final activeIndex = _isToday ? _computeActiveIndex(prayers) : -1;
    final next = _isToday ? _computeNext(prayers) : null;

    return SafeArea(
      child: Column(
        children: [
          _Header(onPickDate: _pickDate),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  _LocationCard(city: city, methodLabel: methodLabel),
                  const SizedBox(height: 14),
                  _DateSelector(
                    date: _selectedDate,
                    isToday: _isToday,
                    onPrev: () => _shiftDate(-1),
                    onNext: () => _shiftDate(1),
                  ),
                  const SizedBox(height: 14),
                  _PrayersList(
                    prayers: prayers,
                    activeIndex: activeIndex,
                    notifications: notifications,
                    onToggleNotification: (name) => ref
                        .read(prayerNotificationsProvider.notifier)
                        .toggle(name),
                  ),
                  const SizedBox(height: 20),
                  const OrnamentDivider(),
                  const SizedBox(height: 16),
                  if (next != null) _NextPrayerBanner(next: next),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
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

  ({PrayerTime prayer, Duration remaining})? _computeNext(
    List<PrayerTime> prayers,
  ) {
    final now = DateTime.now();
    for (final p in prayers) {
      if (!p.isPrayer) continue;
      if (p.time.isAfter(now)) {
        return (prayer: p, remaining: p.time.difference(now));
      }
    }
    return null;
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _Header extends StatelessWidget {
  final VoidCallback onPickDate;

  const _Header({required this.onPickDate});

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Row(
        children: [
          if (canPop)
            IconButton(
              icon:
                  const Icon(Icons.arrow_back, color: AppColors.primaryGreen),
              onPressed: () => Navigator.of(context).maybePop(),
            )
          else
            const SizedBox(width: 48),
          const Expanded(
            child: Center(
              child: Text(
                'Gebetszeiten',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.calendar_month_outlined,
                color: AppColors.primaryGreen),
            onPressed: onPickDate,
          ),
        ],
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  final String city;
  final String methodLabel;

  const _LocationCard({required this.city, required this.methodLabel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on_outlined,
              color: AppColors.primaryGreen, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              city,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              methodLabel,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
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
    'Januar', 'Februar', 'März', 'April', 'Mai', 'Juni',
    'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember',
  ];

  @override
  Widget build(BuildContext context) {
    final label = isToday
        ? 'Heute, ${date.day}. ${_months[date.month - 1]}'
        : '${date.day}. ${_months[date.month - 1]} ${date.year}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left,
                color: AppColors.primaryGreen, size: 26),
            onPressed: onPrev,
          ),
          Expanded(
            child: Center(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryGreen,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right,
                color: AppColors.primaryGreen, size: 26),
            onPressed: onNext,
          ),
        ],
      ),
    );
  }
}

class _PrayersList extends StatelessWidget {
  final List<PrayerTime> prayers;
  final int activeIndex;
  final Set<String> notifications;
  final ValueChanged<String> onToggleNotification;

  const _PrayersList({
    required this.prayers,
    required this.activeIndex,
    required this.notifications,
    required this.onToggleNotification,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < prayers.length; i++) ...[
            _PrayerRow(
              prayer: prayers[i],
              isActive: i == activeIndex,
              notificationOn: notifications.contains(prayers[i].name),
              onToggleNotification: () =>
                  onToggleNotification(prayers[i].name),
            ),
            if (i < prayers.length - 1 && i != activeIndex)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Divider(
                  height: 1,
                  color: AppColors.textMuted.withValues(alpha: 0.15),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _PrayerRow extends StatelessWidget {
  final PrayerTime prayer;
  final bool isActive;
  final bool notificationOn;
  final VoidCallback onToggleNotification;

  const _PrayerRow({
    required this.prayer,
    required this.isActive,
    required this.notificationOn,
    required this.onToggleNotification,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isActive ? AppColors.white : AppColors.textDark;
    final arabicColor = isActive
        ? AppColors.white.withValues(alpha: 0.85)
        : AppColors.textMuted;
    final timeColor = isActive ? AppColors.white : AppColors.textDark;

    return Container(
      margin: isActive
          ? const EdgeInsets.symmetric(horizontal: 8, vertical: 4)
          : EdgeInsets.zero,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: isActive ? AppColors.darkGreen : Colors.transparent,
        borderRadius: isActive ? BorderRadius.circular(14) : null,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              prayer.name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              prayer.arabicName,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: arabicColor),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              prayer.formattedTime,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: timeColor,
              ),
            ),
          ),
          const SizedBox(width: 12),
          if (prayer.isPrayer)
            GestureDetector(
              onTap: onToggleNotification,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  notificationOn
                      ? Icons.notifications_active
                      : Icons.notifications_none_outlined,
                  size: 22,
                  color: isActive ? AppColors.white : AppColors.primaryGreen,
                ),
              ),
            )
          else
            const SizedBox(width: 30),
        ],
      ),
    );
  }
}

class _NextPrayerBanner extends StatelessWidget {
  final ({PrayerTime prayer, Duration remaining}) next;

  const _NextPrayerBanner({required this.next});

  @override
  Widget build(BuildContext context) {
    final hours = next.remaining.inHours;
    final minutes = next.remaining.inMinutes % 60;
    final label = hours > 0
        ? 'in $hours Std $minutes Min'
        : 'in $minutes Min';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkGreen,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.darkGreen.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.accentGold.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.mosque_outlined,
              color: AppColors.accentGold,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nächstes:',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.accentGold.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${next.prayer.name} $label',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.white,
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
