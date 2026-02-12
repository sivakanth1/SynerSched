
import 'dart:async';

// Mocking DocumentSnapshot for testing
class MockDocumentSnapshot {
  final Map<String, dynamic> _data;
  final String id;
  MockDocumentSnapshot(this.id, this._data);
  Map<String, dynamic> data() => _data;
}

class PerformanceBenchmark {
  final List<MockDocumentSnapshot> docs;
  int filterExecutionCount = 0;

  PerformanceBenchmark(this.docs);

  List<MockDocumentSnapshot> applyFiltersSync(String query, String sortOption, Map<String, String> translations) {
    filterExecutionCount++;
    return docs.where((doc) {
      final data = doc.data();
      final title = data['title']?.toString().toLowerCase() ?? '';
      final description = data['description']?.toString().toLowerCase() ?? '';
      final tags = (data['tags'] ?? []) as List<dynamic>;

      final matchesQuery = query.isEmpty ||
          title.contains(query) ||
          description.contains(query) ||
          tags.any((tag) => tag.toString().toLowerCase().contains(query));

      if (!matchesQuery) return false;

      if (sortOption == translations["computer_science"]) {
        return data['department'] == 'Computer Science';
      } else if (sortOption == translations["machine_learning"]) {
        return (data['skills'] ?? []).contains('Machine Learning');
      }

      return true;
    }).toList();
  }

  Future<void> runSearchSimulation({required bool debounced}) async {
    final translations = {
      "recent": "Recent",
      "computer_science": "Computer science",
      "machine_learning": "Machine learning",
    };

    final searchString = "flutter developer machine learning";
    final sortOption = "Recent";

    filterExecutionCount = 0;
    final stopwatch = Stopwatch()..start();

    if (debounced) {
      print('Running DEBOUNCED simulation...');
      Timer? debounce;
      Completer<void> completer = Completer<void>();

      int keystrokes = searchString.length;
      for (int i = 1; i <= keystrokes; i++) {
        final currentQuery = searchString.substring(0, i);

        // Simulate debounce logic
        if (debounce?.isActive ?? false) debounce!.cancel();
        debounce = Timer(Duration(milliseconds: 300), () {
          applyFiltersSync(currentQuery, sortOption, translations);
          if (i == keystrokes) completer.complete();
        });

        // Simulate fast typing (50ms between keystrokes)
        await Future.delayed(Duration(milliseconds: 50));
      }
      await completer.future;
    } else {
      print('Running NON-DEBOUNCED simulation...');
      int keystrokes = searchString.length;
      for (int i = 1; i <= keystrokes; i++) {
        final currentQuery = searchString.substring(0, i);
        applyFiltersSync(currentQuery, sortOption, translations);
      }
    }

    stopwatch.stop();
    print('Simulation completed.');
    print('Total keystrokes: ${searchString.length}');
    print('Filter execution count: $filterExecutionCount');
    print('Total time: ${stopwatch.elapsedMilliseconds}ms');
    print('---');
  }
}

Future<void> main() async {
  final docs = List.generate(1000, (index) => MockDocumentSnapshot('id_$index', {
    'title': 'Project $index ' + (index % 2 == 0 ? 'Flutter Dev' : 'Machine Learning'),
    'description': 'This is a description for project $index. It involves many things.',
    'tags': ['tag1', 'tag2', 'tag_$index'],
    'department': index % 3 == 0 ? 'Computer Science' : 'Other',
    'skills': index % 5 == 0 ? ['Machine Learning', 'Dart'] : ['Java'],
  }));

  final benchmark = PerformanceBenchmark(docs);

  await benchmark.runSearchSimulation(debounced: false);
  await benchmark.runSearchSimulation(debounced: true);
}
