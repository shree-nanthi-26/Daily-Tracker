import 'package:flutter_test/flutter_test.dart';
import 'package:daily_work_mobile/models/task_model.dart';
import 'package:daily_work_mobile/models/habit_model.dart';
import 'package:daily_work_mobile/models/habit_completion_model.dart';
import 'package:daily_work_mobile/models/goal_model.dart';

void main() {
  group('TaskModel Serialization Tests', () {
    test('TaskModel converts to and from JSON correctly', () {
      final now = DateTime(2026, 9, 14, 10, 0, 0);
      final task = TaskModel(
        id: 'task_123',
        text: 'Implement Riverpod providers',
        done: true,
        priority: 'High',
        dueDate: '2026-09-15',
        category: 'Coding',
        notes: 'Add unit tests',
        completedAt: now,
        createdAt: now,
      );

      final json = task.toJson();
      expect(json['id'], 'task_123');
      expect(json['text'], 'Implement Riverpod providers');
      expect(json['done'], true);
      expect(json['priority'], 'High');
      expect(json['due_date'], '2026-09-15');
      expect(json['category'], 'Coding');

      final fromJson = TaskModel.fromJson(json);
      expect(fromJson.id, task.id);
      expect(fromJson.text, task.text);
      expect(fromJson.done, true);
      expect(fromJson.priority, 'High');
      expect(fromJson.category, 'Coding');
    });
  });

  group('HabitModel Serialization Tests', () {
    test('HabitModel converts to and from JSON correctly', () {
      final now = DateTime(2026, 9, 14);
      final habit = HabitModel(
        id: 'h_1',
        title: 'Morning Code Review',
        category: 'Coding',
        color: '#6366F1',
        targetFrequency: 5,
        reminderTime: '09:00 AM',
        createdAt: now,
      );

      final json = habit.toJson();
      expect(json['title'], 'Morning Code Review');
      expect(json['target_frequency'], 5);

      final restored = HabitModel.fromJson(json);
      expect(restored.title, habit.title);
      expect(restored.category, 'Coding');
      expect(restored.targetFrequency, 5);
    });
  });

  group('GoalModel Serialization & Progress Tests', () {
    test('GoalModel calculates progress percentage correctly', () {
      final goal = GoalModel(
        id: 'g_1',
        title: 'Read 20 Articles',
        targetValue: 20,
        currentValue: 15,
        unit: 'articles',
        period: 'monthly',
        createdAt: DateTime(2026, 9, 1),
      );

      expect(goal.progressPercentage, 75.0);

      final json = goal.toJson();
      expect(json['title'], 'Read 20 Articles');

      final restored = GoalModel.fromJson(json);
      expect(restored.progressPercentage, 75.0);
    });
  });

  group('HabitCompletionModel Tests', () {
    test('HabitCompletionModel converts correctly', () {
      final completion = HabitCompletionModel(
        id: 'h_1_2026-09-14',
        habitId: 'h_1',
        dateStr: '2026-09-14',
        completedAt: DateTime(2026, 9, 14, 8, 30),
      );

      final json = completion.toJson();
      expect(json['habit_id'], 'h_1');
      expect(json['date_str'], '2026-09-14');

      final restored = HabitCompletionModel.fromJson(json);
      expect(restored.habitId, 'h_1');
      expect(restored.dateStr, '2026-09-14');
    });
  });
}
