import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syner_sched/localization/app_localizations.dart';
import 'package:syner_sched/shared/custom_nav_bar.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizer = AppLocalizations.of(context)!;

    final List<Map<String, dynamic>> notifications = [
      {
        'type': 'class_update',
        'message': 'CSCI 6362 lecture moved to Room B210.',
        'timestamp': DateTime(2025, 6, 27, 16, 6),
        'icon': Icons.notifications_active,
        'color': Colors.red,
      },
      {
        'type': 'task_reminder',
        'message': 'Assignment 1 is due tomorrow!',
        'timestamp': DateTime(2025, 6, 27, 14, 21),
        'icon': Icons.notifications_none,
        'color': Colors.grey.shade800,
      },
      {
        'type': 'group_message',
        'message': 'Machine Learning Capstone: 2 new replies.',
        'timestamp': DateTime(2025, 6, 26, 16, 21),
        'icon': Icons.notifications_none,
        'color': Colors.grey.shade800,
      },
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      bottomNavigationBar: const CustomNavBar(currentIndex: 0),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/app_background.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        padding: const EdgeInsets.fromLTRB(16, 48, 16, 90),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back Button & Heading
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                  color: const Color(0xFF2D4F48),
                ),
                const SizedBox(width: 8),
                Text(
                  localizer.translate("notifications"),
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D4F48),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Notification Cards
            Expanded(
              child: ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final item = notifications[index];
                  final title = localizer.translate(item['type']);
                  final time = DateFormat(
                    'MMM d, h:mm a',
                  ).format(item['timestamp']);
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    color: Colors.white,
                    margin: const EdgeInsets.only(bottom: 16),
                    child: ListTile(
                      leading: Icon(
                        item['icon'],
                        color: item['color'],
                        size: 28,
                      ),
                      title: Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(item['message']),
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
    );
  }

  static void _noop(int _) {}
}
