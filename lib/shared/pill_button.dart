import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_spacing.dart';

class PillButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isOutlined;
  final double height;
  final double? width;

  const PillButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isOutlined = false,
    this.height = 50.0,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primaryBg = isDark ? AppColors.pureWhite : AppColors.pureBlack;
    final primaryFg = isDark ? AppColors.pureBlack : AppColors.pureWhite;

    Widget childContent;
    if (isLoading) {
      childContent = SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2.0,
          valueColor: AlwaysStoppedAnimation<Color>(
            isOutlined
                ? (isDark ? AppColors.pureWhite : AppColors.pureBlack)
                : primaryFg,
          ),
        ),
      );
    } else {
      childContent = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 18,
              color: isOutlined
                  ? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)
                  : primaryFg,
            ),
            const SizedBox(width: AppSpacing.xs),
          ],
          Text(
            label,
            style: GoogleFonts.mali(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
              color: isOutlined
                  ? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)
                  : primaryFg,
            ),
          ),
        ],
      );
    }

    if (isOutlined) {
      return SizedBox(
        width: width,
        height: height,
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            side: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 1.2,
            ),
            shape: const StadiumBorder(),
          ),
          child: childContent,
        ),
      );
    }

    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBg,
          foregroundColor: primaryFg,
          elevation: 0,
          shape: const StadiumBorder(),
          disabledBackgroundColor: isDark
              ? AppColors.darkSurfaceSecondary
              : AppColors.lightSurfaceSecondary,
        ),
        child: childContent,
      ),
    );
  }
}
