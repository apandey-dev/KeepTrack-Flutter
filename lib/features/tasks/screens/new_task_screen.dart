import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/utils/date_utils.dart';
import '../../../models/priority_level.dart';
import '../../../models/task_model.dart';
import '../../../models/task_theme_color.dart';
import '../../../shared/custom_snackbar.dart';
import '../task_controller.dart';

class NewTaskScreen extends ConsumerStatefulWidget {
  final DateTime? targetDate;

  const NewTaskScreen({super.key, this.targetDate});

  @override
  ConsumerState<NewTaskScreen> createState() => _NewTaskScreenState();
}

class _NewTaskScreenState extends ConsumerState<NewTaskScreen> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  int _selectedColorIndex = 2; // Default to purple (palette[2]) as shown in new-task.png!
  String? _selectedTime;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _openTimePickerSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final primaryTextColor = isDark ? Colors.white : const Color(0xFF111827);
    final secondaryTextColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
    final borderColor = isDark ? const Color(0xFF2E2E2E) : const Color(0xFFE5E7EB);

    String? tempTime = _selectedTime;

    final presets = [
      {'label': 'Morning', 'time': '09:00 AM', 'icon': Icons.wb_sunny_outlined},
      {'label': 'Afternoon', 'time': '01:00 PM', 'icon': Icons.wb_sunny_rounded},
      {'label': 'Evening', 'time': '06:00 PM', 'icon': Icons.wb_twilight_rounded},
      {'label': 'Night', 'time': '09:00 PM', 'icon': Icons.bedtime_outlined},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 28),
              decoration: BoxDecoration(
                color: sheetBg,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Handle Bar
                    Center(
                      child: Container(
                        width: 38,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF383838) : const Color(0xFFD1D5DB),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Sheet Header
                    Text(
                      'Select Due Time',
                      style: GoogleFonts.mali(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: primaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Choose a quick preset or pick custom time',
                      style: GoogleFonts.mali(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: secondaryTextColor,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Quick presets grid (2x2)
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: presets.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 2.4,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemBuilder: (context, index) {
                        final preset = presets[index];
                        final presetTime = preset['time'] as String;
                        final isSelected = tempTime == presetTime;

                        return GestureDetector(
                          onTap: () {
                            setSheetState(() {
                              tempTime = presetTime;
                            });
                          },
                          behavior: HitTestBehavior.opaque,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? (isDark ? Colors.white : const Color(0xFF111827))
                                  : (isDark ? const Color(0xFF262626) : const Color(0xFFF9FAFB)),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected
                                    ? (isDark ? Colors.white : const Color(0xFF111827))
                                    : borderColor,
                                width: 1.2,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  preset['icon'] as IconData,
                                  size: 18,
                                  color: isSelected
                                      ? (isDark ? Colors.black : Colors.white)
                                      : secondaryTextColor,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        preset['label'] as String,
                                        style: GoogleFonts.mali(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: isSelected
                                              ? (isDark ? Colors.black : Colors.white)
                                              : primaryTextColor,
                                        ),
                                      ),
                                      Text(
                                        presetTime,
                                        style: GoogleFonts.mali(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                          color: isSelected
                                              ? (isDark ? Colors.black87 : Colors.white70)
                                              : secondaryTextColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 12),

                    // Custom Time Button
                    OutlinedButton(
                      onPressed: () async {
                        final now = TimeOfDay.now();
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: now,
                        );

                        if (picked != null && mounted) {
                          final hour = picked.hourOfPeriod == 0 ? 12 : picked.hourOfPeriod;
                          final minute = picked.minute.toString().padLeft(2, '0');
                          final period = picked.period == DayPeriod.am ? 'AM' : 'PM';
                          final formattedTime = '${hour.toString().padLeft(2, '0')}:$minute $period';
                          setSheetState(() {
                            tempTime = formattedTime;
                          });
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: borderColor, width: 1.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        foregroundColor: primaryTextColor,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.tune_rounded, size: 18, color: primaryTextColor),
                          const SizedBox(width: 8),
                          Text(
                            tempTime != null && !presets.any((p) => p['time'] == tempTime)
                                ? 'Custom Time: $tempTime'
                                : 'Choose Custom Time...',
                            style: GoogleFonts.mali(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: primaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Actions: Clear & Set Time
                    Row(
                      children: [
                        if (tempTime != null) ...[
                          Expanded(
                            child: SizedBox(
                              height: 48,
                              child: TextButton(
                                onPressed: () {
                                  setState(() {
                                    _selectedTime = null;
                                  });
                                  Navigator.of(ctx).pop();
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.redAccent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                ),
                                child: Text(
                                  'Clear',
                                  style: GoogleFonts.mali(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        Expanded(
                          flex: 2,
                          child: SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _selectedTime = tempTime;
                                });
                                Navigator.of(ctx).pop();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDark ? Colors.white : const Color(0xFF111827),
                                foregroundColor: isDark ? Colors.black : Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                              child: Text(
                                'Set Time',
                                style: GoogleFonts.mali(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _handleCreateTask() async {
    final title = _nameController.text.trim();
    if (title.isEmpty) return;

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final date = widget.targetDate ?? now;
    final targetStart = DateTime(date.year, date.month, date.day);

    if (targetStart.isBefore(todayStart)) {
      AppSnackbar.show(
        context,
        message: 'Cannot create tasks for past dates.',
        isError: true,
      );
      return;
    }

    final dateKey = AppDateUtils.toDateKey(date);

    final newTask = TaskModel(
      id: '',
      userId: '',
      title: title,
      description: _descController.text.trim().isEmpty ? null : _descController.text.trim(),
      scheduledDate: date,
      dateKey: dateKey,
      dueTime: _selectedTime,
      colorIndex: _selectedColorIndex,
      priority: TaskPriority.low,
      isCompleted: false,
    );

    final success = await ref.read(taskActionProvider.notifier).createTask(newTask);

    if (!mounted) return;
    if (success) {
      context.pop();
      AppSnackbar.show(context, message: 'Task created successfully');
    } else {
      final error = ref.read(taskActionProvider).errorMessage;
      if (error != null) {
        AppSnackbar.show(context, message: error, isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final targetDate = widget.targetDate ?? now;
    final targetStart = DateTime(targetDate.year, targetDate.month, targetDate.day);
    final isPastDate = targetStart.isBefore(todayStart);

    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF7F8FA);
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final primaryTextColor = isDark ? Colors.white : const Color(0xFF111827);
    final secondaryTextColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
    final borderColor = isDark ? const Color(0xFF2E2E2E) : const Color(0xFFE5E7EB);
    final previewTheme = TaskThemeColor.getByIndex(_selectedColorIndex);

    final isButtonEnabled = _nameController.text.trim().isNotEmpty && !isPastDate;
    final buttonBg = isButtonEnabled
        ? (isDark ? Colors.white : const Color(0xFF111827))
        : (isDark ? const Color(0xFF2E2E2E) : const Color(0xFFE5E7EB));
    final buttonFg = isButtonEnabled
        ? (isDark ? Colors.black : Colors.white)
        : (isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF));

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title & Subtitle
              Text(
                'New Task',
                style: GoogleFonts.mali(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.6,
                  color: primaryTextColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Add task details, checklist points & theme color',
                style: GoogleFonts.mali(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: secondaryTextColor,
                ),
              ),

              if (isPastDate) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, size: 18, color: Colors.redAccent),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Tasks cannot be created for past dates.',
                          style: GoogleFonts.mali(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.redAccent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Section: CARD PREVIEW
              Text(
                'CARD PREVIEW',
                style: GoogleFonts.mali(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: secondaryTextColor,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                height: 90,
                decoration: BoxDecoration(
                  color: isDark
                      ? Color.alphaBlend(previewTheme.background.withValues(alpha: 0.2), cardBg)
                      : previewTheme.background,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: previewTheme.border, width: 1.5),
                ),
                alignment: Alignment.center,
                child: Text(
                  _nameController.text.trim().isNotEmpty
                      ? _nameController.text.trim()
                      : 'Task Preview',
                  style: GoogleFonts.mali(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : previewTheme.primary,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Section: TASK NAME
              Text(
                'TASK NAME',
                style: GoogleFonts.mali(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: secondaryTextColor,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _nameController,
                style: GoogleFonts.mali(
                  fontSize: 15,
                  color: primaryTextColor,
                ),
                decoration: InputDecoration(
                  hintText: 'e.g., Calculations Practice',
                  hintStyle: GoogleFonts.mali(
                    fontSize: 15,
                    color: secondaryTextColor.withValues(alpha: 0.8),
                  ),
                  filled: true,
                  fillColor: cardBg,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: borderColor, width: 1.2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: isDark ? Colors.white : Colors.black,
                      width: 1.5,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Section: DESCRIPTION (BULLET LIST)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'DESCRIPTION (BULLET LIST)',
                    style: GoogleFonts.mali(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: secondaryTextColor,
                    ),
                  ),
                  Text(
                    "Use '-' for bullets",
                    style: GoogleFonts.mali(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: secondaryTextColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _descController,
                minLines: 4,
                maxLines: 6,
                style: GoogleFonts.mali(
                  fontSize: 14,
                  height: 1.5,
                  color: primaryTextColor,
                ),
                decoration: InputDecoration(
                  hintText: "- Step 1: Quick formulas\n- Step 2: Solve 15 problems\n- Step 3: Review mistakes",
                  hintStyle: GoogleFonts.mali(
                    fontSize: 14,
                    height: 1.5,
                    color: secondaryTextColor.withValues(alpha: 0.7),
                  ),
                  filled: true,
                  fillColor: cardBg,
                  contentPadding: const EdgeInsets.all(18),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: borderColor, width: 1.2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: isDark ? Colors.white : Colors.black,
                      width: 1.5,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Section: DUE TIME (OPTIONAL)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'DUE TIME (OPTIONAL)',
                    style: GoogleFonts.mali(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: secondaryTextColor,
                    ),
                  ),
                  if (_selectedTime != null)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedTime = null;
                        });
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Text(
                        'Clear',
                        style: GoogleFonts.mali(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.redAccent,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => _openTimePickerSheet(context),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _selectedTime != null
                          ? (isDark ? Colors.white : Colors.black)
                          : borderColor,
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 20,
                        color: _selectedTime != null
                            ? (isDark ? Colors.white : const Color(0xFF111827))
                            : secondaryTextColor,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _selectedTime ?? 'Tap to select due time',
                          style: GoogleFonts.mali(
                            fontSize: 15,
                            fontWeight: _selectedTime != null ? FontWeight.w600 : FontWeight.w500,
                            color: _selectedTime != null
                                ? primaryTextColor
                                : secondaryTextColor.withValues(alpha: 0.8),
                          ),
                        ),
                      ),
                      if (_selectedTime != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF262626) : const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Selected',
                            style: GoogleFonts.mali(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white70 : const Color(0xFF374151),
                            ),
                          ),
                        )
                      else
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: secondaryTextColor,
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Section: SUBTLE COLOR THEME
              Text(
                'SUBTLE COLOR THEME',
                style: GoogleFonts.mali(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: secondaryTextColor,
                ),
              ),
              const SizedBox(height: 12),

              // 3x3 Grid of Pastel Colors
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: TaskThemeColor.palette.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 2.2,
                ),
                itemBuilder: (context, index) {
                  final colorTheme = TaskThemeColor.palette[index];
                  final isSelected = _selectedColorIndex == index;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedColorIndex = index;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Color.alphaBlend(colorTheme.background.withValues(alpha: 0.25), cardBg)
                            : colorTheme.background,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? (isDark ? Colors.white : Colors.black)
                              : colorTheme.border,
                          width: isSelected ? 2.0 : 1.2,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: colorTheme.dot,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 36),

              // Bottom Button: "Create Task"
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: isButtonEnabled ? _handleCreateTask : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonBg,
                    foregroundColor: buttonFg,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Create Task',
                    style: GoogleFonts.mali(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
