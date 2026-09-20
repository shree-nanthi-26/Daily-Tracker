import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'widgets/daily_progress_card.dart';
import 'widgets/weekly_progress_card.dart';
import 'widgets/habits_stats_card.dart';
import 'widgets/overall_streak_donut_card.dart';
import 'widgets/habit_calendar_card.dart';
import 'widgets/habit_analytics_card.dart';
import 'widgets/weekly_performance_line_card.dart';
import 'widgets/top_habits_card.dart';
import 'widgets/streak_celebration_banner.dart';

class DashboardScreen extends ConsumerWidget {
  final Function(int tabIndex)? onNavigateTab;

  const DashboardScreen({super.key, this.onNavigateTab});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isLargeDesktop = width >= 1080;
        final isMediumScreen = width >= 720 && width < 1080;

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isLargeDesktop ? 20 : 14,
            vertical: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const StreakCelebrationBanner(),
              const SizedBox(height: 14),

              // ----------------- TOP ROW (4 Cards) -----------------
              // DAILY PROGRESS | WEEKLY PROGRESS | STATS | OVERALL STREAK
              if (isLargeDesktop)
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: DailyProgressCard(height: 220)),
                    SizedBox(width: 14),
                    Expanded(flex: 3, child: WeeklyProgressCard(height: 220)),
                    SizedBox(width: 14),
                    Expanded(flex: 2, child: HabitsStatsCard(height: 220)),
                    SizedBox(width: 14),
                    Expanded(flex: 2, child: OverallStreakDonutCard(height: 220)),
                  ],
                )
              else if (isMediumScreen)
                const Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: DailyProgressCard(height: 220)),
                        SizedBox(width: 14),
                        Expanded(child: WeeklyProgressCard(height: 220)),
                      ],
                    ),
                    SizedBox(height: 14),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: HabitsStatsCard(height: 220)),
                        SizedBox(width: 14),
                        Expanded(child: OverallStreakDonutCard(height: 220)),
                      ],
                    ),
                  ],
                )
              else // Mobile
                const Column(
                  children: [
                    DailyProgressCard(height: 220),
                    SizedBox(height: 12),
                    WeeklyProgressCard(height: 220),
                    SizedBox(height: 12),
                    HabitsStatsCard(height: 210),
                    SizedBox(height: 12),
                    OverallStreakDonutCard(height: 210),
                  ],
                ),

              const SizedBox(height: 14),

              // ------------- MIDDLE ROW (Habit Calendar 70% | Analytics 30%) -------------
              if (width >= 860)
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 7, // 70%
                      child: HabitCalendarCard(),
                    ),
                    SizedBox(width: 14),
                    Expanded(
                      flex: 3, // 30%
                      child: HabitAnalyticsCard(),
                    ),
                  ],
                )
              else
                const Column(
                  children: [
                    HabitCalendarCard(),
                    SizedBox(height: 14),
                    HabitAnalyticsCard(),
                  ],
                ),

              const SizedBox(height: 14),

              // --------- BOTTOM ROW (Weekly Performance 70% | Top 5 Habits 30%) ---------
              if (width >= 860)
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 7, // 70%
                      child: WeeklyPerformanceLineCard(height: 240),
                    ),
                    SizedBox(width: 14),
                    Expanded(
                      flex: 3, // 30%
                      child: TopHabitsCard(height: 240),
                    ),
                  ],
                )
              else
                const Column(
                  children: [
                    WeeklyPerformanceLineCard(height: 230),
                    SizedBox(height: 14),
                    TopHabitsCard(height: 230),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}
