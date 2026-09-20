import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/goal_model.dart';
import 'auth_provider.dart';
import 'task_provider.dart';

enum GoalFilterTab { all, active, achieved }

final goalsStreamProvider = StreamProvider<List<GoalModel>>((ref) {
  final uid = ref.watch(currentUserIdProvider);
  final firestore = ref.watch(firestoreServiceProvider);
  return firestore.streamGoals(uid);
});

final activeGoalsCountProvider = Provider<int>((ref) {
  final goals = ref.watch(goalsStreamProvider).value ?? [];
  return goals.where((g) => !g.isAchieved).length;
});

final goalFilterTabProvider = StateProvider<GoalFilterTab>((ref) => GoalFilterTab.all);
final goalCategoryFilterProvider = StateProvider<String?>((ref) => null);

final filteredGoalsProvider = Provider<List<GoalModel>>((ref) {
  final goals = ref.watch(goalsStreamProvider).value ?? [];
  final tab = ref.watch(goalFilterTabProvider);
  final category = ref.watch(goalCategoryFilterProvider);

  return goals.where((g) {
    if (category != null && category != 'All') {
      if (g.category?.toLowerCase() != category.toLowerCase()) return false;
    }

    switch (tab) {
      case GoalFilterTab.all:
        return true;
      case GoalFilterTab.active:
        return !g.isAchieved;
      case GoalFilterTab.achieved:
        return g.isAchieved;
    }
  }).toList();
});

final goalCountsProvider = Provider<Map<GoalFilterTab, int>>((ref) {
  final goals = ref.watch(goalsStreamProvider).value ?? [];
  int active = 0;
  int achieved = 0;

  for (final g in goals) {
    if (g.isAchieved) {
      achieved++;
    } else {
      active++;
    }
  }

  return {
    GoalFilterTab.all: goals.length,
    GoalFilterTab.active: active,
    GoalFilterTab.achieved: achieved,
  };
});
