import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/habit_provider.dart';
import 'dashboard_section_card.dart';

class OverallStreakDonutCard extends ConsumerWidget {
  final double? height;

  const OverallStreakDonutCard({super.key, this.height = 240});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streakStats = ref.watch(overallStreakProvider);
    final streakCount = streakStats.currentStreak;

    // Normalizing against a 30-day streak cycle
    final progress = streakCount > 0 ? (streakCount / 30.0).clamp(0.05, 1.0) : 0.0;

    final currentMilestone = ref.watch(currentMilestoneProvider);
    final nextMilestone = ref.watch(nextMilestoneProvider);

    return DashboardSectionCard(
      title: 'Overall Streak',
      height: height,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 96,
              height: 96,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Dark Navy circular background ring #0B2D4D
                  const SizedBox(
                    width: 90,
                    height: 90,
                    child: CircularProgressIndicator(
                      value: 1.0,
                      strokeWidth: 8,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.navyPrimary),
                    ),
                  ),
                  // Teal / Green Completed Accent #20BFAE
                  SizedBox(
                    width: 90,
                    height: 90,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 8,
                      strokeCap: StrokeCap.round,
                      backgroundColor: Colors.transparent,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(AppColors.tealAccent),
                    ),
                  ),
                  // Center Streak Number & Days
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$streakCount',
                        style: const TextStyle(
                          color: AppColors.navyPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          height: 1.1,
                        ),
                      ),
                      const Text(
                        'Days',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            // Milestone Badge Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: streakCount >= 3
                    ? currentMilestone.primaryColor.withValues(alpha: 0.12)
                    : AppColors.borderSubtle.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: streakCount >= 3
                      ? currentMilestone.primaryColor.withValues(alpha: 0.3)
                      : AppColors.borderSubtle,
                  width: 1,
                ),
              ),
              child: Text(
                streakCount >= 3
                    ? '${currentMilestone.badgeEmoji} ${currentMilestone.title}'
                    : 'Target: ${nextMilestone.days}d ${nextMilestone.badgeEmoji}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: streakCount >= 3
                      ? currentMilestone.primaryColor
                      : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
