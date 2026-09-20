import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task_model.dart';
import '../services/firestore_service.dart';
import 'auth_provider.dart';

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  final service = FirestoreService();
  service.triggerMockInitialState();
  return service;
});

enum TaskFilterTab { today, upcoming, completed, all }

final taskFilterTabProvider = StateProvider<TaskFilterTab>((ref) => TaskFilterTab.today);
final taskSearchQueryProvider = StateProvider<String>((ref) => '');
final taskCategoryFilterProvider = StateProvider<String?>((ref) => null);

final tasksStreamProvider = StreamProvider<List<TaskModel>>((ref) {
  final uid = ref.watch(currentUserIdProvider);
  final firestore = ref.watch(firestoreServiceProvider);
  return firestore.streamTasks(uid);
});

final filteredTasksProvider = Provider<List<TaskModel>>((ref) {
  final tasksAsync = ref.watch(tasksStreamProvider);
  final filterTab = ref.watch(taskFilterTabProvider);
  final search = ref.watch(taskSearchQueryProvider).toLowerCase().trim();
  final categoryFilter = ref.watch(taskCategoryFilterProvider);

  final tasks = tasksAsync.value ?? [];
  final todayStr = DateTime.now().toIso8601String().substring(0, 10);

  return tasks.where((task) {
    // Search query filter
    if (search.isNotEmpty) {
      final matchesTitle = task.text.toLowerCase().contains(search);
      final matchesNotes = task.notes?.toLowerCase().contains(search) ?? false;
      final matchesCategory = task.category?.toLowerCase().contains(search) ?? false;
      if (!matchesTitle && !matchesNotes && !matchesCategory) {
        return false;
      }
    }

    // Category filter
    if (categoryFilter != null && categoryFilter != 'All') {
      if (task.category?.toLowerCase() != categoryFilter.toLowerCase()) {
        return false;
      }
    }

    // Tab filter
    switch (filterTab) {
      case TaskFilterTab.completed:
        return task.done;
      case TaskFilterTab.today:
        return !task.done && (task.dueDate == null || task.dueDate!.compareTo(todayStr) <= 0);
      case TaskFilterTab.upcoming:
        return !task.done && (task.dueDate != null && task.dueDate!.compareTo(todayStr) > 0);
      case TaskFilterTab.all:
        return true;
    }
  }).toList()
    ..sort((a, b) {
      // Prioritize undone first
      if (a.done != b.done) {
        return a.done ? 1 : -1;
      }
      // Then priority: High > Medium > Low
      const pWeights = {'High': 3, 'Medium': 2, 'Low': 1};
      final pA = pWeights[a.priority] ?? 2;
      final pB = pWeights[b.priority] ?? 2;
      if (pA != pB) {
        return pB.compareTo(pA);
      }
      // Then due date
      if (a.dueDate != null && b.dueDate != null) {
        return a.dueDate!.compareTo(b.dueDate!);
      }
      return b.createdAt.compareTo(a.createdAt);
    });
});

final taskCountsProvider = Provider<Map<TaskFilterTab, int>>((ref) {
  final tasksAsync = ref.watch(tasksStreamProvider);
  final tasks = tasksAsync.value ?? [];
  final todayStr = DateTime.now().toIso8601String().substring(0, 10);

  int todayCount = 0;
  int upcomingCount = 0;
  int completedCount = 0;

  for (final t in tasks) {
    if (t.done) {
      completedCount++;
    } else if (t.dueDate == null || t.dueDate!.compareTo(todayStr) <= 0) {
      todayCount++;
    } else {
      upcomingCount++;
    }
  }

  return {
    TaskFilterTab.today: todayCount,
    TaskFilterTab.upcoming: upcomingCount,
    TaskFilterTab.completed: completedCount,
    TaskFilterTab.all: tasks.length,
  };
});
