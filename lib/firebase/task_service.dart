/// TaskService provides helper methods for interacting with Firestore to manage user-created tasks.
/// It supports creating, retrieving, updating, deleting, and saving tasks along with encryption and decryption of task titles.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../shared/encryption_helper.dart';

class TaskService {
  static FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static FirebaseAuth _auth = FirebaseAuth.instance;

  // Added for testing
  static set firestoreInstance(FirebaseFirestore instance) => _firestore = instance;
  static set authInstance(FirebaseAuth instance) => _auth = instance;

  /// Adds a new task to the Firestore under the authenticated user's tasks collection.
  /// The title is encrypted before storage to maintain user data privacy.
  static Future<void> addTask(String title, DateTime deadline) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final encryptedTitle = EncryptionHelper.encryptText(title, user.uid);

    //  To ensure that offline tasks don’t duplicate
    final taskRef = _firestore
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

  /// Retrieves all tasks for the current user, sorted by deadline.
  /// Returns raw encrypted data without decryption.
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

  /// Retrieves and decrypts all tasks for the current user from Firestore.
  /// Converts timestamp or string-based deadlines to ISO strings for uniformity.
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

  /// Saves a list of allocated task slots under 'allocated_tasks' for the current user.
  /// Any previously saved allocated tasks are deleted before saving the new ones.
  /// Fetches the currently authenticated user for saving allocated tasks.
  static Future<void> saveAllocatedTasks(List<Map<String, dynamic>> tasks) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final userDoc = _firestore.collection('users').doc(user.uid);
    final taskCollection = userDoc.collection('allocated_tasks');

    // Clear existing tasks before saving new ones
    final existing = await taskCollection.get();

    var batch = _firestore.batch();
    int operationCount = 0;

    for (var doc in existing.docs) {
      batch.delete(doc.reference);
      operationCount++;

      if (operationCount >= 500) {
        await batch.commit();
        batch = _firestore.batch();
        operationCount = 0;
      }
    }

    // Add new tasks
    for (var task in tasks) {
      final newDocRef = taskCollection.doc();
      batch.set(newDocRef, task);
      operationCount++;

      if (operationCount >= 500) {
        await batch.commit();
        batch = _firestore.batch();
        operationCount = 0;
      }
    }

    if (operationCount > 0) {
      await batch.commit();
    }
  }

  /// Fetches all allocated task slots for the current user.
  static Future<List<Map<String, dynamic>>> getAllocatedTasks() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    final snapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('allocated_tasks')
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  /// Deletes all tasks under the current user's tasks collection.
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

  /// Updates a task's document by setting its 'completed' field to true.
  static Future<void> markTaskCompleted(String taskId) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _firestore.collection('users').doc(user.uid).collection('tasks').doc(taskId).update({
      'completed': true,
    });
  }

  /// Permanently deletes a task document by its ID from the user's task collection.
  static Future<void> deleteTask(String taskId) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _firestore.collection('users').doc(user.uid).collection('tasks').doc(taskId).delete();
  }


  /// Deletes tasks from the 'tasks' collection where the start time matches the given ISO string.
  /// Used for cleaning up scheduled task blocks.
  static Future<void> deleteTaskByStart(String startIso) async {
    final snapshot = await _firestore
        .collection('tasks')
        .where('start', isEqualTo: startIso)
        .get();
    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
}