import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../models/task_model.dart';
import '../../../models/task_theme_color.dart';
import '../../../services/notification_service.dart';
import '../../../shared/custom_snackbar.dart';
import '../task_controller.dart';

class TaskDetailScreen extends ConsumerWidget {
  final TaskModel task;
  final bool isFromRecord;

  const TaskDetailScreen({
    super.key,
    required this.task,
    this.isFromRecord = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = TaskThemeColor.getByIndex(task.colorIndex);

    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF7F8FA);
    final cardBg = isDark
        ? Color.alphaBlend(theme.background.withValues(alpha: 0.2), const Color(0xFF1E1E1E))
        : theme.background;
    final borderColor = isDark ? theme.border.withValues(alpha: 0.4) : theme.border;
    final primaryTextColor = isDark ? Colors.white : theme.primary;
    final secondaryTextColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);

    final objectives = task.objectives;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              // Big Pastel Card with Task Title
              Container(
                height: 120,
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: borderColor, width: 1.5),
                ),
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  task.title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.mali(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                    color: primaryTextColor,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Due Time & Reminder Pills
              Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    if (task.dueTime != null && task.dueTime!.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDark ? const Color(0xFF2E2E2E) : const Color(0xFFE5E7EB),
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.access_time_rounded,
                              size: 15,
                              color: Color(0xFF3B82F6),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Due at ${task.dueTime}',
                              style: GoogleFonts.mali(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : const Color(0xFF111827),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Reminder status & toggle pill
                    GestureDetector(
                      onTap: isFromRecord ? null : () => _toggleReminder(context, ref),
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: task.reminderEnabled
                              ? (isDark ? const Color(0xFF1E2838) : const Color(0xFFEFF6FF))
                              : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: task.reminderEnabled
                                ? (isDark
                                    ? const Color(0xFF3B82F6).withValues(alpha: 0.5)
                                    : const Color(0xFFBFDBFE))
                                : (isDark
                                    ? const Color(0xFF2E2E2E)
                                    : const Color(0xFFE5E7EB)),
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              task.reminderEnabled
                                  ? Icons.notifications_active_rounded
                                  : Icons.notifications_none_rounded,
                              size: 15,
                              color: task.reminderEnabled
                                  ? const Color(0xFF3B82F6)
                                  : secondaryTextColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              task.reminderEnabled && task.reminderDateTime != null
                                  ? 'Reminder: ${DateFormat('d MMM, hh:mm a').format(task.reminderDateTime!)}'
                                  : 'Set Reminder',
                              style: GoogleFonts.mali(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: task.reminderEnabled
                                    ? (isDark
                                        ? const Color(0xFF93C5FD)
                                        : const Color(0xFF2563EB))
                                    : secondaryTextColor,
                              ),
                            ),
                            if (!isFromRecord) ...[
                              const SizedBox(width: 4),
                              Icon(
                                Icons.edit_outlined,
                                size: 12,
                                color: task.reminderEnabled
                                    ? const Color(0xFF3B82F6)
                                    : secondaryTextColor,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),


              const SizedBox(height: 36),

              // Section: TASK OBJECTIVES
              Text(
                'TASK OBJECTIVES',
                style: GoogleFonts.mali(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: secondaryTextColor,
                ),
              ),
              const SizedBox(height: 20),

              // Objectives Bullet List
              if (objectives.isEmpty)
                Text(
                  'No specific objectives provided.',
                  style: GoogleFonts.mali(
                    fontSize: 14,
                    color: secondaryTextColor,
                    fontStyle: FontStyle.italic,
                  ),
                )
              else
                ...objectives.map(
                  (obj) => Padding(
                    padding: const EdgeInsets.only(bottom: 18.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, right: 14.0),
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: theme.dot,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            obj,
                            style: GoogleFonts.mali(
                              fontSize: 15,
                              height: 1.5,
                              fontWeight: FontWeight.w500,
                              color: isDark ? const Color(0xFFE5E7EB) : const Color(0xFF1F2937),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Bottom Button: "Mark as Done" ONLY when NOT opened from Record
              if (!isFromRecord) ...[
                const SizedBox(height: 36),
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () async {
                      final newStatus = !task.isCompleted;
                      final success = await ref
                          .read(taskActionProvider.notifier)
                          .toggleTaskCompletion(task.id, newStatus);
                      if (context.mounted && success) {
                        context.pop();
                        AppSnackbar.show(
                          context,
                          message: newStatus ? 'Task completed! 🎉' : 'Task marked as pending',
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: task.isCompleted
                          ? (isDark ? const Color(0xFF262626) : const Color(0xFFE5E7EB))
                          : (isDark ? Colors.white : const Color(0xFF111827)),
                      foregroundColor: task.isCompleted
                          ? (isDark ? Colors.white70 : const Color(0xFF374151))
                          : (isDark ? Colors.black : Colors.white),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          task.isCompleted
                              ? Icons.check_circle_rounded
                              : Icons.check_circle_outline_rounded,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          task.isCompleted ? 'Completed ✓ (Tap to Undo)' : 'Mark as Done',
                          style: GoogleFonts.mali(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ] else if (task.isCompleted) ...[
                // In records, just show a subtle non-interactive completed badge
                const SizedBox(height: 28),
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E2E24) : const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? const Color(0xFF065F46) : const Color(0xFFA7F3D0),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          size: 16,
                          color: Color(0xFF10B981),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Task Completed on this day',
                          style: GoogleFonts.mali(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF10B981),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _toggleReminder(BuildContext context, WidgetRef ref) async {
    final newEnabled = !task.reminderEnabled;
    if (newEnabled) {
      final granted = await NotificationService().requestPermissions();
      if (!context.mounted) return;
      if (!granted) {
        AppSnackbar.show(
          context,
          message: 'Notification permission is required to enable reminders.',
          isError: true,
        );
        return;
      }

      DateTime? reminderDate = task.reminderDateTime;
      final now = DateTime.now();
      if (reminderDate == null || reminderDate.isBefore(now)) {
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: task.scheduledDate.isAfter(now) ? task.scheduledDate : now,
          firstDate: now,
          lastDate: DateTime(now.year + 5),
        );
        if (pickedDate == null || !context.mounted) return;

        final pickedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );
        if (pickedTime == null || !context.mounted) return;

        reminderDate = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        if (reminderDate.isBefore(DateTime.now())) {
          if (context.mounted) {
            AppSnackbar.show(
              context,
              message: 'Reminder time cannot be in the past.',
              isError: true,
            );
          }
          return;
        }
      }

      final updatedTask = task.copyWith(
        reminderEnabled: true,
        reminderDateTime: reminderDate,
      );
      await ref.read(taskActionProvider.notifier).updateTask(updatedTask);
      if (context.mounted) {
        AppSnackbar.show(
          context,
          message:
              'Reminder set for ${DateFormat('d MMM, hh:mm a').format(reminderDate)} 🔔',
        );
      }
    } else {
      final updatedTask = task.copyWith(
        reminderEnabled: false,
      );
      await ref.read(taskActionProvider.notifier).updateTask(updatedTask);
      if (context.mounted) {
        AppSnackbar.show(context, message: 'Reminder turned off.');
      }
    }
  }
}

