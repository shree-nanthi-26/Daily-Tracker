import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/date_filter_provider.dart';
import '../../../providers/habit_provider.dart';
import 'dashboard_section_card.dart';

class HabitAnalyticsCard extends ConsumerWidget {
  final double? height;

  const HabitAnalyticsCard({super.key, this.height});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitsStreamProvider).value ?? [];
    final completionsMap = ref.watch(habitCompletionsMapProvider);
    final month = ref.watch(selectedMonthProvider);
    final year = ref.watch(selectedYearProvider);
    final daysCount = ref.watch(daysInSelectedMonthProvider);

    // Calculate completion percentage for each habit in the selected month
    final items = habits.map((h) {
      final habitCompletions = completionsMap[h.id] ?? {};
      int doneCount = 0;
      for (int day = 1; day <= daysCount; day++) {
        final dateStr =
            '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
        if (habitCompletions.contains(dateStr)) {
          doneCount++;
        }
      }

      final double pct = daysCount > 0 ? (doneCount / daysCount) * 100.0 : 0.0;
      final initial = h.title.trim().isNotEmpty ? h.title.trim()[0].toUpperCase() : '?';

      return _HabitAnalyticsData(
        initial: initial,
        title: h.title,
        percentage: pct.clamp(0.0, 100.0),
      );
    }).toList();

    return DashboardSectionCard(
      title: 'Analytics',
      height: height,
      bodyPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: items.isEmpty
          ? const Center(
              child: Text(
                'No habit analytics available',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            )
          : ListView.separated(
              itemCount: items.length,
              shrinkWrap: height == null,
              physics: height != null ? const ClampingScrollPhysics() : const NeverScrollableScrollPhysics(),
              separatorBuilder: (_, __) => const SizedBox(height: 7),
              itemBuilder: (context, index) {
                final item = items[index];

                return Tooltip(
                  message: '${item.title}: ${item.percentage.toInt()}%',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Habit initial
                          Text(
                            item.initial,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: AppColors.navyPrimary,
                            ),
                          ),
                          // Percentage
                          Text(
                            '${item.percentage.toInt()}%',
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      // Horizontal progress bar: Dark navy progress bar #0B2D4D, Light gray track #EEF3F7
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: (item.percentage / 100.0).clamp(0.0, 1.0),
                          backgroundColor: AppColors.cellInactive,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.navyPrimary,
                          ),
                          minHeight: 5,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class _HabitAnalyticsData {
  final String initial;
  final String title;
  final double percentage;

  const _HabitAnalyticsData({
    required this.initial,
    required this.title,
    required this.percentage,
  });
}
