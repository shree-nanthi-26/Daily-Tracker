import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:daily_work_mobile/providers/settings_provider.dart';
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

  group('Phase 5 AppThemeMode & Preferences Logic Tests', () {
    test('AppThemeMode enum has all expected modes and metadata', () {
      expect(AppThemeMode.values.length, 3);
      expect(AppThemeMode.deepNavy.label, 'Deep Navy');
      expect(AppThemeMode.amoledBlack.label, 'AMOLED Black');
      expect(AppThemeMode.modernLight.label, 'Modern Light');

      expect(AppThemeMode.deepNavy.description, contains('Desktop classic navy'));
      expect(AppThemeMode.amoledBlack.description, contains('#000000'));
    });

    test('LocalStorageService persists and loads custom display name', () async {
      final storage = LocalStorageService();
      expect(await storage.loadDisplayName(), isNull);

      await storage.saveDisplayName('Alex Dev');
      expect(await storage.loadDisplayName(), 'Alex Dev');

      await storage.saveDisplayName('Shree Nantheeshwaran');
      expect(await storage.loadDisplayName(), 'Shree Nantheeshwaran');
    });

    test('LocalStorageService persists and loads theme mode', () async {
      final storage = LocalStorageService();
      expect(await storage.loadThemeMode(), isNull);

      await storage.saveThemeMode(AppThemeMode.amoledBlack.name);
      expect(await storage.loadThemeMode(), 'amoledBlack');

      await storage.saveThemeMode(AppThemeMode.modernLight.name);
      expect(await storage.loadThemeMode(), 'modernLight');
    });

    test('LocalStorageService persists and loads haptic feedback preference', () async {
      final storage = LocalStorageService();
      // Default should be true when nothing saved
      expect(await storage.loadHapticsEnabled(), isTrue);

      await storage.saveHapticsEnabled(false);
      expect(await storage.loadHapticsEnabled(), isFalse);

      await storage.saveHapticsEnabled(true);
      expect(await storage.loadHapticsEnabled(), isTrue);
    });
  });

  group('Phase 5 Workspace Backup & JSON Export Tests', () {
    test('exportAllDataAsJson generates complete, parseable backup JSON', () async {
      final storage = LocalStorageService();

      final tasks = [
        TaskModel(
          id: 'task-1',
          text: 'Design Phase 5 Settings Screen',
          done: true,
          priority: 'High',
          category: 'Coding',
          createdAt: DateTime.parse('2026-09-20T10:00:00Z'),
        ),
        TaskModel(
          id: 'task-2',
          text: 'Deploy to Samsung device',
          done: false,
          priority: 'Medium',
          category: 'Work',
          createdAt: DateTime.parse('2026-09-20T11:00:00Z'),
        ),
      ];

      final habits = [
        HabitModel(
          id: 'habit-1',
          title: 'Morning Workout',
          category: 'Health',
          isArchived: false,
          createdAt: DateTime.parse('2026-09-20T08:00:00Z'),
        ),
        HabitModel(
          id: 'habit-2',
          title: 'Read 20 pages',
          category: 'Learning',
          isArchived: true,
          createdAt: DateTime.parse('2026-09-20T09:00:00Z'),
        ),
      ];

      final completions = [
        HabitCompletionModel(
          id: 'comp-1',
          habitId: 'habit-1',
          dateStr: '2026-09-20',
          completedAt: DateTime.parse('2026-09-20T08:30:00Z'),
        ),
      ];

      final goals = [
        GoalModel(
          id: 'goal-1',
          title: 'Complete 10 Coding Tasks',
          currentValue: 10,
          targetValue: 10,
          unit: 'tasks',
          category: 'Coding',
          createdAt: DateTime.parse('2026-09-20T07:00:00Z'),
        ),
      ];

      await storage.saveTasks(tasks);
      await storage.saveHabits(habits);
      await storage.saveCompletions(completions);
      await storage.saveGoals(goals);
      await storage.saveDisplayName('Test Engineer');

      final jsonStr = await storage.exportAllDataAsJson();
      expect(jsonStr, isNotEmpty);

      // Verify parseable JSON
      final Map<String, dynamic> data = jsonDecode(jsonStr);
      expect(data['appName'], 'DailyWork Mobile');
      expect(data['version'], '1.0.0');
      expect(data['exportedAt'], isNotNull);
      expect(data['profile']['displayName'], 'Test Engineer');

      final stats = data['stats'] as Map<String, dynamic>;
      expect(stats['tasksCount'], 2);
      expect(stats['habitsCount'], 2);
      expect(stats['completionsCount'], 1);
      expect(stats['goalsCount'], 1);

      final exportedTasks = data['tasks'] as List;
      expect(exportedTasks.length, 2);
      expect(exportedTasks[0]['id'], 'task-1');
      expect(exportedTasks[0]['done'], true);

      final exportedHabits = data['habits'] as List;
      expect(exportedHabits.length, 2);
      expect(exportedHabits[1]['is_archived'], true);

      final exportedGoals = data['goals'] as List;
      expect(exportedGoals.length, 1);
      expect(exportedGoals[0]['current_value'], 10);
    });
  });

  group('Phase 5 WorkspaceDataStats Model Tests', () {
    test('WorkspaceDataStats aggregates counts accurately', () {
      const stats = WorkspaceDataStats(
        totalTasks: 15,
        completedTasks: 10,
        totalHabits: 8,
        activeHabits: 6,
        archivedHabits: 2,
        totalCompletions: 142,
        totalGoals: 5,
        achievedGoals: 3,
      );

      expect(stats.totalTasks, 15);
      expect(stats.completedTasks, 10);
      expect(stats.activeHabits + stats.archivedHabits, stats.totalHabits);
      expect(stats.totalCompletions, 142);
      expect(stats.achievedGoals, 3);
    });
  });
}
