import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:daily_work_mobile/models/habit_model.dart';
import 'package:daily_work_mobile/services/local_storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Phase 2 Habit Enhancements & Archiving Tests', () {
    test('HabitModel defaults to isArchived=false', () {
      final habit = HabitModel(
        id: 'h_1',
        title: 'Morning Run',
        createdAt: DateTime(2026, 9, 20),
      );

      expect(habit.isArchived, false);
    });

    test('HabitModel copyWith toggles isArchived properly', () {
      final habit = HabitModel(
        id: 'h_1',
        title: 'Morning Run',
        isArchived: false,
        createdAt: DateTime(2026, 9, 20),
      );

      final archived = habit.copyWith(isArchived: true);
      expect(archived.isArchived, true);
      expect(archived.title, 'Morning Run');

      final restored = archived.copyWith(isArchived: false);
      expect(restored.isArchived, false);
    });

    test('HabitModel serializes and deserializes isArchived', () {
      final habit = HabitModel(
        id: 'h_2',
        title: 'Deep Meditation',
        category: 'Health',
        color: '#10B981',
        targetFrequency: 5,
        reminderTime: '07:00 AM',
        isArchived: true,
        createdAt: DateTime(2026, 9, 20),
      );

      final json = habit.toJson();
      expect(json['is_archived'], true);

      final fromJson = HabitModel.fromJson(json);
      expect(fromJson.id, 'h_2');
      expect(fromJson.title, 'Deep Meditation');
      expect(fromJson.isArchived, true);
      expect(fromJson.targetFrequency, 5);
      expect(fromJson.reminderTime, '07:00 AM');
    });

    test('LocalStorage persists and retrieves archived habits', () async {
      final storage = LocalStorageService();

      final activeHabit = HabitModel(
        id: 'h_active',
        title: 'Active Habit',
        isArchived: false,
        createdAt: DateTime(2026, 9, 20),
      );

      final archivedHabit = HabitModel(
        id: 'h_archived',
        title: 'Paused Habit',
        isArchived: true,
        createdAt: DateTime(2026, 9, 20),
      );

      await storage.saveHabits([activeHabit, archivedHabit]);

      final loaded = await storage.loadHabits();
      expect(loaded, isNotNull);
      expect(loaded!.length, 2);

      final activeOnly = loaded.where((h) => !h.isArchived).toList();
      final archivedOnly = loaded.where((h) => h.isArchived).toList();

      expect(activeOnly.length, 1);
      expect(activeOnly.first.title, 'Active Habit');

      expect(archivedOnly.length, 1);
      expect(archivedOnly.first.title, 'Paused Habit');
    });
  });
}
