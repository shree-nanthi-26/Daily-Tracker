import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../services/auth_service.dart';
import '../services/local_storage_service.dart';
import 'auth_provider.dart';
import 'goal_provider.dart';
import 'habit_provider.dart';
import 'task_provider.dart';

enum AppThemeMode {
  deepNavy('Deep Navy', 'Desktop classic navy theme with teal accents', Icons.brightness_medium_rounded),
  amoledBlack('AMOLED Black', 'Pure #000000 dark mode with cyan highlights', Icons.dark_mode_rounded),
  modernLight('Modern Light', 'Clean slate light layout with high clarity', Icons.light_mode_rounded);

  final String label;
  final String description;
  final IconData icon;
  const AppThemeMode(this.label, this.description, this.icon);
}

/// Provider for LocalStorageService
final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService();
});

/// StateNotifier for ThemeMode preference
class ThemeModeNotifier extends StateNotifier<AppThemeMode> {
  final LocalStorageService _storage;

  ThemeModeNotifier(this._storage) : super(AppThemeMode.deepNavy) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final savedMode = await _storage.loadThemeMode();
    if (savedMode != null) {
      for (final mode in AppThemeMode.values) {
        if (mode.name == savedMode) {
          state = mode;
          break;
        }
      }
    }
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    state = mode;
    await _storage.saveThemeMode(mode.name);
  }
}

final themeModePreferenceProvider =
    StateNotifierProvider<ThemeModeNotifier, AppThemeMode>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return ThemeModeNotifier(storage);
});

/// Maps the active AppThemeMode to Flutter ThemeData
final appThemeDataProvider = Provider<ThemeData>((ref) {
  final mode = ref.watch(themeModePreferenceProvider);
  switch (mode) {
    case AppThemeMode.deepNavy:
      return AppTheme.deepNavyTheme;
    case AppThemeMode.amoledBlack:
      return AppTheme.amoledBlackTheme;
    case AppThemeMode.modernLight:
      return AppTheme.modernLightTheme;
  }
});

/// StateNotifier for sensory haptics toggle
class HapticsNotifier extends StateNotifier<bool> {
  final LocalStorageService _storage;

  HapticsNotifier(this._storage) : super(true) {
    _loadHaptics();
  }

  Future<void> _loadHaptics() async {
    final saved = await _storage.loadHapticsEnabled();
    state = saved;
  }

  Future<void> setEnabled(bool enabled) async {
    state = enabled;
    await _storage.saveHapticsEnabled(enabled);
  }
}

final hapticsEnabledProvider =
    StateNotifierProvider<HapticsNotifier, bool>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return HapticsNotifier(storage);
});

/// StateNotifier for custom user display name
class UserDisplayNameNotifier extends StateNotifier<String> {
  final LocalStorageService _storage;
  final AuthService _auth;

  UserDisplayNameNotifier(this._storage, this._auth) : super('Shree Nantheeshwaran') {
    _loadDisplayName();
  }

  Future<void> _loadDisplayName() async {
    final saved = await _storage.loadDisplayName();
    if (saved != null && saved.trim().isNotEmpty) {
      state = saved.trim();
      return;
    }
    final authName = _auth.currentUser?.displayName;
    if (authName != null && authName.trim().isNotEmpty && authName != 'demo') {
      state = authName.trim();
    }
  }

  Future<void> updateDisplayName(String newName) async {
    final trimmed = newName.trim();
    if (trimmed.isEmpty) return;
    state = trimmed;
    await _storage.saveDisplayName(trimmed);
  }
}

final userDisplayNameProvider =
    StateNotifierProvider<UserDisplayNameNotifier, String>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  final auth = ref.watch(authServiceProvider);
  return UserDisplayNameNotifier(storage, auth);
});

/// Model aggregating workspace statistics for Settings Data overview
class WorkspaceDataStats {
  final int totalTasks;
  final int completedTasks;
  final int totalHabits;
  final int activeHabits;
  final int archivedHabits;
  final int totalCompletions;
  final int totalGoals;
  final int achievedGoals;

  const WorkspaceDataStats({
    required this.totalTasks,
    required this.completedTasks,
    required this.totalHabits,
    required this.activeHabits,
    required this.archivedHabits,
    required this.totalCompletions,
    required this.totalGoals,
    required this.achievedGoals,
  });
}

final dataStatsProvider = Provider<WorkspaceDataStats>((ref) {
  final tasks = ref.watch(tasksStreamProvider).value ?? [];
  final habits = ref.watch(habitsStreamProvider).value ?? [];
  final goals = ref.watch(goalsStreamProvider).value ?? [];
  final completionsMap = ref.watch(habitCompletionsMapProvider);

  int completionsCount = 0;
  for (final list in completionsMap.values) {
    completionsCount += list.length;
  }

  return WorkspaceDataStats(
    totalTasks: tasks.length,
    completedTasks: tasks.where((t) => t.done).length,
    totalHabits: habits.length,
    activeHabits: habits.where((h) => !h.isArchived).length,
    archivedHabits: habits.where((h) => h.isArchived).length,
    totalCompletions: completionsCount,
    totalGoals: goals.length,
    achievedGoals: goals.where((g) => g.isAchieved).length,
  );
});
