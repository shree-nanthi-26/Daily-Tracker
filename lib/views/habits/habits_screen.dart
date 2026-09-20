import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/habit_model.dart';
import '../../models/streak_milestone.dart';
import '../../providers/habit_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/task_provider.dart';
import '../dashboard/widgets/streak_milestone_dialog.dart';
import 'widgets/habit_detail_sheet.dart';

class HabitsScreen extends ConsumerStatefulWidget {
  const HabitsScreen({super.key});

  @override
  ConsumerState<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends ConsumerState<HabitsScreen> {
  String _activeFilter = 'active'; // 'active', 'archived', 'all'

  Future<void> _handleToggleCompletion(String uid, String habitId, String dateStr, {bool? isCurrentlyDone}) async {
    try {
      if (isCurrentlyDone == true) {
        HapticFeedback.lightImpact();
      } else {
        HapticFeedback.mediumImpact();
      }

      debugPrint('[HabitsScreen] _handleToggleCompletion tapped: habit=$habitId date=$dateStr isCurrentlyDone=$isCurrentlyDone');
      final firestore = ref.read(firestoreServiceProvider);
      await firestore.toggleCompletion(uid, habitId, dateStr, isCurrentlyDone: isCurrentlyDone);

      // Celebration snackbar when marked complete for today
      final todayStr = DateFormatter.todayIso();
      if (dateStr == todayStr && isCurrentlyDone != true && mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.navyPrimary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: const BorderSide(color: AppColors.borderSubtle),
            ),
            content: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: AppColors.tealAccent, size: 18),
                SizedBox(width: 8),
                Text(
                  'Habit marked for today! Keep up the momentum.',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ],
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }

      // Check if new streak reached an exact milestone
      final newStreak = ref.read(overallStreakProvider).currentStreak;
      final lastCelebrated = ref.read(lastCelebratedMilestoneProvider);

      if (StreakMilestone.isExactMilestone(newStreak) && newStreak != lastCelebrated) {
        ref.read(lastCelebratedMilestoneProvider.notifier).state = newStreak;
        if (mounted) {
          final milestone = StreakMilestone.getMilestoneForStreak(newStreak);
          StreakMilestoneDialog.show(context, milestone);
        }
      }
    } catch (e) {
      debugPrint('[HabitsScreen] _handleToggleCompletion error: $e');
    }
  }

  void _openHabitEditor([HabitModel? habit]) {
    final titleController = TextEditingController(text: habit?.title ?? '');
    String category = habit?.category ?? 'Coding';
    String colorHex = habit?.color ?? '#6366F1';
    int targetFreq = habit?.targetFrequency ?? 7;
    String reminder = habit?.reminderTime ?? '08:00 AM';

    final categories = ['Coding', 'Work', 'Study', 'Health', 'Personal'];
    final colors = [
      '#6366F1', // Indigo
      '#3B82F6', // Blue
      '#10B981', // Emerald
      '#F59E0B', // Amber
      '#EC4899', // Pink
      '#8B5CF6', // Purple
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          return Container(
            decoration: const BoxDecoration(
              color: AppColors.bgCardElevated,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  Text(
                    habit != null ? 'Edit Habit' : 'New Habit',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Title
                  const Text('Habit Title',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: titleController,
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: 'e.g. Read technical articles, Gym, Deep work...',
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Category
                  const Text('Category',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    children: categories.map((c) {
                      final isSelected = category == c;
                      return ChoiceChip(
                        label: Text(c),
                        selected: isSelected,
                        selectedColor: AppColors.primary.withValues(alpha: 0.25),
                        backgroundColor: AppColors.bgInput,
                        side: BorderSide(color: isSelected ? AppColors.primary : AppColors.borderSubtle),
                        labelStyle: TextStyle(
                          fontSize: 12,
                          color: isSelected ? AppColors.primary : AppColors.textSecondary,
                        ),
                        onSelected: (selected) {
                          if (selected) setSheetState(() => category = c);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Color Picker
                  const Text('Theme Color',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  Row(
                    children: colors.map((cHex) {
                      final c = Color(int.parse(cHex.replaceFirst('#', '0xFF')));
                      final isSelected = colorHex.toUpperCase() == cHex.toUpperCase();
                      return GestureDetector(
                        onTap: () => setSheetState(() => colorHex = cHex),
                        child: Container(
                          margin: const EdgeInsets.only(right: 10),
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? Colors.white : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: isSelected
                              ? const Icon(Icons.check, size: 16, color: Colors.white)
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Target Frequency
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Target Frequency',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                      Text('$targetFreq days / week',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
                    ],
                  ),
                  Slider(
                    value: targetFreq.toDouble(),
                    min: 1,
                    max: 7,
                    divisions: 6,
                    activeColor: AppColors.primary,
                    inactiveColor: AppColors.bgInput,
                    onChanged: (val) {
                      setSheetState(() => targetFreq = val.toInt());
                    },
                  ),
                  const SizedBox(height: 20),

                  // Save
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (titleController.text.trim().isEmpty) return;
                        final uid = ref.read(currentUserIdProvider);
                        final firestore = ref.read(firestoreServiceProvider);

                        final newOrUpdated = habit != null
                            ? habit.copyWith(
                                title: titleController.text.trim(),
                                category: category,
                                color: colorHex,
                                targetFrequency: targetFreq,
                                reminderTime: reminder,
                              )
                            : HabitModel(
                                id: '',
                                title: titleController.text.trim(),
                                category: category,
                                color: colorHex,
                                targetFrequency: targetFreq,
                                reminderTime: reminder,
                                createdAt: DateTime.now(),
                              );

                        if (habit != null) {
                          firestore.updateHabit(uid, newOrUpdated);
                        } else {
                          firestore.createHabit(uid, newOrUpdated);
                        }
                        Navigator.of(ctx).pop();
                      },
                      child: Text(habit != null ? 'Save Changes' : 'Create Habit'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _confirmDeleteHabit(HabitModel habit) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCardElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.borderCard),
        ),
        title: const Text('Delete Habit?'),
        content: Text(
          'Delete habit "${habit.title}"? Your streak history for this habit will be removed.',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () {
              final uid = ref.read(currentUserIdProvider);
              ref.read(firestoreServiceProvider).deleteHabit(uid, habit.id);
              Navigator.of(ctx).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, int count) {
    final isSelected = _activeFilter == value;
    return ChoiceChip(
      label: Text('$label ($count)'),
      selected: isSelected,
      selectedColor: AppColors.primary.withValues(alpha: 0.25),
      backgroundColor: AppColors.bgCard,
      side: BorderSide(
        color: isSelected ? AppColors.primary : AppColors.borderSubtle,
        width: isSelected ? 1.5 : 1,
      ),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
      ),
      onSelected: (selected) {
        if (selected) {
          HapticFeedback.selectionClick();
          setState(() => _activeFilter = value);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final allHabits = ref.watch(habitsStreamProvider).value ?? [];
    final completionsMap = ref.watch(habitCompletionsMapProvider);
    final uid = ref.watch(currentUserIdProvider);

    final activeHabits = allHabits.where((h) => !h.isArchived).toList();
    final archivedHabits = allHabits.where((h) => h.isArchived).toList();

    List<HabitModel> displayedHabits;
    if (_activeFilter == 'archived') {
      displayedHabits = archivedHabits;
    } else if (_activeFilter == 'all') {
      displayedHabits = allHabits;
    } else {
      displayedHabits = activeHabits;
    }

    final todayStr = DateFormatter.todayIso();
    final weekDays = DateFormatter.getCurrentWeekDays();

    return Scaffold(
      backgroundColor: AppColors.bgMain,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'Habits & Routines',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      _openHabitEditor();
                    },
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add Habit'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('Active', 'active', activeHabits.length),
                    const SizedBox(width: 8),
                    _buildFilterChip('Archived', 'archived', archivedHabits.length),
                    const SizedBox(width: 8),
                    _buildFilterChip('All', 'all', allHabits.length),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Habits List
              Expanded(
                child: displayedHabits.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _activeFilter == 'archived'
                                  ? Icons.archive_outlined
                                  : Icons.repeat_rounded,
                              size: 48,
                              color: AppColors.textMuted.withValues(alpha: 0.4),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _activeFilter == 'archived'
                                  ? 'No archived habits'
                                  : 'No habits tracked yet',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _activeFilter == 'archived'
                                  ? 'Archive habits from their options menu when pausing them'
                                  : 'Build consistency by adding your first daily habit',
                              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: displayedHabits.length,
                        itemBuilder: (ctx, index) {
                          final habit = displayedHabits[index];
                          final isCompletedToday =
                              completionsMap[habit.id]?.contains(todayStr) ?? false;
                          final habitColor = Color(
                            int.tryParse(habit.color.replaceFirst('#', '0xFF')) ??
                                0xFF6366F1,
                          );

                          return InkWell(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              HabitDetailSheet.show(
                                context,
                                habit: habit,
                                onEdit: () => _openHabitEditor(habit),
                                onDelete: () => _confirmDeleteHabit(habit),
                              );
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: AppColors.bgCard,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.borderCard),
                              ),
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Top row: Title, tag, more options
                                  Row(
                                    children: [
                                      Container(
                                        width: 10,
                                        height: 10,
                                        decoration: BoxDecoration(
                                          color: habitColor,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          habit.title,
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textPrimary,
                                            decoration: habit.isArchived
                                                ? TextDecoration.lineThrough
                                                : null,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                                        decoration: BoxDecoration(
                                          color: habitColor.withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          habit.category,
                                          style: TextStyle(
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.w600,
                                            color: habitColor,
                                          ),
                                        ),
                                      ),
                                      if (habit.isArchived) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppColors.textMuted.withValues(alpha: 0.18),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: const Text(
                                            'Archived',
                                            style: TextStyle(fontSize: 9, color: AppColors.textMuted, fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                      ],
                                      PopupMenuButton<String>(
                                        icon: const Icon(Icons.more_vert, size: 18, color: AppColors.textMuted),
                                        color: AppColors.navyPrimary,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          side: const BorderSide(color: AppColors.navySecondary),
                                        ),
                                        onSelected: (val) {
                                          if (val == 'details') {
                                            HapticFeedback.lightImpact();
                                            HabitDetailSheet.show(
                                              context,
                                              habit: habit,
                                              onEdit: () => _openHabitEditor(habit),
                                              onDelete: () => _confirmDeleteHabit(habit),
                                            );
                                          }
                                          if (val == 'archive') {
                                            HapticFeedback.mediumImpact();
                                            final updated = habit.copyWith(isArchived: !habit.isArchived);
                                            ref.read(firestoreServiceProvider).updateHabit(uid, updated);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  updated.isArchived
                                                      ? 'Habit "${habit.title}" archived'
                                                      : 'Habit "${habit.title}" restored',
                                                ),
                                                duration: const Duration(seconds: 2),
                                              ),
                                            );
                                          }
                                          if (val == 'edit') {
                                            HapticFeedback.selectionClick();
                                            _openHabitEditor(habit);
                                          }
                                          if (val == 'delete') {
                                            HapticFeedback.selectionClick();
                                            _confirmDeleteHabit(habit);
                                          }
                                        },
                                        itemBuilder: (c) => [
                                          const PopupMenuItem(
                                            value: 'details',
                                            child: Row(
                                              children: [
                                                Icon(Icons.calendar_month_outlined, size: 16, color: Colors.white),
                                                SizedBox(width: 8),
                                                Text(
                                                  'Monthly Breakdown',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          PopupMenuItem(
                                            value: 'archive',
                                            child: Row(
                                              children: [
                                                Icon(
                                                  habit.isArchived
                                                      ? Icons.unarchive_outlined
                                                      : Icons.archive_outlined,
                                                  size: 16,
                                                  color: Colors.white,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  habit.isArchived ? 'Restore Habit' : 'Archive Habit',
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const PopupMenuItem(
                                            value: 'edit',
                                            child: Row(
                                              children: [
                                                Icon(Icons.edit_outlined, size: 16, color: Colors.white),
                                                SizedBox(width: 8),
                                                Text(
                                                  'Edit',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const PopupMenuItem(
                                            value: 'delete',
                                            child: Row(
                                              children: [
                                                Icon(Icons.delete_outline, size: 16, color: Color(0xFFFF6B6B)),
                                                SizedBox(width: 8),
                                                Text(
                                                  'Delete',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600,
                                                    color: Color(0xFFFF6B6B),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),

                                  // Middle Row: Weekly Consistency Dot Grid
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: weekDays.map((d) {
                                      final dStr = DateFormatter.toIsoDate(d);
                                      final isDone = completionsMap[habit.id]?.contains(dStr) ?? false;
                                      final isToday = dStr == todayStr;
                                      final shortDay = DateFormatter.formatShortDay(d);

                                      return Column(
                                        children: [
                                          Text(
                                            shortDay[0], // M, T, W...
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                                              color: isToday ? AppColors.primary : AppColors.textMuted,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          GestureDetector(
                                            onTap: () {
                                              _handleToggleCompletion(uid, habit.id, dStr, isCurrentlyDone: isDone);
                                            },
                                            child: Container(
                                              width: 32,
                                              height: 32,
                                              decoration: BoxDecoration(
                                                color: isDone ? habitColor : AppColors.bgInput,
                                                borderRadius: BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: isToday
                                                      ? AppColors.primary
                                                      : (isDone ? habitColor : AppColors.borderSubtle),
                                                  width: isToday ? 1.5 : 1,
                                                ),
                                              ),
                                              child: isDone
                                                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                                                  : null,
                                            ),
                                          ),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                  const SizedBox(height: 14),

                                  // Bottom Row: Frequency label & Today toggle
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          HapticFeedback.lightImpact();
                                          HabitDetailSheet.show(
                                            context,
                                            habit: habit,
                                            onEdit: () => _openHabitEditor(habit),
                                            onDelete: () => _confirmDeleteHabit(habit),
                                          );
                                        },
                                        borderRadius: BorderRadius.circular(6),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                                          child: Row(
                                            children: [
                                              const Icon(
                                                Icons.calendar_month_outlined,
                                                size: 13,
                                                color: AppColors.tealAccent,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Target: ${habit.targetFrequency}d / wk',
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  color: AppColors.textSecondary,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      OutlinedButton.icon(
                                        onPressed: () {
                                          _handleToggleCompletion(uid, habit.id, todayStr, isCurrentlyDone: isCompletedToday);
                                        },
                                        icon: Icon(
                                          isCompletedToday ? Icons.check_circle : Icons.circle_outlined,
                                          size: 14,
                                          color: isCompletedToday ? AppColors.success : AppColors.textMuted,
                                        ),
                                        label: Text(
                                          isCompletedToday ? 'Done Today' : 'Mark Today',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: isCompletedToday ? AppColors.success : AppColors.textSecondary,
                                          ),
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                          side: BorderSide(
                                            color: isCompletedToday ? AppColors.success : AppColors.borderSubtle,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          HapticFeedback.selectionClick();
          _openHabitEditor();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
