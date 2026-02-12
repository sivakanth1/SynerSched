import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:syner_sched/firebase/task_service.dart';

// Mocks

class MockUser extends Fake implements User {
  @override
  String get uid => 'test_user_id';
}

class MockFirebaseAuth extends Fake implements FirebaseAuth {
  final MockUser _user = MockUser();
  @override
  User? get currentUser => _user;
}

class MockWriteBatch extends Fake implements WriteBatch {
  int commitCount = 0;
  int operationCount = 0;

  @override
  void delete(DocumentReference document) {
    operationCount++;
  }

  @override
  Future<void> commit() async {
    commitCount++;
    await Future.delayed(const Duration(milliseconds: 20)); // Simulate batch commit latency
  }
}

class MockDocumentReference extends Fake implements DocumentReference<Map<String, dynamic>> {
  final String _id;
  int deleteCount = 0;

  MockDocumentReference(this._id);

  @override
  String get id => _id;

  @override
  Future<void> delete() async {
    deleteCount++;
    await Future.delayed(const Duration(milliseconds: 10)); // Simulate single delete latency
  }
}

class MockDocumentSnapshot extends Fake implements QueryDocumentSnapshot<Map<String, dynamic>> {
  final String _id;
  final MockDocumentReference _reference;

  MockDocumentSnapshot(this._id) : _reference = MockDocumentReference(_id);

  @override
  String get id => _id;

  @override
  DocumentReference<Map<String, dynamic>> get reference => _reference;

  @override
  Map<String, dynamic> data() => {};
}

class MockQuerySnapshot extends Fake implements QuerySnapshot<Map<String, dynamic>> {
  final List<MockDocumentSnapshot> _docs;

  MockQuerySnapshot(this._docs);

  @override
  List<QueryDocumentSnapshot<Map<String, dynamic>>> get docs => _docs;
}

class MockTasksCollectionReference extends Fake implements CollectionReference<Map<String, dynamic>> {
  final List<MockDocumentSnapshot> _docs;

  MockTasksCollectionReference(this._docs);

  @override
  Future<QuerySnapshot<Map<String, dynamic>>> get([GetOptions? options]) async {
    return MockQuerySnapshot(_docs);
  }
}

class MockUserDocumentReference extends Fake implements DocumentReference<Map<String, dynamic>> {
  final List<MockDocumentSnapshot> tasks;

  MockUserDocumentReference(this.tasks);

  @override
  CollectionReference<Map<String, dynamic>> collection(String collectionPath) {
    if (collectionPath == 'tasks') {
      return MockTasksCollectionReference(tasks);
    }
    throw UnimplementedError();
  }
}

class MockUsersCollectionReference extends Fake implements CollectionReference<Map<String, dynamic>> {
  final Map<String, MockUserDocumentReference> users = {};

  void addUser(String uid, List<MockDocumentSnapshot> tasks) {
    users[uid] = MockUserDocumentReference(tasks);
  }

  @override
  DocumentReference<Map<String, dynamic>> doc([String? path]) {
    if (path != null && users.containsKey(path)) {
      return users[path]!;
    }
    throw UnimplementedError();
  }
}

class MockFirebaseFirestore extends Fake implements FirebaseFirestore {
  final MockUsersCollectionReference usersCollection = MockUsersCollectionReference();
  final MockWriteBatch _batch = MockWriteBatch();

  void setupUserTasks(String uid, int taskCount) {
    final tasks = List.generate(taskCount, (i) => MockDocumentSnapshot('task_$i'));
    usersCollection.addUser(uid, tasks);
  }

  @override
  CollectionReference<Map<String, dynamic>> collection(String collectionPath) {
    if (collectionPath == 'users') {
      return usersCollection;
    }
    throw UnimplementedError();
  }

  @override
  WriteBatch batch() {
    return _batch;
  }
}

void main() {
  test('deleteAllUserTasks benchmark', () async {
    final mockFirestore = MockFirebaseFirestore();
    final mockAuth = MockFirebaseAuth();
    final taskCount = 1000;

    mockFirestore.setupUserTasks(mockAuth.currentUser!.uid, taskCount);

    TaskService.setFirestoreInstance(mockFirestore);
    TaskService.setAuthInstance(mockAuth);

    print('Starting benchmark with $taskCount tasks...');
    final stopwatch = Stopwatch()..start();
    await TaskService.deleteAllUserTasks();
    stopwatch.stop();

    print('Deleted $taskCount tasks in ${stopwatch.elapsedMilliseconds}ms');

    // Collect stats
    int totalDeletes = 0;
    // We need to access the created docs to check delete counts
    final userDoc = mockFirestore.usersCollection.users[mockAuth.currentUser!.uid]!;
    for (var doc in userDoc.tasks) {
      // Cast to MockDocumentSnapshot to access private reference and then cast to MockDocumentReference
      // But MockDocumentSnapshot._reference is private.
      // I need to expose it or cast doc.reference.
      final ref = doc.reference as MockDocumentReference;
      totalDeletes += ref.deleteCount;
    }

    final batchCommits = (mockFirestore.batch() as MockWriteBatch).commitCount;

    print('Total individual deletes: $totalDeletes');
    print('Total batch commits: ${mockFirestore._batch.commitCount}');
    print('Total batch operations: ${mockFirestore._batch.operationCount}');

    // Assertions for Baseline (N+1 deletes)
    // If we haven't optimized yet:
    // expect(totalDeletes, taskCount);
    // expect(mockFirestore._batch.commitCount, 0);

    // Assertions for Optimization (Batch deletes)
    // expect(totalDeletes, 0);
    // expect(mockFirestore._batch.commitCount, greaterThan(0));
  });
}
