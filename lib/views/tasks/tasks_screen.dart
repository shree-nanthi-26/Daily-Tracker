import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../models/task_model.dart';
import '../../providers/task_provider.dart';
import '../../providers/auth_provider.dart';
import '../dashboard/widgets/dashboard_section_card.dart';
import 'widgets/task_card_item.dart';
import 'widgets/task_editor_sheet.dart';
import 'widgets/task_progress_pie_card.dart';

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openTaskEditor([TaskModel? task]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => TaskEditorSheet(
        existingTask: task,
        onSave: (updatedTask) {
          final uid = ref.read(currentUserIdProvider);
          final firestore = ref.read(firestoreServiceProvider);
          if (task == null) {
            firestore.createTask(uid, updatedTask);
          } else {
            firestore.updateTask(uid, updatedTask);
          }
        },
      ),
    );
  }

  void _confirmDelete(TaskModel task) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCardElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.borderCard),
        ),
        title: const Text('Delete Task?'),
        content: Text(
          'Are you sure you want to delete "${task.text}"? This action cannot be undone.',
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
              ref.read(firestoreServiceProvider).deleteTask(uid, task.id);
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
    final activeTab = ref.watch(taskFilterTabProvider);
    final counts = ref.watch(taskCountsProvider);
    final filteredTasks = ref.watch(filteredTasksProvider);
    final categoryFilter = ref.watch(taskCategoryFilterProvider);
    final uid = ref.watch(currentUserIdProvider);
    final firestore = ref.watch(firestoreServiceProvider);
    final allTasks = ref.watch(tasksStreamProvider).value ?? [];

    final categories = ['All', 'Coding', 'Work', 'Study', 'Browser', 'General', 'Personal'];

    return Scaffold(
      backgroundColor: AppColors.bgMain,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tasks',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Manage daily work, track deadlines, and monitor your progress',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: AppColors.textSecondary.withValues(alpha: 0.9),
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => _openTaskEditor(),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('New Task'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.tealAccent,
                      foregroundColor: AppColors.navyPrimary,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      textStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Responsive Body Layout
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 940;

                    if (isWide) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left Section: Search, Filters & Task List
                          Expanded(
                            child: Column(
                              children: [
                                _buildSearchField(),
                                const SizedBox(height: 10),
                                _buildTabBar(activeTab, counts),
                                const SizedBox(height: 8),
                                _buildCategoryPills(categories, categoryFilter),
                                const SizedBox(height: 10),
                                Expanded(
                                  child: _buildTaskList(
                                    filteredTasks: filteredTasks,
                                    uid: uid,
                                    firestore: firestore,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Right Section: Progress Pie Card & Insights
                          SizedBox(
                            width: 320,
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  const TaskProgressPieCard(),
                                  const SizedBox(height: 14),
                                  _buildInsightsCard(allTasks),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    } else {
                      // Narrow / Mobile Layout
                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            const TaskProgressPieCard(),
                            const SizedBox(height: 12),
                            _buildSearchField(),
                            const SizedBox(height: 10),
                            _buildTabBar(activeTab, counts),
                            const SizedBox(height: 8),
                            _buildCategoryPills(categories, categoryFilter),
                            const SizedBox(height: 10),
                            SizedBox(
                              height: 480,
                              child: _buildTaskList(
                                filteredTasks: filteredTasks,
                                uid: uid,
                                firestore: firestore,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openTaskEditor(),
        backgroundColor: AppColors.tealAccent,
        foregroundColor: AppColors.navyPrimary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderCard),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          const Icon(Icons.search, size: 18, color: AppColors.textMuted),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
              decoration: const InputDecoration(
                hintText: 'Search tasks by title, note, or tag...',
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
                filled: false,
              ),
              onChanged: (val) {
                ref.read(taskSearchQueryProvider.notifier).state = val;
              },
            ),
          ),
          if (_searchController.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                ref.read(taskSearchQueryProvider.notifier).state = '';
              },
              child: const Icon(Icons.clear, size: 16, color: AppColors.textMuted),
            ),
        ],
      ),
    );
  }

  Widget _buildTabBar(TaskFilterTab activeTab, Map<TaskFilterTab, int> counts) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildTabChip(TaskFilterTab.today, 'Today', counts[TaskFilterTab.today] ?? 0, activeTab),
          _buildTabChip(TaskFilterTab.upcoming, 'Upcoming', counts[TaskFilterTab.upcoming] ?? 0, activeTab),
          _buildTabChip(TaskFilterTab.completed, 'Completed', counts[TaskFilterTab.completed] ?? 0, activeTab),
          _buildTabChip(TaskFilterTab.all, 'All', counts[TaskFilterTab.all] ?? 0, activeTab),
        ],
      ),
    );
  }

  Widget _buildCategoryPills(List<String> categories, String? categoryFilter) {
    return SizedBox(
      height: 30,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (ctx, index) {
          final cat = categories[index];
          final isSelected = (categoryFilter == null && cat == 'All') || categoryFilter == cat;
          return GestureDetector(
            onTap: () {
              ref.read(taskCategoryFilterProvider.notifier).state = cat == 'All' ? null : cat;
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.navyPrimary : AppColors.bgCard,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isSelected ? AppColors.navyPrimary : AppColors.borderSubtle,
                ),
              ),
              child: Center(
                child: Text(
                  cat,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTaskList({
    required List<TaskModel> filteredTasks,
    required String uid,
    required dynamic firestore,
  }) {
    if (filteredTasks.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.borderCard),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_outline_rounded,
                size: 46,
                color: AppColors.textMuted.withValues(alpha: 0.4),
              ),
              const SizedBox(height: 10),
              const Text(
                'No tasks found',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Try changing filters or click "+ New Task" above',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderCard),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: ListView.separated(
          padding: const EdgeInsets.all(10),
          itemCount: filteredTasks.length,
          separatorBuilder: (_, __) => const SizedBox(height: 6),
          itemBuilder: (ctx, index) {
            final task = filteredTasks[index];
            return TaskCardItem(
              key: ValueKey(task.id),
              task: task,
              onToggleDone: () => firestore.toggleTaskDone(uid, task),
              onEdit: () => _openTaskEditor(task),
              onDelete: () => _confirmDelete(task),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTabChip(TaskFilterTab tab, String label, int count, TaskFilterTab current) {
    final isSelected = tab == current;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: InkWell(
        onTap: () {
          ref.read(taskFilterTabProvider.notifier).state = tab;
        },
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.navyPrimary : AppColors.bgCard,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isSelected ? AppColors.navyPrimary : AppColors.borderCard,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isSelected) ...[
                const Icon(Icons.check, size: 12, color: AppColors.tealAccent),
                const SizedBox(width: 5),
              ],
              Text(
                '$label ($count)',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInsightsCard(List<TaskModel> tasks) {
    final highPriority = tasks.where((t) => !t.done && t.priority == 'High').length;
    final completedCount = tasks.where((t) => t.done).length;
    final totalCount = tasks.length;

    return DashboardSectionCard(
      title: 'Productivity Insights',
      icon: Icons.lightbulb_outline,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildInsightRow(
            icon: Icons.check_circle_rounded,
            iconColor: AppColors.tealAccent,
            title: 'Completed Milestones',
            subtitle: '$completedCount of $totalCount tasks finished',
          ),
          const Divider(height: 14, color: AppColors.borderSubtle),
          _buildInsightRow(
            icon: Icons.priority_high_rounded,
            iconColor: highPriority > 0 ? AppColors.priorityHigh : AppColors.greenSuccess,
            title: highPriority > 0 ? '$highPriority Urgent Items' : 'All Clear',
            subtitle: highPriority > 0
                ? 'High priority tasks require your immediate attention'
                : 'No urgent high-priority tasks pending!',
          ),
        ],
      ),
    );
  }

  Widget _buildInsightRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 14, color: iconColor),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.navyPrimary,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10.5,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
