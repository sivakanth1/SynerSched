import 'package:flutter_test/flutter_test.dart';
import 'package:syner_sched/shared/constants.dart';

void main() {
  group('AppConstants', () {
    test('availableCourses should not be empty', () {
      expect(AppConstants.availableCourses, isNotEmpty);
    });

    test('availableCourses should contain expected courses', () {
      expect(AppConstants.availableCourses, contains('COSC 5311 - Advanced Operating Systems'));
      expect(AppConstants.availableCourses, contains('COSC 5360 - Parallel Computing'));
      expect(AppConstants.availableCourses, contains('COSC 5321 - Database Systems'));
      expect(AppConstants.availableCourses, contains('COSC 5340 - Computer Networks'));
      expect(AppConstants.availableCourses, contains('COSC 5315 - Software Engineering'));
      expect(AppConstants.availableCourses, contains('COSC 5390 - Advanced Algorithms'));
    });

    test('availableCourses should have 6 items', () {
       expect(AppConstants.availableCourses.length, 6);
    });
  });
}
