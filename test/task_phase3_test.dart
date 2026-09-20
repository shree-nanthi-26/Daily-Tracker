import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:daily_work_mobile/models/task_model.dart';
import 'package:daily_work_mobile/providers/task_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final today = DateTime.now();
  final todayStr = today.toIso8601String().substring(0, 10);
  final yesterdayStr = today.subtract(const Duration(days: 1)).toIso8601String().substring(0, 10);
  final tomorrowStr = today.add(const Duration(days: 1)).toIso8601String().substring(0, 10);

  final sampleTasks = [
    TaskModel(
      id: 't1',
      text: 'Submit financial report',
      priority: 'High',
      category: 'Work',
      dueDate: yesterdayStr, // Overdue
      done: false,
      createdAt: DateTime(2026, 9, 10),
    ),
    TaskModel(
      id: 't2',
      text: 'Buy groceries',
      priority: 'Low',
      category: 'Personal',
      dueDate: todayStr, // Today
      done: false,
      createdAt: DateTime(2026, 9, 15),
    ),
    TaskModel(
      id: 't3',
      text: 'Schedule doctor appointment',
      priority: 'Medium',
      category: 'Health',
      dueDate: tomorrowStr, // Upcoming
      done: false,
      createdAt: DateTime(2026, 9, 12),
    ),
    TaskModel(
      id: 't4',
      text: 'Read book chapter',
      priority: 'Low',
      category: 'Personal',
      dueDate: yesterdayStr,
      done: true, // Completed (even though yesterday)
      createdAt: DateTime(2026, 9, 5),
    ),
  ];

  group('Phase 3 Task Tab & Count Logic Tests', () {
    test('Overdue and upcoming counts compute accurately', () async {
      final container = ProviderContainer(
        overrides: [
          tasksStreamProvider.overrideWith((ref) => Stream.value(sampleTasks)),
        ],
      );
      await container.read(tasksStreamProvider.future);

      final counts = container.read(taskCountsProvider);
      expect(counts[TaskFilterTab.all], 4);
      expect(counts[TaskFilterTab.today], 1); // t2
      expect(counts[TaskFilterTab.upcoming], 1); // t3
      expect(counts[TaskFilterTab.overdue], 1); // t1
      expect(counts[TaskFilterTab.completed], 1); // t4
    });

    test('Filtered tasks with TaskFilterTab.overdue returns only unfinished overdue tasks', () async {
      final container = ProviderContainer(
        overrides: [
          tasksStreamProvider.overrideWith((ref) => Stream.value(sampleTasks)),
        ],
      );
      await container.read(tasksStreamProvider.future);
      container.read(taskFilterTabProvider.notifier).state = TaskFilterTab.overdue;

      final filtered = container.read(filteredTasksProvider);
      expect(filtered.length, 1);
      expect(filtered.first.id, 't1');
      expect(filtered.first.text, 'Submit financial report');
    });

    test('Filtered tasks with TaskFilterTab.upcoming returns future tasks', () async {
      final container = ProviderContainer(
        overrides: [
          tasksStreamProvider.overrideWith((ref) => Stream.value(sampleTasks)),
        ],
      );
      await container.read(tasksStreamProvider.future);
      container.read(taskFilterTabProvider.notifier).state = TaskFilterTab.upcoming;

      final filtered = container.read(filteredTasksProvider);
      expect(filtered.length, 1);
      expect(filtered.first.id, 't3');
    });
  });

  group('Phase 3 Priority & Search Filter Tests', () {
    test('Filtering by priority High returns only High priority tasks', () async {
      final container = ProviderContainer(
        overrides: [
          tasksStreamProvider.overrideWith((ref) => Stream.value(sampleTasks)),
        ],
      );
      await container.read(tasksStreamProvider.future);
      container.read(taskFilterTabProvider.notifier).state = TaskFilterTab.all;
      container.read(taskPriorityFilterProvider.notifier).state = 'High';

      final filtered = container.read(filteredTasksProvider);
      expect(filtered.length, 1);
      expect(filtered.first.priority, 'High');
      expect(filtered.first.id, 't1');
    });

    test('Search query matches notes and title', () async {
      final container = ProviderContainer(
        overrides: [
          tasksStreamProvider.overrideWith((ref) => Stream.value(sampleTasks)),
        ],
      );
      await container.read(tasksStreamProvider.future);
      container.read(taskFilterTabProvider.notifier).state = TaskFilterTab.all;
      container.read(taskSearchQueryProvider.notifier).state = 'financial';

      final filtered = container.read(filteredTasksProvider);
      expect(filtered.length, 1);
      expect(filtered.first.id, 't1');
    });
  });

  group('Phase 3 Multi-Option Sorting Tests', () {
    test('Sort by Priority High to Low places High then Medium then Low', () async {
      final container = ProviderContainer(
        overrides: [
          tasksStreamProvider.overrideWith((ref) => Stream.value(sampleTasks)),
        ],
      );
      await container.read(tasksStreamProvider.future);
      container.read(taskFilterTabProvider.notifier).state = TaskFilterTab.all;
      container.read(taskSortOrderProvider.notifier).state = TaskSortOrder.priorityHighFirst;

      final filtered = container.read(filteredTasksProvider);
      expect(filtered[0].id, 't1'); // High
      expect(filtered[1].id, 't3'); // Medium
      expect(filtered[2].id, 't2'); // Low
      expect(filtered[3].id, 't4'); // Completed
    });

    test('Sort by Priority Low to High places Low then Medium then High', () async {
      final container = ProviderContainer(
        overrides: [
          tasksStreamProvider.overrideWith((ref) => Stream.value(sampleTasks)),
        ],
      );
      await container.read(tasksStreamProvider.future);
      container.read(taskFilterTabProvider.notifier).state = TaskFilterTab.all;
      container.read(taskSortOrderProvider.notifier).state = TaskSortOrder.priorityLowFirst;

      final filtered = container.read(filteredTasksProvider);
      expect(filtered[0].id, 't2'); // Low
      expect(filtered[1].id, 't3'); // Medium
      expect(filtered[2].id, 't1'); // High
      expect(filtered[3].id, 't4'); // Completed
    });

    test('Sort by Alphabetical A to Z sorts task text alphabetically', () async {
      final container = ProviderContainer(
        overrides: [
          tasksStreamProvider.overrideWith((ref) => Stream.value(sampleTasks)),
        ],
      );
      await container.read(tasksStreamProvider.future);
      container.read(taskFilterTabProvider.notifier).state = TaskFilterTab.all;
      container.read(taskSortOrderProvider.notifier).state = TaskSortOrder.alphabetical;

      final filtered = container.read(filteredTasksProvider);
      expect(filtered[0].text, 'Buy groceries');
      expect(filtered[1].text, 'Schedule doctor appointment');
      expect(filtered[2].text, 'Submit financial report');
      expect(filtered[3].text, 'Read book chapter');
    });

    test('Sort by Due Date Soonest sorts overdue/earliest dates first', () async {
      final container = ProviderContainer(
        overrides: [
          tasksStreamProvider.overrideWith((ref) => Stream.value(sampleTasks)),
        ],
      );
      await container.read(tasksStreamProvider.future);
      container.read(taskFilterTabProvider.notifier).state = TaskFilterTab.all;
      container.read(taskSortOrderProvider.notifier).state = TaskSortOrder.dueDateSoonest;

      final filtered = container.read(filteredTasksProvider);
      expect(filtered[0].id, 't1'); // yesterday
      expect(filtered[1].id, 't2'); // today
      expect(filtered[2].id, 't3'); // tomorrow
    });
  });
}
