/// A utility class that provides shared helper methods for the SynerSched app,
/// including semester ID calculation and schedule navigation logic.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../routes/app_routes.dart';

class Utility{
  /// Returns the current semester ID string based on the current date.
  /// Example: "Spring2025", "Summer2025", or "Fall2025".
  static String getCurrentSemesterId() {
    final now = DateTime.now();
    final year = now.year;
    final month = now.month;

    if (month >= 1 && month <= 5) return 'Spring$year';
    if (month >= 6 && month <= 7) return 'Summer$year';
    return 'Fall$year';
  }

  /// Navigates to the appropriate schedule screen based on whether a schedule
  /// exists for the current semester. If no schedule exists or the semester has changed,
  /// the user is directed to build a new schedule.
  ///
  /// - Saves and checks the last used semester ID in shared preferences.
  /// - Queries Firestore for the current semester's schedule.
  /// - Navigates to schedule builder or result screen accordingly.
  static Future<void> ensureScheduleExists(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final currentSemester = Utility.getCurrentSemesterId();
    final savedSemester = prefs.getString('lastSemesterId');
    final user = FirebaseAuth.instance.currentUser;

    final scheduleSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection('schedules')
        .doc(currentSemester)
        .get();

    if (savedSemester != currentSemester || !scheduleSnapshot.exists) {
      Navigator.pushNamed(context, AppRoutes.scheduleBuilder);
    } else {
      Navigator.pushNamed(context, AppRoutes.scheduleResult);
    }
  }

}