import 'package:flutter/material.dart';
import '../../../../models/task_model.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';

class TaskCardItem extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onToggleDone;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TaskCardItem({
    super.key,
    required this.task,
    required this.onToggleDone,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final priorityColor = AppColors.getPriorityColor(task.priority);
    final categoryColor = AppColors.getCategoryColor(task.category);

    String? formattedDueDate;
    if (task.dueDate != null) {
      final parsed = DateFormatter.parseIsoDate(task.dueDate);
      if (parsed != null) {
        formattedDueDate = DateFormatter.formatDisplay(parsed);
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: task.done ? AppColors.borderSubtle : AppColors.borderCard,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Checkbox
              GestureDetector(
                onTap: onToggleDone,
                child: Container(
                  width: 22,
                  height: 22,
                  margin: const EdgeInsets.only(top: 2, right: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: task.done ? AppColors.primary : AppColors.textMuted,
                      width: 1.5,
                    ),
                    color: task.done ? AppColors.primary : Colors.transparent,
                  ),
                  child: task.done
                      ? const Icon(Icons.check, size: 15, color: Colors.white)
                      : null,
                ),
              ),

              // Title and notes
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.text,
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: task.done ? AppColors.textMuted : AppColors.textPrimary,
                        decoration: task.done ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    if (task.notes != null && task.notes!.trim().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        task.notes!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Quick Actions
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 18, color: AppColors.textMuted),
                color: AppColors.navyPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: AppColors.navySecondary),
                ),
                onSelected: (val) {
                  if (val == 'edit') onEdit();
                  if (val == 'delete') onDelete();
                },
                itemBuilder: (ctx) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 16, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Edit Task',
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
                          'Delete Task',
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
          const SizedBox(height: 10),

          // Badges Row
          Row(
            children: [
              // Priority badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                decoration: BoxDecoration(
                  color: priorityColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  task.priority,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: priorityColor,
                  ),
                ),
              ),
              const SizedBox(width: 6),

              // Category badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(Icons.tag, size: 11, color: categoryColor),
                    const SizedBox(width: 3),
                    Text(
                      task.category ?? 'General',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: categoryColor,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Due Date chip
              if (formattedDueDate != null) ...[
                Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded,
                        size: 11, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text(
                      formattedDueDate,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
