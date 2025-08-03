import 'package:flutter/material.dart';
import '../../firebase/schedule_service.dart';
import '../../firebase/smart_scheduler.dart';
import '../../firebase/task_service.dart';
import '../../localization/app_localizations.dart';
import '../../shared/custom_nav_bar.dart';

class ScheduleResultScreen extends StatefulWidget {
  const ScheduleResultScreen({super.key});

  @override
  State<ScheduleResultScreen> createState() => _ScheduleResultScreenState();
}

class _ScheduleResultScreenState extends State<ScheduleResultScreen> {
  late String _selectedDay;
  List<Map<String, dynamic>> weeklySlots = [];

  @override
  void initState() {
    super.initState();
    _selectedDay = '';
    _loadAndGenerateSchedule();
  }

  /// Loads the schedule data from Firestore, generates a weekly time grid based on user preferences,
  /// marks the grid with courses, breaks, and tasks, and updates the state with the prepared slots.
  Future<void> _loadAndGenerateSchedule() async {
    final schedule = await ScheduleService.getSchedules() as Map<String, dynamic>?;
    if (schedule == null) return;

    final preferredTime = schedule['preferredTime'] ?? 'morning';
    final workloadLevel = schedule['workloadLevel'] ?? 'medium';

    final generated = SmartScheduler.generateGridWithPreferences(
      preferredTime: preferredTime,
      workloadLevel: workloadLevel,
    );

    final rawCourses = List<Map<String, dynamic>>.from(schedule['selectedCourses'] ?? []);
    final List<Map<String, dynamic>> flattenedCourses = [];
    for (var course in rawCourses) {
      final originalDays = List<String>.from(course['days'] ?? []);
      final shortDays = originalDays.map((d) => _shortDayNameFromLong(d)).toList();
      for (var shortDay in shortDays) {
        flattenedCourses.add({
          ...course,
          'days': [shortDay],
          'startTime': _convertToIsoTime(course['startTime'], shortDay),
          'endTime': _convertToIsoTime(course['endTime'], shortDay),
        });
      }
    }

    final breaks = List<Map<String, dynamic>>.from(schedule['breaks'] ?? []);
    final mockTasks = [
      {
        'title': 'Test Task',
        'deadline': DateTime.now().add(Duration(minutes: 30)).toIso8601String(),
      }
    ];

    final marked = SmartScheduler.allocateTasks(
      weeklyGrid: SmartScheduler.markScheduleWithCoursesAndBreaks(
        grid: generated,
        courses: flattenedCourses,
        breaks: breaks,
      ),
      tasks: mockTasks,
    );

    final tasks = await TaskService.getTasks();

    final taskMarked = SmartScheduler.allocateTasks(weeklyGrid: marked, tasks: tasks);

    final now = DateTime.now();
    final filtered = taskMarked.where((slot) {
      final end = DateTime.tryParse(slot['end'] ?? '');
      return end == null || end.isAfter(now); // keep only future or ongoing slots
    }).toList();

    setState(() {
      weeklySlots = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This widget builds the UI for selecting a day of the week and viewing the schedule slots for that day.
    // It displays the current week, allows day selection, and shows tasks, classes, and breaks in a list.
    final localizer = AppLocalizations.of(context)!;
    final today = DateTime.now();
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    final weekDates = List.generate(7, (i) => startOfWeek.add(Duration(days: i)));

    if (_selectedDay.isEmpty) {
      _selectedDay = _shortDayName(context, DateTime.now());
    }

    final daySlots = _combineConsecutiveSlots(
      weeklySlots.where((slot) => slot['day'] == _selectedDay && slot['type'] != 'free').toList()
        ..sort((a, b) => a['start'].compareTo(b['start'])),
    );

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/app_background.jpg"),
          fit: BoxFit.fill,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            localizer.translate("your_weekly_schedule"),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D4F48),
            ),
          ),
        ),
        bottomNavigationBar: CustomNavBar(currentIndex: 1,),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, size: 18, color: Color(0xFF2D4F48)),
                    const SizedBox(width: 6),
                    Text(
                      "${today.day} ${_monthName(context, today.month)}",
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Color(0xFF2D4F48)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 75,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: weekDates.length,
                    itemBuilder: (context, index) {
                      final date = weekDates[index];
                      final shortDay = _shortDayName(context, date);
                      final isSelected = shortDay == _selectedDay;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedDay = shortDay),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF2D4F48) : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(shortDay, style: TextStyle(color: isSelected ? Colors.white : Colors.black)),
                              Text('${date.day}', style: TextStyle(color: isSelected ? Colors.white : Colors.black)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: daySlots.isEmpty
                      ? Center(child: Text(localizer.translate("no_schedule_for_day")))
                      : ListView.builder(
                    itemCount: daySlots.length,
                      itemBuilder: (context, index) {
                        final item = daySlots[index];

                        if (item['type'] == 'task') {
                          return Dismissible(
                            key: ValueKey(item['start']),
                            direction: DismissDirection.endToStart,
                            // Confirm dismissal with options to mark completed or delete the task
                            confirmDismiss: (_) async {
                              return await showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('Manage Task'),
                                  content: const Text('What do you want to do with this task?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () async {
                                        await TaskService.markTaskCompleted(item['start']);
                                        Navigator.of(context).pop(true);
                                      },
                                      child: const Text('Mark as Completed'),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        await TaskService.deleteTaskByStart(item['start']);
                                        Navigator.of(context).pop(true);
                                      },
                                      child: const Text('Delete'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(false),
                                      child: const Text('Cancel'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            background: Container(
                              alignment: Alignment.centerRight,
                              color: Colors.red,
                              padding: const EdgeInsets.only(right: 20),
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            child: _buildSlotCard(item), // ← wrap in helper
                          );
                        }

                        return _buildSlotCard(item); // Non-task items
                      }
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Merges adjacent schedule slots that have the same type and title into a single slot.
/// This helps to display continuous blocks of time as one item instead of multiple separate entries.
List<Map<String, dynamic>> _combineConsecutiveSlots(List<Map<String, dynamic>> slots) {
  if (slots.isEmpty) return [];

  final combined = <Map<String, dynamic>>[];
  var current = Map<String, dynamic>.from(slots[0]);

  for (int i = 1; i < slots.length; i++) {
    final next = slots[i];
    final currentEnd = DateTime.parse(current['end']);
    final nextStart = DateTime.parse(next['start']);

    final isSame = current['type'] == next['type'] && current['title'] == next['title'];
    final isAdjacent = currentEnd.isAtSameMomentAs(nextStart);

    if (isSame && isAdjacent) {
      // Extend the current slot's end time and update the displayed time range
      current['end'] = next['end'];
      current['time'] = '${current['time'].split(' - ').first} - ${next['time'].split(' - ').last}';
    } else {
      combined.add(current);
      current = Map<String, dynamic>.from(next);
    }
  }

  combined.add(current);
  return combined;
}

/// Builds a card widget representing a schedule slot (class, break, or task).
/// The card displays an icon, title, and time range with distinct colors for each slot type.
Widget _buildSlotCard(Map<String, dynamic> item) {
  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: item['type'] == 'break'
          ? Colors.orange.shade100
          : item['type'] == 'class'
          ? Colors.teal.shade100
          : Colors.greenAccent,
      borderRadius: BorderRadius.circular(18),
    ),
    child: Row(
      children: [
        Icon(
          // Choose icon based on slot type
          item['type'] == 'break'
              ? Icons.local_cafe
              : item['type'] == 'class'
              ? Icons.school_rounded
              : Icons.task_alt_rounded,
          color: const Color(0xFF2D4F48),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display the title of the slot (e.g., class name, break name, task title)
              Text(item['title'],
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D4F48))),
              // Display the time range of the slot
              Text(item['time'], style: const TextStyle(color: Colors.black87)),
            ],
          ),
        ),
      ],
    ),
  );
}

