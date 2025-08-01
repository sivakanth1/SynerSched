import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class NotificationLogger {
  static const _key = 'syner_sched_notifications';

  static Future<void> logNotification(Map<String, dynamic> notif) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];

    list.add(jsonEncode(notif));
    await prefs.setStringList(_key, list);
  }

  static Future<List<Map<String, dynamic>>> getNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    return list.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}