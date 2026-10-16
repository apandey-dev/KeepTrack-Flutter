import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/task_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../services/notification_service.dart';

/// Provider for stream of tasks for a specific dateKey (e.g. "2026-10-15")
final tasksForDateProvider = StreamProvider.family<List<TaskModel>, String>((ref, dateKey) {
  final authUser = ref.watch(authStateProvider).value;
  if (authUser == null) return Stream.value(<TaskModel>[]);

  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.watchTasksForDate(authUser.uid, dateKey);
});

/// Provider for stream of tasks for a list of 7 consecutive date keys
final weeklyTasksProvider = StreamProvider.family<List<TaskModel>, List<String>>((ref, dateKeys) {
  final authUser = ref.watch(authStateProvider).value;
  if (authUser == null) return Stream.value(<TaskModel>[]);

  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.watchTasksForDates(authUser.uid, dateKeys);
});

/// Provider for stream of all tasks across all dates for stats
final allTasksProvider = StreamProvider<List<TaskModel>>((ref) {
  final authUser = ref.watch(authStateProvider).value;
  if (authUser == null) return Stream.value(<TaskModel>[]);

  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.watchAllTasks(authUser.uid);
});

/// Map of dateKey -> TaskStats (total, completed)
class DailyTaskStats {
  final int total;
  final int completed;

  const DailyTaskStats({this.total = 0, this.completed = 0});

  double get progress => total == 0 ? 0.0 : (completed / total);
}

/// Computes task count summary for weekly calendar
final weeklyStatsProvider = Provider.family<Map<String, DailyTaskStats>, List<String>>((ref, dateKeys) {
  final weeklyTasksAsync = ref.watch(weeklyTasksProvider(dateKeys));
  final Map<String, DailyTaskStats> stats = {
    for (final k in dateKeys) k: const DailyTaskStats(),
  };

  weeklyTasksAsync.whenData((tasks) {
    for (final task in tasks) {
      final current = stats[task.dateKey] ?? const DailyTaskStats();
      stats[task.dateKey] = DailyTaskStats(
        total: current.total + 1,
        completed: current.completed + (task.isCompleted ? 1 : 0),
      );
    }
  });

  return stats;
});

/// State for Task Actions (create, update, delete, toggle)
class TaskActionState {
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  const TaskActionState({
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  TaskActionState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
  }) {
    return TaskActionState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}

class TaskActionNotifier extends Notifier<TaskActionState> {
  late final FirestoreService _firestoreService;
  late final NotificationService _notificationService;

  @override
  TaskActionState build() {
    _firestoreService = ref.watch(firestoreServiceProvider);
    _notificationService = ref.watch(notificationServiceProvider);
    return const TaskActionState();
  }

  String? get _currentUid => ref.read(authStateProvider).value?.uid;

  Future<bool> createTask(TaskModel task) async {
    final uid = _currentUid;
    if (uid == null) {
      state = state.copyWith(errorMessage: 'User not authenticated.');
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final taskId = await _firestoreService.addTask(uid, task);

      // Schedule reminder notification if enabled and date is valid
      if (task.reminderEnabled && task.reminderDateTime != null) {
        final notifId = _notificationService.getNotificationIdForTask(taskId);
        await _notificationService.scheduleTaskReminder(
          id: notifId,
          title: 'Reminder: ${task.title}',
          body: task.description?.isNotEmpty == true
              ? task.description!
              : (task.dueTime != null ? 'Due at ${task.dueTime}' : 'KeepTrack task is due now.'),
          scheduledDateTime: task.reminderDateTime!,
          payload: taskId,
        );
      }

      state = state.copyWith(isLoading: false, successMessage: 'Task added');
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> updateTask(TaskModel task) async {
    final uid = _currentUid;
    if (uid == null) {
      state = state.copyWith(errorMessage: 'User not authenticated.');
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _firestoreService.updateTask(uid, task);

      final notifId = _notificationService.getNotificationIdForTask(task.id);
      if (task.reminderEnabled && task.reminderDateTime != null && !task.isCompleted) {
        await _notificationService.cancelReminder(notifId);
        await _notificationService.scheduleTaskReminder(
          id: notifId,
          title: 'Reminder: ${task.title}',
          body: task.description?.isNotEmpty == true
              ? task.description!
              : (task.dueTime != null ? 'Due at ${task.dueTime}' : 'KeepTrack task is due now.'),
          scheduledDateTime: task.reminderDateTime!,
          payload: task.id,
        );
      } else {
        await _notificationService.cancelReminder(notifId);
      }

      state = state.copyWith(isLoading: false, successMessage: 'Task updated');
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> toggleTaskCompletion(String taskId, bool isCompleted) async {
    final uid = _currentUid;
    if (uid == null) return false;

    try {
      await _firestoreService.toggleTaskStatus(uid, taskId, isCompleted);
      final notifId = _notificationService.getNotificationIdForTask(taskId);
      if (isCompleted) {
        // Automatically cancel reminder when task is completed
        await _notificationService.cancelReminder(notifId);
      }
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> deleteTask(String taskId) async {
    final uid = _currentUid;
    if (uid == null) return false;

    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      // Cancel any scheduled reminder for this task
      final notifId = _notificationService.getNotificationIdForTask(taskId);
      await _notificationService.cancelReminder(notifId);

      await _firestoreService.deleteTask(uid, taskId);
      state = state.copyWith(isLoading: false, successMessage: 'Task removed');
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }
}

final taskActionProvider =
    NotifierProvider<TaskActionNotifier, TaskActionState>(TaskActionNotifier.new);
