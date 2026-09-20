import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/dashboard_provider.dart';
import 'dashboard_section_card.dart';

class WeeklyProgressCard extends ConsumerWidget {
  final double? height;

  const WeeklyProgressCard({super.key, this.height = 240});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weeklyConsistency = ref.watch(weeklyConsistencyProvider);

    return DashboardSectionCard(
      title: 'Weekly Progress',
      trailing: const Text(
        'Mon - Sun',
        style: TextStyle(
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
            child: BarChart(
              BarChartData(
                maxY: 100,
                minY: 0,
                alignment: BarChartAlignment.spaceAround,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => AppColors.navyPrimary,
                    tooltipRoundedRadius: 4,
                    tooltipPadding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final item = weeklyConsistency[group.x.toInt()];
                      return BarTooltipItem(
                        '${item.dayName}: ${rod.toY.toInt()}%',
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
                      interval: 25, // 0, 25, 50, 75, 100
                      getTitlesWidget: (value, meta) {
                        final v = value.toInt();
                        if (v == 0 || v == 25 || v == 50 || v == 75 || v == 100) {
                          return Text(
                            '$v',
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
                      reservedSize: 20,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= weeklyConsistency.length) {
                          return const SizedBox.shrink();
                        }
                        final item = weeklyConsistency[idx];
                        return Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            item.dayName,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
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
                  horizontalInterval: 25,
                  getDrawingHorizontalLine: (value) => const FlLine(
                    color: AppColors.borderSubtle,
                    strokeWidth: 0.8,
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: weeklyConsistency.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final item = entry.value;

                  return BarChartGroupData(
                    x: idx,
                    barRods: [
                      BarChartRodData(
                        toY: item.percentage == 0 ? 3 : item.percentage,
                        // DARK NAVY BARS #0B2D4D
                        color: item.percentage > 0
                            ? AppColors.navyPrimary
                            : AppColors.cellInactive,
                        width: 14,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(2)),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
