import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/utils/date_formatter.dart';
import 'task_provider.dart';
import 'habit_provider.dart';
import 'goal_provider.dart';

class DashboardStats {
  final int totalTasks;
  final int completedTasks;
  final double taskCompletionRate; // 0 - 100
  final int totalHabits;
  final int habitsCompletedToday;
  final int currentStreak;
  final int bestStreak;
  final int activeGoalsCount;

  const DashboardStats({
    required this.totalTasks,
    required this.completedTasks,
    required this.taskCompletionRate,
    required this.totalHabits,
    required this.habitsCompletedToday,
    required this.currentStreak,
    required this.bestStreak,
    required this.activeGoalsCount,
  });
}

final dashboardStatsProvider = Provider<DashboardStats>((ref) {
  final tasks = ref.watch(tasksStreamProvider).value ?? [];
  final habits = ref.watch(habitsStreamProvider).value ?? [];
  final completionsMap = ref.watch(habitCompletionsMapProvider);
  final streakStats = ref.watch(overallStreakProvider);
  final activeGoals = ref.watch(activeGoalsCountProvider);

  final totalTasks = tasks.length;
  final completedTasks = tasks.where((t) => t.done).length;
  final taskCompletionRate =
      totalTasks > 0 ? (completedTasks / totalTasks) * 100 : 0.0;

  final todayStr = DateFormatter.todayIso();
  int habitsCompletedToday = 0;
  for (final habit in habits) {
    if (completionsMap[habit.id]?.contains(todayStr) ?? false) {
      habitsCompletedToday++;
    }
  }

  return DashboardStats(
    totalTasks: totalTasks,
    completedTasks: completedTasks,
    taskCompletionRate: taskCompletionRate,
    totalHabits: habits.length,
    habitsCompletedToday: habitsCompletedToday,
    currentStreak: streakStats.currentStreak,
    bestStreak: streakStats.bestStreak,
    activeGoalsCount: activeGoals,
  );
});

class DailyConsistencyItem {
  final String dayName;
  final String dateStr;
  final int completedCount;
  final int totalHabits;
  final double percentage; // 0.0 - 100.0
  final bool isToday;

  const DailyConsistencyItem({
    required this.dayName,
    required this.dateStr,
    required this.completedCount,
    required this.totalHabits,
    required this.percentage,
    required this.isToday,
  });
}

final weeklyConsistencyProvider = Provider<List<DailyConsistencyItem>>((ref) {
  final habits = ref.watch(habitsStreamProvider).value ?? [];
  final completionsMap = ref.watch(habitCompletionsMapProvider);
  final weekDays = DateFormatter.getCurrentWeekDays();
  final todayStr = DateFormatter.todayIso();

  return weekDays.map((date) {
    final dateStr = DateFormatter.toIsoDate(date);
    final dayName = DateFormatter.formatShortDay(date);
    final isToday = dateStr == todayStr;

    int completed = 0;
    for (final h in habits) {
      if (completionsMap[h.id]?.contains(dateStr) ?? false) {
        completed++;
      }
    }

    final total = habits.isEmpty ? 1 : habits.length;
    final pct = habits.isEmpty ? 0.0 : (completed / total) * 100.0;

    return DailyConsistencyItem(
      dayName: dayName,
      dateStr: dateStr,
      completedCount: completed,
      totalHabits: habits.length,
      percentage: pct.clamp(0.0, 100.0),
      isToday: isToday,
    );
  }).toList();
});
