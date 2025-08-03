// This screen displays all system-generated notifications such as task reminders, class updates, or messages.
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syner_sched/localization/app_localizations.dart';
import 'package:syner_sched/shared/custom_nav_bar.dart';

import '../../shared/notification_logger.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<Map<String, dynamic>> notifications = [];

  // Initializes the state of the screen and loads notifications from local storage.
  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  // Loads notifications from the NotificationLogger and reverses the list to show the most recent first.
  Future<void> _loadNotifications() async {
    final data = await NotificationLogger.getNotifications();
    setState(() {
      notifications = data.reversed.toList(); // recent first
    });
  }

  // Returns an appropriate icon based on the type of notification.
  IconData _getIcon(String type) {
    switch (type) {
      case 'task_reminder':
        return Icons.notifications_active;
      case 'class_update':
        return Icons.school;
      case 'group_message':
        return Icons.group;
      default:
        return Icons.notifications;
    }
  }

  // Returns a color to represent each notification type visually.
  Color _getColor(String type) {
    switch (type) {
      case 'task_reminder':
        return Colors.grey.shade800;
      case 'class_update':
        return Colors.red;
      default:
        return Colors.teal;
    }
  }

  // Builds the main UI for the notifications screen, including the app bar, delete button, and list of notifications.
  @override
  Widget build(BuildContext context) {
    final localizer = AppLocalizations.of(context)!;

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/app_background.jpg"),
          fit: BoxFit.fill,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            localizer.translate("notifications"),
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D4F48),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                await NotificationLogger.clear();
                setState(() {
                  notifications.clear();
                });
              },
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        extendBody: true,
        bottomNavigationBar: const CustomNavBar(currentIndex: 0),
        body: Container(
          padding: const EdgeInsets.fromLTRB(16, 48, 16, 90),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Notification Cards
              Expanded(
                child: notifications.isEmpty
                    ? Center(child: Text(localizer.translate("no_notifications")))
                    : ListView.builder(
                        itemCount: notifications.length,
                        itemBuilder: (context, index) {
                          // Extracts the current notification item and parses its timestamp.
                          final item = notifications[index];
                          final title = AppLocalizations.of(
                            context,
                          )!.translate(item['type'] ?? 'task_reminder');
                          final parsedTime = DateTime.tryParse(item['timestamp'] ??
                              item['scheduledTime'] ??
                              item['createdAt'] ??
                              DateTime.now().toIso8601String());

                          final time = DateFormat('MMM d, h:mm a').format(parsedTime!);
                          // Displays the notification inside a stylized card with icon, title, message, and timestamp.
                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            color: Colors.white,
                            margin: const EdgeInsets.only(bottom: 16),
                            child: ListTile(
                              leading: Icon(
                                _getIcon(item['type']),
                                color: _getColor(item['type']),
                                size: 28,
                              ),
                              title: Text(
                                title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(item['message'] ?? 'No message'),
                              trailing: Text(
                                time,
                                style: const TextStyle(
                                  color: Color(0xFF4A4A4A),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
