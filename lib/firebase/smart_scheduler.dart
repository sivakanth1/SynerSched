import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Represents a time slot within a day, with start and end times,
/// a type (free, class, break, task), and an optional label.
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

  /// Returns a formatted string representation of the time slot, e.g. "8:00 AM - 9:00 AM".
  String get formattedTime =>
      '${_formatTime(startTime)} - ${_formatTime(endTime)}';

  /// Helper to format a TimeOfDay object into a readable string with AM/PM.
  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final suffix = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $suffix';
  }

  /// Converts a TimeOfDay instance to total minutes since midnight.
  static int toMinutes(TimeOfDay t) => t.hour * 60 + t.minute;
}

/// Provides methods to generate and manipulate scheduling grids,
/// marking classes, breaks, and tasks within weekly time slots.
class SmartScheduler {

  /// Generates a grid of 10-minute time slots for a week based on user's preferred
  /// study time (morning, afternoon, night) and workload level (light, medium, intense).
  /// Returns a list of maps representing each slot with day, time range, start/end ISO strings, type, and title.
  static List<Map<String, dynamic>> generateGridWithPreferences({
    required String preferredTime,
    required String workloadLevel,
  }) {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    // Define start hours for different preferred times
    final Map<String, int> startHours = {
      'morning': 8,
      'afternoon': 13,
      'night': 18,
    };

    // Define durations in hours for different workload levels
    final Map<String, int> durations = {
      'light': 4,   // 4 hours
      'medium': 6,  // 6 hours
      'intense': 10, // 8 hours (note: comment says 8 hours but value is 10)
    };

    final startHour = startHours[preferredTime] ?? 8;
    final duration = durations[workloadLevel] ?? 4;
    final endHour = startHour + duration;

    final slots = <Map<String, dynamic>>[];

    // Iterate over each day and create 10-minute slots within the specified time range
    for (var i = 0; i < 7; i++) {
      final date = monday.add(Duration(days: i));
      final day = days[i];
      for (int hour = startHour; hour < endHour; hour++) {
        for (int minute = 0; minute < 60; minute += 10) {
          final start = DateTime(date.year, date.month, date.day, hour, minute);
          final end = start.add(const Duration(minutes: 10));

          slots.add({
            'day': day,
            'time': '${_formatTime(start)} - ${_formatTime(end)}',
            'start': start.toIso8601String(),
            'end': end.toIso8601String(),
            'type': 'free',
            'title': '',
          });
        }
      }
    }

    return slots;
  }

  /// Formats a DateTime object into a 12-hour time string with AM/PM.
  static String _formatTime(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }


  /// Marks the grid slots with classes and breaks based on provided course and break schedules.
  /// The schedules use ISO8601 time strings for start and end times.
  /// Updates slot types to 'class' or 'break' and sets appropriate titles.
  static List<Map<String, dynamic>> markScheduleWithCoursesAndBreaks({
    required List<Map<String, dynamic>> grid,
    required List<Map<String, dynamic>> courses,
    required List<Map<String, dynamic>> breaks,
  }) {
    // Mark class slots in the grid
    for (var course in courses) {
      final days = (course['days'] as List<dynamic>? ?? []).map((e) => e.toString()).toList();
      final start = course['startTime'] ?? '';
      final end = course['endTime'] ?? '';
      final title = course['courseName'] ?? 'Course';

      for (var slot in grid) {
        if (days.contains(slot['day']) &&
            _isTimeWithinSlot(slot['start'], slot['end'], start, end)) {
          slot['type'] = 'class';
          slot['title'] = title;
        }
      }
    }

    // Mark break slots in the grid
    for (var br in breaks) {
      final days = (br['days'] as List<dynamic>? ?? []).map((e) => e.toString()).toList();
      final start = br['startTime'] ?? '';
      final end = br['endTime'] ?? '';

      for (var slot in grid) {
        if (days.contains(slot['day']) &&
            _isTimeWithinSlot(slot['start'], slot['end'], start, end)) {
          slot['type'] = 'break';
          slot['title'] = 'Break';
        }
      }
    }

    return grid;
  }

