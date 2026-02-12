import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;
import 'notification_logger.dart';

class NotificationService {
  // Plugin instance to manage local notifications on Android devices
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  // Flag to ensure initialization is performed only once
  static bool _isInitialized = false;

  // Initializes the notification plugin, sets up required settings, and requests permission
  // Note: Timezone initialization (tz.initializeTimeZones()) must be called before this service is initialized.
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

    _isInitialized = true;
  }

  // Returns platform-specific notification settings used when displaying a notification
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

  // Immediately displays a notification with the given ID, title, and message
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

  // Schedules a notification to appear at a specified future date and time
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
      // Error handling can be expanded here, e.g., log to a service
    }
  }

  // Cancels all scheduled and active notifications
  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  // Cancels a single notification using its unique ID
  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }
}