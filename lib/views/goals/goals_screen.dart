import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../models/goal_model.dart';
import '../../providers/goal_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/task_provider.dart';

class GoalsScreen extends ConsumerStatefulWidget {
  const GoalsScreen({super.key});

  @override
  ConsumerState<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends ConsumerState<GoalsScreen> {
  void _openGoalEditor([GoalModel? goal]) {
    final titleController = TextEditingController(text: goal?.title ?? '');
    final targetController =
        TextEditingController(text: goal != null ? '${goal.targetValue.toInt()}' : '10');
    final unitController = TextEditingController(text: goal?.unit ?? 'hours');
    final deadlineController = TextEditingController(text: goal?.deadline ?? 'This Month');
    String period = goal?.period ?? 'weekly';

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
                    goal != null ? 'Edit Goal' : 'New Goal',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Title
                  const Text('Goal Title',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: titleController,
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: 'e.g. 50 Focus Sessions, Read 2 books...',
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Target & Unit
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Target Value',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                            const SizedBox(height: 6),
                            TextField(
                              controller: targetController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                              decoration: const InputDecoration(hintText: '30'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Unit of Measurement',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                            const SizedBox(height: 6),
                            TextField(
                              controller: unitController,
                              style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                              decoration: const InputDecoration(hintText: 'hours, sessions, etc.'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Period
                  const Text('Target Period',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                  const SizedBox(height: 6),
                  Row(
                    children: ['daily', 'weekly', 'monthly'].map((p) {
                      final isSelected = period == p;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(p[0].toUpperCase() + p.substring(1)),
                          selected: isSelected,
                          selectedColor: AppColors.primary.withValues(alpha: 0.25),
                          backgroundColor: AppColors.bgInput,
                          side: BorderSide(color: isSelected ? AppColors.primary : AppColors.borderSubtle),
                          labelStyle: TextStyle(
                            fontSize: 12,
                            color: isSelected ? AppColors.primary : AppColors.textSecondary,
                          ),
                          onSelected: (selected) {
                            if (selected) setSheetState(() => period = p);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Deadline
                  const Text('Deadline Label (Optional)',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: deadlineController,
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                    decoration: const InputDecoration(hintText: 'e.g. End of Q3, This Sunday...'),
                  ),
                  const SizedBox(height: 20),

                  // Submit
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (titleController.text.trim().isEmpty) return;
                        final targetVal = double.tryParse(targetController.text) ?? 10.0;
                        final uid = ref.read(currentUserIdProvider);
                        final firestore = ref.read(firestoreServiceProvider);

                        final newOrUpdated = goal != null
                            ? goal.copyWith(
                                title: titleController.text.trim(),
                                targetValue: targetVal,
                                unit: unitController.text.trim().isEmpty ? 'units' : unitController.text.trim(),
                                period: period,
                                deadline: deadlineController.text.trim(),
                              )
                            : GoalModel(
                                id: '',
                                title: titleController.text.trim(),
                                targetValue: targetVal,
                                currentValue: 0.0,
                                unit: unitController.text.trim().isEmpty ? 'units' : unitController.text.trim(),
                                period: period,
                                deadline: deadlineController.text.trim(),
                                createdAt: DateTime.now(),
                              );

                        if (goal != null) {
                          firestore.updateGoal(uid, newOrUpdated);
                        } else {
                          firestore.createGoal(uid, newOrUpdated);
                        }
                        Navigator.of(ctx).pop();
                      },
                      child: Text(goal != null ? 'Save Changes' : 'Create Goal'),
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

  void _confirmDeleteGoal(GoalModel goal) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCardElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.borderCard),
        ),
        title: const Text('Delete Goal?'),
        content: Text(
          'Are you sure you want to delete "${goal.title}"?',
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
              ref.read(firestoreServiceProvider).deleteGoal(uid, goal.id);
              Navigator.of(ctx).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final goals = ref.watch(goalsStreamProvider).value ?? [];
    final uid = ref.watch(currentUserIdProvider);
    final firestore = ref.watch(firestoreServiceProvider);

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
                      'Goals & Targets',
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
                    onPressed: () => _openGoalEditor(),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('New Goal'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Goals List
              Expanded(
                child: goals.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.track_changes_rounded,
                              size: 48,
                              color: AppColors.textMuted.withValues(alpha: 0.4),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'No goals defined yet',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Set productivity targets to stay focused and aligned',
                              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: goals.length,
                        itemBuilder: (ctx, index) {
                          final goal = goals[index];
                          final pct = goal.progressPercentage;

                          return Container(
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
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: AppColors.accentCyan.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.track_changes_rounded,
                                        size: 16,
                                        color: AppColors.accentCyan,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        goal.title,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        goal.period.toUpperCase(),
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                     PopupMenuButton<String>(
                                       icon: const Icon(Icons.more_vert, size: 18, color: AppColors.textMuted),
                                       color: AppColors.navyPrimary,
                                       shape: RoundedRectangleBorder(
                                         borderRadius: BorderRadius.circular(8),
                                         side: const BorderSide(color: AppColors.navySecondary),
                                       ),
                                       onSelected: (val) {
                                         if (val == 'edit') _openGoalEditor(goal);
                                         if (val == 'delete') _confirmDeleteGoal(goal);
                                       },
                                       itemBuilder: (c) => [
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
                                const SizedBox(height: 14),

                                // Target vs Current values
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${goal.currentValue.toInt()} / ${goal.targetValue.toInt()} ${goal.unit}',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      '${pct.toInt()}%',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: pct >= 100 ? AppColors.success : AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),

                                // Progress Bar
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: LinearProgressIndicator(
                                    value: (pct / 100.0).clamp(0.0, 1.0),
                                    backgroundColor: AppColors.bgInput,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      pct >= 100 ? AppColors.success : AppColors.primary,
                                    ),
                                    minHeight: 7,
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // Steppers and deadline
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      goal.deadline != null && goal.deadline!.isNotEmpty
                                          ? 'Deadline: ${goal.deadline}'
                                          : 'No deadline set',
                                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                    ),
                                    Row(
                                      children: [
                                        OutlinedButton(
                                          onPressed: goal.currentValue <= 0
                                              ? null
                                              : () => firestore.updateGoalProgress(uid, goal.id, -1),
                                          style: OutlinedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                            minimumSize: Size.zero,
                                            side: const BorderSide(color: AppColors.borderCard),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                          ),
                                          child: const Text(
                                            '-1',
                                            style: TextStyle(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        ElevatedButton(
                                          onPressed: () => firestore.updateGoalProgress(uid, goal.id, 1),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.tealAccent,
                                            foregroundColor: AppColors.navyPrimary,
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                            minimumSize: Size.zero,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            elevation: 0,
                                          ),
                                          child: const Text(
                                            '+1',
                                            style: TextStyle(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
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
        onPressed: () => _openGoalEditor(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
