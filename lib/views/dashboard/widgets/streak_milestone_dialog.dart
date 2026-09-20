import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../models/streak_milestone.dart';

class StreakMilestoneDialog extends StatelessWidget {
  final StreakMilestone milestone;

  const StreakMilestoneDialog({
    super.key,
    required this.milestone,
  });

  static Future<void> show(BuildContext context, StreakMilestone milestone) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => StreakMilestoneDialog(milestone: milestone),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 380),
        decoration: BoxDecoration(
          color: AppColors.bgCardElevated,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: milestone.primaryColor.withValues(alpha: 0.5),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: milestone.primaryColor.withValues(alpha: 0.25),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Glowing Badge Circle
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    milestone.primaryColor,
                    milestone.secondaryColor,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: milestone.primaryColor.withValues(alpha: 0.45),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  milestone.badgeEmoji,
                  style: const TextStyle(fontSize: 40),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Overline
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: milestone.primaryColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: milestone.primaryColor.withValues(alpha: 0.35),
                ),
              ),
              child: Text(
                'MILESTONE UNLOCKED • ${milestone.days} DAYS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: milestone.primaryColor,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Headline
            Text(
              milestone.headline,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 8),

            // Badge Title
            Text(
              milestone.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: milestone.secondaryColor,
              ),
            ),
            const SizedBox(height: 14),

            // Message
            Text(
              milestone.message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                height: 1.45,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),

            // Action Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: milestone.primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shadowColor: milestone.primaryColor.withValues(alpha: 0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Keep the Streak Alive! 🔥',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
