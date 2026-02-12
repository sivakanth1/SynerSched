
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

  PerformanceBenchmark(this.docs);

  List<MockDocumentSnapshot> applyFiltersSync(String query, String sortOption, Map<String, String> translations) {
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

  void runBaseline() {
    print('Starting baseline benchmark with ${docs.length} documents...');

    final translations = {
      "recent": "Recent",
      "computer_science": "Computer science",
      "machine_learning": "Machine learning",
    };

    final queries = ['dev', 'flutter', 'machine', 'learning', 'app', 'test', 'collab', 'firebase', 'dart', 'sync'];
    final sortOptions = ["Recent", "Computer science", "Machine learning"];

    final stopwatch = Stopwatch()..start();

    int totalFilteredCount = 0;
    int iterations = 100;

    for (int i = 0; i < iterations; i++) {
      for (final query in queries) {
        for (final sortOption in sortOptions) {
          final filtered = applyFiltersSync(query, sortOption, translations);
          totalFilteredCount += filtered.length;
        }
      }
    }

    stopwatch.stop();
    print('Baseline completed.');
    print('Total iterations: ${iterations * queries.length * sortOptions.length}');
    print('Total time: ${stopwatch.elapsedMilliseconds}ms');
    print('Average time per filter: ${stopwatch.elapsedMilliseconds / (iterations * queries.length * sortOptions.length)}ms');
  }
}

void main() {
  final docs = List.generate(1000, (index) => MockDocumentSnapshot('id_$index', {
    'title': 'Project $index ' + (index % 2 == 0 ? 'Flutter Dev' : 'Machine Learning'),
    'description': 'This is a description for project $index. It involves many things.',
    'tags': ['tag1', 'tag2', 'tag_$index'],
    'department': index % 3 == 0 ? 'Computer Science' : 'Other',
    'skills': index % 5 == 0 ? ['Machine Learning', 'Dart'] : ['Java'],
  }));

  final benchmark = PerformanceBenchmark(docs);
  benchmark.runBaseline();
}
