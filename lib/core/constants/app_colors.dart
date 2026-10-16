import 'package:flutter/material.dart';

/// AppColors encapsulates the strict monochrome design system palette.
/// It emphasizes high contrast, crisp lines, and calm, distraction-free surfaces.
class AppColors {
  AppColors._();

  // Monochrome Core - Light
  static const Color lightBackground = Color(0xFFFAFAFA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceSecondary = Color(0xFFF2F2F7);
  static const Color lightTextPrimary = Color(0xFF111111);
  static const Color lightTextSecondary = Color(0xFF6B6B70);
  static const Color lightTextTertiary = Color(0xFF9E9EA4);
  static const Color lightBorder = Color(0xFFE5E5EA);
  static const Color lightDivider = Color(0xFFEEEEF0);

  // Monochrome Core - Dark
  static const Color darkBackground = Color(0xFF0D0D0E);
  static const Color darkSurface = Color(0xFF161618);
  static const Color darkSurfaceSecondary = Color(0xFF222226);
  static const Color darkTextPrimary = Color(0xFFF5F5F7);
  static const Color darkTextSecondary = Color(0xFFA1A1A6);
  static const Color darkTextTertiary = Color(0xFF636366);
  static const Color darkBorder = Color(0xFF2C2C2E);
  static const Color darkDivider = Color(0xFF1F1F23);

  // Pure Tones
  static const Color pureBlack = Color(0xFF000000);
  static const Color pureWhite = Color(0xFFFFFFFF);

  // Priority Monochrome Shades
  static const Color priorityLowLight = Color(0xFF8E8E93);
  static const Color priorityMediumLight = Color(0xFF48484A);
  static const Color priorityHighLight = Color(0xFF000000);

  static const Color priorityLowDark = Color(0xFF636366);
  static const Color priorityMediumDark = Color(0xFFA1A1A6);
  static const Color priorityHighDark = Color(0xFFFFFFFF);
}
