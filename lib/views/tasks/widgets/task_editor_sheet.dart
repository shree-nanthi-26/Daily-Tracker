import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../models/task_model.dart';
import '../../../../core/theme/app_colors.dart';

class TaskEditorSheet extends StatefulWidget {
  final TaskModel? existingTask;
  final Function(TaskModel task) onSave;

  const TaskEditorSheet({
    super.key,
    this.existingTask,
    required this.onSave,
  });

  @override
  State<TaskEditorSheet> createState() => _TaskEditorSheetState();
}

class _TaskEditorSheetState extends State<TaskEditorSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _notesController;
  late String _priority;
  late String _category;
  DateTime? _dueDate;

  final List<String> _categories = [
    'Coding',
    'Work',
    'Study',
    'Browser',
    'General',
    'Personal'
  ];

  final List<String> _priorities = ['High', 'Medium', 'Low'];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.existingTask?.text ?? '');
    _notesController = TextEditingController(text: widget.existingTask?.notes ?? '');
    _priority = widget.existingTask?.priority ?? 'Medium';
    _category = widget.existingTask?.category ?? 'General';
    if (widget.existingTask?.dueDate != null) {
      _dueDate = DateTime.tryParse(widget.existingTask!.dueDate!);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 3)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              surface: AppColors.bgCard,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final dueDateStr = _dueDate != null
          ? DateFormat('yyyy-MM-dd').format(_dueDate!)
          : null;

      final task = widget.existingTask != null
          ? widget.existingTask!.copyWith(
              text: _titleController.text.trim(),
              notes: _notesController.text.trim(),
              priority: _priority,
              category: _category,
              dueDate: dueDateStr,
            )
          : TaskModel(
              id: '',
              text: _titleController.text.trim(),
              notes: _notesController.text.trim(),
              priority: _priority,
              category: _category,
              dueDate: dueDateStr,
              createdAt: DateTime.now(),
            );

      widget.onSave(task);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingTask != null;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bgCardElevated,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEditing ? 'Edit Task' : 'New Task',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20, color: AppColors.textMuted),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Task Title
              const Text(
                'Task Description',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _titleController,
                autofocus: !isEditing,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'What needs to get done?',
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter a task description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Notes / Details
              const Text(
                'Notes & Details (Optional)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                decoration: const InputDecoration(
                  hintText: 'Add context, links, or sub-tasks...',
                ),
              ),
              const SizedBox(height: 16),

              // Priority Selector
              const Text(
                'Priority',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: _priorities.map((p) {
                  final isSelected = _priority == p;
                  final pColor = AppColors.getPriorityColor(p);
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(p),
                      selected: isSelected,
                      selectedColor: pColor.withValues(alpha: 0.2),
                      backgroundColor: AppColors.bgInput,
                      side: BorderSide(
                        color: isSelected ? pColor : AppColors.borderSubtle,
                      ),
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? pColor : AppColors.textSecondary,
                      ),
                      onSelected: (selected) {
                        if (selected) setState(() => _priority = p);
                      },
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Category & Due Date Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Dropdown
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Category',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: AppColors.bgInput,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.borderSubtle),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _category,
                              isExpanded: true,
                              dropdownColor: AppColors.bgCardElevated,
                              style: const TextStyle(
                                  color: AppColors.textPrimary, fontSize: 13),
                              items: _categories.map((c) {
                                return DropdownMenuItem(
                                  value: c,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: AppColors.getCategoryColor(c),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(c),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _category = val);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Due Date
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Due Date',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        InkWell(
                          onTap: _selectDueDate,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: AppColors.bgInput,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.borderSubtle),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today,
                                    size: 15, color: AppColors.textMuted),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _dueDate != null
                                        ? DateFormat('MMM d, yyyy').format(_dueDate!)
                                        : 'Select Date',
                                    style: TextStyle(
                                      color: _dueDate != null
                                          ? AppColors.textPrimary
                                          : AppColors.textMuted,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                if (_dueDate != null)
                                  GestureDetector(
                                    onTap: () => setState(() => _dueDate = null),
                                    child: const Icon(Icons.clear,
                                        size: 16, color: AppColors.textMuted),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: Text(isEditing ? 'Save Changes' : 'Create Task'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
