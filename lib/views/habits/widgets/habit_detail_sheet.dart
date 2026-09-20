import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../models/habit_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/habit_provider.dart';
import '../../../providers/task_provider.dart';

class HabitDetailSheet extends ConsumerStatefulWidget {
  final HabitModel habit;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const HabitDetailSheet({
    super.key,
    required this.habit,
    required this.onEdit,
    required this.onDelete,
  });

  static void show(
    BuildContext context, {
    required HabitModel habit,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => HabitDetailSheet(
        habit: habit,
        onEdit: onEdit,
        onDelete: onDelete,
      ),
    );
  }

  @override
  ConsumerState<HabitDetailSheet> createState() => _HabitDetailSheetState();
}

class _HabitDetailSheetState extends ConsumerState<HabitDetailSheet> {
  late DateTime _displayedMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _displayedMonth = DateTime(now.year, now.month, 1);
  }

  void _previousMonth() {
    HapticFeedback.selectionClick();
    setState(() {
      _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    HapticFeedback.selectionClick();
    setState(() {
      _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month + 1, 1);
    });
  }

  int _calculateCurrentStreak(Set<String> completedDates) {
    if (completedDates.isEmpty) return 0;

    final now = DateTime.now();
    final todayStr = DateFormatter.toIsoDate(now);
    final yesterdayStr = DateFormatter.toIsoDate(now.subtract(const Duration(days: 1)));

    DateTime? checkDate;
    if (completedDates.contains(todayStr)) {
      checkDate = now;
    } else if (completedDates.contains(yesterdayStr)) {
      checkDate = now.subtract(const Duration(days: 1));
    } else {
      return 0;
    }

    int streak = 0;
    var runner = checkDate;
    while (true) {
      final s = DateFormatter.toIsoDate(runner);
      if (completedDates.contains(s)) {
        streak++;
        runner = runner.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }

  int _calculateBestStreak(Set<String> completedDates) {
    if (completedDates.isEmpty) return 0;
    final sorted = completedDates.toList()..sort();
    if (sorted.isEmpty) return 0;

    int best = 1;
    int current = 1;

    for (int i = 0; i < sorted.length - 1; i++) {
      final d1 = DateTime.parse(sorted[i]);
      final d2 = DateTime.parse(sorted[i + 1]);
      if (d2.difference(d1).inDays == 1) {
        current++;
        if (current > best) best = current;
      } else if (d2.difference(d1).inDays > 1) {
        current = 1;
      }
    }
    return best;
  }

  @override
  Widget build(BuildContext context) {
    final completionsMap = ref.watch(habitCompletionsMapProvider);
    final completedDates = completionsMap[widget.habit.id] ?? <String>{};
    final firestore = ref.watch(firestoreServiceProvider);
    final uid = ref.watch(currentUserIdProvider);

    final habitColor = Color(
      int.tryParse(widget.habit.color.replaceFirst('#', '0xFF')) ?? 0xFF6366F1,
    );

    final currentStreak = _calculateCurrentStreak(completedDates);
    final bestStreak = _calculateBestStreak(completedDates);

    // Days in current displayed month
    final daysInMonth = DateTime(_displayedMonth.year, _displayedMonth.month + 1, 0).day;
    final firstWeekday = DateTime(_displayedMonth.year, _displayedMonth.month, 1).weekday; // 1 = Monday ... 7 = Sunday
    final prefixEmptyDays = firstWeekday - 1;

    final monthPrefix = '${_displayedMonth.year}-${_displayedMonth.month.toString().padLeft(2, '0')}';
    final completedThisMonth = completedDates.where((d) => d.startsWith(monthPrefix)).length;
    final completionPct = daysInMonth > 0 ? (completedThisMonth / daysInMonth * 100).round() : 0;

    final monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final monthTitle = '${monthNames[_displayedMonth.month - 1]} ${_displayedMonth.year}';
    final todayStr = DateFormatter.todayIso();

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bgCardElevated,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 18,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle Bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderSubtle,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header Row: Dot, Title, Category Badge, Archive Status
            Row(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: habitColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.habit.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: habitColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    widget.habit.category,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: habitColor,
                    ),
                  ),
                ),
                if (widget.habit.isArchived) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.textMuted.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'ARCHIVED',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 6),

            // Subtitle: Target & Reminder
            Row(
              children: [
                const Icon(Icons.repeat_rounded, size: 14, color: AppColors.textMuted),
                const SizedBox(width: 4),
                Text(
                  '${widget.habit.targetFrequency} days / week',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                if (widget.habit.reminderTime != null) ...[
                  const SizedBox(width: 12),
                  const Icon(Icons.notifications_none_rounded, size: 14, color: AppColors.textMuted),
                  const SizedBox(width: 4),
                  Text(
                    widget.habit.reminderTime!,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 18),

            // Stat Cards Row
            Row(
              children: [
                Expanded(
                  child: _buildStatBox(
                    label: 'Current Streak',
                    value: '$currentStreak Days',
                    icon: Icons.local_fire_department_rounded,
                    iconColor: const Color(0xFFFF9500),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildStatBox(
                    label: 'Best Streak',
                    value: '$bestStreak Days',
                    icon: Icons.emoji_events_rounded,
                    iconColor: const Color(0xFFFFD60A),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildStatBox(
                    label: 'This Month',
                    value: '$completedThisMonth / $daysInMonth',
                    subtitle: '$completionPct%',
                    icon: Icons.calendar_month_rounded,
                    iconColor: AppColors.tealAccent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Calendar Navigation Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.bgInput,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left_rounded, color: AppColors.textPrimary, size: 22),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    onPressed: _previousMonth,
                  ),
                  Text(
                    monthTitle,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right_rounded, color: AppColors.textPrimary, size: 22),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    onPressed: _nextMonth,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Weekday initials (M, T, W, T, F, S, S)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const ['M', 'T', 'W', 'T', 'F', 'S', 'S'].map((day) {
                return Expanded(
                  child: Center(
                    child: Text(
                      day,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),

            // Calendar Days Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: prefixEmptyDays + daysInMonth,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 6,
                crossAxisSpacing: 6,
                childAspectRatio: 1.0,
              ),
              itemBuilder: (ctx, index) {
                if (index < prefixEmptyDays) {
                  return const SizedBox.shrink();
                }

                final dayNumber = index - prefixEmptyDays + 1;
                final dateStr =
                    '${_displayedMonth.year}-${_displayedMonth.month.toString().padLeft(2, '0')}-${dayNumber.toString().padLeft(2, '0')}';
                final isDone = completedDates.contains(dateStr);
                final isToday = dateStr == todayStr;

                return InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    firestore.toggleCompletion(uid, widget.habit.id, dateStr, isCurrentlyDone: isDone);
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    decoration: BoxDecoration(
                      color: isDone ? habitColor : AppColors.bgInput,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isToday
                            ? AppColors.primary
                            : (isDone ? habitColor : AppColors.borderSubtle),
                        width: isToday ? 1.8 : 1,
                      ),
                    ),
                    child: Center(
                      child: isDone
                          ? const Icon(Icons.check, size: 16, color: Colors.white)
                          : Text(
                              '$dayNumber',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                                color: isToday ? AppColors.primary : AppColors.textSecondary,
                              ),
                            ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            // Bottom Actions: Archive / Unarchive, Edit, Delete
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      final updated = widget.habit.copyWith(isArchived: !widget.habit.isArchived);
                      firestore.updateHabit(uid, updated);
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            updated.isArchived
                                ? 'Habit "${widget.habit.title}" archived'
                                : 'Habit "${widget.habit.title}" restored to active',
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: Icon(
                      widget.habit.isArchived
                          ? Icons.unarchive_outlined
                          : Icons.archive_outlined,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    label: Text(
                      widget.habit.isArchived ? 'Restore' : 'Archive',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      side: const BorderSide(color: AppColors.borderSubtle),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      Navigator.of(context).pop();
                      widget.onEdit();
                    },
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('Edit', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBox({
    required String label,
    required String value,
    String? subtitle,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.bgInput,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: iconColor),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.tealAccent,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
