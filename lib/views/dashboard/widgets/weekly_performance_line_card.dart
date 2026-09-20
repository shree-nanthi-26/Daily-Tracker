import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/dashboard_provider.dart';
import 'dashboard_section_card.dart';

class WeeklyPerformanceLineCard extends ConsumerWidget {
  final double? height;

  const WeeklyPerformanceLineCard({super.key, this.height = 250});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weeklyConsistency = ref.watch(weeklyConsistencyProvider);

    final spots = weeklyConsistency.asMap().entries.map((entry) {
      final index = entry.key.toDouble();
      final item = entry.value;
      return FlSpot(index, item.percentage.clamp(0.0, 100.0));
    }).toList();

    return DashboardSectionCard(
      title: 'Weekly Performance',
      height: height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: 100,
                minX: 0,
                maxX: 6,
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => AppColors.navyPrimary,
                    tooltipRoundedRadius: 4,
                    tooltipPadding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final idx = spot.x.toInt();
                        final name = idx >= 0 && idx < weeklyConsistency.length
                            ? weeklyConsistency[idx].dayName
                            : '';
                        return LineTooltipItem(
                          '$name: ${spot.y.toInt()}%',
                          const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      }).toList();
                    },
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
                      interval: 25,
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
                      interval: 1,
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
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.35,
                    // DARK NAVY LINE #0B2D4D
                    color: AppColors.navyPrimary,
                    barWidth: 2.5,
                    isStrokeCapRound: true,
                    // SMALL CIRCULAR DATA POINTS
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 3.5,
                          color: AppColors.navyPrimary,
                          strokeWidth: 1.5,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(show: false),
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
