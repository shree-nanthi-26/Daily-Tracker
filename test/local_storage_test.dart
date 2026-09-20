import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:daily_work_mobile/services/local_storage_service.dart';
import 'package:daily_work_mobile/models/task_model.dart';
import 'package:daily_work_mobile/models/habit_model.dart';
import 'package:daily_work_mobile/models/habit_completion_model.dart';
import 'package:daily_work_mobile/models/goal_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('LocalStorageService Tests', () {
    test('Saves and loads tasks persistently', () async {
      final storage = LocalStorageService();

      expect(await storage.isInitialized(), false);
      expect(await storage.loadTasks(), null);

      final task = TaskModel(
        id: 't_persisted_1',
        text: 'Test persistent task',
        done: true,
        priority: 'High',
        createdAt: DateTime(2026, 9, 20),
      );

      await storage.saveTasks([task]);
      await storage.setInitialized(true);

      expect(await storage.isInitialized(), true);

      final loaded = await storage.loadTasks();
      expect(loaded, isNotNull);
      expect(loaded!.length, 1);
      expect(loaded[0].id, 't_persisted_1');
      expect(loaded[0].text, 'Test persistent task');
      expect(loaded[0].done, true);
    });

    test('Saves and loads habits & completions persistently', () async {
      final storage = LocalStorageService();

      final habit = HabitModel(
        id: 'h_persisted_1',
        title: 'Drink 2L Water',
        category: 'Health',
        color: '#20BFAE',
        createdAt: DateTime(2026, 9, 20),
      );

      final completion = HabitCompletionModel(
        id: 'h_persisted_1_2026-09-20',
        habitId: 'h_persisted_1',
        dateStr: '2026-09-20',
        completedAt: DateTime(2026, 9, 20, 10, 0),
      );

      await storage.saveHabits([habit]);
      await storage.saveCompletions([completion]);

      final loadedHabits = await storage.loadHabits();
      expect(loadedHabits, isNotNull);
      expect(loadedHabits!.length, 1);
      expect(loadedHabits[0].title, 'Drink 2L Water');

      final loadedCompletions = await storage.loadCompletions();
      expect(loadedCompletions, isNotNull);
      expect(loadedCompletions!.length, 1);
      expect(loadedCompletions[0].habitId, 'h_persisted_1');
      expect(loadedCompletions[0].dateStr, '2026-09-20');
    });

    test('Saves and loads goals persistently', () async {
      final storage = LocalStorageService();

      final goal = GoalModel(
        id: 'g_persisted_1',
        title: 'Read 5 books',
        targetValue: 5,
        currentValue: 2,
        unit: 'books',
        createdAt: DateTime(2026, 9, 20),
      );

      await storage.saveGoals([goal]);

      final loadedGoals = await storage.loadGoals();
      expect(loadedGoals, isNotNull);
      expect(loadedGoals!.length, 1);
      expect(loadedGoals[0].title, 'Read 5 books');
      expect(loadedGoals[0].currentValue, 2);
    });

    test('Clears all stored data properly', () async {
      final storage = LocalStorageService();

      await storage.saveTasks([
        TaskModel(id: '1', text: 'Task 1', createdAt: DateTime.now()),
      ]);
      await storage.setInitialized(true);

      expect(await storage.isInitialized(), true);
      expect(await storage.loadTasks(), isNotNull);

      await storage.clearAll();

      expect(await storage.isInitialized(), false);
      expect(await storage.loadTasks(), null);
    });
  });
}
