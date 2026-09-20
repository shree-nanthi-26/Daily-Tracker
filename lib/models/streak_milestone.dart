import 'package:flutter/material.dart';

class StreakMilestone {
  final int days;
  final String title;
  final String badgeEmoji;
  final String headline;
  final String message;
  final Color primaryColor;
  final Color secondaryColor;

  const StreakMilestone({
    required this.days,
    required this.title,
    required this.badgeEmoji,
    required this.headline,
    required this.message,
    required this.primaryColor,
    required this.secondaryColor,
  });

  /// Check if the given streak is a milestone (e.g. 3, 7, 14, 21, 28, 30, 60, 90, 100, or any multiple of 7 or 30).
  static bool isExactMilestone(int streak) {
    if (streak <= 0) return false;
    if (streak == 3 || streak == 7 || streak == 14 || streak == 21 || streak == 30 || streak == 60 || streak == 90 || streak == 100) {
      return true;
    }
    // Every 7 days (weekly) or every 30 days (monthly)
    return (streak % 7 == 0) || (streak % 30 == 0);
  }

  /// Get the milestone definition for a given streak number.
  static StreakMilestone getMilestoneForStreak(int streak) {
    if (streak == 3) {
      return const StreakMilestone(
        days: 3,
        title: 'Momentum Spark',
        badgeEmoji: '⚡',
        headline: '3-Day Streak Achieved!',
        message: 'The hardest part is getting started — you are building real momentum!',
        primaryColor: Color(0xFFF59E0B), // Amber
        secondaryColor: Color(0xFFEF4444),
      );
    }
    if (streak == 7) {
      return const StreakMilestone(
        days: 7,
        title: 'Week Warrior',
        badgeEmoji: '🔥',
        headline: '7-Day Streak Conquered!',
        message: 'A full week of unbroken dedication! You have laid the foundation of success.',
        primaryColor: Color(0xFFFF5722), // Deep Orange
        secondaryColor: Color(0xFFFF9800),
      );
    }
    if (streak == 14) {
      return const StreakMilestone(
        days: 14,
        title: 'Fortnight Champion',
        badgeEmoji: '⚡',
        headline: '14-Day Streak Unlocked!',
        message: 'Two solid weeks of consistency! Your discipline is unstoppable.',
        primaryColor: Color(0xFF6366F1), // Indigo
        secondaryColor: Color(0xFF8B5CF6),
      );
    }
    if (streak == 21) {
      return const StreakMilestone(
        days: 21,
        title: 'Habit Master',
        badgeEmoji: '🌟',
        headline: '21-Day Habit Formed!',
        message: 'Science proves it takes 21 days to form a habit. It is now part of who you are!',
        primaryColor: Color(0xFF10B981), // Emerald
        secondaryColor: Color(0xFF06B6D4),
      );
    }
    if (streak == 30) {
      return const StreakMilestone(
        days: 30,
        title: 'Monthly Legend',
        badgeEmoji: '🏆',
        headline: '1 Full Month Completed!',
        message: '30 straight days of excellence! You belong to the top 1% of achievers.',
        primaryColor: Color(0xFFEAB308), // Gold
        secondaryColor: Color(0xFFF97316),
      );
    }
    if (streak == 60) {
      return const StreakMilestone(
        days: 60,
        title: 'Diamond Discipline',
        badgeEmoji: '💎',
        headline: '60-Day Streak Reached!',
        message: 'Two whole months! Your perseverance is turning habits into a lifestyle.',
        primaryColor: Color(0xFF3B82F6), // Blue
        secondaryColor: Color(0xFF06B6D4),
      );
    }
    if (streak == 90) {
      return const StreakMilestone(
        days: 90,
        title: 'Quarter Titan',
        badgeEmoji: '👑',
        headline: '90-Day Quarter Conquered!',
        message: 'An entire season of continuous growth! True mastery in motion.',
        primaryColor: Color(0xFF8B5CF6), // Purple
        secondaryColor: Color(0xFFEC4899),
      );
    }
    if (streak == 100) {
      return const StreakMilestone(
        days: 100,
        title: 'Centurion Master',
        badgeEmoji: '💯',
        headline: '100-Day Triple Digits!',
        message: 'A legendary 100-day milestone! Your dedication inspires everyone.',
        primaryColor: Color(0xFFEC4899), // Pink
        secondaryColor: Color(0xFFF43F5E),
      );
    }

    // Dynamic for any other multiple of 30
    if (streak % 30 == 0) {
      final months = streak ~/ 30;
      return StreakMilestone(
        days: streak,
        title: '$months-Month Victor',
        badgeEmoji: '🏆',
        headline: '$streak-Day ($months-Month) Milestone!',
        message: '$months consecutive months of unbroken focus. Phenomenal achievement!',
        primaryColor: const Color(0xFFF59E0B),
        secondaryColor: const Color(0xFFEAB308),
      );
    }

    // Dynamic for any other multiple of 7
    if (streak % 7 == 0) {
      final weeks = streak ~/ 7;
      return StreakMilestone(
        days: streak,
        title: 'Week $weeks Victor',
        badgeEmoji: '🔥',
        headline: '$streak-Day ($weeks-Week) Milestone!',
        message: '$weeks weeks in a row without missing a beat! Keep the streak alive.',
        primaryColor: const Color(0xFFFF6D00),
        secondaryColor: const Color(0xFFFF9100),
      );
    }

    // Default fallback
    return StreakMilestone(
      days: streak,
      title: '$streak-Day Achiever',
      badgeEmoji: '🔥',
      headline: '$streak-Day Streak!',
      message: 'Great consistency! Every single day counts toward your bigger vision.',
      primaryColor: const Color(0xFF6366F1),
      secondaryColor: const Color(0xFF3B82F6),
    );
  }

  /// Finds the next milestone target for any streak.
  static StreakMilestone getNextMilestone(int streak) {
    const predefined = [3, 7, 14, 21, 30, 60, 90, 100];
    for (final target in predefined) {
      if (streak < target) {
        return getMilestoneForStreak(target);
      }
    }
    // Beyond 100: next multiple of 7 or 30
    final nextWeekly = ((streak ~/ 7) + 1) * 7;
    final nextMonthly = ((streak ~/ 30) + 1) * 30;
    final next = nextWeekly < nextMonthly ? nextWeekly : nextMonthly;
    return getMilestoneForStreak(next);
  }

  /// Calculates progress from the previous milestone to this one.
  static double getProgressToNext(int streak) {
    if (streak <= 0) return 0.0;
    final next = getNextMilestone(streak);
    int prevTarget = 0;
    const predefined = [0, 3, 7, 14, 21, 30, 60, 90, 100];
    for (int i = 0; i < predefined.length; i++) {
      if (predefined[i] > streak) break;
      prevTarget = predefined[i];
    }
    final range = next.days - prevTarget;
    if (range <= 0) return 1.0;
    final progress = (streak - prevTarget) / range;
    return progress.clamp(0.0, 1.0);
  }
}
