import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/utils/date_utils.dart';
import '../../tasks/task_controller.dart';
import 'date_day_pill.dart';

class WeeklyDateSelector extends ConsumerWidget {
  final List<DateTime> next7Days;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const WeeklyDateSelector({
    super.key,
    required this.next7Days,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateKeys = next7Days.map((d) => AppDateUtils.toDateKey(d)).toList();
    final weeklyStats = ref.watch(weeklyStatsProvider(dateKeys));

    return SizedBox(
      height: 94,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: next7Days.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.xs),
        itemBuilder: (context, index) {
          final date = next7Days[index];
          final key = AppDateUtils.toDateKey(date);
          final stats = weeklyStats[key];
          final isSelected = AppDateUtils.isSameDay(date, selectedDate);

          return DateDayPill(
            date: date,
            isSelected: isSelected,
            totalTasks: stats?.total ?? 0,
            onTap: () => onDateSelected(date),
          );
        },
      ),
    );
  }
}
