import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/task_model.dart';
import '../models/habit_model.dart';
import '../models/habit_completion_model.dart';
import '../models/goal_model.dart';
import 'firebase_service.dart';
import 'local_storage_service.dart';

class FirestoreService {
  final FirebaseFirestore? _db =
      FirebaseService.isInitialized ? FirebaseFirestore.instance : null;
  final Uuid _uuid = const Uuid();
  final LocalStorageService _storage = LocalStorageService();

  /// Whether Cloud Firestore is actively initialized and reachable
  bool get isCloudActive => _db != null;

  List<TaskModel> get currentTasks => List.unmodifiable(_mockTasks);
  List<HabitModel> get currentHabits => List.unmodifiable(_mockHabits);
  List<HabitCompletionModel> get currentCompletions => List.unmodifiable(_mockCompletions);
  List<GoalModel> get currentGoals => List.unmodifiable(_mockGoals);

  // Fallback in-memory store if Firebase credentials aren't connected yet
  final List<TaskModel> _mockTasks = [
    TaskModel(
      id: 'mock_1',
      text: 'Review pull request for API integration',
      done: true,
      priority: 'High',
      dueDate: DateTime.now().toIso8601String().substring(0, 10),
      category: 'Coding',
      notes: 'Check authentication middleware & edge cases',
      completedAt: DateTime.now().subtract(const Duration(hours: 1)),
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
    ),
    TaskModel(
      id: 'mock_2',
      text: 'Implement progress analytics pie chart',
      done: true,
      priority: 'High',
      dueDate: DateTime.now().toIso8601String().substring(0, 10),
      category: 'Coding',
      notes: 'Calculate task completion rates and priority breakdown',
      completedAt: DateTime.now().subtract(const Duration(minutes: 30)),
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    TaskModel(
      id: 'mock_3',
      text: 'Draft Q3 productivity roadmap',
      done: false,
      priority: 'High',
      dueDate: DateTime.now().toIso8601String().substring(0, 10),
      category: 'Work',
      notes: 'Align goals with weekly performance benchmarks',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    TaskModel(
      id: 'mock_4',
      text: 'Read documentation & system architecture',
      done: false,
      priority: 'Medium',
      dueDate: DateTime.now().toIso8601String().substring(0, 10),
      category: 'Study',
      notes: 'Focus on Riverpod state flow and reactive providers',
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
    ),
    TaskModel(
      id: 'mock_5',
      text: 'Weekly team sprint planning meeting',
      done: false,
      priority: 'Medium',
      dueDate: DateTime.now().add(const Duration(days: 1)).toIso8601String().substring(0, 10),
      category: 'Work',
      notes: 'Prepare sprint backlog and key deliverables',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    TaskModel(
      id: 'mock_6',
      text: 'Research Flutter web canvas performance',
      done: false,
      priority: 'Low',
      dueDate: DateTime.now().add(const Duration(days: 2)).toIso8601String().substring(0, 10),
      category: 'Browser',
      notes: 'Investigate WASM rendering pipeline in Flutter 3.24+',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    TaskModel(
      id: 'mock_7',
      text: 'Organize workspace & plan tomorrow',
      done: true,
      priority: 'Low',
      dueDate: DateTime.now().toIso8601String().substring(0, 10),
      category: 'Personal',
      notes: 'Set top 3 priorities for the morning',
      completedAt: DateTime.now().subtract(const Duration(hours: 2)),
      createdAt: DateTime.now().subtract(const Duration(hours: 8)),
    ),
  ];

  final List<HabitModel> _mockHabits = [
    HabitModel(
      id: 'habit_1',
      title: 'Wake up early',
      category: 'Health',
      color: '#20BFAE',
      targetFrequency: 7,
      reminderTime: '06:00 AM',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    HabitModel(
      id: 'habit_2',
      title: 'Exercise',
      category: 'Health',
      color: '#3AA66F',
      targetFrequency: 6,
      reminderTime: '07:00 AM',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    HabitModel(
      id: 'habit_3',
      title: 'Read a book',
      category: 'Study',
      color: '#0B2D4D',
      targetFrequency: 7,
      reminderTime: '08:30 PM',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    HabitModel(
      id: 'habit_4',
      title: 'Drink water',
      category: 'Health',
      color: '#20BFAE',
      targetFrequency: 7,
      reminderTime: 'All day',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    HabitModel(
      id: 'habit_5',
      title: 'Healthy eating',
      category: 'Health',
      color: '#3AA66F',
      targetFrequency: 7,
      reminderTime: '01:00 PM',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    HabitModel(
      id: 'habit_6',
      title: 'Learn something new',
      category: 'Study',
      color: '#0B2D4D',
      targetFrequency: 5,
      reminderTime: '05:00 PM',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    HabitModel(
      id: 'habit_7',
      title: 'No social media',
      category: 'Work',
      color: '#20BFAE',
      targetFrequency: 7,
      reminderTime: '09:00 AM',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    HabitModel(
      id: 'habit_8',
      title: 'Meditate',
      category: 'Health',
      color: '#3AA66F',
      targetFrequency: 7,
      reminderTime: '07:30 AM',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    HabitModel(
      id: 'habit_9',
      title: 'Plan tomorrow',
      category: 'Work',
      color: '#0B2D4D',
      targetFrequency: 7,
      reminderTime: '09:30 PM',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    HabitModel(
      id: 'habit_10',
      title: 'Be productive',
      category: 'Work',
      color: '#20BFAE',
      targetFrequency: 7,
      reminderTime: '10:00 AM',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
  ];

  final List<HabitCompletionModel> _mockCompletions = [];
  final List<GoalModel> _mockGoals = [
    GoalModel(
      id: 'goal_1',
      title: 'Complete 30 Focus Sessions',
      targetValue: 30,
      currentValue: 18,
      unit: 'sessions',
      period: 'monthly',
      deadline: 'End of Month',
      category: 'Work',
      linkedType: 'tasks',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    GoalModel(
      id: 'goal_2',
      title: 'Finish DailyWork Flutter app',
      targetValue: 10,
      currentValue: 6,
      unit: 'modules',
      period: 'weekly',
      deadline: 'This Sunday',
      category: 'Work',
      linkedType: 'all',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  final StreamController<List<TaskModel>> _mockTaskStream =
      StreamController<List<TaskModel>>.broadcast();
  final StreamController<List<HabitModel>> _mockHabitStream =
      StreamController<List<HabitModel>>.broadcast();
  final StreamController<List<HabitCompletionModel>> _mockCompletionStream =
      StreamController<List<HabitCompletionModel>>.broadcast();
  final StreamController<List<GoalModel>> _mockGoalStream =
      StreamController<List<GoalModel>>.broadcast();

  FirestoreService() {
    _initLocalStorage();
  }

  Future<void> _initLocalStorage() async {
    try {
      final bool initialized = await _storage.isInitialized();
      if (initialized) {
        final savedTasks = await _storage.loadTasks();
        if (savedTasks != null) {
          _mockTasks.clear();
          _mockTasks.addAll(savedTasks);
        }

        final savedHabits = await _storage.loadHabits();
        if (savedHabits != null) {
          _mockHabits.clear();
          _mockHabits.addAll(savedHabits);
        }

        final savedCompletions = await _storage.loadCompletions();
        if (savedCompletions != null) {
          _mockCompletions.clear();
          _mockCompletions.addAll(savedCompletions);
        }

        final savedGoals = await _storage.loadGoals();
        if (savedGoals != null) {
          _mockGoals.clear();
          _mockGoals.addAll(savedGoals);
        }
      } else {
        _initMockCompletions();
        await _storage.saveTasks(_mockTasks);
        await _storage.saveHabits(_mockHabits);
        await _storage.saveCompletions(_mockCompletions);
        await _storage.saveGoals(_mockGoals);
        await _storage.setInitialized(true);
      }
      triggerMockInitialState();
      debugPrint('[FirestoreService] Local storage loaded: ${_mockTasks.length} tasks, ${_mockHabits.length} habits, ${_mockCompletions.length} completions, ${_mockGoals.length} goals.');
    } catch (e) {
      debugPrint('[FirestoreService] _initLocalStorage error: $e');
    }
  }

  void _initMockCompletions() {
    final now = DateTime.now();
    final year = now.year;
    final month = now.month;

    // Habit completion probability targets to match reference screenshot:
    // W: 90%, E: 80%, R: 85%, D: 75%, H: 60%, L: 70%, N: 65%, M: 85%, P: 55%, B: 75%
    final rates = [0.90, 0.80, 0.85, 0.75, 0.60, 0.70, 0.65, 0.85, 0.55, 0.75];

    // Seed completions for day 1 to 30 of this month
    for (int day = 1; day <= 30; day++) {
      final dateStr =
          '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
      final completionDate = DateTime(year, month, day, 12);

      for (int hIdx = 0; hIdx < _mockHabits.length; hIdx++) {
        final habit = _mockHabits[hIdx];
        final rate = rates[hIdx];

        // Pseudo-random deterministic hash for this habit and day
        final hash = ((day * 37 + (hIdx + 1) * 73) % 100) / 100.0;
        final shouldComplete = hash < rate;

        if (shouldComplete) {
          _mockCompletions.add(HabitCompletionModel(
            id: '${habit.id}_$dateStr',
            habitId: habit.id,
            dateStr: dateStr,
            completedAt: completionDate,
          ));
        }
      }
    }

    // Ensure streak is exactly 18 consecutive days up to today
    for (int i = 0; i < 18; i++) {
      final streakDay = now.subtract(Duration(days: i));
      final dateStr = streakDay.toIso8601String().substring(0, 10);
      // Ensure at least habit_1 is completed on every day in the 18-day streak
      if (!_mockCompletions.any((c) => c.habitId == 'habit_1' && c.dateStr == dateStr)) {
        _mockCompletions.add(HabitCompletionModel(
          id: 'habit_1_$dateStr',
          habitId: 'habit_1',
          dateStr: dateStr,
          completedAt: streakDay,
        ));
      }
    }
  }

  // ================= TASKS =================
  Stream<List<TaskModel>> streamTasks(String uid) {
    final controller = StreamController<List<TaskModel>>.broadcast();
    void emitLatest() {
      if (!controller.isClosed) controller.add(List<TaskModel>.from(_mockTasks));
    }
    controller.onListen = emitLatest;
    emitLatest();

    StreamSubscription? firestoreSub;
    final mockSub = _mockTaskStream.stream.listen(
      (data) {
        if (!controller.isClosed) controller.add(data);
      },
      onError: (e) {
        if (!controller.isClosed) controller.addError(e);
      },
    );

    if (_db != null) {
      try {
        firestoreSub = _db
            .collection('users')
            .doc(uid)
            .collection('tasks')
            .orderBy('created_at', descending: true)
            .snapshots()
            .listen(
          (snapshot) {
            final items = snapshot.docs
                .map((doc) => TaskModel.fromFirestore(doc))
                .toList();
            if (items.isNotEmpty) {
              _mockTasks.clear();
              _mockTasks.addAll(items);
              _storage.saveTasks(_mockTasks);
              if (!controller.isClosed) controller.add(items);
            }
          },
          onError: (error) {
            debugPrint('[FirestoreService] streamTasks error: $error. Using local state.');
          },
        );
      } catch (e) {
        debugPrint('[FirestoreService] Could not attach tasks snapshot listener: $e');
      }
    }

    controller.onCancel = () {
      firestoreSub?.cancel();
      mockSub.cancel();
    };

    return controller.stream;
  }

  Future<void> createTask(String uid, TaskModel task) async {
    final newTask = task.id.isEmpty ? task.copyWith(id: _uuid.v4()) : task;
    _mockTasks.insert(0, newTask);
    _storage.saveTasks(_mockTasks);
    _mockTaskStream.add(List.from(_mockTasks));

    if (_db != null) {
      try {
        final docRef = _db
            .collection('users')
            .doc(uid)
            .collection('tasks')
            .doc(newTask.id);
        await docRef.set(newTask.toFirestore());
      } catch (e) {
        debugPrint('[FirestoreService] createTask Firestore error: $e');
      }
    }
  }

  Future<void> updateTask(String uid, TaskModel task) async {
    final index = _mockTasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _mockTasks[index] = task;
      _storage.saveTasks(_mockTasks);
      _mockTaskStream.add(List.from(_mockTasks));
    }

    if (_db != null) {
      try {
        await _db
            .collection('users')
            .doc(uid)
            .collection('tasks')
            .doc(task.id)
            .update(task.toFirestore());
      } catch (e) {
        debugPrint('[FirestoreService] updateTask Firestore error: $e');
      }
    }
  }

  Future<void> toggleTaskDone(String uid, TaskModel task) async {
    final bool newDone = !task.done;
    final updated = task.copyWith(
      done: newDone,
      completedAt: newDone ? DateTime.now() : null,
    );
    await updateTask(uid, updated);

    // Auto-progress linked goals
    final delta = newDone ? 1.0 : -1.0;
    _autoProgressGoals(
      category: task.category,
      activityType: 'tasks',
      delta: delta,
      uid: uid,
    );
  }

  Future<void> deleteTask(String uid, String taskId) async {
    _mockTasks.removeWhere((t) => t.id == taskId);
    _storage.saveTasks(_mockTasks);
    _mockTaskStream.add(List.from(_mockTasks));

    if (_db != null) {
      try {
        await _db
            .collection('users')
            .doc(uid)
            .collection('tasks')
            .doc(taskId)
            .delete();
      } catch (e) {
        debugPrint('[FirestoreService] deleteTask Firestore error: $e');
      }
    }
  }

  // ================= HABITS =================
  Stream<List<HabitModel>> streamHabits(String uid) {
    final controller = StreamController<List<HabitModel>>.broadcast();
    void emitLatest() {
      if (!controller.isClosed) controller.add(List<HabitModel>.from(_mockHabits));
    }
    controller.onListen = emitLatest;
    emitLatest();

    StreamSubscription? firestoreSub;
    final mockSub = _mockHabitStream.stream.listen(
      (data) {
        if (!controller.isClosed) controller.add(data);
      },
      onError: (e) {
        if (!controller.isClosed) controller.addError(e);
      },
    );

    if (_db != null) {
      try {
        firestoreSub = _db
            .collection('users')
            .doc(uid)
            .collection('habits')
            .orderBy('sort_order')
            .snapshots()
            .listen(
          (snapshot) {
            final items = snapshot.docs
                .map((doc) => HabitModel.fromFirestore(doc))
                .toList();
            if (items.isNotEmpty) {
              _mockHabits.clear();
              _mockHabits.addAll(items);
              _storage.saveHabits(_mockHabits);
              if (!controller.isClosed) controller.add(items);
            }
          },
          onError: (error) {
            debugPrint('[FirestoreService] streamHabits error: $error. Using local state.');
          },
        );
      } catch (e) {
        debugPrint('[FirestoreService] Could not attach habits listener: $e');
      }
    }

    controller.onCancel = () {
      firestoreSub?.cancel();
      mockSub.cancel();
    };

    return controller.stream;
  }

  Future<void> createHabit(String uid, HabitModel habit) async {
    final newHabit = habit.id.isEmpty ? habit.copyWith(id: _uuid.v4()) : habit;
    _mockHabits.add(newHabit);
    _storage.saveHabits(_mockHabits);
    _mockHabitStream.add(List.from(_mockHabits));

    if (_db != null) {
      try {
        final docRef = _db
            .collection('users')
            .doc(uid)
            .collection('habits')
            .doc(newHabit.id);
        await docRef.set(newHabit.toFirestore());
      } catch (e) {
        debugPrint('[FirestoreService] createHabit Firestore error: $e');
      }
    }
  }

  Future<void> updateHabit(String uid, HabitModel habit) async {
    final idx = _mockHabits.indexWhere((h) => h.id == habit.id);
    if (idx != -1) {
      _mockHabits[idx] = habit;
      _storage.saveHabits(_mockHabits);
      _mockHabitStream.add(List.from(_mockHabits));
    }

    if (_db != null) {
      try {
        await _db
            .collection('users')
            .doc(uid)
            .collection('habits')
            .doc(habit.id)
            .update(habit.toFirestore());
      } catch (e) {
        debugPrint('[FirestoreService] updateHabit Firestore error: $e');
      }
    }
  }

  Future<void> deleteHabit(String uid, String habitId) async {
    _mockHabits.removeWhere((h) => h.id == habitId);
    _storage.saveHabits(_mockHabits);
    _mockHabitStream.add(List.from(_mockHabits));

    if (_db != null) {
      try {
        await _db
            .collection('users')
            .doc(uid)
            .collection('habits')
            .doc(habitId)
            .delete();
      } catch (e) {
        debugPrint('[FirestoreService] deleteHabit Firestore error: $e');
      }
    }
  }

  // ================= HABIT COMPLETIONS =================
  Stream<List<HabitCompletionModel>> streamCompletions(String uid) {
    if (_db == null) {
      return _mockCompletionStream.stream;
    }

    final controller = StreamController<List<HabitCompletionModel>>.broadcast();
    void emitLatest() {
      if (!controller.isClosed) {
        controller.add(List<HabitCompletionModel>.from(_mockCompletions));
      }
    }
    controller.onListen = emitLatest;
    emitLatest();

    StreamSubscription? firestoreSub;
    StreamSubscription? mockSub;

    mockSub = _mockCompletionStream.stream.listen(
      (data) {
        if (!controller.isClosed) controller.add(data);
      },
      onError: (e) {
        if (!controller.isClosed) controller.addError(e);
      },
    );

    try {
      firestoreSub = _db
          .collection('users')
          .doc(uid)
          .collection('habit_completions')
          .snapshots()
          .listen(
        (snapshot) {
          final items = snapshot.docs
              .map((doc) => HabitCompletionModel.fromFirestore(doc))
              .toList();
          _mockCompletions.clear();
          _mockCompletions.addAll(items);
          _storage.saveCompletions(_mockCompletions);
          if (!controller.isClosed) {
            controller.add(List<HabitCompletionModel>.from(_mockCompletions));
          }
        },
        onError: (error) {
          debugPrint('[FirestoreService] streamCompletions error: $error. Using local state.');
        },
      );
    } catch (e) {
      debugPrint('[FirestoreService] Could not attach habit_completions listener: $e');
    }

    controller.onCancel = () {
      firestoreSub?.cancel();
      mockSub?.cancel();
    };

    return controller.stream;
  }

  Future<void> toggleCompletion(String uid, String habitId, String dateStr, {bool? isCurrentlyDone}) async {
    final completionId = '${habitId}_$dateStr';

    // 1. Determine whether we are adding or removing without blocking on network get()
    final bool isDone = isCurrentlyDone ?? _mockCompletions.any((c) => c.id == completionId);

    // 2. Immediate optimistic update on local state (0ms)
    if (isDone) {
      _mockCompletions.removeWhere((c) => c.id == completionId);
    } else {
      _mockCompletions.add(HabitCompletionModel(
        id: completionId,
        habitId: habitId,
        dateStr: dateStr,
        completedAt: DateTime.now(),
      ));
    }
    _storage.saveCompletions(_mockCompletions);
    _mockCompletionStream.add(List.from(_mockCompletions));
    debugPrint('[FirestoreService] toggleCompletion optimistic toggle: $habitId (done: ${!isDone})');

    // Auto-progress linked goals if toggling today's habit completion
    final todayStr = DateTime.now().toIso8601String().substring(0, 10);
    if (dateStr == todayStr) {
      final habitIdx = _mockHabits.indexWhere((h) => h.id == habitId);
      final habitCategory = habitIdx != -1 ? _mockHabits[habitIdx].category : null;
      final delta = isDone ? -1.0 : 1.0;
      _autoProgressGoals(
        category: habitCategory,
        activityType: 'habits',
        delta: delta,
        uid: uid,
      );
    }

    // 3. Sync to Cloud Firestore in background without blocking UI
    if (_db != null) {
      try {
        final docRef = _db
            .collection('users')
            .doc(uid)
            .collection('habit_completions')
            .doc(completionId);

        final syncFuture = isDone
            ? docRef.delete()
            : docRef.set({
                'habit_id': habitId,
                'date_str': dateStr,
                'completed_at': Timestamp.now(),
              });

        syncFuture.catchError((e) {
          debugPrint('[FirestoreService] toggleCompletion Firestore write notice: $e');
        });
      } catch (e) {
        debugPrint('[FirestoreService] toggleCompletion Firestore write error: $e');
      }
    }
  }

  // ================= GOALS =================
  Stream<List<GoalModel>> streamGoals(String uid) {
    final controller = StreamController<List<GoalModel>>.broadcast();
    void emitLatest() {
      if (!controller.isClosed) {
        controller.add(List<GoalModel>.from(_mockGoals));
      }
    }
    controller.onListen = emitLatest;
    emitLatest();

    StreamSubscription? firestoreSub;
    final mockSub = _mockGoalStream.stream.listen(
      (data) {
        if (!controller.isClosed) controller.add(data);
      },
      onError: (e) {
        if (!controller.isClosed) controller.addError(e);
      },
    );

    if (_db != null) {
      try {
        firestoreSub = _db
            .collection('users')
            .doc(uid)
            .collection('goals')
            .orderBy('created_at')
            .snapshots()
            .listen(
          (snapshot) {
            final items = snapshot.docs
                .map((doc) => GoalModel.fromFirestore(doc))
                .toList();
            if (items.isNotEmpty) {
              _mockGoals.clear();
              _mockGoals.addAll(items);
              _storage.saveGoals(_mockGoals);
              if (!controller.isClosed) controller.add(items);
            }
          },
          onError: (error) {
            debugPrint('[FirestoreService] streamGoals error: $error. Using local state.');
          },
        );
      } catch (e) {
        debugPrint('[FirestoreService] Could not attach goals listener: $e');
      }
    }

    controller.onCancel = () {
      firestoreSub?.cancel();
      mockSub.cancel();
    };

    return controller.stream;
  }

  Future<void> createGoal(String uid, GoalModel goal) async {
    final newGoal = goal.id.isEmpty ? goal.copyWith(id: _uuid.v4()) : goal;
    _mockGoals.add(newGoal);
    _storage.saveGoals(_mockGoals);
    _mockGoalStream.add(List.from(_mockGoals));

    if (_db != null) {
      try {
        final docRef = _db
            .collection('users')
            .doc(uid)
            .collection('goals')
            .doc(newGoal.id);
        await docRef.set(newGoal.toFirestore());
      } catch (e) {
        debugPrint('[FirestoreService] createGoal Firestore error: $e');
      }
    }
  }

  Future<void> updateGoal(String uid, GoalModel goal) async {
    final idx = _mockGoals.indexWhere((g) => g.id == goal.id);
    if (idx != -1) {
      _mockGoals[idx] = goal;
      _storage.saveGoals(_mockGoals);
      _mockGoalStream.add(List.from(_mockGoals));
    }

    if (_db != null) {
      try {
        await _db
            .collection('users')
            .doc(uid)
            .collection('goals')
            .doc(goal.id)
            .update(goal.toFirestore());
      } catch (e) {
        debugPrint('[FirestoreService] updateGoal Firestore error: $e');
      }
    }
  }

  Future<bool> updateGoalProgress(String uid, String goalId, double delta) async {
    bool newlyAchieved = false;
    final idx = _mockGoals.indexWhere((g) => g.id == goalId);
    if (idx != -1) {
      final cur = _mockGoals[idx].currentValue;
      final target = _mockGoals[idx].targetValue;
      final updatedVal = (cur + delta).clamp(0.0, 9999999.0);
      _mockGoals[idx] = _mockGoals[idx].copyWith(currentValue: updatedVal);
      if (cur < target && updatedVal >= target && target > 0) {
        newlyAchieved = true;
      }
      _storage.saveGoals(_mockGoals);
      _mockGoalStream.add(List.from(_mockGoals));
    }

    if (_db != null) {
      try {
        final docRef = _db
            .collection('users')
            .doc(uid)
            .collection('goals')
            .doc(goalId);
        await docRef.update({
          'current_value': FieldValue.increment(delta),
        });
      } catch (e) {
        debugPrint('[FirestoreService] updateGoalProgress Firestore error: $e');
      }
    }
    return newlyAchieved;
  }

  Future<bool> setGoalProgress(String uid, String goalId, double exactValue) async {
    bool newlyAchieved = false;
    final idx = _mockGoals.indexWhere((g) => g.id == goalId);
    if (idx != -1) {
      final cur = _mockGoals[idx].currentValue;
      final target = _mockGoals[idx].targetValue;
      final updatedVal = exactValue.clamp(0.0, 9999999.0);
      _mockGoals[idx] = _mockGoals[idx].copyWith(currentValue: updatedVal);
      if (cur < target && updatedVal >= target && target > 0) {
        newlyAchieved = true;
      }
      _storage.saveGoals(_mockGoals);
      _mockGoalStream.add(List.from(_mockGoals));
    }

    if (_db != null) {
      try {
        final docRef = _db
            .collection('users')
            .doc(uid)
            .collection('goals')
            .doc(goalId);
        await docRef.update({
          'current_value': exactValue,
        });
      } catch (e) {
        debugPrint('[FirestoreService] setGoalProgress Firestore error: $e');
      }
    }
    return newlyAchieved;
  }

  void _autoProgressGoals({
    required String? category,
    required String activityType,
    required double delta,
    required String uid,
  }) {
    bool anyChanged = false;
    for (int i = 0; i < _mockGoals.length; i++) {
      final goal = _mockGoals[i];
      if (goal.linkedType == 'manual') continue;

      final matchesType = goal.linkedType == 'all' || goal.linkedType == activityType;
      final matchesCategory = goal.category == null ||
          goal.category == 'All' ||
          (category != null &&
              goal.category?.trim().toLowerCase() == category.trim().toLowerCase());

      if (matchesType && matchesCategory) {
        final newVal = (goal.currentValue + delta).clamp(0.0, 9999999.0);
        _mockGoals[i] = goal.copyWith(currentValue: newVal);
        anyChanged = true;

        if (_db != null) {
          try {
            _db.collection('users').doc(uid).collection('goals').doc(goal.id).update({
              'current_value': FieldValue.increment(delta),
            }).catchError((_) {});
          } catch (_) {}
        }
      }
    }
    if (anyChanged) {
      _storage.saveGoals(_mockGoals);
      _mockGoalStream.add(List.from(_mockGoals));
    }
  }

  Future<void> deleteGoal(String uid, String goalId) async {
    _mockGoals.removeWhere((g) => g.id == goalId);
    _storage.saveGoals(_mockGoals);
    _mockGoalStream.add(List.from(_mockGoals));

    if (_db != null) {
      try {
        await _db
            .collection('users')
            .doc(uid)
            .collection('goals')
            .doc(goalId)
            .delete();
      } catch (e) {
        debugPrint('[FirestoreService] deleteGoal Firestore error: $e');
      }
    }
  }

  // Initial mock pump
  void triggerMockInitialState() {
    _mockTaskStream.add(List.from(_mockTasks));
    _mockHabitStream.add(List.from(_mockHabits));
    _mockCompletionStream.add(List.from(_mockCompletions));
    _mockGoalStream.add(List.from(_mockGoals));
  }

  // Clear all sample demo data so the user can track their actual real data
  void clearSampleData() {
    _mockTasks.clear();
    _mockHabits.clear();
    _mockCompletions.clear();
    _mockGoals.clear();
    _storage.clearAll();
    _storage.setInitialized(true);
    _mockTaskStream.add([]);
    _mockHabitStream.add([]);
    _mockCompletionStream.add([]);
    _mockGoalStream.add([]);
  }

  /// Generates a structured snapshot payload of current local models for synchronization or inspection
  Map<String, dynamic> prepareSyncPayload() {
    return {
      'tasks': _mockTasks.map((t) => t.toFirestore()).toList(),
      'habits': _mockHabits.map((h) => h.toFirestore()).toList(),
      'completions': _mockCompletions.map((c) => c.toFirestore()).toList(),
      'goals': _mockGoals.map((g) => g.toFirestore()).toList(),
      'summary': {
        'tasksCount': _mockTasks.length,
        'habitsCount': _mockHabits.length,
        'completionsCount': _mockCompletions.length,
        'goalsCount': _mockGoals.length,
        'totalCount': _mockTasks.length + _mockHabits.length + _mockCompletions.length + _mockGoals.length,
      }
    };
  }

  /// Synchronize all local offline data to Cloud Firestore under users/{uid}/...
  /// Uses batched writes to ensure high performance and atomicity.
  Future<Map<String, int>> syncLocalToCloud(String uid) async {
    if (_db == null) {
      throw StateError('Cloud Firestore is not active. Firebase is running in offline/demo mode.');
    }

    final int tasksSynced = _mockTasks.length;
    final int habitsSynced = _mockHabits.length;
    final int completionsSynced = _mockCompletions.length;
    final int goalsSynced = _mockGoals.length;

    // Collect all write operations
    final List<MapEntry<DocumentReference, Map<String, dynamic>>> operations = [];
    final userDoc = _db.collection('users').doc(uid);

    for (final task in _mockTasks) {
      final docRef = userDoc.collection('tasks').doc(task.id);
      operations.add(MapEntry(docRef, task.toFirestore()));
    }

    for (final habit in _mockHabits) {
      final docRef = userDoc.collection('habits').doc(habit.id);
      operations.add(MapEntry(docRef, habit.toFirestore()));
    }

    for (final completion in _mockCompletions) {
      final docRef = userDoc.collection('habit_completions').doc(completion.id);
      operations.add(MapEntry(docRef, completion.toFirestore()));
    }

    for (final goal in _mockGoals) {
      final docRef = userDoc.collection('goals').doc(goal.id);
      operations.add(MapEntry(docRef, goal.toFirestore()));
    }

    // Commit in chunks of up to 400 (Firestore maximum batch size is 500)
    const int chunkSize = 400;
    for (int i = 0; i < operations.length; i += chunkSize) {
      final chunk = operations.sublist(
        i,
        (i + chunkSize > operations.length) ? operations.length : i + chunkSize,
      );
      final batch = _db.batch();
      for (final op in chunk) {
        batch.set(op.key, op.value, SetOptions(merge: true));
      }
      await batch.commit();
    }

    debugPrint('[FirestoreService] syncLocalToCloud complete for $uid: $tasksSynced tasks, $habitsSynced habits, $completionsSynced completions, $goalsSynced goals.');

    return {
      'tasks': tasksSynced,
      'habits': habitsSynced,
      'completions': completionsSynced,
      'goals': goalsSynced,
      'total': tasksSynced + habitsSynced + completionsSynced + goalsSynced,
    };
  }

  /// Download and pull cloud data from Cloud Firestore into local offline storage.
  Future<Map<String, int>> fetchCloudToLocal(String uid) async {
    if (_db == null) {
      throw StateError('Cloud Firestore is not active. Firebase is running in offline/demo mode.');
    }

    final userDoc = _db.collection('users').doc(uid);

    final tasksSnap = await userDoc.collection('tasks').get();
    final habitsSnap = await userDoc.collection('habits').get();
    final completionsSnap = await userDoc.collection('habit_completions').get();
    final goalsSnap = await userDoc.collection('goals').get();

    final cloudTasks = tasksSnap.docs.map((d) => TaskModel.fromFirestore(d)).toList();
    final cloudHabits = habitsSnap.docs.map((d) => HabitModel.fromFirestore(d)).toList();
    final cloudCompletions = completionsSnap.docs.map((d) => HabitCompletionModel.fromFirestore(d)).toList();
    final cloudGoals = goalsSnap.docs.map((d) => GoalModel.fromFirestore(d)).toList();

    if (cloudTasks.isNotEmpty) {
      _mockTasks.clear();
      _mockTasks.addAll(cloudTasks);
      await _storage.saveTasks(_mockTasks);
      _mockTaskStream.add(List.from(_mockTasks));
    }

    if (cloudHabits.isNotEmpty) {
      _mockHabits.clear();
      _mockHabits.addAll(cloudHabits);
      await _storage.saveHabits(_mockHabits);
      _mockHabitStream.add(List.from(_mockHabits));
    }

    if (cloudCompletions.isNotEmpty) {
      _mockCompletions.clear();
      _mockCompletions.addAll(cloudCompletions);
      await _storage.saveCompletions(_mockCompletions);
      _mockCompletionStream.add(List.from(_mockCompletions));
    }

    if (cloudGoals.isNotEmpty) {
      _mockGoals.clear();
      _mockGoals.addAll(cloudGoals);
      await _storage.saveGoals(_mockGoals);
      _mockGoalStream.add(List.from(_mockGoals));
    }

    debugPrint('[FirestoreService] fetchCloudToLocal complete: ${cloudTasks.length} tasks, ${cloudHabits.length} habits, ${cloudCompletions.length} completions, ${cloudGoals.length} goals.');

    return {
      'tasks': cloudTasks.length,
      'habits': cloudHabits.length,
      'completions': cloudCompletions.length,
      'goals': cloudGoals.length,
      'total': cloudTasks.length + cloudHabits.length + cloudCompletions.length + cloudGoals.length,
    };
  }
}
