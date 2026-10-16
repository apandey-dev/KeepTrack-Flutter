import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class CircularIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final double size;
  final double iconSize;
  final String? tooltip;
  final bool isPrimary;

  const CircularIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.size = 46.0,
    this.iconSize = 22.0,
    this.tooltip,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isPrimary
        ? (isDark ? AppColors.pureWhite : AppColors.pureBlack)
        : (isDark ? AppColors.darkSurfaceSecondary : AppColors.lightSurfaceSecondary);

    final fgColor = isPrimary
        ? (isDark ? AppColors.pureBlack : AppColors.pureWhite)
        : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary);

    final button = Material(
      color: bgColor,
      shape: CircleBorder(
        side: BorderSide(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1.0,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      child: InkWell(
        onTap: onPressed,
        child: SizedBox(
          width: size,
          height: size,
          child: Center(
            child: Icon(
              icon,
              size: iconSize,
              color: fgColor,
            ),
          ),
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return button;
  }
}
