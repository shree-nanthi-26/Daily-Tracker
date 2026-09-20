import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/date_filter_provider.dart';
import '../../../providers/habit_provider.dart';
import 'dashboard_section_card.dart';

class TopHabitsCard extends ConsumerWidget {
  final double? height;

  const TopHabitsCard({super.key, this.height = 250});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitsStreamProvider).value ?? [];
    final completionsMap = ref.watch(habitCompletionsMapProvider);
    final month = ref.watch(selectedMonthProvider);
    final year = ref.watch(selectedYearProvider);
    final daysCount = ref.watch(daysInSelectedMonthProvider);

    // Calculate rates and take top 5
    final ranked = habits.map((h) {
      final completions = completionsMap[h.id] ?? {};
      int doneCount = 0;
      for (int d = 1; d <= daysCount; d++) {
        final dateStr =
            '$year-${month.toString().padLeft(2, '0')}-${d.toString().padLeft(2, '0')}';
        if (completions.contains(dateStr)) doneCount++;
      }
      final double pct = daysCount > 0 ? (doneCount / daysCount) * 100.0 : 0.0;
      return (habit: h, percentage: pct.clamp(0.0, 100.0));
    }).toList()
      ..sort((a, b) => b.percentage.compareTo(a.percentage));

    final top5 = ranked.take(5).toList();

    return DashboardSectionCard(
      title: 'Top 5 Habits',
      height: height,
      bodyPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: top5.isEmpty
          ? const Center(
              child: Text(
                'No habits tracked yet',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            )
          : ListView.separated(
              itemCount: top5.length,
              physics: const ClampingScrollPhysics(),
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = top5[index];
                final rank = index + 1;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Rank number and Habit name: "1. Wake up early"
                        Expanded(
                          child: Text(
                            '$rank. ${item.habit.title}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Completion percentage: "90%"
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
                );
              },
            ),
    );
  }
}
