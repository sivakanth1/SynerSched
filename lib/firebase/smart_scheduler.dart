import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TimeSlot {
  final String day;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  String type; // 'free', 'class', 'break', 'task'
  String? label; // Course or Task name

  TimeSlot({
    required this.day,
    required this.startTime,
    required this.endTime,
    this.type = 'free',
    this.label,
  });

  String get formattedTime =>
      '${_formatTime(startTime)} - ${_formatTime(endTime)}';

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final suffix = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $suffix';
  }

  // Converts TimeOfDay to total minutes since midnight
  static int toMinutes(TimeOfDay t) => t.hour * 60 + t.minute;
}

class SmartScheduler {
  static List<String> days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  // static List<TimeSlot> generateWeeklyGrid() {
  //   List<TimeSlot> grid = [];
  //
  //   for (var day in days) {
  //     TimeOfDay current = const TimeOfDay(hour: 8, minute: 0);
  //     const TimeOfDay end = TimeOfDay(hour: 22, minute: 0);
  //
  //     while (_isBefore(current, end)) {
  //       final next = _add30Minutes(current);
  //       grid.add(TimeSlot(
  //         day: day,
  //         startTime: current,
  //         endTime: next,
  //       ));
  //       current = next;
  //     }
  //   }
  //
  //   return grid;
  // }

  static bool _isBefore(TimeOfDay a, TimeOfDay b) {
    return a.hour < b.hour || (a.hour == b.hour && a.minute < b.minute);
  }

  static TimeOfDay _add30Minutes(TimeOfDay time) {
    int hour = time.hour;
    int minute = time.minute + 30;
    if (minute >= 60) {
      hour += 1;
      minute -= 60;
    }
    return TimeOfDay(hour: hour, minute: minute);
  }

  static void markClassSlots({
    required List<TimeSlot> grid,
    required String courseName,
    required List<String> classDays,
    required TimeOfDay classStart,
    required TimeOfDay classEnd,
  }) {
    for (var slot in grid) {
      if (classDays.contains(slot.day) &&
          _overlaps(slot.startTime, slot.endTime, classStart, classEnd)) {
        slot.type = 'class';
        slot.label = courseName;
      }
    }
  }

  static void markBreakSlots({
    required List<TimeSlot> grid,
    required List<String> breakDays,
    required TimeOfDay breakStart,
    required TimeOfDay breakEnd,
  }) {
    for (var slot in grid) {
      if (breakDays.contains(slot.day) &&
          _overlaps(slot.startTime, slot.endTime, breakStart, breakEnd)) {
        slot.type = 'break';
        slot.label = 'Break';
      }
    }
  }

  static bool _overlaps(
      TimeOfDay slotStart,
      TimeOfDay slotEnd,
      TimeOfDay rangeStart,
      TimeOfDay rangeEnd,
      ) {
    final slotStartMin = TimeSlot.toMinutes(slotStart);
    final slotEndMin = TimeSlot.toMinutes(slotEnd);
    final rangeStartMin = TimeSlot.toMinutes(rangeStart);
    final rangeEndMin = TimeSlot.toMinutes(rangeEnd);

    return slotStartMin < rangeEndMin && slotEndMin > rangeStartMin;
  }

  /// Helper to approximate a DateTime from day name + time (used for deadline comparison)
  static DateTime _approximateDateTime(String day, TimeOfDay time) {
    final now = DateTime.now();
    final daysMap = {
      'Monday': 1,
      'Tuesday': 2,
      'Wednesday': 3,
      'Thursday': 4,
      'Friday': 5,
      'Saturday': 6,
      'Sunday': 7,
    };
    final todayWeekday = now.weekday;
    final targetWeekday = daysMap[day]!;
    final dayDifference = targetWeekday - todayWeekday;

    final targetDate = now.add(Duration(days: dayDifference));
    return DateTime(
      targetDate.year,
      targetDate.month,
      targetDate.day,
      time.hour,
      time.minute,
    );
  }

  // Generates a weekly grid with hourly time slots from 8AM to 6PM
  static List<Map<String, dynamic>> generateWeeklyGrid() {
    List<Map<String, dynamic>> grid = [];
    List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    for (var day in days) {
      for (int hour = 8; hour <= 18; hour++) {
        final now = DateTime.now();
        final dayIndex = days.indexOf(day); // 0 for Mon, 1 for Tue, ...
        final slotDate = now
            .subtract(Duration(days: now.weekday - 1))
            .add(Duration(days: dayIndex));

        final start = DateTime(slotDate.year, slotDate.month, slotDate.day, hour);
        final end = DateTime(slotDate.year, slotDate.month, slotDate.day, hour + 1);

        grid.add({
          'day': day,
          'hour': hour,
          'time': '${_formatTime(hour)} - ${_formatTime(hour + 1)}',
          'type': 'free',
          'title': '',
          'start': start.toIso8601String(),
          'end': end.toIso8601String(),
        });
      }
    }
    return grid;
  }

  static List<Map<String, dynamic>> markClassesAndBreaks({
    required List<Map<String, dynamic>> grid,
    required List<Map<String, dynamic>> occupiedSlots,
  }) {
    for (var occ in occupiedSlots) {
      for (var slot in grid) {
        if (slot['day'] == occ['day'] && slot['hour'] == occ['hour']) {
          slot['type'] = occ['type'];
          slot['title'] = occ['title'];
        }
      }
    }
    return grid;
  }

  // Example structure for task allocation (not yet integrated in current screen)
  static List<Map<String, dynamic>> allocateTasks({
    required List<Map<String, dynamic>> weeklyGrid,
    required List<Map<String, dynamic>> tasks,
  }) {
    print(weeklyGrid
        .where((e) => e['day'] == 'Sat')
        .map((e) => '${e['time']} - ${e['start']} to ${e['end']}')
        .join('\n'));
    for (var task in tasks) {
      if (task['deadline'] == null || task['title'] == null) continue;

      final title = (task['title'] ?? 'Untitled').toString();
      final deadlineRaw = task['deadline'];
      DateTime deadlineTime;

      if (deadlineRaw is Timestamp) {
        deadlineTime = deadlineRaw.toDate();
      } else if (deadlineRaw is String) {
        deadlineTime = DateTime.tryParse(deadlineRaw) ?? DateTime.now();
      } else {
        continue; // Skip unsupported format
      }

      final DateTime startTime = deadlineTime.subtract(const Duration(hours: 1));
      final String taskDay = _shortDayName(deadlineTime);

      for (int i = 0; i < weeklyGrid.length; i++) {
        final slot = weeklyGrid[i];

        if (slot['type'] == 'free' && slot['day'] == taskDay) {
          final slotStart = DateTime.tryParse(slot['start'] ?? '');
          final slotEnd = DateTime.tryParse(slot['end'] ?? '');

          if (slotStart == null || slotEnd == null) continue;

          if (slotStart.isBefore(deadlineTime) &&
              slotStart.isAfter(startTime.subtract(const Duration(minutes: 1)))) {
            weeklyGrid[i] = {
              ...slot,
              'type': 'task',
              'title': title,
              'start': slot['start'],
              'end': slot['end'],
            };
            break;
          }
        }
      }
    }

    return weeklyGrid;
  }

// Helper to convert weekday to short form like 'Mon', 'Tue'
  static String _shortDayName(DateTime date) {
    return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][date.weekday - 1];
  }

  static String _formatTime(int hour) {
    final h = hour % 12 == 0 ? 12 : hour % 12;
    final period = hour < 12 ? 'AM' : 'PM';
    return '$h:00 $period';
  }
}