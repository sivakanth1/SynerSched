import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../shared/encryption_helper.dart';

class TaskService {
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static Future<void> addTask(String title, DateTime deadline) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final encryptedTitle = EncryptionHelper.encryptText(title, user.uid);

    //  To ensure that offline tasks don’t duplicate
    final taskRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('tasks')
        .doc(); // generates ID but doesn't write yet

    await taskRef.set({
      'type': 'task',
      'id': taskRef.id,
      'title': encryptedTitle,
      'deadline': deadline,
    });
  }

  static Future<List<Map<String, dynamic>>> getTasks() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    final snapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('tasks')
        .orderBy('deadline')
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  // Fetches tasks before returning current ones
  static Future<List<Map<String, dynamic>>> getUserTasks() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    final snapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('tasks')
        .get();

    List<Map<String, dynamic>> tasks = [];

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final deadlineField = data['deadline'];
      late DateTime deadline;

      if (deadlineField is Timestamp) {
        deadline = deadlineField.toDate();
      } else if (deadlineField is String) {
        deadline = DateTime.tryParse(deadlineField) ?? DateTime.now();
      } else {
        continue;
      }

      final encryptedTitle = data['title'] ?? '';
      final decryptedTitle = EncryptionHelper.decryptText(encryptedTitle, user.uid);

      tasks.add({
        'title': decryptedTitle,
        'deadline': deadline.toIso8601String(),
      });
    }

    return tasks;
  }

  static Future<void> saveAllocatedTasks(List<Map<String, dynamic>> tasks) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final taskCollection = userDoc.collection('allocated_tasks');

    // Clear existing tasks before saving new ones
    final existing = await taskCollection.get();
    for (var doc in existing.docs) {
      await doc.reference.delete();
    }

    // Add new tasks
    for (var task in tasks) {
      await taskCollection.add(task);
    }
  }

  static Future<List<Map<String, dynamic>>> getAllocatedTasks() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('allocated_tasks')
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  static Future<void> deleteAllUserTasks() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final snapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('tasks')
        .get();

    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
}