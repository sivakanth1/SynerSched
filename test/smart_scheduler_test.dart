import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:syner_sched/firebase/smart_scheduler.dart';

void main() {
  group('SmartScheduler.allocateTasks', () {
    late List<Map<String, dynamic>> grid;

    setUp(() {
      // Create a simple grid for testing
      // Monday 10:00 - 11:00
      final monStart = DateTime(2023, 10, 23, 10);
      final monEnd = DateTime(2023, 10, 23, 11);

      // Tuesday 10:00 - 11:00
      final tueStart = DateTime(2023, 10, 24, 10);
      final tueEnd = DateTime(2023, 10, 24, 11);

      grid = [
        {
          'day': 'Mon',
          'hour': 10,
          'type': 'free',
          'title': '',
          'start': monStart.toIso8601String(),
          'end': monEnd.toIso8601String(),
        },
        {
          'day': 'Tue',
          'hour': 10,
          'type': 'free',
          'title': '',
          'start': tueStart.toIso8601String(),
          'end': tueEnd.toIso8601String(),
        },
      ];
    });

    test('should allocate a task with String deadline to a free slot', () {
      final tasks = [
        {
          'title': 'Test Task',
          'deadline': DateTime(2023, 10, 23, 11).toIso8601String(),
        }
      ];

      final result = SmartScheduler.allocateTasks(weeklyGrid: grid, tasks: tasks);

      expect(result[0]['type'], 'task');
      expect(result[0]['title'], 'Test Task');
      expect(result[1]['type'], 'free');
    });

    test('should allocate a task with Timestamp deadline to a free slot', () {
      final tasks = [
        {
          'title': 'Timestamp Task',
          'deadline': Timestamp.fromDate(DateTime(2023, 10, 24, 11)),
        }
      ];

      final result = SmartScheduler.allocateTasks(weeklyGrid: grid, tasks: tasks);

      expect(result[1]['type'], 'task');
      expect(result[1]['title'], 'Timestamp Task');
      expect(result[0]['type'], 'free');
    });

    test('should respect task day (Mon task should not be in Tue slot)', () {
       // Monday task but only Tuesday slot is free
      grid[0]['type'] = 'class';
      final tasks = [
        {
          'title': 'Monday Task',
          'deadline': DateTime(2023, 10, 23, 11).toIso8601String(),
        }
      ];

      final result = SmartScheduler.allocateTasks(weeklyGrid: grid, tasks: tasks);

      expect(result[0]['type'], 'class');
      expect(result[1]['type'], 'free');
    });

    test('should only use free slots', () {
      grid[0]['type'] = 'class';
      final tasks = [
        {
          'title': 'Task',
          'deadline': DateTime(2023, 10, 23, 11).toIso8601String(),
        }
      ];

      final result = SmartScheduler.allocateTasks(weeklyGrid: grid, tasks: tasks);

      expect(result[0]['type'], 'class');
      expect(result[0]['title'], isNot('Task'));
    });

    test('should skip tasks with missing title or deadline', () {
      final tasks = [
        {'title': 'No Deadline'},
        {'deadline': DateTime(2023, 10, 23, 11).toIso8601String()},
      ];

      final result = SmartScheduler.allocateTasks(weeklyGrid: List.from(grid), tasks: tasks);

      expect(result[0]['type'], 'free');
      expect(result[1]['type'], 'free');
    });

    test('should skip tasks with unsupported deadline format', () {
      final tasks = [
        {
          'title': 'Bad Format',
          'deadline': 12345, // Not String or Timestamp
        }
      ];

      final result = SmartScheduler.allocateTasks(weeklyGrid: List.from(grid), tasks: tasks);

      expect(result[0]['type'], 'free');
    });

    test('should handle cases with no suitable slots', () {
      final tasks = [
        {
          'title': 'Late Task',
          'deadline': DateTime(2023, 10, 25, 11).toIso8601String(), // Wednesday
        }
      ];

      final result = SmartScheduler.allocateTasks(weeklyGrid: List.from(grid), tasks: tasks);

      expect(result[0]['type'], 'free');
      expect(result[1]['type'], 'free');
    });
  });
}
