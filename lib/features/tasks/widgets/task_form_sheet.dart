import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/validators.dart';
import '../../../models/priority_level.dart';
import '../../../models/task_model.dart';
import '../../../shared/custom_snackbar.dart';
import '../../../shared/pill_button.dart';
import '../task_controller.dart';

class TaskFormSheet extends ConsumerStatefulWidget {
  final DateTime initialDate;
  final TaskModel? taskToEdit;

  const TaskFormSheet({
    super.key,
    required this.initialDate,
    this.taskToEdit,
  });

  static Future<void> show(
    BuildContext context, {
    required DateTime initialDate,
    TaskModel? taskToEdit,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => TaskFormSheet(
        initialDate: initialDate,
        taskToEdit: taskToEdit,
      ),
    );
  }

  @override
  ConsumerState<TaskFormSheet> createState() => _TaskFormSheetState();
}

class _TaskFormSheetState extends ConsumerState<TaskFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  late DateTime _selectedDate;
  TimeOfDay? _selectedTime;
  late TaskPriority _selectedPriority;

  @override
  void initState() {
    super.initState();
    final edit = widget.taskToEdit;
    _titleController = TextEditingController(text: edit?.title ?? '');
    _descController = TextEditingController(text: edit?.description ?? '');
    _selectedDate = edit?.scheduledDate ?? widget.initialDate;
    _selectedTime = edit?.dueTime != null ? AppDateUtils.stringToTimeOfDay(edit!.dueTime) : null;
    _selectedPriority = edit?.priority ?? TaskPriority.low;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? const ColorScheme.dark(
                    primary: AppColors.pureWhite,
                    onPrimary: AppColors.pureBlack,
                    surface: AppColors.darkSurface,
                    onSurface: AppColors.darkTextPrimary,
                  )
                : const ColorScheme.light(
                    primary: AppColors.pureBlack,
                    onPrimary: AppColors.pureWhite,
                    surface: AppColors.lightSurface,
                    onSurface: AppColors.lightTextPrimary,
                  ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? const ColorScheme.dark(
                    primary: AppColors.pureWhite,
                    onPrimary: AppColors.pureBlack,
                    surface: AppColors.darkSurface,
                    onSurface: AppColors.darkTextPrimary,
                  )
                : const ColorScheme.light(
                    primary: AppColors.pureBlack,
                    onPrimary: AppColors.pureWhite,
                    surface: AppColors.lightSurface,
                    onSurface: AppColors.lightTextPrimary,
                  ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final dateKey = AppDateUtils.toDateKey(_selectedDate);
    final dueTimeStr = _selectedTime != null ? AppDateUtils.timeOfDayToString(_selectedTime!) : null;

    final isEditing = widget.taskToEdit != null;
    bool success;

    if (isEditing) {
      final updated = widget.taskToEdit!.copyWith(
        title: _titleController.text.trim(),
        description: _descController.text.trim().isEmpty ? null : _descController.text.trim(),
        scheduledDate: _selectedDate,
        dateKey: dateKey,
        dueTime: dueTimeStr,
        priority: _selectedPriority,
      );
      success = await ref.read(taskActionProvider.notifier).updateTask(updated);
    } else {
      final newTask = TaskModel(
        id: '',
        userId: '',
        title: _titleController.text.trim(),
        description: _descController.text.trim().isEmpty ? null : _descController.text.trim(),
        scheduledDate: _selectedDate,
        dateKey: dateKey,
        dueTime: dueTimeStr,
        priority: _selectedPriority,
        isCompleted: false,
      );
      success = await ref.read(taskActionProvider.notifier).createTask(newTask);
    }

    if (!mounted) return;
    if (success) {
      Navigator.of(context).pop();
      AppSnackbar.show(
        context,
        message: isEditing ? 'Task updated' : 'Task added successfully',
      );
    } else {
      final error = ref.read(taskActionProvider).errorMessage;
      if (error != null) {
        AppSnackbar.show(context, message: error, isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final actionState = ref.watch(taskActionProvider);
    final isEditing = widget.taskToEdit != null;

    final cardBg = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final secondaryBg = isDark ? AppColors.darkSurfaceSecondary : AppColors.lightSurfaceSecondary;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLg)),
        border: Border(
          top: BorderSide(color: borderColor, width: 1.2),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Sheet Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEditing ? 'Edit Task' : 'New Task',
                      style: GoogleFonts.mali(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 22),
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),

                // Title Input
                TextFormField(
                  controller: _titleController,
                  autofocus: !isEditing,
                  textCapitalization: TextCapitalization.sentences,
                  style: GoogleFonts.mali(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'What needs to be done?',
                  ),
                  validator: AppValidators.validateTaskTitle,
                ),
                const SizedBox(height: AppSpacing.md),

                // Optional Description Input
                TextFormField(
                  controller: _descController,
                  maxLines: 3,
                  minLines: 2,
                  textCapitalization: TextCapitalization.sentences,
                  style: GoogleFonts.mali(
                    fontSize: 14,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Add description or notes (optional)',
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Date & Time Selectors Row
                Row(
                  children: [
                    // Date Button
                    Expanded(
                      child: GestureDetector(
                        onTap: _pickDate,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: secondaryBg,
                            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                            border: Border.all(color: borderColor),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today_rounded,
                                size: 16,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Expanded(
                                child: Text(
                                  AppDateUtils.isToday(_selectedDate)
                                      ? 'Today'
                                      : AppDateUtils.formatShortDate(_selectedDate),
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.mali(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),

                    // Time Button
                    Expanded(
                      child: GestureDetector(
                        onTap: _pickTime,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: secondaryBg,
                            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                            border: Border.all(color: borderColor),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                size: 16,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Expanded(
                                child: Text(
                                  _selectedTime != null
                                      ? AppDateUtils.formatTimeOfDay(_selectedTime!, context)
                                      : 'Add time',
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.mali(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: _selectedTime != null
                                        ? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)
                                        : (isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary),
                                  ),
                                ),
                              ),
                              if (_selectedTime != null)
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedTime = null;
                                    });
                                  },
                                  child: Icon(
                                    Icons.close_rounded,
                                    size: 16,
                                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),

                // Priority Selector
                Text(
                  'Priority',
                  style: GoogleFonts.mali(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: TaskPriority.values.map((priority) {
                    final isSelected = _selectedPriority == priority;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedPriority = priority;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? (isDark ? AppColors.pureWhite : AppColors.pureBlack)
                                  : secondaryBg,
                              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                              border: Border.all(
                                color: isSelected
                                    ? (isDark ? AppColors.pureWhite : AppColors.pureBlack)
                                    : borderColor,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              priority.label,
                              style: GoogleFonts.mali(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? (isDark ? AppColors.pureBlack : AppColors.pureWhite)
                                    : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Submit Button
                PillButton(
                  label: isEditing ? 'Save Changes' : 'Create Task',
                  isLoading: actionState.isLoading,
                  onPressed: _saveTask,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
