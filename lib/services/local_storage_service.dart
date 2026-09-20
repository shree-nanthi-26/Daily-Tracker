import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task_model.dart';
import '../models/habit_model.dart';
import '../models/habit_completion_model.dart';
import '../models/goal_model.dart';

/// Service responsible for persisting tasks, habits, completions, and goals
/// locally on the device so that all data survives app restarts, process kills,
/// and offline sessions.
class LocalStorageService {
  static const String _kTasksKey = 'dailywork_local_tasks';
  static const String _kHabitsKey = 'dailywork_local_habits';
  static const String _kCompletionsKey = 'dailywork_local_completions';
  static const String _kGoalsKey = 'dailywork_local_goals';
  static const String _kInitializedKey = 'dailywork_local_initialized';

  SharedPreferences? _prefs;

  Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Check if the local database has been initialized previously
  Future<bool> isInitialized() async {
    try {
      final prefs = await _getPrefs();
      return prefs.getBool(_kInitializedKey) ?? false;
    } catch (e) {
      debugPrint('[LocalStorageService] isInitialized error: $e');
      return false;
    }
  }

  Future<void> setInitialized(bool value) async {
    try {
      final prefs = await _getPrefs();
      await prefs.setBool(_kInitializedKey, value);
    } catch (e) {
      debugPrint('[LocalStorageService] setInitialized error: $e');
    }
  }

  // ================= TASKS =================
  Future<List<TaskModel>?> loadTasks() async {
    try {
      final prefs = await _getPrefs();
      final jsonStr = prefs.getString(_kTasksKey);
      if (jsonStr == null || jsonStr.isEmpty) return null;

      final List<dynamic> list = jsonDecode(jsonStr);
      return list
          .map((item) => TaskModel.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    } catch (e) {
      debugPrint('[LocalStorageService] loadTasks error: $e');
      return null;
    }
  }

  Future<void> saveTasks(List<TaskModel> tasks) async {
    try {
      final prefs = await _getPrefs();
      final jsonStr = jsonEncode(tasks.map((t) => t.toJson()).toList());
      await prefs.setString(_kTasksKey, jsonStr);
    } catch (e) {
      debugPrint('[LocalStorageService] saveTasks error: $e');
    }
  }

  // ================= HABITS =================
  Future<List<HabitModel>?> loadHabits() async {
    try {
      final prefs = await _getPrefs();
      final jsonStr = prefs.getString(_kHabitsKey);
      if (jsonStr == null || jsonStr.isEmpty) return null;

      final List<dynamic> list = jsonDecode(jsonStr);
      return list
          .map((item) => HabitModel.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    } catch (e) {
      debugPrint('[LocalStorageService] loadHabits error: $e');
      return null;
    }
  }

  Future<void> saveHabits(List<HabitModel> habits) async {
    try {
      final prefs = await _getPrefs();
      final jsonStr = jsonEncode(habits.map((h) => h.toJson()).toList());
      await prefs.setString(_kHabitsKey, jsonStr);
    } catch (e) {
      debugPrint('[LocalStorageService] saveHabits error: $e');
    }
  }

  // ================= HABIT COMPLETIONS =================
  Future<List<HabitCompletionModel>?> loadCompletions() async {
    try {
      final prefs = await _getPrefs();
      final jsonStr = prefs.getString(_kCompletionsKey);
      if (jsonStr == null || jsonStr.isEmpty) return null;

      final List<dynamic> list = jsonDecode(jsonStr);
      return list
          .map((item) => HabitCompletionModel.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    } catch (e) {
      debugPrint('[LocalStorageService] loadCompletions error: $e');
      return null;
    }
  }

  Future<void> saveCompletions(List<HabitCompletionModel> completions) async {
    try {
      final prefs = await _getPrefs();
      final jsonStr = jsonEncode(completions.map((c) => c.toJson()).toList());
      await prefs.setString(_kCompletionsKey, jsonStr);
    } catch (e) {
      debugPrint('[LocalStorageService] saveCompletions error: $e');
    }
  }

  // ================= GOALS =================
  Future<List<GoalModel>?> loadGoals() async {
    try {
      final prefs = await _getPrefs();
      final jsonStr = prefs.getString(_kGoalsKey);
      if (jsonStr == null || jsonStr.isEmpty) return null;

      final List<dynamic> list = jsonDecode(jsonStr);
      return list
          .map((item) => GoalModel.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    } catch (e) {
      debugPrint('[LocalStorageService] loadGoals error: $e');
      return null;
    }
  }

  Future<void> saveGoals(List<GoalModel> goals) async {
    try {
      final prefs = await _getPrefs();
      final jsonStr = jsonEncode(goals.map((g) => g.toJson()).toList());
      await prefs.setString(_kGoalsKey, jsonStr);
    } catch (e) {
      debugPrint('[LocalStorageService] saveGoals error: $e');
    }
  }

  // ================= CLEAR ALL =================
  Future<void> clearAll() async {
    try {
      final prefs = await _getPrefs();
      await prefs.remove(_kTasksKey);
      await prefs.remove(_kHabitsKey);
      await prefs.remove(_kCompletionsKey);
      await prefs.remove(_kGoalsKey);
      await prefs.remove(_kInitializedKey);
    } catch (e) {
      debugPrint('[LocalStorageService] clearAll error: $e');
    }
  }
}
