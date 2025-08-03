import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Provides methods to retrieve the logged-in user's class schedule from Firestore.
class ClassService {
  /// Fetches the list of class schedule entries for the currently authenticated user.
  static Future<List<Map<String, dynamic>>> getUserClassSchedule() async {
    // Ensure the user is logged in before attempting to retrieve schedule.
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    // Retrieve documents from the 'class_schedule' subcollection of the user's document.
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('class_schedule')
        .get();

    // Convert the retrieved Firestore documents into a list of maps for further use.
    return snapshot.docs.map((doc) => doc.data()).toList();
  }
}