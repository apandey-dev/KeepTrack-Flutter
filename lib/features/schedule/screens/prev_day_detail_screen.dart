import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/date_utils.dart';
import '../../../shared/custom_snackbar.dart';
import '../../tasks/widgets/task_delete_dialog.dart';
import '../../tasks/screens/task_detail_screen.dart';
import '../../tasks/task_controller.dart';
import '../../tasks/widgets/pastel_task_card.dart';

class PrevDayDetailScreen extends ConsumerWidget {
  final DateTime date;

  const PrevDayDetailScreen({super.key, required this.date});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateKey = AppDateUtils.toDateKey(date);
    final tasksAsync = ref.watch(tasksForDateProvider(dateKey));

    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF7F8FA);
    final primaryTextColor = isDark ? Colors.white : const Color(0xFF111827);
    final secondaryTextColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);

    final titleDateFormatted = DateFormat('EEEE, d MMMM yyyy').format(date);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title: e.g. "Friday, 16 October 2026" (No back button, handled by mobile back)
              Text(
                titleDateFormatted,
                style: GoogleFonts.mali(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                  color: primaryTextColor,
                ),
              ),

              const SizedBox(height: 4),

              // Subtitle: "• X Tasks"
              tasksAsync.when(
                data: (tasks) => Text(
                  '• ${tasks.length} ${tasks.length == 1 ? 'Task' : 'Tasks'}',
                  style: GoogleFonts.mali(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: secondaryTextColor,
                  ),
                ),
                loading: () => Text(
                  '• Loading tasks...',
                  style: GoogleFonts.mali(
                    fontSize: 14,
                    color: secondaryTextColor,
                  ),
                ),
                error: (_, _) => Text(
                  '• Unable to load tasks',
                  style: GoogleFonts.mali(
                    fontSize: 14,
                    color: secondaryTextColor,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Tasks Grid / Row strictly for this day (NO New Task button in records!)
              tasksAsync.when(
                data: (tasks) {
                  if (tasks.isEmpty) {
                    return Container(
                      margin: const EdgeInsets.only(top: 24),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 36),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark ? const Color(0xFF2E2E2E) : const Color(0xFFE5E7EB),
                          width: 1.2,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.event_note_rounded,
                            size: 40,
                            color: secondaryTextColor,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No Tasks on This Day',
                            style: GoogleFonts.mali(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: primaryTextColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'There are no tasks recorded for this date.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.mali(
                              fontSize: 13,
                              color: secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      const spacing = 10.0;
                      final cardWidth = (constraints.maxWidth - (spacing * 2)) / 3;
                      final cardHeight = cardWidth * 0.85;

                      return Wrap(
                        spacing: spacing,
                        runSpacing: spacing,
                        children: tasks.map(
                          (task) => PastelTaskCard(
                            task: task,
                            width: cardWidth,
                            height: cardHeight,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => TaskDetailScreen(
                                    task: task,
                                    isFromRecord: true, // Record mode: NO Mark as Done button
                                  ),
                                ),
                              );
                            },
                            onLongPress: () {
                              TaskDeleteBottomSheet.show(
                                context,
                                task.title,
                                () async {
                                  final success = await ref
                                      .read(taskActionProvider.notifier)
                                      .deleteTask(task.id);
                                  if (context.mounted && success) {
                                    AppSnackbar.show(context, message: 'Task deleted');
                                  }
                                },
                              );
                            },
                          ),
                        ).toList(),
                      );
                    },
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                ),
                error: (err, _) => Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    'Error: $err',
                    style: GoogleFonts.mali(color: Colors.redAccent),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
