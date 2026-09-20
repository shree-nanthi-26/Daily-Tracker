import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:daily_work_mobile/models/goal_model.dart';
import 'package:daily_work_mobile/models/task_model.dart';
import 'package:daily_work_mobile/providers/goal_provider.dart';
import 'package:daily_work_mobile/services/firestore_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Phase 4 GoalModel & Progress Tests', () {
    test('GoalModel correctly parses category, linkedType, and calculates isAchieved', () {
      final goal = GoalModel(
        id: 'g_test',
        title: 'Run 10km',
        targetValue: 10,
        currentValue: 8,
        unit: 'km',
        category: 'Health',
        linkedType: 'habits',
        createdAt: DateTime(2026, 9, 20),
      );

      expect(goal.isAchieved, false);
      expect(goal.category, 'Health');
      expect(goal.linkedType, 'habits');
      expect(goal.progressPercentage, 80.0);

      final achievedGoal = goal.copyWith(currentValue: 10);
      expect(achievedGoal.isAchieved, true);
      expect(achievedGoal.progressPercentage, 100.0);

      final overachievedGoal = goal.copyWith(currentValue: 12);
      expect(overachievedGoal.isAchieved, true);
      expect(overachievedGoal.progressPercentage, 100.0);
    });

    test('GoalModel JSON serialization and deserialization preserves all fields', () {
      final goal = GoalModel(
        id: 'g_json',
        title: 'Complete 25 Modules',
        targetValue: 25,
        currentValue: 15,
        unit: 'modules',
        period: 'monthly',
        deadline: 'End of Month',
        category: 'Work',
        linkedType: 'tasks',
        createdAt: DateTime(2026, 9, 20),
      );

      final json = goal.toJson();
      expect(json['category'], 'Work');
      expect(json['linked_type'], 'tasks');

      final deserialized = GoalModel.fromJson(json);
      expect(deserialized.id, 'g_json');
      expect(deserialized.title, 'Complete 25 Modules');
      expect(deserialized.category, 'Work');
      expect(deserialized.linkedType, 'tasks');
      expect(deserialized.currentValue, 15);
      expect(deserialized.targetValue, 25);
    });
  });

  group('Phase 4 Auto-Progress Goals Integration Tests', () {
    test('Completing a matching task automatically increments linked goal', () async {
      final firestore = FirestoreService();
      const uid = 'test_user';

      // Create a Work goal linked to tasks
      final goal = GoalModel(
        id: 'g_work',
        title: 'Finish 5 Work Tasks',
        targetValue: 5,
        currentValue: 2,
        unit: 'tasks',
        category: 'Work',
        linkedType: 'tasks',
        createdAt: DateTime.now(),
      );
      await firestore.createGoal(uid, goal);

      // Create a Work task
      final task = TaskModel(
        id: 't_work_1',
        text: 'Deploy API server',
        category: 'Work',
        done: false,
        createdAt: DateTime.now(),
      );
      await firestore.createTask(uid, task);

      // Mark task as done
      await firestore.toggleTaskDone(uid, task);

      // Verify the goal was automatically incremented by 1
      final goals = await firestore.streamGoals(uid).first;
      final updatedGoal = goals.firstWhere((g) => g.id == 'g_work');
      expect(updatedGoal.currentValue, 3.0);

      // Uncheck task
      final completedTask = task.copyWith(done: true);
      await firestore.toggleTaskDone(uid, completedTask);

      // Verify the goal was decremented back to 2
      final goalsAfter = await firestore.streamGoals(uid).first;
      final revertedGoal = goalsAfter.firstWhere((g) => g.id == 'g_work');
      expect(revertedGoal.currentValue, 2.0);
    });

    test('Non-matching category task does NOT increment goal', () async {
      final firestore = FirestoreService();
      const uid = 'test_user_2';

      final goal = GoalModel(
        id: 'g_health',
        title: 'Gym sessions',
        targetValue: 10,
        currentValue: 4,
        unit: 'sessions',
        category: 'Health',
        linkedType: 'tasks',
        createdAt: DateTime.now(),
      );
      await firestore.createGoal(uid, goal);

      final personalTask = TaskModel(
        id: 't_personal_1',
        text: 'Grocery shopping',
        category: 'Personal',
        done: false,
        createdAt: DateTime.now(),
      );
      await firestore.createTask(uid, personalTask);

      // Toggle personal task
      await firestore.toggleTaskDone(uid, personalTask);

      final goals = await firestore.streamGoals(uid).first;
      final currentHealthGoal = goals.firstWhere((g) => g.id == 'g_health');
      expect(currentHealthGoal.currentValue, 4.0); // Unchanged!
    });

    test('updateGoalProgress returns newlyAchieved = true when hitting target', () async {
      final firestore = FirestoreService();
      const uid = 'test_user_3';

      final goal = GoalModel(
        id: 'g_milestone',
        title: 'Hit 10 milestones',
        targetValue: 10,
        currentValue: 9,
        unit: 'milestones',
        createdAt: DateTime.now(),
      );
      await firestore.createGoal(uid, goal);

      // Increment from 9 to 10
      final newlyAchieved = await firestore.updateGoalProgress(uid, 'g_milestone', 1);
      expect(newlyAchieved, true);

      // Increment again from 10 to 11 (already achieved, so newlyAchieved is false)
      final againAchieved = await firestore.updateGoalProgress(uid, 'g_milestone', 1);
      expect(againAchieved, false);
    });

    test('setGoalProgress allows direct value setting', () async {
      final firestore = FirestoreService();
      const uid = 'test_user_4';

      final goal = GoalModel(
        id: 'g_exact',
        title: 'Read 20 articles',
        targetValue: 20,
        currentValue: 5,
        unit: 'articles',
        createdAt: DateTime.now(),
      );
      await firestore.createGoal(uid, goal);

      final newlyAchieved = await firestore.setGoalProgress(uid, 'g_exact', 20);
      expect(newlyAchieved, true);

      final goals = await firestore.streamGoals(uid).first;
      final exactGoal = goals.firstWhere((g) => g.id == 'g_exact');
      expect(exactGoal.currentValue, 20.0);
      expect(exactGoal.isAchieved, true);
    });
  });

  group('Phase 4 Goal Filter & Count Tests', () {
    test('Filtered goals and counts separate active and achieved accurately', () async {
      final sampleGoals = [
        GoalModel(
          id: 'g1',
          title: 'Goal 1 Incomplete',
          targetValue: 10,
          currentValue: 5,
          unit: 'units',
          createdAt: DateTime.now(),
        ),
        GoalModel(
          id: 'g2',
          title: 'Goal 2 Complete',
          targetValue: 10,
          currentValue: 10,
          unit: 'units',
          createdAt: DateTime.now(),
        ),
      ];

      final container = ProviderContainer(
        overrides: [
          goalsStreamProvider.overrideWith((ref) => Stream.value(sampleGoals)),
        ],
      );
      await container.read(goalsStreamProvider.future);

      final counts = container.read(goalCountsProvider);
      expect(counts[GoalFilterTab.all], 2);
      expect(counts[GoalFilterTab.active], 1);
      expect(counts[GoalFilterTab.achieved], 1);

      container.read(goalFilterTabProvider.notifier).state = GoalFilterTab.achieved;
      final achievedList = container.read(filteredGoalsProvider);
      expect(achievedList.length, 1);
      expect(achievedList.first.id, 'g2');

      container.read(goalFilterTabProvider.notifier).state = GoalFilterTab.active;
      final activeList = container.read(filteredGoalsProvider);
      expect(activeList.length, 1);
      expect(activeList.first.id, 'g1');
    });
  });
}
