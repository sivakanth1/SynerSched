// This class provides methods to log, retrieve, and clear notifications
// stored locally using SharedPreferences.
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class NotificationLogger {
  // Key used for storing the list of notifications in SharedPreferences.
  static const _key = 'syner_sched_notifications';

  // Stores a new notification to local storage.
  static Future<void> logNotification(Map<String, dynamic> notif) async {
    final prefs = await SharedPreferences.getInstance();
    // Retrieve the existing list of encoded notifications.
    final list = prefs.getStringList(_key) ?? [];

    // Encode the new notification as a JSON string and add it to the list.
    list.add(jsonEncode(notif));
    // Save the updated list back to SharedPreferences.
    await prefs.setStringList(_key, list);
  }

  // Retrieves all stored notifications.
  static Future<List<Map<String, dynamic>>> getNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    // Decode each JSON string back into a Map<String, dynamic>.
    return list.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
  }

  // Clears all stored notifications.
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}