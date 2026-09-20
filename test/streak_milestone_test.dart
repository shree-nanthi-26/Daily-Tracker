import 'package:flutter_test/flutter_test.dart';
import 'package:daily_work_mobile/models/streak_milestone.dart';

void main() {
  group('StreakMilestone Logic Tests', () {
    test('isExactMilestone identifies milestone days accurately', () {
      // Non-milestones
      expect(StreakMilestone.isExactMilestone(0), isFalse);
      expect(StreakMilestone.isExactMilestone(1), isFalse);
      expect(StreakMilestone.isExactMilestone(2), isFalse);
      expect(StreakMilestone.isExactMilestone(4), isFalse);
      expect(StreakMilestone.isExactMilestone(5), isFalse);
      expect(StreakMilestone.isExactMilestone(12), isFalse);
      expect(StreakMilestone.isExactMilestone(25), isFalse);

      // Predefined & Weekly (every 7 days) milestones
      expect(StreakMilestone.isExactMilestone(3), isTrue);
      expect(StreakMilestone.isExactMilestone(7), isTrue);
      expect(StreakMilestone.isExactMilestone(14), isTrue);
      expect(StreakMilestone.isExactMilestone(21), isTrue);
      expect(StreakMilestone.isExactMilestone(28), isTrue);
      expect(StreakMilestone.isExactMilestone(35), isTrue);
      expect(StreakMilestone.isExactMilestone(42), isTrue);

      // Monthly milestones (every 30 days) & Major milestones
      expect(StreakMilestone.isExactMilestone(30), isTrue);
      expect(StreakMilestone.isExactMilestone(60), isTrue);
      expect(StreakMilestone.isExactMilestone(90), isTrue);
      expect(StreakMilestone.isExactMilestone(100), isTrue);
      expect(StreakMilestone.isExactMilestone(120), isTrue);
    });

    test('getMilestoneForStreak returns correct metadata', () {
      final day7 = StreakMilestone.getMilestoneForStreak(7);
      expect(day7.title, 'Week Warrior');
      expect(day7.badgeEmoji, '🔥');
      expect(day7.headline, contains('7-Day Streak'));

      final day14 = StreakMilestone.getMilestoneForStreak(14);
      expect(day14.title, 'Fortnight Champion');
      expect(day14.badgeEmoji, '⚡');

      final day21 = StreakMilestone.getMilestoneForStreak(21);
      expect(day21.title, 'Habit Master');
      expect(day21.badgeEmoji, '🌟');

      final day30 = StreakMilestone.getMilestoneForStreak(30);
      expect(day30.title, 'Monthly Legend');
      expect(day30.badgeEmoji, '🏆');

      final day35 = StreakMilestone.getMilestoneForStreak(35);
      expect(day35.title, 'Week 5 Victor');
      expect(day35.badgeEmoji, '🔥');

      final day60 = StreakMilestone.getMilestoneForStreak(60);
      expect(day60.title, 'Diamond Discipline');
    });

    test('getNextMilestone determines next targets sequentially', () {
      expect(StreakMilestone.getNextMilestone(0).days, 3);
      expect(StreakMilestone.getNextMilestone(1).days, 3);
      expect(StreakMilestone.getNextMilestone(2).days, 3);
      expect(StreakMilestone.getNextMilestone(3).days, 7);
      expect(StreakMilestone.getNextMilestone(5).days, 7);
      expect(StreakMilestone.getNextMilestone(7).days, 14);
      expect(StreakMilestone.getNextMilestone(10).days, 14);
      expect(StreakMilestone.getNextMilestone(14).days, 21);
      expect(StreakMilestone.getNextMilestone(21).days, 30);
      expect(StreakMilestone.getNextMilestone(30).days, 60);
      expect(StreakMilestone.getNextMilestone(90).days, 100);
    });

    test('getProgressToNext calculates proper percentage between milestones', () {
      expect(StreakMilestone.getProgressToNext(0), 0.0);
      // From 3 to 7: total span = 4. At streak 5, progress = (5 - 3) / 4 = 0.5
      expect(StreakMilestone.getProgressToNext(5), closeTo(0.5, 0.01));
      // At streak 7, next is 14. Target span = 14 - 7 = 7.
      expect(StreakMilestone.getProgressToNext(7), 0.0);
    });
  });
}
