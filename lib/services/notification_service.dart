import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import '../models/habit_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  static const String channelId = 'habit_reminders_channel';
  static const String channelName = 'Habit Reminders';
  static const String channelDesc = 'Daily notifications and reminders for your scheduled habits';

  /// Parse strings like '07:00 AM', '8:30 PM', '14:00', '9:15 AM' into TimeOfDay
  static TimeOfDay? parseReminderTime(String? timeStr) {
    if (timeStr == null || timeStr.trim().isEmpty) return null;
    final clean = timeStr.trim();

    // Match 12-hour format with AM/PM (e.g., '07:00 AM', '7:30 pm', '12:00 PM')
    final amPmMatch =
        RegExp(r'^(\d{1,2}):(\d{2})\s*(AM|PM)$', caseSensitive: false)
            .firstMatch(clean);
    if (amPmMatch != null) {
      int hour = int.parse(amPmMatch.group(1)!);
      final minute = int.parse(amPmMatch.group(2)!);
      final isPm = amPmMatch.group(3)!.toUpperCase() == 'PM';
      if (isPm && hour < 12) hour += 12;
      if (!isPm && hour == 12) hour = 0;
      if (hour >= 0 && hour < 24 && minute >= 0 && minute < 60) {
        return TimeOfDay(hour: hour, minute: minute);
      }
    }

    // Match 24-hour military format (e.g. '19:30', '08:00')
    final militaryMatch = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(clean);
    if (militaryMatch != null) {
      final hour = int.parse(militaryMatch.group(1)!);
      final minute = int.parse(militaryMatch.group(2)!);
      if (hour >= 0 && hour < 24 && minute >= 0 && minute < 60) {
        return TimeOfDay(hour: hour, minute: minute);
      }
    }

    return null;
  }

  /// Initialize local notification channels and timezone data
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      tz_data.initializeTimeZones();

      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
        macOS: darwinSettings,
      );

      await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (response) {
          debugPrint('[NotificationService] Notification tapped: ${response.payload}');
        },
      );

      // Create Android High Importance notification channel
      final androidImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        await androidImplementation.createNotificationChannel(
          const AndroidNotificationChannel(
            channelId,
            channelName,
            description: channelDesc,
            importance: Importance.high,
            playSound: true,
            enableVibration: true,
          ),
        );
        // Request runtime permission on Android 13+ (API 33+)
        await androidImplementation.requestNotificationsPermission();
      }

      _isInitialized = true;
      debugPrint('[NotificationService] Successfully initialized local notification alarms');
    } catch (e) {
      debugPrint('[NotificationService] Initialization error (safe fallback): $e');
    }
  }

  NotificationDetails _getNotificationDetails(String? category) {
    const androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDesc,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFF20BFAE), // Teal accent
      styleInformation: DefaultStyleInformation(true, true),
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    return const NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );
  }

  /// Trigger instant test notification
  Future<void> showInstantNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      await _notificationsPlugin.show(
        99999,
        title,
        body,
        _getNotificationDetails('Test'),
        payload: payload,
      );
    } catch (e) {
      debugPrint('[NotificationService] showInstantNotification error: $e');
    }
  }

  /// Schedule daily repeating reminder for a habit
  Future<void> scheduleHabitReminder(HabitModel habit) async {
    if (habit.isArchived || habit.reminderTime == null) {
      await cancelHabitReminder(habit.id);
      return;
    }

    final time = parseReminderTime(habit.reminderTime);
    if (time == null) return;

    try {
      final id = _habitIdToNumeric(habit.id);
      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );

      // If scheduled time has already passed today, advance to tomorrow
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      await _notificationsPlugin.zonedSchedule(
        id,
        'Reminder: ${habit.title}',
        'Time to complete your "${habit.title}" habit for today!',
        scheduledDate,
        _getNotificationDetails(habit.category),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: habit.id,
      );

      debugPrint('[NotificationService] Scheduled daily reminder for "${habit.title}" at ${habit.reminderTime}');
    } catch (e) {
      debugPrint('[NotificationService] scheduleHabitReminder error: $e');
    }
  }

  /// Cancel reminder for a specific habit
  Future<void> cancelHabitReminder(String habitId) async {
    try {
      final id = _habitIdToNumeric(habitId);
      await _notificationsPlugin.cancel(id);
      debugPrint('[NotificationService] Cancelled reminder for habit $habitId');
    } catch (e) {
      debugPrint('[NotificationService] cancelHabitReminder error: $e');
    }
  }

  /// Sync all active habits with local notification schedule
  Future<void> syncHabitReminders(List<HabitModel> habits) async {
    for (final habit in habits) {
      if (habit.isArchived || habit.reminderTime == null || habit.reminderTime == 'All day') {
        await cancelHabitReminder(habit.id);
      } else {
        await scheduleHabitReminder(habit);
      }
    }
  }

  int _habitIdToNumeric(String habitId) {
    return habitId.hashCode.abs() % 100000;
  }
}
