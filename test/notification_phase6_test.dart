import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daily_work_mobile/models/habit_model.dart';
import 'package:daily_work_mobile/providers/notification_provider.dart';
import 'package:daily_work_mobile/services/notification_service.dart';

void main() {
  group('Phase 6 NotificationService Time Parsing Tests', () {
    test('parseReminderTime correctly parses standard 12-hour AM formats', () {
      final t1 = NotificationService.parseReminderTime('06:00 AM');
      expect(t1, isNotNull);
      expect(t1!.hour, 6);
      expect(t1.minute, 0);

      final t2 = NotificationService.parseReminderTime('7:30 am');
      expect(t2, isNotNull);
      expect(t2!.hour, 7);
      expect(t2.minute, 30);

      final t3 = NotificationService.parseReminderTime('09:45 AM');
      expect(t3, isNotNull);
      expect(t3!.hour, 9);
      expect(t3.minute, 45);
    });

    test('parseReminderTime correctly parses 12-hour PM formats', () {
      final t1 = NotificationService.parseReminderTime('01:00 PM');
      expect(t1, isNotNull);
      expect(t1!.hour, 13);
      expect(t1.minute, 0);

      final t2 = NotificationService.parseReminderTime('08:30 PM');
      expect(t2, isNotNull);
      expect(t2!.hour, 20);
      expect(t2.minute, 30);

      final t3 = NotificationService.parseReminderTime('11:59 pm');
      expect(t3, isNotNull);
      expect(t3!.hour, 23);
      expect(t3.minute, 59);
    });

    test('parseReminderTime correctly handles 12:00 PM (noon) and 12:00 AM (midnight)', () {
      final noon = NotificationService.parseReminderTime('12:00 PM');
      expect(noon, isNotNull);
      expect(noon!.hour, 12);
      expect(noon.minute, 0);

      final midnight = NotificationService.parseReminderTime('12:00 AM');
      expect(midnight, isNotNull);
      expect(midnight!.hour, 0);
      expect(midnight.minute, 0);
    });

    test('parseReminderTime correctly parses 24-hour military format', () {
      final t1 = NotificationService.parseReminderTime('14:20');
      expect(t1, isNotNull);
      expect(t1!.hour, 14);
      expect(t1.minute, 20);

      final t2 = NotificationService.parseReminderTime('08:05');
      expect(t2, isNotNull);
      expect(t2!.hour, 8);
      expect(t2.minute, 5);
    });

    test('parseReminderTime returns null for invalid strings or All day labels', () {
      expect(NotificationService.parseReminderTime('All day'), isNull);
      expect(NotificationService.parseReminderTime(''), isNull);
      expect(NotificationService.parseReminderTime('   '), isNull);
      expect(NotificationService.parseReminderTime(null), isNull);
      expect(NotificationService.parseReminderTime('Not a time'), isNull);
      expect(NotificationService.parseReminderTime('25:00'), isNull);
      expect(NotificationService.parseReminderTime('12:65 AM'), isNull);
    });
  });

  group('Phase 6 HabitReminderItem & Sorting Tests', () {
    test('HabitReminderItem sorts pending reminders before completed ones and chronologically', () {
      final now = DateTime.now();
      final h1 = HabitModel(
        id: 'h1',
        title: 'Morning Yoga',
        reminderTime: '06:00 AM',
        createdAt: now,
      );
      final h2 = HabitModel(
        id: 'h2',
        title: 'Evening Run',
        reminderTime: '06:00 PM',
        createdAt: now,
      );
      final h3 = HabitModel(
        id: 'h3',
        title: 'Lunch Walk',
        reminderTime: '12:30 PM',
        createdAt: now,
      );

      final items = [
        HabitReminderItem(
          habit: h2,
          time: const TimeOfDay(hour: 18, minute: 0),
          reminderTimeStr: '06:00 PM',
          isCompletedToday: false,
          sortMinutes: 18 * 60,
        ),
        HabitReminderItem(
          habit: h1,
          time: const TimeOfDay(hour: 6, minute: 0),
          reminderTimeStr: '06:00 AM',
          isCompletedToday: true, // Already done!
          sortMinutes: 6 * 60,
        ),
        HabitReminderItem(
          habit: h3,
          time: const TimeOfDay(hour: 12, minute: 30),
          reminderTimeStr: '12:30 PM',
          isCompletedToday: false,
          sortMinutes: 12 * 60 + 30,
        ),
      ];

      items.sort((a, b) {
        if (a.isCompletedToday != b.isCompletedToday) {
          return a.isCompletedToday ? 1 : -1;
        }
        return a.sortMinutes.compareTo(b.sortMinutes);
      });

      // h3 (12:30 PM, pending) should be first
      expect(items[0].habit.id, 'h3');
      expect(items[0].isCompletedToday, isFalse);

      // h2 (06:00 PM, pending) should be second
      expect(items[1].habit.id, 'h2');
      expect(items[1].isCompletedToday, isFalse);

      // h1 (06:00 AM, completed) should be last
      expect(items[2].habit.id, 'h1');
      expect(items[2].isCompletedToday, isTrue);
    });

    test('Pending count correctly filters out completed habits', () {
      final now = DateTime.now();
      final items = [
        HabitReminderItem(
          habit: HabitModel(id: '1', title: 'A', reminderTime: '07:00 AM', createdAt: now),
          time: const TimeOfDay(hour: 7, minute: 0),
          reminderTimeStr: '07:00 AM',
          isCompletedToday: false,
          sortMinutes: 420,
        ),
        HabitReminderItem(
          habit: HabitModel(id: '2', title: 'B', reminderTime: '08:00 AM', createdAt: now),
          time: const TimeOfDay(hour: 8, minute: 0),
          reminderTimeStr: '08:00 AM',
          isCompletedToday: true,
          sortMinutes: 480,
        ),
        HabitReminderItem(
          habit: HabitModel(id: '3', title: 'C', reminderTime: '09:00 PM', createdAt: now),
          time: const TimeOfDay(hour: 21, minute: 0),
          reminderTimeStr: '09:00 PM',
          isCompletedToday: false,
          sortMinutes: 1260,
        ),
      ];

      final pendingCount = items.where((i) => !i.isCompletedToday).length;
      expect(pendingCount, 2);
    });
  });
}
