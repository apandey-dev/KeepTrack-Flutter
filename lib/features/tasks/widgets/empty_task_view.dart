import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../shared/duotone_icon.dart';
import '../../../shared/pill_button.dart';

class EmptyTaskView extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onAddTask;

  const EmptyTaskView({
    super.key,
    this.title = 'No tasks for this day',
    this.subtitle = 'Enjoy your free time or plan your next achievement.',
    required this.onAddTask,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36.0, vertical: 48.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppDuotoneIcon(
              icon: Icons.checklist_rounded,
              size: 80,
              iconSize: 40,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.mali(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.mali(
                fontSize: 14,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            PillButton(
              label: 'Add Task',
              icon: Icons.add_rounded,
              height: 46,
              onPressed: onAddTask,
            ),
          ],
        ),
      ),
    );
  }
}
