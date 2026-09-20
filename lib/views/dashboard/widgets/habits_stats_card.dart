import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../providers/habit_provider.dart';
import 'dashboard_section_card.dart';

class HabitsStatsCard extends ConsumerWidget {
  final double? height;

  const HabitsStatsCard({super.key, this.height = 240});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitsStreamProvider).value ?? [];
    final completionsMap = ref.watch(habitCompletionsMapProvider);
    final todayStr = DateFormatter.todayIso();

    final totalHabits = habits.length;
    int completedToday = 0;
    for (final h in habits) {
      if (completionsMap[h.id]?.contains(todayStr) ?? false) {
        completedToday++;
      }
    }
    final inProgress = (totalHabits - completedToday).clamp(0, 9999);

    return DashboardSectionCard(
      title: 'Stats',
      height: height,
      bodyPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _buildStatBox(
              label: 'Total Habits',
              value: '$totalHabits',
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: _buildStatBox(
              label: 'Completed',
              value: '$completedToday',
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: _buildStatBox(
              label: 'In Progress',
              value: '$inProgress',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox({
    required String label,
    required String value,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCardElevated,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.borderCard, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Navy Label / Header area
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
            color: AppColors.navyPrimary,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Light Background with Large Number
          Expanded(
            child: Container(
              color: Colors.white,
              alignment: Alignment.center,
              child: Text(
                value,
                style: const TextStyle(
                  color: AppColors.navyPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  height: 1.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
