import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/date_filter_provider.dart';
import '../../../providers/habit_provider.dart';
import '../../../providers/task_provider.dart';
import 'dashboard_section_card.dart';

class DailyProgressCard extends ConsumerWidget {
  final double? height;

  const DailyProgressCard({super.key, this.height = 240});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(selectedMonthProvider);
    final year = ref.watch(selectedYearProvider);
    final daysCount = ref.watch(daysInSelectedMonthProvider);
    final monthName = ref.watch(selectedMonthNameProvider);

    final habits = ref.watch(habitsStreamProvider).value ?? [];
    final completionsMap = ref.watch(habitCompletionsMapProvider);
    final tasks = ref.watch(tasksStreamProvider).value ?? [];

    final totalHabits = habits.length;

    // Calculate daily completion percentage for each day 1..daysCount
    final dailyValues = List.generate(daysCount, (i) {
      final day = i + 1;
      final dateStr =
          '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';

      int completedHabits = 0;
      for (final h in habits) {
        if (completionsMap[h.id]?.contains(dateStr) ?? false) {
          completedHabits++;
        }
      }

      int completedTasks = 0;
      int dayTasks = 0;
      for (final t in tasks) {
        if (t.dueDate == dateStr) {
          dayTasks++;
          if (t.done) completedTasks++;
        }
      }

      double pct = 0.0;
      if (totalHabits > 0 || dayTasks > 0) {
        final totalItems = totalHabits + dayTasks;
        final completedItems = completedHabits + completedTasks;
        pct = (completedItems / totalItems) * 100.0;
      }
      return pct.clamp(0.0, 100.0);
    });

    return DashboardSectionCard(
      title: 'Daily Progress',
      trailing: Text(
        '$monthName $year',
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
      height: height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Determine bar width
                final availableWidth = constraints.maxWidth - 32;
                final barWidth = (availableWidth / (daysCount * 1.5)).clamp(4.0, 10.0);

                return BarChart(
                  BarChartData(
                    maxY: 100,
                    minY: 0,
                    alignment: BarChartAlignment.spaceBetween,
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipColor: (_) => AppColors.navyPrimary,
                        tooltipRoundedRadius: 4,
                        tooltipPadding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final day = group.x + 1;
                          return BarTooltipItem(
                            'Day $day: ${rod.toY.toInt()}%',
                            const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 26,
                          interval: 50,
                          getTitlesWidget: (value, meta) {
                            if (value == 0 || value == 50 || value == 100) {
                              return Text(
                                '${value.toInt()}',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w500,
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 18,
                          interval: 1,
                          getTitlesWidget: (value, meta) {
                            final day = value.toInt() + 1;
                            if (day > daysCount) return const SizedBox.shrink();
                            // Show day numbers horizontally: every 5 days or 1, 5, 10, 15, 20, 25, 30
                            final showNum = day == 1 || day % 5 == 0 || day == daysCount;
                            if (!showNum) return const SizedBox.shrink();

                            return Padding(
                              padding: const EdgeInsets.only(top: 3.0),
                              child: Text(
                                '$day',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 8.5,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 50,
                      getDrawingHorizontalLine: (value) => const FlLine(
                        color: AppColors.borderSubtle,
                        strokeWidth: 0.8,
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: List.generate(daysCount, (i) {
                      final val = dailyValues[i];

                      return BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: val == 0 ? 2 : val,
                            // DARK NAVY BARS #0B2D4D
                            color: val > 0 ? AppColors.navyPrimary : AppColors.cellInactive,
                            width: barWidth,
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(2)),
                          ),
                        ],
                      );
                    }),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
