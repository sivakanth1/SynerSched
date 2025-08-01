import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../shared/encryption_helper.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // Save task
  Future<void> addTask(String title, DateTime deadline) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final encryptedTitle = EncryptionHelper.encryptText(title, uid);

    await _db.collection('users').doc(uid).collection('tasks').add({
      'title': encryptedTitle,
      'deadline': deadline.toIso8601String(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Fetch tasks
  Stream<List<Map<String, dynamic>>> getTasksStream() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const Stream.empty();

    return _db
        .collection('users')
        .doc(uid)
        .collection('tasks')
        .orderBy('deadline')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  // Save class schedule
  Future<void> addClass(String courseName, String day, String time) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await _db.collection('users').doc(uid).collection('classes').add({
      'course': courseName,
      'day': day,
      'time': time,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Fetch class schedule
  Stream<List<Map<String, dynamic>>> getClassScheduleStream() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const Stream.empty();

    return _db
        .collection('users')
        .doc(uid)
        .collection('classes')
        .orderBy('day')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }
}