  /// Checks if a given time range (startTime to endTime) overlaps with a slot's time range (slotStartIso to slotEndIso).
  /// All times are ISO8601 strings.
  static bool _isTimeWithinSlot(String slotStartIso, String slotEndIso, String startTime, String endTime) {
    final slotStart = DateTime.tryParse(slotStartIso);
    final slotEnd = DateTime.tryParse(slotEndIso);
    final start = _parseTimeToDateTime(startTime);
    final end = _parseTimeToDateTime(endTime);

    if (slotStart == null || slotEnd == null || start == null || end == null) return false;

    return slotStart.isBefore(end) && slotEnd.isAfter(start);
  }

  /// Parses a time string into a DateTime object.
  /// Supports ISO8601 format or formatted time strings like '9:00 AM'.
  /// Returns current DateTime on failure to avoid crashes.
  static DateTime _parseTimeToDateTime(String timeStr) {
    try {
      if (timeStr.contains('T')) {
        // Already in ISO format
        return DateTime.parse(timeStr);
      } else {
        // e.g., '9:00 AM'
        return DateFormat.jm().parse(timeStr);
      }
    } catch (e) {
      return DateTime.now(); // fallback to avoid crash
    }
  }

  /// List of full day names used in weekly scheduling.
  static List<String> days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  /// Checks if TimeOfDay a is before TimeOfDay b.
  static bool _isBefore(TimeOfDay a, TimeOfDay b) {
    return a.hour < b.hour || (a.hour == b.hour && a.minute < b.minute);
  }

  /// Adds 30 minutes to a given TimeOfDay, rolling over the hour if needed.
  static TimeOfDay _add30Minutes(TimeOfDay time) {
    int hour = time.hour;
    int minute = time.minute + 30;
    if (minute >= 60) {
      hour += 1;
      minute -= 60;
    }
    return TimeOfDay(hour: hour, minute: minute);
  }

  /// Marks slots in the grid as 'class' if they overlap with the specified class time range on given days.
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

  /// Marks slots in the grid as 'break' if they overlap with the specified break time range on given days.
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

  /// Checks if two time ranges overlap. Each range is defined by start and end TimeOfDay.
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

  /// Approximates a DateTime object combining a day name and a TimeOfDay.
  /// Useful for comparing deadlines or scheduling within the current week.
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

  /// Generates a weekly grid with hourly time slots from 8 AM to 6 PM for each day.
  /// Each slot includes day, hour, time range, type, title, and ISO start/end times.
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
          'time': '${_formatTime(start)} - ${_formatTime(end)}',
          'type': 'free',
          'title': '',
          'start': start.toIso8601String(),
          'end': end.toIso8601String(),
        });
      }
    }
    return grid;
  }

  /// Marks occupied slots (classes, breaks, tasks) in the weekly grid by matching day and hour.
  /// Updates the slot's type and title accordingly.
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

  /// Allocates tasks into the weekly grid by finding free slots before their deadlines.
  /// Marks the allocated slot as 'task' with the task's title.
  static List<Map<String, dynamic>> allocateTasks({
    required List<Map<String, dynamic>> weeklyGrid,
    required List<Map<String, dynamic>> tasks,
  }) {
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

      // Find a free slot on the task day that overlaps with the last hour before deadline
      for (int i = 0; i < weeklyGrid.length; i++) {
        final slot = weeklyGrid[i];

        if (slot['type'] == 'free' && slot['day'] == taskDay) {
          final slotStart = DateTime.tryParse(slot['start'] ?? '');
          final slotEnd = DateTime.tryParse(slot['end'] ?? '');

          if (slotStart == null || slotEnd == null) continue;

          if (slotStart.isBefore(deadlineTime) &&
              slotEnd.isAfter(startTime)) {
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

  /// Converts a DateTime's weekday into a short day name string like 'Mon', 'Tue', etc.
  static String _shortDayName(DateTime date) {
    return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][date.weekday - 1];
  }
}