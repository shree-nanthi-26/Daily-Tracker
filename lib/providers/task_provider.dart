import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task_model.dart';
import '../services/firestore_service.dart';
import 'auth_provider.dart';

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  final service = FirestoreService();
  service.triggerMockInitialState();
  return service;
});

enum TaskFilterTab { all, today, upcoming, overdue, completed }

enum TaskSortOrder {
  priorityHighFirst,
  priorityLowFirst,
  dueDateSoonest,
  dueDateLatest,
  newestFirst,
  oldestFirst,
  alphabetical,
}

extension TaskSortOrderX on TaskSortOrder {
  String get label {
    switch (this) {
      case TaskSortOrder.priorityHighFirst:
        return 'Priority: High → Low';
      case TaskSortOrder.priorityLowFirst:
        return 'Priority: Low → High';
      case TaskSortOrder.dueDateSoonest:
        return 'Due Date: Soonest';
      case TaskSortOrder.dueDateLatest:
        return 'Due Date: Furthest';
      case TaskSortOrder.newestFirst:
        return 'Created: Newest';
      case TaskSortOrder.oldestFirst:
        return 'Created: Oldest';
      case TaskSortOrder.alphabetical:
        return 'Title: A → Z';
    }
  }

  IconData get icon {
    switch (this) {
      case TaskSortOrder.priorityHighFirst:
      case TaskSortOrder.priorityLowFirst:
        return Icons.bolt_rounded;
      case TaskSortOrder.dueDateSoonest:
      case TaskSortOrder.dueDateLatest:
        return Icons.calendar_today_rounded;
      case TaskSortOrder.newestFirst:
      case TaskSortOrder.oldestFirst:
        return Icons.access_time_rounded;
      case TaskSortOrder.alphabetical:
        return Icons.sort_by_alpha_rounded;
    }
  }
}

final taskFilterTabProvider = StateProvider<TaskFilterTab>((ref) => TaskFilterTab.today);
final taskSearchQueryProvider = StateProvider<String>((ref) => '');
final taskCategoryFilterProvider = StateProvider<String?>((ref) => null);
final taskPriorityFilterProvider = StateProvider<String?>((ref) => null);
final taskSortOrderProvider = StateProvider<TaskSortOrder>((ref) => TaskSortOrder.priorityHighFirst);

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
  final priorityFilter = ref.watch(taskPriorityFilterProvider);
  final sortOrder = ref.watch(taskSortOrderProvider);

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

    // Priority filter
    if (priorityFilter != null && priorityFilter != 'All') {
      if (task.priority.toLowerCase() != priorityFilter.toLowerCase()) {
        return false;
      }
    }

    // Tab filter
    switch (filterTab) {
      case TaskFilterTab.completed:
        return task.done;
      case TaskFilterTab.today:
        return !task.done && (task.dueDate == null || task.dueDate == todayStr);
      case TaskFilterTab.upcoming:
        return !task.done && task.dueDate != null && task.dueDate!.compareTo(todayStr) > 0;
      case TaskFilterTab.overdue:
        return !task.done && task.dueDate != null && task.dueDate!.compareTo(todayStr) < 0;
      case TaskFilterTab.all:
        return true;
    }
  }).toList()
    ..sort((a, b) {
      // Prioritize undone first unless on completed tab
      if (a.done != b.done) {
        return a.done ? 1 : -1;
      }

      switch (sortOrder) {
        case TaskSortOrder.priorityHighFirst:
          const pWeights = {'High': 3, 'Medium': 2, 'Low': 1};
          final pA = pWeights[a.priority] ?? 2;
          final pB = pWeights[b.priority] ?? 2;
          if (pA != pB) return pB.compareTo(pA);
          if (a.dueDate != null && b.dueDate != null) return a.dueDate!.compareTo(b.dueDate!);
          return b.createdAt.compareTo(a.createdAt);

        case TaskSortOrder.priorityLowFirst:
          const pWeights = {'High': 3, 'Medium': 2, 'Low': 1};
          final pA = pWeights[a.priority] ?? 2;
          final pB = pWeights[b.priority] ?? 2;
          if (pA != pB) return pA.compareTo(pB);
          if (a.dueDate != null && b.dueDate != null) return a.dueDate!.compareTo(b.dueDate!);
          return b.createdAt.compareTo(a.createdAt);

        case TaskSortOrder.dueDateSoonest:
          if (a.dueDate != null && b.dueDate != null) {
            final cmp = a.dueDate!.compareTo(b.dueDate!);
            if (cmp != 0) return cmp;
          } else if (a.dueDate != null) {
            return -1;
          } else if (b.dueDate != null) {
            return 1;
          }
          return b.createdAt.compareTo(a.createdAt);

        case TaskSortOrder.dueDateLatest:
          if (a.dueDate != null && b.dueDate != null) {
            final cmp = b.dueDate!.compareTo(a.dueDate!);
            if (cmp != 0) return cmp;
          } else if (a.dueDate != null) {
            return -1;
          } else if (b.dueDate != null) {
            return 1;
          }
          return b.createdAt.compareTo(a.createdAt);

        case TaskSortOrder.newestFirst:
          return b.createdAt.compareTo(a.createdAt);

        case TaskSortOrder.oldestFirst:
          return a.createdAt.compareTo(b.createdAt);

        case TaskSortOrder.alphabetical:
          return a.text.toLowerCase().compareTo(b.text.toLowerCase());
      }
    });
});

final taskCountsProvider = Provider<Map<TaskFilterTab, int>>((ref) {
  final tasksAsync = ref.watch(tasksStreamProvider);
  final tasks = tasksAsync.value ?? [];
  final todayStr = DateTime.now().toIso8601String().substring(0, 10);

  int todayCount = 0;
  int upcomingCount = 0;
  int overdueCount = 0;
  int completedCount = 0;

  for (final t in tasks) {
    if (t.done) {
      completedCount++;
    } else if (t.dueDate != null && t.dueDate!.compareTo(todayStr) < 0) {
      overdueCount++;
    } else if (t.dueDate != null && t.dueDate!.compareTo(todayStr) > 0) {
      upcomingCount++;
    } else {
      // Due today or has no due date set
      todayCount++;
    }
  }

  return {
    TaskFilterTab.all: tasks.length,
    TaskFilterTab.today: todayCount,
    TaskFilterTab.upcoming: upcomingCount,
    TaskFilterTab.overdue: overdueCount,
    TaskFilterTab.completed: completedCount,
  };
});

