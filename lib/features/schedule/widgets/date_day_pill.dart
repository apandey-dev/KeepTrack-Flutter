import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/utils/date_utils.dart';

class DateDayPill extends StatelessWidget {
  final DateTime date;
  final bool isSelected;
  final int totalTasks;
  final VoidCallback onTap;

  const DateDayPill({
    super.key,
    required this.date,
    required this.isSelected,
    this.totalTasks = 0,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isToday = AppDateUtils.isToday(date);
    final weekday = AppDateUtils.formatWeekday(date);
    final dayNumber = AppDateUtils.formatDayNumber(date);

    final selectedBg = isDark ? AppColors.pureWhite : AppColors.pureBlack;
    final selectedFg = isDark ? AppColors.pureBlack : AppColors.pureWhite;

    final unselectedBg = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final unselectedFg = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: 62,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? selectedBg : unselectedBg,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: isSelected ? selectedBg : borderColor,
            width: isToday && !isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Weekday abbreviation
            Text(
              weekday,
              style: GoogleFonts.mali(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                color: isSelected
                    ? selectedFg
                    : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
              ),
            ),
            const SizedBox(height: 4),

            // Day Number
            Text(
              dayNumber,
              style: GoogleFonts.mali(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isSelected ? selectedFg : unselectedFg,
              ),
            ),
            const SizedBox(height: 6),

            // Indicator: Today badge or Task Count Dot
            if (isToday)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark ? AppColors.pureBlack : AppColors.pureWhite)
                      : (isDark ? AppColors.pureWhite : AppColors.pureBlack),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'TODAY',
                  style: GoogleFonts.mali(
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                    color: isSelected
                        ? (isDark ? AppColors.pureWhite : AppColors.pureBlack)
                        : (isDark ? AppColors.pureBlack : AppColors.pureWhite),
                  ),
                ),
              )
            else if (totalTasks > 0)
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? selectedFg
                      : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                ),
              )
            else
              const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