/// Returns the localized short day name (e.g., Mon, Tue) for a given date.
String _shortDayName(BuildContext context, DateTime date) {
  final localizer = AppLocalizations.of(context)!;
  return [
    localizer.translate("mon"),
    localizer.translate("tue"),
    localizer.translate("wed"),
    localizer.translate("thu"),
    localizer.translate("fri"),
    localizer.translate("sat"),
    localizer.translate("sun")
  ][date.weekday - 1];
}

/// Returns the localized month name for a given month number (1-12).
String _monthName(BuildContext context, int month) {
  final localizer = AppLocalizations.of(context)!;
  return [
    localizer.translate("january"),
    localizer.translate("february"),
    localizer.translate("march"),
    localizer.translate("april"),
    localizer.translate("may"),
    localizer.translate("june"),
    localizer.translate("july"),
    localizer.translate("august"),
    localizer.translate("september"),
    localizer.translate("october"),
    localizer.translate("november"),
    localizer.translate("december")
  ][month - 1];
}

/// Converts a full day name (e.g., Monday) to its short form (e.g., Mon).
String _shortDayNameFromLong(String longDay) {
  switch (longDay.toLowerCase()) {
    case 'monday':
      return 'Mon';
    case 'tuesday':
      return 'Tue';
    case 'wednesday':
      return 'Wed';
    case 'thursday':
      return 'Thu';
    case 'friday':
      return 'Fri';
    case 'saturday':
      return 'Sat';
    case 'sunday':
      return 'Sun';
    default:
      return longDay;
  }
}

/// Converts a time string (e.g., "10:30 AM") and a short day name (e.g., "Mon") to an ISO8601 datetime string.
/// This helps to assign exact timestamps to schedule slots relative to the current week.
String _convertToIsoTime(String? timeStr, String shortDay) {
  if (timeStr == null) return '';
  try {
    final now = DateTime.now();
    final dayIndex = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'].indexOf(shortDay);
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final slotDate = monday.add(Duration(days: dayIndex));

    final hour = int.parse(timeStr.split(':')[0]) + (timeStr.contains('PM') && !timeStr.contains('12') ? 12 : 0);
    final minute = int.parse(timeStr.split(':')[1].split(' ')[0]);

    final dt = DateTime(slotDate.year, slotDate.month, slotDate.day, hour, minute);
    return dt.toIso8601String();
  } catch (_) {
    return '';
  }
}