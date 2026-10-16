import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  static const String channelId = 'task_reminders_channel';
  static const String channelName = 'Task Reminders';
  static const String channelDescription =
      'Notifications for scheduled tasks, due times, and daily reminders';

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      // 1. Initialize timezone database
      tz_data.initializeTimeZones();
      try {
        final timezoneInfo = await FlutterTimezone.getLocalTimezone();
        tz.setLocalLocation(tz.getLocation(timezoneInfo.identifier));
      } catch (e) {
        debugPrint('Could not set local timezone, falling back to default: $e');
      }

      // 2. Android Initialization Settings
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

      // 3. iOS Initialization Settings
      const darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
      );

      await _plugin.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          debugPrint('Notification clicked with payload: ${response.payload}');
        },
      );

      // 4. Create Android Notification Channel
      final androidPlugin = _plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        const channel = AndroidNotificationChannel(
          channelId,
          channelName,
          description: channelDescription,
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
        );
        await androidPlugin.createNotificationChannel(channel);
      }

      _isInitialized = true;
      debugPrint('NotificationService initialized successfully.');
    } catch (e) {
      debugPrint('Error initializing NotificationService: $e');
    }
  }

  /// Request Notification Permissions (Android 13+ and iOS)
  Future<bool> requestPermissions() async {
    try {
      if (Platform.isAndroid) {
        final androidPlugin = _plugin
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
        if (androidPlugin != null) {
          final granted = await androidPlugin.requestNotificationsPermission();
          try {
            await androidPlugin.requestExactAlarmsPermission();
          } catch (_) {}
          return granted ?? false;
        }
      } else if (Platform.isIOS) {
        final iosPlugin = _plugin
            .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
        if (iosPlugin != null) {
          final granted = await iosPlugin.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
          return granted ?? false;
        }
      }
      return true;
    } catch (e) {
      debugPrint('Error requesting notification permissions: $e');
      return false;
    }
  }

  /// Check if notification permissions are granted
  Future<bool> arePermissionsGranted() async {
    try {
      if (Platform.isAndroid) {
        final androidPlugin = _plugin
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
        return await androidPlugin?.areNotificationsEnabled() ?? false;
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Generate deterministic positive 32-bit integer notification ID from task ID
  int getNotificationIdForTask(String taskId) {
    return taskId.hashCode & 0x7FFFFFFF;
  }

  /// Schedule a task reminder notification at a specific date & time
  Future<bool> scheduleTaskReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDateTime,
    String? payload,
  }) async {
    if (!_isInitialized) await init();

    final now = DateTime.now();
    if (scheduledDateTime.isBefore(now)) {
      debugPrint('Cannot schedule reminder in the past: $scheduledDateTime (now: $now)');
      return false;
    }

    try {
      await requestPermissions();

      final tzDateTime = tz.TZDateTime.from(scheduledDateTime, tz.local);

      const androidDetails = AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDescription,
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
        enableVibration: true,
        playSound: true,
        icon: '@mipmap/ic_launcher',
      );

      const darwinDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: darwinDetails,
      );

      await _plugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: tzDateTime,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: payload,
      );

      debugPrint('Successfully scheduled reminder [$id] at $tzDateTime');
      return true;
    } catch (e) {
      debugPrint('Error scheduling task reminder: $e');
      return false;
    }
  }

  /// Show an immediate test notification
  Future<void> showInstantNotification({
    String title = 'KeepTrack Reminder Test 🔔',
    String body = 'Notifications are working properly on your device!',
    String? payload,
  }) async {
    if (!_isInitialized) await init();
    await requestPermissions();

    const androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    await _plugin.show(
      id: DateTime.now().millisecondsSinceEpoch & 0x7FFFFFFF,
      title: title,
      body: body,
      notificationDetails: details,
      payload: payload,
    );
  }

  /// Cancel a scheduled reminder
  Future<void> cancelReminder(int id) async {
    try {
      await _plugin.cancel(id: id);
      debugPrint('Cancelled notification [$id]');
    } catch (e) {
      debugPrint('Error cancelling notification: $e');
    }
  }

  /// Cancel all scheduled reminders
  Future<void> cancelAll() async {
    try {
      await _plugin.cancelAll();
      debugPrint('Cancelled all notifications');
    } catch (e) {
      debugPrint('Error cancelling all notifications: $e');
    }
  }

  /// Retrieve pending scheduled notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      return await _plugin.pendingNotificationRequests();
    } catch (e) {
      debugPrint('Error getting pending notifications: $e');
      return [];
    }
  }
}

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});
