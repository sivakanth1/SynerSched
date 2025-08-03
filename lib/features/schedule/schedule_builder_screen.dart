import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:syner_sched/localization/app_localizations.dart';
import 'package:syner_sched/routes/app_routes.dart';
import 'package:syner_sched/shared/custom_button.dart';
import 'package:syner_sched/shared/custom_nav_bar.dart';
import 'package:syner_sched/shared/utils.dart';
import '../../firebase/schedule_service.dart';

class ScheduleBuilderScreen extends StatefulWidget {
  const ScheduleBuilderScreen({super.key});

  @override
  State<ScheduleBuilderScreen> createState() => _ScheduleBuilderScreenState();
}

/// This stateful widget manages the schedule builder screen, allowing users
/// to select courses, set preferred study and break times, and configure
/// preferences for building their semester schedule.
class _ScheduleBuilderScreenState extends State<ScheduleBuilderScreen> {
  String _courseType = 'Required';
  List<Map<String, dynamic>> _selectedCourses = [
    {
      'courseName': 'COSC 5311 - Advanced Operating Systems',
      'startTime': '',
      'endTime': '',
      'days': <String>[]
    }
  ];
  List<Map<String, TimeOfDay?>> _breaks = [];
  String _preferredTime = 'morning';
  String _workloadLevel = 'medium';

  final List<String> courses = [
    'COSC 5311 - Advanced Operating Systems',
    'COSC 5360 - Parallel Computing',
    'COSC 5321 - Database Systems',
    'COSC 5340 - Computer Networks',
    'COSC 5315 - Software Engineering',
    'COSC 5390 - Advanced Algorithms',
  ];

  @override
  void initState() {
    super.initState();
    // Load user preferences and check if a new semester schedule needs to be built
    _loadPreferences();
    _checkSemesterChange();
  }

