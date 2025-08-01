import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ScheduleService {
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static String getCurrentSemesterId() {
    final now = DateTime.now();
    final year = now.year;
    final month = now.month;

    if (month >= 1 && month <= 5) return 'Spring$year';
    if (month >= 6 && month <= 7) return 'Summer$year';
    return 'Fall$year';
  }

  /// Save the schedule to Firestore and generate weekly class slots.
  static Future<void> saveSchedule(Map<String, dynamic> scheduleData) async {
    final user = _auth.currentUser;
    if (user == null) return;

    // Extract necessary fields
    final selectedCourses = List<String>.from(scheduleData['selectedCourses'] ?? []);
    final preferredTime = scheduleData['preferredTime'] ?? 'morning';
    final semesterId = getCurrentSemesterId();
    scheduleData['semesterId'] = semesterId;

    // Time slot logic
    final timeslot = preferredTime == 'morning'
        ? '9:00 AM'
        : preferredTime == 'afternoon'
        ? '1:00 PM'
        : '6:00 PM';

    final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];

    // Generate weekly schedule
    final weekly = <Map<String, String>>[];
    for (int i = 0; i < selectedCourses.length; i++) {
      weekly.add({
        'day': weekdays[i % weekdays.length],
        'course': selectedCourses[i],
        'time': timeslot,
      });
    }

    scheduleData['weekly'] = weekly;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('schedules')
        .doc(semesterId)
        .set(scheduleData);
  }

  /// Get all schedules for the logged-in user.
  static Future<Object?> getSchedules() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    final semesterId = getCurrentSemesterId();

    final doc = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('schedules')
        .doc(semesterId)
        .get();

    return doc.exists ? doc.data() : null;
  }

  /// Get only the latest schedule.
  static Future<Map<String, dynamic>?> getLatestSchedule() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final snapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('schedules')
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;

    return snapshot.docs.first.data();
  }

  static Future<bool> hasSchedule() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    final semesterId = getCurrentSemesterId();

    final doc = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('schedules')
        .doc(semesterId)
        .get();

    return doc.exists;
  }
}