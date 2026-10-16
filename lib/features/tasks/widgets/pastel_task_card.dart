import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/task_model.dart';
import '../../../models/task_theme_color.dart';

class PastelTaskCard extends StatelessWidget {
  final TaskModel? task;
  final bool isNewTaskButton;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final double? width;
  final double? height;

  const PastelTaskCard({
    super.key,
    this.task,
    this.isNewTaskButton = false,
    required this.onTap,
    this.onLongPress,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isNewTaskButton) {
      final newCardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
      final newCardBorder = isDark ? const Color(0xFF2E2E2E) : const Color(0xFFE5E7EB);
      final newCardText = isDark ? const Color(0xFFD1D5DB) : const Color(0xFF4B5563);

      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: width ?? 110,
          height: height ?? 90,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: newCardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: newCardBorder, width: 1.2),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
          ),
          alignment: Alignment.center,
          child: Text(
            'New Task',
            textAlign: TextAlign.center,
            style: GoogleFonts.mali(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: newCardText,
            ),
          ),
        ),
      );
    }

    final isCompleted = task?.isCompleted ?? false;
    final theme = TaskThemeColor.getByIndex(task?.colorIndex ?? 1);
    final cardBg = isDark
        ? Color.alphaBlend(theme.background.withValues(alpha: 0.2), const Color(0xFF1E1E1E))
        : theme.background;

    // Green border for completed task!
    final borderColor = isCompleted
        ? const Color(0xFF10B981)
        : (isDark ? theme.border.withValues(alpha: 0.4) : theme.border);
    final borderWidth = isCompleted ? 2.0 : 1.2;
    final textColor = isDark ? Colors.white : theme.primary;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: width ?? 110,
        height: height ?? 90,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: borderWidth),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.025),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              task?.title ?? '',
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.mali(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: textColor,
                letterSpacing: -0.2,
                height: 1.25,
              ),
            ),
            if (isCompleted) ...[
              const SizedBox(height: 3),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 11,
                    color: Color(0xFF10B981),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    'Done',
                    style: GoogleFonts.mali(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
            ] else if (task?.dueTime != null && task!.dueTime!.isNotEmpty) ...[
              const SizedBox(height: 3),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                decoration: BoxDecoration(
                  color: isDark ? Colors.black38 : Colors.white70,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  task!.dueTime!,
                  maxLines: 1,
                  style: GoogleFonts.mali(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                    color: textColor.withValues(alpha: 0.85),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