  /// Checks if the semester has changed or if a new schedule is needed.
  /// If a new semester is detected and no schedule exists for it,
  /// prompts the user to build a new schedule.
  /// Returns true if a new schedule is required for the current semester.
  Future<bool> _checkSemesterChange() async {
    final prefs = await SharedPreferences.getInstance();
    final currentSemester = Utility.getCurrentSemesterId();
    final savedSemester = prefs.getString('lastSemesterId');
    final user = FirebaseAuth.instance.currentUser!;

    if (savedSemester != currentSemester) {
      final scheduleSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('schedules')
          .doc(currentSemester)
          .get();

      if (!scheduleSnapshot.exists) {
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.translate("new_semester_detected")),
            content: Text(AppLocalizations.of(context)!.translateWithArgs("new_semester_content", [currentSemester])),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(AppLocalizations.of(context)!.translate("later")),
              ),
              ElevatedButton(
                onPressed: () {
                  prefs.setString('lastSemesterId', currentSemester);
                  Navigator.pop(ctx);
                  // Don’t push to scheduleBuilder again, just continue on current screen
                },
                child: Text(AppLocalizations.of(context)!.translate("yes_build")),
              ),
            ],
          ),
        );
        return true;
      } else {
        // Save current semester in prefs without prompting
        prefs.setString('lastSemesterId', currentSemester);
        return false;
      }
    }
    return false;
  }

  /// Loads saved user preferences (course type, selected courses, preferred time, workload level)
  /// from local storage and updates the state accordingly.
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _courseType = prefs.getString('courseType') ?? 'Required';
      final savedCourses = prefs.getStringList('selectedCourses');
      if (savedCourses != null && savedCourses.isNotEmpty) {
        _selectedCourses = savedCourses
            .map((name) => {
                  'courseName': name,
                  'startTime': '',
                  'endTime': '',
                  'days': <String>[], // Explicitly List<String>
                })
            .toList();
      }
      _preferredTime = prefs.getString('preferredTime') ?? 'morning';
      _workloadLevel = prefs.getString('workloadLevel') ?? 'medium';
      // _breaks persistence can be added here later
    });
  }

  /// Saves the current user preferences (course type, selected courses, preferred time, workload level)
  /// to local storage for persistence between sessions.
  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('courseType', _courseType);
    // Save course names only for backward compatibility
    await prefs.setStringList('selectedCourses',
        _selectedCourses.map((e) => e['courseName']?.toString() ?? '').toList());
    await prefs.setString('preferredTime', _preferredTime);
    await prefs.setString('workloadLevel', _workloadLevel);
    await prefs.setString('lastSemesterId', Utility.getCurrentSemesterId());
    // _breaks persistence can be added here later
  }
  /// Builds a set of day-of-week checkboxes (FilterChips) for a course at the given index.
  /// Allows the user to select which days the course occurs on.
  Widget _buildDayCheckboxes(int index) {
    final List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return Wrap(
      spacing: 8,
      children: days.map((day) {
        final isSelected = (_selectedCourses[index]['days'] as List<String>).contains(day);
        return FilterChip(
          label: Text(day),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              final List<String> courseDays = _selectedCourses[index]['days'] as List<String>;
              if (selected) {
                if (!courseDays.contains(day)) {
                  courseDays.add(day);
                }
              } else {
                courseDays.remove(day);
              }
              _selectedCourses[index]['days'] = courseDays;
            });
          },
        );
      }).toList(),
    );
  }

  /// Shows a time picker dialog for selecting a break's start or end time.
  /// Updates the break time at the specified index in the _breaks list.
  Future<void> _pickBreakTime(int index, {required bool isStart}) async {
    final picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null) {
      setState(() {
        _breaks[index][isStart ? 'start' : 'end'] = picked;
      });
    }
  }

  /// Formats a TimeOfDay object to a readable string (e.g., '2:30 PM').
  String _formatTime(TimeOfDay? time) {
    if (time == null) return '--';
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final suffix = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:${time.minute.toString().padLeft(2, '0')} $suffix';
  }

  /// Adds a new course selection field to the list, up to a maximum of 6.
  /// If the limit is reached, shows a message to the user.
  void _addCourseField() {
    if (_selectedCourses.length < 6) {
      setState(() {
        _selectedCourses.add({
          'courseName': courses.first,
          'startTime': '',
          'endTime': '',
          'days': <String>[]
        });
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.translate("max_course_limit"))),
      );
    }
  }

  /// Removes the course selection field at the given index from the list.
  void _removeCourseField(int index) {
    setState(() {
      _selectedCourses.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizer = AppLocalizations.of(context)!;

    // Main UI container with background image and scaffold
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/app_background.jpg"),
          fit: BoxFit.fill,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(localizer.translate("build_schedule"),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2D4F48))),
          centerTitle: true,
          backgroundColor: Colors.transparent,
        ),
        backgroundColor: Colors.transparent,
        bottomNavigationBar: const CustomNavBar(currentIndex: 1),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section: Course type selection
                  Text(localizer.translate("course_type"), style: const TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildChoiceChip(localizer.translate("required")),
                      const SizedBox(width: 12),
                      _buildChoiceChip(localizer.translate("elective")),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Section: Course selection and configuration
                  Text(localizer.translate("select_courses"), style: const TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  ..._selectedCourses.asMap().entries.map((entry) {
                    final index = entry.key;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Column(
                        children: [
                          // Dropdown for course selection and delete button
                          Row(
                            children: [
                              Expanded(child: _buildCourseDropdown(index)),
                              if (_selectedCourses.length > 1)
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _removeCourseField(index),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Time pickers for course start and end time
                          _buildTimePickersForCourse(index),
                          const SizedBox(height: 8),
                          // Day checkboxes for course meeting days
                          _buildDayCheckboxes(index),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 4),
                  // Button to add a new course field
                  TextButton.icon(
                    onPressed: _addCourseField,
                    icon: const Icon(Icons.add),
                    label: Text(localizer.translate("add_course")),
                  ),
                  const SizedBox(height: 24),

                  // Section: Break entry (start and end times for breaks)
                  Text(localizer.translate("break_time_range"), style: const TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  Column(
                    children: [
                      ..._breaks.asMap().entries.map((entry) {
                        int index = entry.key;
                        TimeOfDay? start = entry.value['start'];
                        TimeOfDay? end = entry.value['end'];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              // Time picker for break start
                              _buildTimePicker(localizer.translate("start_time"), start, () => _pickBreakTime(index, isStart: true)),
                              const SizedBox(width: 12),
                              // Time picker for break end
                              _buildTimePicker(localizer.translate("end_time"), end, () => _pickBreakTime(index, isStart: false)),
                              // Delete button for the break
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    _breaks.removeAt(index);
                                  });
                                },
                              )
                            ],
                          ),
                        );
                      }),
                      // Button to add a new break time range
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _breaks.add({'start': null, 'end': null});
                          });
                        },
                        icon: const Icon(Icons.add),
                        label: Text(localizer.translate("add_break")),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Section: Preferred study time selection
                  Text(localizer.translate("preferred_study_time"), style: const TextStyle(fontWeight: FontWeight.w500)),
                  _buildDropdown(
                    value: _preferredTime,
                    items: ['morning', 'afternoon', 'evening'],
                    onChanged: (v) => setState(() => _preferredTime = v!),
                  ),
                  const SizedBox(height: 24),

                  // Section: Workload preference selection
                  Text(localizer.translate("workload_preference"), style: const TextStyle(fontWeight: FontWeight.w500)),
                  _buildDropdown(
                    value: _workloadLevel,
                    items: ['light', 'medium', 'intense'],
                    onChanged: (v) => setState(() => _workloadLevel = v!),
                  ),
                  const SizedBox(height: 40),

                  // Section: Generate schedule button
                  Center(
                    child: buildCustomButton(
                      context,
                      () async {
                        // Validate that all selected courses have both start and end times filled
                        bool hasMissingTimes = _selectedCourses.any((course) =>
                            (course['startTime']?.isEmpty ?? true) || (course['endTime']?.isEmpty ?? true));
                        if (hasMissingTimes) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(AppLocalizations.of(context)!.translate("please_fill_all_course_times"))),
                          );
                          return;
                        }

                        // Validate that all breaks have both start and end times filled
                        bool hasIncompleteBreaks = _breaks.any((b) =>
                            (b['start'] == null) || (b['end'] == null));
                        if (hasIncompleteBreaks) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(AppLocalizations.of(context)!.translate("please_fill_all_break_times"))),
                          );
                          return;
                        }

                        // Save the schedule data to Firestore and navigate to the result page
                        await ScheduleService.saveSchedule({
                          'courseType': _courseType,
                          'selectedCourses': _selectedCourses.map((course) => {
                            'courseName': course['courseName'],
                            'startTime': course['startTime'],
                            'endTime': course['endTime'],
                            'days': List<String>.from(course['days'] ?? <String>[]),
                          }).toList(),
                          'preferredTime': _preferredTime,
                          'workloadLevel': _workloadLevel,
                          'breaks': _breaks.map((b) => {
                            'start': b['start']?.format(context) ?? '',
                            'end': b['end']?.format(context) ?? ''
                          }).toList(),
                          'createdAt': DateTime.now().toIso8601String(),
                        });
                        Navigator.pushReplacementNamed(context, AppRoutes.scheduleResult);
                      },
                      const Icon(Icons.schedule),
                      Text(
                        localizer.translate("generate_schedule"),
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  /// Builds a selectable chip (Required/Elective) for course type selection.
  /// Highlights the selected chip and updates the course type state.
  Widget _buildChoiceChip(String label) {
    final selected = _courseType.toLowerCase() == label.toLowerCase();
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _courseType = label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFB7D0EC) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: selected ? const Color(0xFFB7D0EC) : const Color(0xFFBFD6E2)),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.black : Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  /// Builds a time picker widget for selecting a time value (used for breaks).
  /// Displays the current value or a label if not set.
  Widget _buildTimePicker(String label, TimeOfDay? time, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
          alignment: Alignment.centerLeft,
          child: Text(
            time == null ? label : _formatTime(time),
            style: TextStyle(fontSize: 15, color: time == null ? Colors.grey : Colors.black),
          ),
        ),
      ),
    );
  }

  /// Builds a dropdown menu for selecting a value from a list of options.
  /// Used for preferred study time and workload level selection.
  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    final localizer = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: DropdownButton<String>(
        value: value,
        icon: const Icon(Icons.keyboard_arrow_down),
        isExpanded: true,
        underline: const SizedBox(),
        onChanged: onChanged,
        items: items.map((item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(localizer.translate(item)),
          );
        }).toList(),
      ),
    );
  }

  /// Builds a dropdown menu for selecting a course from the available courses list.
  /// Used for each course field in the schedule builder.
  Widget _buildCourseDropdown(int index) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: DropdownButton<String>(
        value: _selectedCourses[index]['courseName'],
        icon: const Icon(Icons.keyboard_arrow_down),
        isExpanded: true,
        underline: const SizedBox(),
        onChanged: (value) {
          if (value != null) {
            setState(() => _selectedCourses[index]['courseName'] = value);
          }
        },
        items: courses.map((course) {
          return DropdownMenuItem(value: course, child: Text(course));
        }).toList(),
      ),
    );
  }

  /// Builds a row of two time pickers for selecting the start and end times of a course.
  /// Used for each course in the schedule builder.
  Widget _buildTimePickersForCourse(int index) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () async {
              final picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
              if (picked != null) {
                setState(() {
                  _selectedCourses[index]['startTime'] = picked.format(context);
                });
              }
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child: Text(_selectedCourses[index]['startTime']!.isEmpty
                  ? AppLocalizations.of(context)!.translate("start_time")
                  : _selectedCourses[index]['startTime']!),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: GestureDetector(
            onTap: () async {
              final picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
              if (picked != null) {
                setState(() {
                  _selectedCourses[index]['endTime'] = picked.format(context);
                });
              }
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child: Text(_selectedCourses[index]['endTime']!.isEmpty
                  ? AppLocalizations.of(context)!.translate("end_time")
                  : _selectedCourses[index]['endTime']!),
            ),
          ),
        ),
      ],
    );
  }
}