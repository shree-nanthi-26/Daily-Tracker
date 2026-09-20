import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../models/goal_model.dart';
import '../../providers/goal_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/task_provider.dart';
import 'widgets/goal_celebration_dialog.dart';

class GoalsScreen extends ConsumerStatefulWidget {
  const GoalsScreen({super.key});

  @override
  ConsumerState<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends ConsumerState<GoalsScreen> {
  final List<String> _categories = const ['All', 'Work', 'Personal', 'Health', 'Learning'];

  void _openGoalEditor([GoalModel? goal]) {
    final titleController = TextEditingController(text: goal?.title ?? '');
    final targetController =
        TextEditingController(text: goal != null ? '${goal.targetValue.toInt()}' : '10');
    final unitController = TextEditingController(text: goal?.unit ?? 'hours');
    final deadlineController = TextEditingController(text: goal?.deadline ?? 'This Month');
    String period = goal?.period ?? 'weekly';
    String selectedCategory = goal?.category ?? 'Work';
    String selectedLinkedType = goal?.linkedType ?? 'all';

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

                  // Linked Category
                  const Text('Goal Category',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: _categories.map((cat) {
                      final isSelected = selectedCategory == cat;
                      return ChoiceChip(
                        label: Text(cat),
                        selected: isSelected,
                        selectedColor: AppColors.primary.withValues(alpha: 0.25),
                        backgroundColor: AppColors.bgInput,
                        side: BorderSide(color: isSelected ? AppColors.primary : AppColors.borderSubtle),
                        labelStyle: TextStyle(
                          fontSize: 11.5,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? AppColors.primary : AppColors.textSecondary,
                        ),
                        onSelected: (selected) {
                          if (selected) setSheetState(() => selectedCategory = cat);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Activity Link Type
                  const Text('Automatic Progress Linking',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  const Text(
                    'Automatically increment this goal whenever completed in matching category',
                    style: TextStyle(fontSize: 10.5, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      {'type': 'all', 'label': 'All Activities'},
                      {'type': 'tasks', 'label': 'Tasks Only'},
                      {'type': 'habits', 'label': 'Habits Only'},
                      {'type': 'manual', 'label': 'Manual Only'},
                    ].map((item) {
                      final isSelected = selectedLinkedType == item['type'];
                      return ChoiceChip(
                        label: Text(item['label']!),
                        selected: isSelected,
                        selectedColor: AppColors.tealAccent.withValues(alpha: 0.2),
                        backgroundColor: AppColors.bgInput,
                        side: BorderSide(color: isSelected ? AppColors.tealAccent : AppColors.borderSubtle),
                        labelStyle: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? AppColors.tealAccent : AppColors.textSecondary,
                        ),
                        onSelected: (selected) {
                          if (selected) setSheetState(() => selectedLinkedType = item['type']!);
                        },
                      );
                    }).toList(),
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
                        HapticFeedback.selectionClick();
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
                                category: selectedCategory,
                                linkedType: selectedLinkedType,
                              )
                            : GoalModel(
                                id: '',
                                title: titleController.text.trim(),
                                targetValue: targetVal,
                                currentValue: 0.0,
                                unit: unitController.text.trim().isEmpty ? 'units' : unitController.text.trim(),
                                period: period,
                                deadline: deadlineController.text.trim(),
                                category: selectedCategory,
                                linkedType: selectedLinkedType,
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

  void _showSetProgressDialog(GoalModel goal) {
    final controller = TextEditingController(text: '${goal.currentValue.toInt()}');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCardElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.borderCard),
        ),
        title: Text('Set Progress (${goal.unit})', style: const TextStyle(fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Target: ${goal.targetValue.toInt()} ${goal.unit}',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Enter current value',
                suffixText: goal.unit,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final val = double.tryParse(controller.text.trim());
              if (val != null) {
                final uid = ref.read(currentUserIdProvider);
                final newlyAchieved = await ref.read(firestoreServiceProvider).setGoalProgress(uid, goal.id, val);
                if (!ctx.mounted) return;
                Navigator.of(ctx).pop();
                if (newlyAchieved && mounted) {
                  GoalCelebrationDialog.show(context, goal.copyWith(currentValue: val));
                } else {
                  HapticFeedback.mediumImpact();
                }
              }
            },
            child: const Text('Update'),
          ),
        ],
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
              HapticFeedback.mediumImpact();
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
    final filteredGoals = ref.watch(filteredGoalsProvider);
    final counts = ref.watch(goalCountsProvider);
    final currentTab = ref.watch(goalFilterTabProvider);
    final currentCategory = ref.watch(goalCategoryFilterProvider);
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
              const SizedBox(height: 14),

              // Filter Tabs (All / Active / Achieved)
              _buildFilterTabs(counts, currentTab),
              const SizedBox(height: 10),

              // Category Pills
              _buildCategoryPills(currentCategory),
              const SizedBox(height: 12),

              // Goals List
              Expanded(
                child: filteredGoals.isEmpty
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
                            Text(
                              currentTab == GoalFilterTab.achieved
                                  ? 'No achieved goals yet'
                                  : 'No goals found',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              currentTab == GoalFilterTab.achieved
                                  ? 'Keep progressing on your active targets to complete them!'
                                  : 'Set targets to stay aligned and build momentum',
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredGoals.length,
                        itemBuilder: (ctx, index) {
                          final goal = filteredGoals[index];
                          final pct = goal.progressPercentage;
                          final isAchieved = goal.isAchieved;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: AppColors.bgCard,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isAchieved
                                    ? const Color(0xFFFFD700).withValues(alpha: 0.5)
                                    : AppColors.borderCard,
                                width: isAchieved ? 1.5 : 1,
                              ),
                              boxShadow: isAchieved
                                  ? [
                                      BoxShadow(
                                        color: const Color(0xFFFFD700).withValues(alpha: 0.12),
                                        blurRadius: 16,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : null,
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
                                        color: isAchieved
                                            ? const Color(0xFFFFD700).withValues(alpha: 0.18)
                                            : AppColors.accentCyan.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        isAchieved ? Icons.emoji_events_rounded : Icons.track_changes_rounded,
                                        size: 16,
                                        color: isAchieved ? const Color(0xFFFFD700) : AppColors.accentCyan,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        goal.title,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: isAchieved ? const Color(0xFFFFD700) : AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                    if (isAchieved) ...[
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFD700).withValues(alpha: 0.18),
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.4)),
                                        ),
                                        child: const Text(
                                          'ACHIEVED 🏆',
                                          style: TextStyle(
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFFFFD700),
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                    ],
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
                                        if (val == 'set_progress') _showSetProgressDialog(goal);
                                      },
                                      itemBuilder: (c) => [
                                        const PopupMenuItem(
                                          value: 'set_progress',
                                          child: Row(
                                            children: [
                                              Icon(Icons.tune_rounded, size: 16, color: Colors.white),
                                              SizedBox(width: 8),
                                              Text(
                                                'Set Exact Progress',
                                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
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
                                                'Edit Goal',
                                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
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
                                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFFFF6B6B)),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),

                                // Category and Linked Badges
                                Row(
                                  children: [
                                    if (goal.category != null && goal.category!.isNotEmpty) ...[
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.bgInput,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          '#${goal.category}',
                                          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                    ],
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.bgInput,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.sync_rounded, size: 11, color: AppColors.tealAccent),
                                          const SizedBox(width: 3),
                                          Text(
                                            goal.linkedType == 'tasks'
                                                ? 'Linked: Tasks'
                                                : (goal.linkedType == 'habits'
                                                    ? 'Linked: Habits'
                                                    : (goal.linkedType == 'manual'
                                                        ? 'Manual only'
                                                        : 'Linked: All')),
                                            style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                // Target vs Current values
                                InkWell(
                                  onTap: () => _showSetProgressDialog(goal),
                                  borderRadius: BorderRadius.circular(6),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 2),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              '${goal.currentValue.toInt()} / ${goal.targetValue.toInt()} ${goal.unit}',
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w700,
                                                color: isAchieved ? const Color(0xFFFFD700) : AppColors.textPrimary,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            const Icon(Icons.edit_note_rounded, size: 14, color: AppColors.textMuted),
                                          ],
                                        ),
                                        Text(
                                          '${pct.toInt()}%',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: isAchieved ? const Color(0xFFFFD700) : AppColors.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),

                                // Progress Bar
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: LinearProgressIndicator(
                                    value: (pct / 100.0).clamp(0.0, 1.0),
                                    backgroundColor: AppColors.bgInput,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      isAchieved ? const Color(0xFFFFD700) : AppColors.primary,
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
                                              : () {
                                                  HapticFeedback.lightImpact();
                                                  firestore.updateGoalProgress(uid, goal.id, -1);
                                                },
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
                                          onPressed: () async {
                                            final newlyAchieved = await firestore.updateGoalProgress(uid, goal.id, 1);
                                            if (!context.mounted) return;
                                            if (newlyAchieved) {
                                              GoalCelebrationDialog.show(
                                                context,
                                                goal.copyWith(currentValue: goal.currentValue + 1),
                                              );
                                            } else {
                                              HapticFeedback.mediumImpact();
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: isAchieved ? const Color(0xFFFFD700) : AppColors.tealAccent,
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

  Widget _buildFilterTabs(Map<GoalFilterTab, int> counts, GoalFilterTab currentTab) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip(GoalFilterTab.all, 'All Goals', counts[GoalFilterTab.all] ?? 0, currentTab),
          _buildFilterChip(GoalFilterTab.active, 'Active', counts[GoalFilterTab.active] ?? 0, currentTab),
          _buildFilterChip(GoalFilterTab.achieved, 'Achieved 🏆', counts[GoalFilterTab.achieved] ?? 0, currentTab, isGold: true),
        ],
      ),
    );
  }

  Widget _buildFilterChip(GoalFilterTab tab, String label, int count, GoalFilterTab current, {bool isGold = false}) {
    final isSelected = tab == current;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          ref.read(goalFilterTabProvider.notifier).state = tab;
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? (isGold ? const Color(0xFFFFD700).withValues(alpha: 0.25) : AppColors.navyPrimary)
                : AppColors.bgCard,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? (isGold ? const Color(0xFFFFD700) : AppColors.navyPrimary)
                  : AppColors.borderCard,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? (isGold ? const Color(0xFFFFD700) : Colors.white)
                      : (isGold ? const Color(0xFFFFD700) : AppColors.textSecondary),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                decoration: BoxDecoration(
                  color: isGold ? const Color(0xFFFFD700).withValues(alpha: 0.2) : AppColors.bgInput,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isGold ? const Color(0xFFFFD700) : AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryPills(String? currentCategory) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _categories.map((cat) {
          final isSelected = (currentCategory == null && cat == 'All') || currentCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 6.0),
            child: InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                ref.read(goalCategoryFilterProvider.notifier).state = cat == 'All' ? null : cat;
              },
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary.withValues(alpha: 0.18) : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.borderSubtle,
                  ),
                ),
                child: Text(
                  cat,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? AppColors.primary : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
