import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/utils/date_utils.dart';
import '../../models/task_model.dart';
import '../tasks/task_controller.dart';
import '../../shared/app_top_header.dart';
import 'screens/prev_day_detail_screen.dart';

class ScheduleScreen extends ConsumerWidget {
  const ScheduleScreen({super.key});

  List<DateTime> _getFirstSectionDates() {
    final now = DateTime.now();
    final year = (now.year == 2026) ? 2026 : now.year;
    final month = (now.year == 2026) ? 10 : now.month;
    final totalDays = DateTime(year, month + 1, 0).day;
    return List.generate(totalDays, (i) => DateTime(year, month, 1 + i));
  }

  List<DateTime> _getSecondSectionDates() {
    final now = DateTime.now();
    final month = (now.year == 2026) ? 11 : (now.month == 12 ? 1 : now.month + 1);
    final nextYear = (now.year == 2026) ? 2026 : (now.month == 12 ? now.year + 1 : now.year);
    final totalDays = DateTime(nextYear, month + 1, 0).day;
    return List.generate(totalDays, (i) => DateTime(nextYear, month, 1 + i));
  }

  String _getFirstSectionTitle() {
    final now = DateTime.now();
    if (now.year == 2026 && now.month == 10) {
      return 'OCTOBER 2026';
    }
    return DateFormat('MMMM yyyy').format(now).toUpperCase();
  }

  String _getSecondSectionTitle() {
    final now = DateTime.now();
    if (now.year == 2026 && now.month == 10) {
      return 'NOVEMBER 2026';
    }
    final nextMonth = DateTime(now.year, now.month + 1, 1);
    return DateFormat('MMMM yyyy').format(nextMonth).toUpperCase();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF7F8FA);
    final allTasks = ref.watch(allTasksProvider).value ?? [];

    final firstDates = _getFirstSectionDates();
    final secondDates = _getSecondSectionDates();
    final firstTitle = _getFirstSectionTitle();
    final secondTitle = _getSecondSectionTitle();

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Header [ Today | Record ] Capsule + Sun/Moon Theme Toggle
            AppTopHeader(
              isRecordTab: true,
              onTabChanged: (isRecord) {
                if (!isRecord) {
                  context.go('/today');
                }
              },
            ),

            const SizedBox(height: 4),

            // Scrollable Calendar Grids matching assets/records.png
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Section 1 Header: e.g. OCTOBER 2026
                    _buildSectionHeader(firstTitle, isDark),
                    const SizedBox(height: 12),

                    // Section 1: 4-Column Date Grid
                    _buildDateGrid(context, firstDates, isDark, allTasks),

                    const SizedBox(height: 28),

                    // Section 2 Header: e.g. NOVEMBER 2026
                    _buildSectionHeader(secondTitle, isDark),
                    const SizedBox(height: 12),

                    // Section 2: 4-Column Date Grid
                    _buildDateGrid(context, secondDates, isDark, allTasks),

                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    final dividerColor = isDark ? const Color(0xFF2E2E2E) : const Color(0xFFE5E7EB);
    return Row(
      children: [
        Text(
          title,
          style: GoogleFonts.mali(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: const Color(0xFF9CA3AF),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Container(
            height: 1.2,
            color: dividerColor,
          ),
        ),
      ],
    );
  }

  Widget _buildDateGrid(
    BuildContext context,
    List<DateTime> dates,
    bool isDark,
    List<TaskModel> allTasks,
  ) {
    final today = DateTime.now();

    return LayoutBuilder(
      builder: (context, constraints) {
        const crossAxisCount = 4;
        const spacing = 10.0;
        final totalSpacing = spacing * (crossAxisCount - 1);
        final tileWidth = (constraints.maxWidth - totalSpacing) / crossAxisCount;
        final tileHeight = tileWidth * 1.08;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: dates.map((date) {
            final isToday = date.year == today.year &&
                date.month == today.month &&
                date.day == today.day;

            final dateKey = AppDateUtils.toDateKey(date);
            final dayTasks = allTasks.where((t) => t.dateKey == dateKey).toList();
            final hasTasks = dayTasks.isNotEmpty;
            final allDone = hasTasks && dayTasks.every((t) => t.isCompleted);
            final hasPending = hasTasks && dayTasks.any((t) => !t.isCompleted);

            final weekdayShort = DateFormat('EEE').format(date).toUpperCase();

            Color tileBg;
            Border border;
            Color weekdayColor = const Color(0xFF9CA3AF);
            Color dayNumberColor = isDark ? Colors.white : const Color(0xFF111827);

            if (allDone) {
              // Day is completed: GREEN tile!
              tileBg = isDark
                  ? const Color(0xFF064E3B).withValues(alpha: 0.5)
                  : const Color(0xFFD1FAE5);
              border = Border.all(
                color: const Color(0xFF10B981),
                width: 1.8,
              );
              weekdayColor = isDark ? const Color(0xFFA7F3D0) : const Color(0xFF047857);
              dayNumberColor = isDark ? const Color(0xFF6EE7B7) : const Color(0xFF065F46);
            } else if (hasPending) {
              // Day has tasks but not all completed: ORANGE BORDER!
              tileBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
              border = Border.all(
                color: const Color(0xFFF59E0B),
                width: 1.8,
              );
              dayNumberColor = isDark ? Colors.white : const Color(0xFF111827);
            } else if (isToday) {
              tileBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
              border = Border.all(
                color: isDark ? Colors.white : const Color(0xFF111827),
                width: 1.8,
              );
            } else {
              tileBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
              border = Border.all(
                color: isDark ? const Color(0xFF262626) : const Color(0xFFF0F2F5),
                width: 1.0,
              );
            }

            return GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PrevDayDetailScreen(date: date),
                  ),
                );
              },
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: tileWidth,
                height: tileHeight,
                decoration: BoxDecoration(
                  color: tileBg,
                  borderRadius: BorderRadius.circular(18),
                  border: border,
                  boxShadow: (isDark || isToday || allDone || hasPending)
                      ? null
                      : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      weekdayShort,
                      style: GoogleFonts.mali(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.6,
                        color: weekdayColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${date.day}',
                      style: GoogleFonts.mali(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                        color: dayNumberColor,
                      ),
                    ),
                    if (allDone) ...[
                      const SizedBox(height: 2),
                      const Icon(
                        Icons.check_rounded,
                        size: 13,
                        color: Color(0xFF10B981),
                      ),
                    ] else if (hasPending) ...[
                      const SizedBox(height: 4),
                      Container(
                        width: 5,
                        height: 5,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF59E0B),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ] else if (isToday) ...[
                      const SizedBox(height: 3),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white : const Color(0xFF111827),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 7),
                    ],
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
