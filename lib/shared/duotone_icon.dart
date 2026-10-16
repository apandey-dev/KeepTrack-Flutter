import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

/// AppDuotoneIcon creates a rounded, circular, duotone-style icon container.
/// It uses two monochrome tones: a soft background surface and high-contrast foreground icon,
/// optionally with a subtle dual-layer accent.
class AppDuotoneIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final double iconSize;
  final VoidCallback? onTap;
  final bool isSelected;
  final Color? backgroundColor;
  final Color? iconColor;
  final Widget? badge;

  const AppDuotoneIcon({
    super.key,
    required this.icon,
    this.size = 44.0,
    this.iconSize = 22.0,
    this.onTap,
    this.isSelected = false,
    this.backgroundColor,
    this.iconColor,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Duotone color calculations
    final defaultBg = isSelected
        ? (isDark ? AppColors.pureWhite : AppColors.pureBlack)
        : (isDark ? AppColors.darkSurfaceSecondary : AppColors.lightSurfaceSecondary);

    final defaultIconColor = isSelected
        ? (isDark ? AppColors.pureBlack : AppColors.pureWhite)
        : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary);

    final effectiveBg = backgroundColor ?? defaultBg;
    final effectiveIconColor = iconColor ?? defaultIconColor;

    Widget container = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: effectiveBg,
        shape: BoxShape.circle,
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1.0,
        ),
      ),
      child: Center(
        child: Icon(
          icon,
          size: iconSize,
          color: effectiveIconColor,
        ),
      ),
    );

    if (badge != null) {
      container = Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          container,
          Positioned(
            right: 0,
            top: 0,
            child: badge!,
          ),
        ],
      );
    }

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: container,
        ),
      );
    }

    return container;
  }
}
