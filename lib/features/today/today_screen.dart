import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/utils/date_utils.dart';
import '../../shared/custom_snackbar.dart';
import '../tasks/widgets/task_delete_dialog.dart';
import '../../shared/app_top_header.dart';
import '../tasks/screens/new_task_screen.dart';
import '../tasks/screens/task_detail_screen.dart';
import '../tasks/task_controller.dart';
import '../tasks/widgets/pastel_task_card.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final today = DateTime.now();
    final todayKey = AppDateUtils.toDateKey(today);
    final tasksAsync = ref.watch(tasksForDateProvider(todayKey));

    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF7F8FA);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Header: [ Today | Record ] Capsule + Sun/Moon Theme Toggle
            AppTopHeader(
              isRecordTab: false,
              onTabChanged: (isRecord) {
                if (isRecord) {
                  context.go('/record');
                }
              },
            ),

            const SizedBox(height: 4),

            // Main Content: Tasks Grid matching assets/home.png
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(tasksForDateProvider(todayKey));
                },
                color: isDark ? Colors.white : Colors.black,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                  child: tasksAsync.when(
                    data: (tasks) {
                      return LayoutBuilder(
                        builder: (context, constraints) {
                          // Calculate width for 3 cards per row with tighter spacing for larger cards
                          const spacing = 10.0;
                          final cardWidth = (constraints.maxWidth - (spacing * 2)) / 3;
                          final cardHeight = cardWidth * 0.85;

                          return Wrap(
                            spacing: spacing,
                            runSpacing: spacing,
                            children: [
                              ...tasks.map(
                                (task) => PastelTaskCard(
                                  task: task,
                                  width: cardWidth,
                                  height: cardHeight,
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => TaskDetailScreen(task: task),
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
                              ),
                              PastelTaskCard(
                                isNewTaskButton: true,
                                width: cardWidth,
                                height: cardHeight,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => NewTaskScreen(targetDate: today),
                                    ),
                                  );
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                    loading: () => const Padding(
                      padding: EdgeInsets.only(top: 80.0),
                      child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    error: (err, stack) => Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Text(
                          'Unable to load tasks.\n$err',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.mali(
                            color: isDark ? Colors.white70 : Colors.black54,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
