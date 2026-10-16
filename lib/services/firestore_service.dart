import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task_model.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore;

  FirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Reference to users collection
  CollectionReference<Map<String, dynamic>> get _usersRef =>
      _firestore.collection('users');

  /// Reference to user's tasks subcollection: users/{uid}/tasks
  CollectionReference<Map<String, dynamic>> _tasksRef(String uid) =>
      _usersRef.doc(uid).collection('tasks');

  // --- User Profile ---

  /// Create or update user profile document in Firestore
  Future<void> saveOrUpdateUserProfile(UserModel user) async {
    try {
      await _usersRef.doc(user.uid).set(
            user.toMap(),
            SetOptions(merge: true),
          );
    } catch (e) {
      // Non-critical background sync
    }
  }

  /// Watch user profile stream
  Stream<UserModel?> watchUserProfile(String uid) {
    if (uid.isEmpty) return Stream.value(null);
    return _usersRef.doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    });
  }

  // --- Tasks Stream & CRUD ---

  /// Real-time stream of tasks for a specific normalized dateKey (e.g. "2026-10-15")
  /// Sorted with incomplete tasks first, then by dueTime, then by createdAt.
  Stream<List<TaskModel>> watchTasksForDate(String uid, String dateKey) {
    if (uid.isEmpty) return Stream.value(<TaskModel>[]);

    return _tasksRef(uid)
        .where('dateKey', isEqualTo: dateKey)
        .snapshots()
        .map((snapshot) {
      final tasks = snapshot.docs
          .map((doc) => TaskModel.fromFirestore(doc))
          .toList();

      // Logical sorting:
      // 1. Incomplete first, completed last
      // 2. Tasks with dueTime first (ordered by dueTime)
      // 3. Fallback to createdAt or title
      tasks.sort((a, b) {
        if (a.isCompleted != b.isCompleted) {
          return a.isCompleted ? 1 : -1;
        }

        // Both same completion status, sort by due time if available
        if (a.dueTime != null && b.dueTime != null) {
          final cmp = a.dueTime!.compareTo(b.dueTime!);
          if (cmp != 0) return cmp;
        } else if (a.dueTime != null && b.dueTime == null) {
          return -1;
        } else if (a.dueTime == null && b.dueTime != null) {
          return 1;
        }

        // Secondary sort by createdAt
        if (a.createdAt != null && b.createdAt != null) {
          return a.createdAt!.compareTo(b.createdAt!);
        }

        return a.title.toLowerCase().compareTo(b.title.toLowerCase());
      });

      return tasks;
    });
  }

  /// Stream of all tasks for a list of date keys (for weekly schedule counts)
  Stream<List<TaskModel>> watchTasksForDates(String uid, List<String> dateKeys) {
    if (uid.isEmpty || dateKeys.isEmpty) return Stream.value(<TaskModel>[]);

    // Firestore `whereIn` supports up to 30 items; we pass 7 days.
    return _tasksRef(uid)
        .where('dateKey', whereIn: dateKeys)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList());
  }

  /// Stream of all tasks for a user
  Stream<List<TaskModel>> watchAllTasks(String uid) {
    if (uid.isEmpty) return Stream.value(<TaskModel>[]);
    return _tasksRef(uid)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList());
  }

  /// Add a new task
  Future<String> addTask(String uid, TaskModel task) async {
    try {
      final docRef = _tasksRef(uid).doc();
      final taskWithId = task.copyWith(id: docRef.id, userId: uid);
      await docRef.set(taskWithId.toMap());
      return docRef.id;
    } on FirebaseException catch (e) {
      throw e.message ?? 'Failed to save task to cloud database.';
    } catch (e) {
      throw 'An error occurred while adding the task. Please try again.';
    }
  }

  /// Update an existing task
  Future<void> updateTask(String uid, TaskModel task) async {
    try {
      await _tasksRef(uid).doc(task.id).update(task.toMap());
    } on FirebaseException catch (e) {
      throw e.message ?? 'Failed to update task in cloud database.';
    } catch (e) {
      throw 'An error occurred while updating the task. Please try again.';
    }
  }

  /// Toggle task completion status
  Future<void> toggleTaskStatus(String uid, String taskId, bool isCompleted) async {
    try {
      await _tasksRef(uid).doc(taskId).update({
        'isCompleted': isCompleted,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw e.message ?? 'Failed to update task status.';
    } catch (e) {
      throw 'An error occurred while updating task status.';
    }
  }

  /// Delete a task
  Future<void> deleteTask(String uid, String taskId) async {
    try {
      await _tasksRef(uid).doc(taskId).delete();
    } on FirebaseException catch (e) {
      throw e.message ?? 'Failed to delete task from database.';
    } catch (e) {
      throw 'An error occurred while deleting the task.';
    }
  }
}

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});
