import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/goal_model.dart';
import 'auth_provider.dart';
import 'task_provider.dart';

final goalsStreamProvider = StreamProvider<List<GoalModel>>((ref) {
  final uid = ref.watch(currentUserIdProvider);
  final firestore = ref.watch(firestoreServiceProvider);
  return firestore.streamGoals(uid);
});

final activeGoalsCountProvider = Provider<int>((ref) {
  final goals = ref.watch(goalsStreamProvider).value ?? [];
  return goals.where((g) => g.progressPercentage < 100.0).length;
});
