import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/utils/date_formatter.dart';
import '../models/habit_model.dart';
import '../services/notification_service.dart';
import 'habit_provider.dart';

class HabitReminderItem {
  final HabitModel habit;
  final TimeOfDay? time;
  final String reminderTimeStr;
  final bool isCompletedToday;
  final int sortMinutes;

  const HabitReminderItem({
    required this.habit,
    required this.time,
    required this.reminderTimeStr,
    required this.isCompletedToday,
    required this.sortMinutes,
  });
}

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

/// List of all scheduled habit reminders for today with completion status
final scheduledHabitRemindersProvider = Provider<List<HabitReminderItem>>((ref) {
  final allHabits = ref.watch(habitsStreamProvider).value ?? [];
  final activeHabits = allHabits.where((h) => !h.isArchived).toList();
  final completionsMap = ref.watch(habitCompletionsMapProvider);
  final todayStr = DateFormatter.todayIso();

  final List<HabitReminderItem> items = [];

  for (final habit in activeHabits) {
    if (habit.reminderTime == null || habit.reminderTime!.trim().isEmpty) continue;

    final parsedTime = NotificationService.parseReminderTime(habit.reminderTime);
    final isDone = completionsMap[habit.id]?.contains(todayStr) ?? false;
    final minutes = parsedTime != null ? (parsedTime.hour * 60 + parsedTime.minute) : 9999;

    items.add(
      HabitReminderItem(
        habit: habit,
        time: parsedTime,
        reminderTimeStr: habit.reminderTime!,
        isCompletedToday: isDone,
        sortMinutes: minutes,
      ),
    );
  }

  // Sort: Pending items first by time of day, then completed items
  items.sort((a, b) {
    if (a.isCompletedToday != b.isCompletedToday) {
      return a.isCompletedToday ? 1 : -1;
    }
    return a.sortMinutes.compareTo(b.sortMinutes);
  });

  return items;
});

/// Count of pending (uncompleted) habit reminders for today
final pendingRemindersCountProvider = Provider<int>((ref) {
  final reminders = ref.watch(scheduledHabitRemindersProvider);
  return reminders.where((r) => !r.isCompletedToday).length;
});
