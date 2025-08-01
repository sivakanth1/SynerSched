import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ClassService {
  static Future<List<Map<String, dynamic>>> getUserClassSchedule() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('class_schedule')
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }
}