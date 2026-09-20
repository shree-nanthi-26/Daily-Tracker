import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/task_model.dart';
import '../../../providers/task_provider.dart';
import '../../dashboard/widgets/dashboard_section_card.dart';

class TaskProgressPieCard extends ConsumerStatefulWidget {
  final double? height;

  const TaskProgressPieCard({super.key, this.height});

  @override
  ConsumerState<TaskProgressPieCard> createState() => _TaskProgressPieCardState();
}

class _TaskProgressPieCardState extends ConsumerState<TaskProgressPieCard> {
  // 'All' or 'Today'
  String _selectedScope = 'All';

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(tasksStreamProvider);
    final allTasks = tasksAsync.value ?? [];

    final todayStr = DateTime.now().toIso8601String().substring(0, 10);
    final List<TaskModel> targetTasks = _selectedScope == 'Today'
        ? allTasks.where((t) => t.dueDate == todayStr || t.dueDate == null).toList()
        : allTasks;

    final totalTasks = targetTasks.length;
    final completedTasks = targetTasks.where((t) => t.done).length;
    final pendingTasks = totalTasks - completedTasks;

    final double completionRate =
        totalTasks > 0 ? (completedTasks / totalTasks) * 100.0 : 0.0;

    // Priority breakdown of pending tasks in current scope
    final highPriority = targetTasks.where((t) => !t.done && t.priority == 'High').length;
    final mediumPriority = targetTasks.where((t) => !t.done && t.priority == 'Medium').length;
    final lowPriority = targetTasks.where((t) => !t.done && t.priority == 'Low').length;

    return DashboardSectionCard(
      title: 'Task Progress',
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildScopeToggle('All', _selectedScope == 'All'),
          const SizedBox(width: 4),
          _buildScopeToggle('Today', _selectedScope == 'Today'),
        ],
      ),
      height: widget.height,
      bodyPadding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Donut Pie Chart with Center Metrics
          SizedBox(
            height: 146,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 3,
                    centerSpaceRadius: 46,
                    startDegreeOffset: -90,
                    sections: totalTasks == 0
                        ? [
                            PieChartSectionData(
                              value: 1,
                              color: AppColors.cellInactive,
                              radius: 18,
                              showTitle: false,
                            ),
                          ]
                        : [
                            // Completed Section (Teal Accent #20BFAE)
                            if (completedTasks > 0)
                              PieChartSectionData(
                                value: completedTasks.toDouble(),
                                color: AppColors.tealAccent,
                                radius: 18,
                                showTitle: false,
                              ),
                            // Pending Section (Dark Navy #0B2D4D)
                            if (pendingTasks > 0)
                              PieChartSectionData(
                                value: pendingTasks.toDouble(),
                                color: AppColors.navyPrimary,
                                radius: 18,
                                showTitle: false,
                              ),
                          ],
                  ),
                ),
                // Center Percentage & Label
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${completionRate.toInt()}%',
                      style: const TextStyle(
                        color: AppColors.navyPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'Complete',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Legend / Status Indicators
          Row(
            children: [
              // Completed Stat Block
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.bgCardElevated,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.borderCard),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: AppColors.tealAccent,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Completed',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '$completedTasks',
                              style: const TextStyle(
                                color: AppColors.navyPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Pending Stat Block
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.bgCardElevated,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.borderCard),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: AppColors.navyPrimary,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'In Progress',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '$pendingTasks',
                              style: const TextStyle(
                                color: AppColors.navyPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Priority Breakdown Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.cellInactive,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildPriorityBadge('High', highPriority, AppColors.priorityHigh),
                Container(width: 1, height: 16, color: AppColors.borderCard),
                _buildPriorityBadge('Medium', mediumPriority, AppColors.priorityMedium),
                Container(width: 1, height: 16, color: AppColors.borderCard),
                _buildPriorityBadge('Low', lowPriority, AppColors.priorityLow),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScopeToggle(String scope, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedScope = scope;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.tealAccent : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSelected ? AppColors.tealAccent : AppColors.tealAccent.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
        child: Text(
          scope,
          style: TextStyle(
            color: isSelected ? AppColors.navyPrimary : Colors.white,
            fontSize: 10.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityBadge(String label, int count, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          '$label: ',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 10.5,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          '$count',
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
