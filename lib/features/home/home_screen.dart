import 'package:flutter/material.dart';

import 'widgets/daily_reminder_banner.dart';
import 'widgets/greeting_header.dart';
import 'widgets/next_prayer_card.dart';
import 'widgets/prayer_times_row.dart';
import 'widgets/quick_actions_grid.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: [
            SizedBox(height: 16),
            GreetingHeader(),
            SizedBox(height: 24),
            NextPrayerCard(),
            SizedBox(height: 20),
            PrayerTimesRow(),
            SizedBox(height: 20),
            QuickActionsGrid(),
            SizedBox(height: 20),
            DailyReminderBanner(),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
