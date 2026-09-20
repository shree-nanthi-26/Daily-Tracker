import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/habit_model.dart';
import '../models/habit_completion_model.dart';
import '../models/streak_milestone.dart';
import 'auth_provider.dart';
import 'task_provider.dart';

final habitsStreamProvider = StreamProvider<List<HabitModel>>((ref) {
  final uid = ref.watch(currentUserIdProvider);
  final firestore = ref.watch(firestoreServiceProvider);
  return firestore.streamHabits(uid);
});

final habitCompletionsStreamProvider =
    StreamProvider<List<HabitCompletionModel>>((ref) {
  final uid = ref.watch(currentUserIdProvider);
  final firestore = ref.watch(firestoreServiceProvider);
  return firestore.streamCompletions(uid);
});

// Map of [habitId][dateStr] => bool
final habitCompletionsMapProvider =
    Provider<Map<String, Set<String>>>((ref) {
  final completionsAsync = ref.watch(habitCompletionsStreamProvider);
  final completions = completionsAsync.value ?? [];

  final map = <String, Set<String>>{};
  for (final c in completions) {
    map.putIfAbsent(c.habitId, () => <String>{}).add(c.dateStr);
  }
  return map;
});

class StreakStats {
  final int currentStreak;
  final int bestStreak;

  const StreakStats({required this.currentStreak, required this.bestStreak});
}

final overallStreakProvider = Provider<StreakStats>((ref) {
  final completionsAsync = ref.watch(habitCompletionsStreamProvider);
  final completions = completionsAsync.value ?? [];

  if (completions.isEmpty) {
    return const StreakStats(currentStreak: 0, bestStreak: 0);
  }

  // Collect unique dates where at least one habit was completed
  final uniqueDates = completions.map((c) => c.dateStr).toSet().toList()
    ..sort((a, b) => b.compareTo(a)); // Descending

  final now = DateTime.now();
  final todayStr = now.toIso8601String().substring(0, 10);
  final yesterdayStr = now.subtract(const Duration(days: 1)).toIso8601String().substring(0, 10);

  int currentStreak = 0;
  int bestStreak = 0;
  int tempStreak = 0;

  DateTime? checkDate = uniqueDates.contains(todayStr)
      ? now
      : (uniqueDates.contains(yesterdayStr) ? now.subtract(const Duration(days: 1)) : null);

  if (checkDate != null) {
    var runner = checkDate;
    while (true) {
      final s = runner.toIso8601String().substring(0, 10);
      if (uniqueDates.contains(s)) {
        currentStreak++;
        runner = runner.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
  }

  // Calculate best consecutive run
  final ascendingDates = uniqueDates.reversed.toList();
  for (int i = 0; i < ascendingDates.length; i++) {
    tempStreak++;
    if (i < ascendingDates.length - 1) {
      final cur = DateTime.parse(ascendingDates[i]);
      final next = DateTime.parse(ascendingDates[i + 1]);
      if (next.difference(cur).inDays != 1) {
        if (tempStreak > bestStreak) bestStreak = tempStreak;
        tempStreak = 0;
      }
    }
  }
  if (tempStreak > bestStreak) bestStreak = tempStreak;

  return StreakStats(
    currentStreak: currentStreak,
    bestStreak: bestStreak < currentStreak ? currentStreak : bestStreak,
  );
});

final currentMilestoneProvider = Provider<StreakMilestone>((ref) {
  final streak = ref.watch(overallStreakProvider).currentStreak;
  return StreakMilestone.getMilestoneForStreak(streak);
});

final nextMilestoneProvider = Provider<StreakMilestone>((ref) {
  final streak = ref.watch(overallStreakProvider).currentStreak;
  return StreakMilestone.getNextMilestone(streak);
});

final lastCelebratedMilestoneProvider = StateProvider<int>((ref) => 0);

