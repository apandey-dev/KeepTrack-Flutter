import 'package:flutter/material.dart';

class TaskThemeColor {
  final Color background;
  final Color border;
  final Color primary;
  final Color dot;

  const TaskThemeColor({
    required this.background,
    required this.border,
    required this.primary,
    required this.dot,
  });

  static const List<TaskThemeColor> palette = [
    // 0: Light Green
    TaskThemeColor(
      background: Color(0xFFEBF5EB),
      border: Color(0xFFD3EBD3),
      primary: Color(0xFF1E6B24),
      dot: Color(0xFF4CAF50),
    ),
    // 1: Light Blue
    TaskThemeColor(
      background: Color(0xFFE8F1FA),
      border: Color(0xFFD0E2F4),
      primary: Color(0xFF1E3A8A),
      dot: Color(0xFF2196F3),
    ),
    // 2: Light Purple
    TaskThemeColor(
      background: Color(0xFFF3EDFA),
      border: Color(0xFFE5D5F7),
      primary: Color(0xFF581C87),
      dot: Color(0xFF8B5CF6),
    ),
    // 3: Light Peach / Orange
    TaskThemeColor(
      background: Color(0xFFFDF0E7),
      border: Color(0xFFF9DCBE),
      primary: Color(0xFFC2410C),
      dot: Color(0xFFF97316),
    ),
    // 4: Light Pink
    TaskThemeColor(
      background: Color(0xFFFCE8EE),
      border: Color(0xFFF8D1DD),
      primary: Color(0xFFBE185D),
      dot: Color(0xFFEC4899),
    ),
    // 5: Light Warm Yellow
    TaskThemeColor(
      background: Color(0xFFFEF9E7),
      border: Color(0xFFFDF0BA),
      primary: Color(0xFFB45309),
      dot: Color(0xFFEAB308),
    ),
    // 6: Light Teal / Cyan
    TaskThemeColor(
      background: Color(0xFFE6F7F7),
      border: Color(0xFFC7EFEF),
      primary: Color(0xFF0F766E),
      dot: Color(0xFF14B8A6),
    ),
    // 7: Light Gray / Lavender
    TaskThemeColor(
      background: Color(0xFFF1F2F6),
      border: Color(0xFFE1E3EB),
      primary: Color(0xFF475569),
      dot: Color(0xFF64748B),
    ),
    // 8: Light Lime
    TaskThemeColor(
      background: Color(0xFFF4F8EB),
      border: Color(0xFFE4F0D2),
      primary: Color(0xFF4D7C0F),
      dot: Color(0xFF84CC16),
    ),
  ];

  static TaskThemeColor getByIndex(int index) {
    if (index < 0 || index >= palette.length) {
      return palette[1]; // default blue
    }
    return palette[index];
  }
}
