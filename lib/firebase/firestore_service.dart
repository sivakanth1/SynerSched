/// This service handles all Firestore interactions for user tasks, class schedules, and collaborations.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../shared/encryption_helper.dart';

/// FirestoreService class provides methods to interact with Firestore database for tasks, classes, and collaborations.
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  /// Adds a new task to the current user's 'tasks' collection in Firestore with encrypted title and timestamp.
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

  /// Returns a stream of all tasks for the current user, ordered by deadline.
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

  /// Adds a new class to the current user's 'classes' collection in Firestore with metadata.
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

  /// Returns a stream of all classes for the current user, ordered by day.
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

  /// Returns a stream of all collaborations that the given user ID is a member of.
  Stream<List<Map<String, dynamic>>> getUserJoinedCollaborations(String uid) {
    return FirebaseFirestore.instance
        .collection('collaborations')
        .where('members', arrayContains: uid)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }
}