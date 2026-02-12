
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:syner_sched/firebase/task_service.dart';

// ---------------------------------------------------------
// Mocks
// ---------------------------------------------------------

class MockUser implements User {
  @override
  String get uid => 'test_user_uid';

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockFirebaseAuth implements FirebaseAuth {
  final MockUser? _user;
  MockFirebaseAuth({MockUser? user}) : _user = user;

  @override
  User? get currentUser => _user;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockDocumentReference implements DocumentReference<Map<String, dynamic>> {
  final String _id;
  MockDocumentReference([this._id = 'new_id']);

  @override
  String get id => _id;

  @override
  Future<void> delete() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockQueryDocumentSnapshot implements QueryDocumentSnapshot<Map<String, dynamic>> {
  final MockDocumentReference _ref;
  MockQueryDocumentSnapshot(this._ref);

  @override
  DocumentReference<Map<String, dynamic>> get reference => _ref;

  @override
  Map<String, dynamic> data() => {};

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockQuerySnapshot implements QuerySnapshot<Map<String, dynamic>> {
  final List<MockQueryDocumentSnapshot> _docs;
  MockQuerySnapshot(this._docs);

  @override
  List<QueryDocumentSnapshot<Map<String, dynamic>>> get docs => _docs;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockAllocatedTasksCollectionReference implements CollectionReference<Map<String, dynamic>> {
  final List<MockDocumentReference> _existingDocs;
  MockAllocatedTasksCollectionReference(this._existingDocs);

  @override
  Future<QuerySnapshot<Map<String, dynamic>>> get([GetOptions? options]) async {
    return MockQuerySnapshot(
      _existingDocs.map((ref) => MockQueryDocumentSnapshot(ref)).toList()
    );
  }

  @override
  DocumentReference<Map<String, dynamic>> doc([String? path]) {
    return MockDocumentReference(path ?? 'new_id');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockUserDocumentReference implements DocumentReference<Map<String, dynamic>> {
    final MockAllocatedTasksCollectionReference allocatedTasksCollection;
    MockUserDocumentReference(this.allocatedTasksCollection);

    @override
    CollectionReference<Map<String, dynamic>> collection(String collectionPath) {
        if (collectionPath == 'allocated_tasks') {
            return allocatedTasksCollection;
        }
        throw UnimplementedError('Unexpected collection: $collectionPath');
    }

    @override
    dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockUsersCollectionReference implements CollectionReference<Map<String, dynamic>> {
    final MockAllocatedTasksCollectionReference allocatedTasksCollection;
    MockUsersCollectionReference(this.allocatedTasksCollection);

    @override
    DocumentReference<Map<String, dynamic>> doc([String? path]) {
        return MockUserDocumentReference(allocatedTasksCollection);
    }

    @override
    dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockWriteBatch implements WriteBatch {
  int commitCount = 0;
  List<String> operations = [];

  @override
  void delete(DocumentReference document) {
    operations.add('delete');
  }

  @override
  void set<T>(DocumentReference<T> document, T data, [SetOptions? options]) {
    operations.add('set');
  }

  @override
  Future<void> commit() async {
    commitCount++;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockFirestore implements FirebaseFirestore {
  final MockAllocatedTasksCollectionReference allocatedTasksCollection;
  final List<MockWriteBatch> batches = [];

  MockFirestore(this.allocatedTasksCollection);

  @override
  CollectionReference<Map<String, dynamic>> collection(String collectionPath) {
    if (collectionPath == 'users') {
        return MockUsersCollectionReference(allocatedTasksCollection);
    }
    throw UnimplementedError('Unexpected collection: $collectionPath');
  }

  @override
  WriteBatch batch() {
    final b = MockWriteBatch();
    batches.add(b);
    return b;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}


// ---------------------------------------------------------
// Tests
// ---------------------------------------------------------

void main() {
  group('TaskService.saveAllocatedTasks', () {
    late MockFirestore mockFirestore;
    late MockFirebaseAuth mockAuth;
    late MockAllocatedTasksCollectionReference mockCollection;

    setUp(() {
      mockAuth = MockFirebaseAuth(user: MockUser());
      TaskService.authInstance = mockAuth;
    });

    test('commits batch when operations reach 500', () async {
      // 400 existing docs
      final existingDocs = List.generate(400, (i) => MockDocumentReference('doc_$i'));
      mockCollection = MockAllocatedTasksCollectionReference(existingDocs);
      mockFirestore = MockFirestore(mockCollection);
      TaskService.firestoreInstance = mockFirestore;

      // 200 new tasks
      final newTasks = List.generate(200, (i) => {'title': 'Task $i'});

      // Execute
      await TaskService.saveAllocatedTasks(newTasks);

      // Verify
      expect(mockFirestore.batches.length, 2);
      expect(mockFirestore.batches[0].commitCount, 1);
      expect(mockFirestore.batches[0].operations.length, 500); // 400 deletes + 100 sets

      expect(mockFirestore.batches[1].commitCount, 1);
      expect(mockFirestore.batches[1].operations.length, 100); // 100 sets
    });

    test('handles exactly 500 operations', () async {
      // 500 existing docs
      final existingDocs = List.generate(500, (i) => MockDocumentReference('doc_$i'));
      mockCollection = MockAllocatedTasksCollectionReference(existingDocs);
      mockFirestore = MockFirestore(mockCollection);
      TaskService.firestoreInstance = mockFirestore;

      // 0 new tasks
      final newTasks = <Map<String, dynamic>>[];

      // Execute
      await TaskService.saveAllocatedTasks(newTasks);

      // Verify
      expect(mockFirestore.batches.length, 2);
      expect(mockFirestore.batches[0].commitCount, 1);
      expect(mockFirestore.batches[0].operations.length, 500);

      expect(mockFirestore.batches[1].commitCount, 0); // Empty batch not committed
      expect(mockFirestore.batches[1].operations.length, 0);
    });

    test('handles small number of operations', () async {
      final existingDocs = List.generate(10, (i) => MockDocumentReference('doc_$i'));
      mockCollection = MockAllocatedTasksCollectionReference(existingDocs);
      mockFirestore = MockFirestore(mockCollection);
      TaskService.firestoreInstance = mockFirestore;

      final newTasks = List.generate(10, (i) => {'title': 'Task $i'});

      // Execute
      await TaskService.saveAllocatedTasks(newTasks);

      // Verify
      expect(mockFirestore.batches.length, 1);
      expect(mockFirestore.batches[0].commitCount, 1);
      expect(mockFirestore.batches[0].operations.length, 20);
    });
  });
}
