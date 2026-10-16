import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/utils/date_utils.dart';
import 'priority_level.dart';

class TaskModel {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final DateTime scheduledDate;
  final String dateKey;
  final String? dueTime;
  final TaskPriority priority;
  final int colorIndex;
  final bool isCompleted;
  final bool reminderEnabled;
  final DateTime? reminderDateTime;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const TaskModel({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.scheduledDate,
    required this.dateKey,
    this.dueTime,
    this.priority = TaskPriority.low,
    this.colorIndex = 1,
    this.isCompleted = false,
    this.reminderEnabled = false,
    this.reminderDateTime,
    this.createdAt,
    this.updatedAt,
  });

  /// Parse description as bullet-point objectives
  List<String> get objectives {
    if (description == null || description!.trim().isEmpty) return const [];
    return description!
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .map((line) {
          if (line.startsWith('-') || line.startsWith('•') || line.startsWith('*')) {
            return line.substring(1).trim();
          }
          return line;
        })
        .where((line) => line.isNotEmpty)
        .toList();
  }

  /// Factory constructor to create a TaskModel from Cloud Firestore Document
  factory TaskModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return TaskModel.fromMap(data, doc.id);
  }

  /// Factory constructor to parse map and id
  factory TaskModel.fromMap(Map<String, dynamic> data, String docId) {
    DateTime parseTimestamp(dynamic val, DateTime fallback) {
      if (val is Timestamp) return val.toDate();
      if (val is String) {
        return DateTime.tryParse(val) ?? fallback;
      }
      if (val is int) {
        return DateTime.fromMillisecondsSinceEpoch(val);
      }
      return fallback;
    }

    final scheduled = parseTimestamp(data['scheduledDate'], DateTime.now());
    final dateKey = data['dateKey'] as String? ?? AppDateUtils.toDateKey(scheduled);

    DateTime? created;
    if (data['createdAt'] is Timestamp) {
      created = (data['createdAt'] as Timestamp).toDate();
    }

    DateTime? updated;
    if (data['updatedAt'] is Timestamp) {
      updated = (data['updatedAt'] as Timestamp).toDate();
    }

    DateTime? reminderTime;
    if (data['reminderDateTime'] is Timestamp) {
      reminderTime = (data['reminderDateTime'] as Timestamp).toDate();
    } else if (data['reminderDateTime'] is String) {
      reminderTime = DateTime.tryParse(data['reminderDateTime'] as String);
    }

    final reminderEnabled = data['reminderEnabled'] as bool? ?? (reminderTime != null);

    return TaskModel(
      id: docId,
      userId: data['userId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      description: data['description'] as String?,
      scheduledDate: scheduled,
      dateKey: dateKey,
      dueTime: data['dueTime'] as String?,
      priority: TaskPriority.fromValue(data['priority'] as String?),
      colorIndex: (data['colorIndex'] as num?)?.toInt() ?? 1,
      isCompleted: data['isCompleted'] as bool? ?? false,
      reminderEnabled: reminderEnabled,
      reminderDateTime: reminderTime,
      createdAt: created,
      updatedAt: updated,
    );
  }

  /// Convert TaskModel to Map for Firestore persistence
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title.trim(),
      'description': description?.trim(),
      'scheduledDate': Timestamp.fromDate(scheduledDate),
      'dateKey': dateKey,
      'dueTime': dueTime,
      'priority': priority.toValue(),
      'colorIndex': colorIndex,
      'isCompleted': isCompleted,
      'reminderEnabled': reminderEnabled,
      'reminderDateTime':
          reminderDateTime != null ? Timestamp.fromDate(reminderDateTime!) : null,
      'updatedAt': FieldValue.serverTimestamp(),
      if (createdAt == null) 'createdAt': FieldValue.serverTimestamp(),
    };
  }

  /// Helper copyWith for immutability and optimistic updates
  TaskModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    DateTime? scheduledDate,
    String? dateKey,
    String? dueTime,
    TaskPriority? priority,
    int? colorIndex,
    bool? isCompleted,
    bool? reminderEnabled,
    DateTime? reminderDateTime,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      dateKey: dateKey ?? this.dateKey,
      dueTime: dueTime ?? this.dueTime,
      priority: priority ?? this.priority,
      colorIndex: colorIndex ?? this.colorIndex,
      isCompleted: isCompleted ?? this.isCompleted,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderDateTime: reminderDateTime ?? this.reminderDateTime,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
