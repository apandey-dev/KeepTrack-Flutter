import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/utils/date_utils.dart';
import '../../../models/priority_level.dart';
import '../../../models/task_model.dart';
import '../../../shared/custom_snackbar.dart';
import '../task_controller.dart';
import 'task_checkbox.dart';
import 'task_delete_dialog.dart';
import 'task_form_sheet.dart';

class TaskCard extends ConsumerWidget {
  final TaskModel task;

  const TaskCard({
    super.key,
    required this.task,
  });

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    TaskDeleteDialog.show(
      context,
      task.title,
      () async {
        final success = await ref.read(taskActionProvider.notifier).deleteTask(task.id);
        if (context.mounted && success) {
          AppSnackbar.show(context, message: 'Task deleted');
        }
      },
    );
  }

  void _openEdit(BuildContext context) {
    TaskFormSheet.show(
      context,
      initialDate: task.scheduledDate,
      taskToEdit: task,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardBg = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final primaryTextColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final mutedTextColor = isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary;
    final secondaryTextColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Dismissible(
      key: Key('dismiss_${task.id}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        _confirmDelete(context, ref);
        return false; // Let the confirmation dialog perform actual deletion
      },
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 6.0),
        padding: const EdgeInsets.only(right: 20.0),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurfaceSecondary : AppColors.lightSurfaceSecondary,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: borderColor),
        ),
        child: Icon(
          Icons.delete_outline_rounded,
          color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
          size: 24,
        ),
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(vertical: 6.0),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: task.isCompleted
                ? (isDark ? AppColors.darkDivider : AppColors.lightDivider)
                : borderColor,
            width: 1.0,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Circular Checkbox
            Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: TaskCheckbox(
                isCompleted: task.isCompleted,
                onChanged: (val) {
                  ref.read(taskActionProvider.notifier).toggleTaskCompletion(task.id, val);
                },
              ),
            ),
            const SizedBox(width: AppSpacing.md),

            // Task Content
            Expanded(
              child: GestureDetector(
                onTap: () => _openEdit(context),
                behavior: HitTestBehavior.opaque,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Task Title
                    Text(
                      task.title,
                      style: GoogleFonts.mali(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                        decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                        color: task.isCompleted ? mutedTextColor : primaryTextColor,
                      ),
                    ),

                    // Task Description if present
                    if (task.description != null && task.description!.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        task.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.mali(
                          fontSize: 13,
                          color: task.isCompleted ? mutedTextColor : secondaryTextColor,
                        ),
                      ),
                    ],

                    // Badges row: Due Time & Priority
                    if (task.dueTime != null || task.priority != TaskPriority.low) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 4.0,
                        children: [
                          if (task.dueTime != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.darkSurfaceSecondary
                                    : AppColors.lightSurfaceSecondary,
                                borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                                border: Border.all(color: borderColor, width: 0.8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.access_time_rounded,
                                    size: 12,
                                    color: task.isCompleted ? mutedTextColor : secondaryTextColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    AppDateUtils.formatStoredTime(task.dueTime),
                                    style: GoogleFonts.mali(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: task.isCompleted ? mutedTextColor : secondaryTextColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (task.priority != TaskPriority.low)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.darkSurfaceSecondary
                                    : AppColors.lightSurfaceSecondary,
                                borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                                border: Border.all(color: borderColor, width: 0.8),
                              ),
                              child: Text(
                                task.priority.label,
                                style: GoogleFonts.mali(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: task.isCompleted ? mutedTextColor : primaryTextColor,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Actions Popup Menu
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert_rounded,
                size: 18,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
              padding: EdgeInsets.zero,
              color: cardBg,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                side: BorderSide(color: borderColor),
              ),
              onSelected: (val) {
                if (val == 'edit') {
                  _openEdit(context);
                } else if (val == 'delete') {
                  _confirmDelete(context, ref);
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      const Icon(Icons.edit_outlined, size: 16),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        'Edit',
                        style: GoogleFonts.mali(fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      const Icon(Icons.delete_outline_rounded, size: 16),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        'Delete',
                        style: GoogleFonts.mali(fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
