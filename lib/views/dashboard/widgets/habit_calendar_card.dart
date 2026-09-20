import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/date_filter_provider.dart';
import '../../../providers/habit_provider.dart';
import '../../../providers/task_provider.dart';
import 'dashboard_section_card.dart';

class HabitCalendarCard extends ConsumerWidget {
  final double? height;

  const HabitCalendarCard({super.key, this.height});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(selectedMonthProvider);
    final year = ref.watch(selectedYearProvider);
    final daysCount = ref.watch(daysInSelectedMonthProvider);
    final monthName = ref.watch(selectedMonthNameProvider);

    final allHabits = ref.watch(habitsStreamProvider).value ?? [];
    final habits = allHabits.where((h) => !h.isArchived).toList();
    final completionsMap = ref.watch(habitCompletionsMapProvider);
    final firestore = ref.watch(firestoreServiceProvider);
    final uid = ref.watch(currentUserIdProvider);

    return DashboardSectionCard(
      title: 'Habit Calendar',
      trailing: Text(
        '$monthName $year',
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
      height: height,
      bodyPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: habits.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Text(
                  'No habits created yet. Add habits to start tracking consistency!',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ),
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                const initialColWidth = 28.0;
                const cellSize = 19.0;
                const cellSpacing = 3.0;
                final totalCalendarWidth = initialColWidth + (daysCount * (cellSize + cellSpacing));
                final shouldScroll = totalCalendarWidth > constraints.maxWidth;

                Widget content = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Horizontal Column Headers: 1 2 3 4 5 ... 30
                    Row(
                      children: [
                        const SizedBox(width: initialColWidth),
                        ...List.generate(daysCount, (i) {
                          final day = i + 1;
                          return Container(
                            width: cellSize,
                            margin: const EdgeInsets.only(right: cellSpacing),
                            alignment: Alignment.center,
                            child: Text(
                              '$day',
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Habit Rows with Initials + Matrix Cells
                    ...habits.map((h) {
                      final habitCompletions = completionsMap[h.id] ?? {};
                      // Extract first letter of habit title
                      final initial = h.title.trim().isNotEmpty
                          ? h.title.trim()[0].toUpperCase()
                          : '?';

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 5.0),
                        child: Row(
                          children: [
                            // Habit Initial Label (W, E, R, D, H, L, N, M, P, B...)
                            Tooltip(
                              message: h.title,
                              child: Container(
                                width: initialColWidth,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  initial,
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.navyPrimary,
                                  ),
                                ),
                              ),
                            ),

                            // Calendar Cells for Days 1..30
                            ...List.generate(daysCount, (i) {
                              final day = i + 1;
                              final dateStr =
                                  '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
                              final isDone = habitCompletions.contains(dateStr);

                              return Tooltip(
                                message: '${h.title}\n$dateStr: ${isDone ? "Completed" : "Incomplete"}',
                                child: InkWell(
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    firestore.toggleCompletion(uid, h.id, dateStr, isCurrentlyDone: isDone);
                                  },
                                  borderRadius: BorderRadius.circular(2),
                                  child: Container(
                                    width: cellSize,
                                    height: cellSize,
                                    margin: const EdgeInsets.only(right: cellSpacing),
                                    decoration: BoxDecoration(
                                      // COMPLETED CELL: Green/teal square #3AA66F
                                      // INCOMPLETE CELL: Very light gray square #EEF3F7
                                      color: isDone ? AppColors.greenSuccess : AppColors.cellInactive,
                                      borderRadius: BorderRadius.circular(2),
                                      border: Border.all(
                                        color: isDone
                                            ? AppColors.greenSuccess
                                            : AppColors.borderSubtle,
                                        width: 0.8,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      );
                    }),
                  ],
                );

                if (shouldScroll) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: content,
                  );
                }
                return content;
              },
            ),
    );
  }
}
