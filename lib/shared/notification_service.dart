import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'notification_logger.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );

    await _notificationsPlugin.initialize(settings);

    // Asking for permissions
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    tz.initializeTimeZones();

    _isInitialized = true;
  }

  NotificationDetails notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'syner_sched_channel', // Must match your AndroidManifest if declared there
        'SynerSched Notifications',
        channelDescription: 'This channel is responsible for all notifications',
        importance: Importance.max,
        priority: Priority.high,
      ),
    );
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    await _notificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails(),
    );

    await NotificationLogger.logNotification({
      'type': 'task_reminder',
      'message': body,
      'timestamp': DateTime.now().toIso8601String(),
      'icon': 'task', // for mapping later
      'color': 'grey'
    });
  }

  /// Schedule Notification (non-exact)
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    final tz.TZDateTime tzTime = tz.TZDateTime.from(scheduledTime, tz.local);

    try {
      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tzTime,
        notificationDetails(),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time, // optional
      );

      // ✅ Log the scheduled notification for UI display
      await NotificationLogger.logNotification({
        'type': 'task_reminder',
        'title': title,
        'message': body,
        'scheduledTime': scheduledTime.toIso8601String(),
        'createdAt': DateTime.now().toIso8601String(),
        'icon': 'task',
        'color': 'grey',
      });
    } catch (e) {
      SnackBar(content: Text("Error scheduling notification: ${e.toString()}"));
    }
  }
}