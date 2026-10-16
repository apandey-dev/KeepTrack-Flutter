import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class TaskCheckbox extends StatelessWidget {
  final bool isCompleted;
  final ValueChanged<bool> onChanged;
  final double size;

  const TaskCheckbox({
    super.key,
    required this.isCompleted,
    required this.onChanged,
    this.size = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final activeBg = isDark ? AppColors.pureWhite : AppColors.pureBlack;
    final activeCheck = isDark ? AppColors.pureBlack : AppColors.pureWhite;
    final inactiveBorder = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return GestureDetector(
      onTap: () => onChanged(!isCompleted),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isCompleted ? activeBg : Colors.transparent,
          border: Border.all(
            color: isCompleted ? activeBg : inactiveBorder,
            width: isCompleted ? 2.0 : 1.8,
          ),
        ),
        child: Center(
          child: AnimatedScale(
            scale: isCompleted ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutBack,
            child: Icon(
              Icons.check_rounded,
              size: size * 0.65,
              color: activeCheck,
            ),
          ),
        ),
      ),
    );
  }
}
