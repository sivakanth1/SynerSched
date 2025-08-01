import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

class _ScheduleBuilderScreenState extends State<ScheduleBuilderScreen> {
  String _courseType = 'Required';
  List<String> _selectedCourses = ['COSC 5311 - Advanced Operating Systems'];
  TimeOfDay? _breakStart;
  TimeOfDay? _breakEnd;
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
    _loadPreferences();
    _checkSemesterChange();
  }

  Future<void> _checkSemesterChange() async {
    final prefs = await SharedPreferences.getInstance();
    final currentSemester = Utility.getCurrentSemesterId();
    final savedSemester = prefs.getString('lastSemesterId');

    if (savedSemester != currentSemester) {
      // Show dialog
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("New Semester Detected"),
          content: Text("It's now $currentSemester. Would you like to build a new schedule?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Later"),
            ),
            ElevatedButton(
              onPressed: () {
                prefs.setString('lastSemesterId', currentSemester);
                Navigator.pop(ctx);
                Navigator.pushReplacementNamed(context, AppRoutes.scheduleBuilder);
              },
              child: const Text("Yes, Build"),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _courseType = prefs.getString('courseType') ?? 'Required';
      _selectedCourses = prefs.getStringList('selectedCourses') ?? ['COSC 5311 - Advanced Operating Systems'];
      _preferredTime = prefs.getString('preferredTime') ?? 'morning';
      _workloadLevel = prefs.getString('workloadLevel') ?? 'medium';
    });
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('courseType', _courseType);
    await prefs.setStringList('selectedCourses', _selectedCourses);
    await prefs.setString('preferredTime', _preferredTime);
    await prefs.setString('workloadLevel', _workloadLevel);
    await prefs.setString('lastSemesterId', Utility.getCurrentSemesterId());
  }

  Future<void> _pickTime({required bool isStart}) async {
    final picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null) {
      setState(() {
        isStart ? _breakStart = picked : _breakEnd = picked;
      });
    }
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return '--';
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final suffix = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:${time.minute.toString().padLeft(2, '0')} $suffix';
  }

  void _addCourseField() {
    if (_selectedCourses.length < 6) {
      setState(() {
        _selectedCourses.add(courses.first);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.translate("max_course_limit"))),
      );
    }
  }

  void _removeCourseField(int index) {
    setState(() {
      _selectedCourses.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizer = AppLocalizations.of(context)!;

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
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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

                Text(localizer.translate("select_courses"), style: const TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                ..._selectedCourses.asMap().entries.map((entry) {
                  final index = entry.key;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Expanded(child: _buildCourseDropdown(index)),
                        if (_selectedCourses.length > 1)
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeCourseField(index),
                          ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 4),
                TextButton.icon(
                  onPressed: _addCourseField,
                  icon: const Icon(Icons.add),
                  label: Text(localizer.translate("add_course")),
                ),
                const SizedBox(height: 24),

                Text(localizer.translate("break_time_range"), style: const TextStyle(fontWeight: FontWeight.w500)),
                Row(children: [
                  _buildTimePicker(localizer.translate("start_time"), _breakStart, () => _pickTime(isStart: true)),
                  const SizedBox(width: 16),
                  _buildTimePicker(localizer.translate("end_time"), _breakEnd, () => _pickTime(isStart: false)),
                ]),
                const SizedBox(height: 24),

                Text(localizer.translate("preferred_study_time"), style: const TextStyle(fontWeight: FontWeight.w500)),
                _buildDropdown(value: _preferredTime, items: ['morning', 'afternoon', 'evening'], onChanged: (v) => setState(() => _preferredTime = v!)),
                const SizedBox(height: 24),

                Text(localizer.translate("workload_preference"), style: const TextStyle(fontWeight: FontWeight.w500)),
                _buildDropdown(value: _workloadLevel, items: ['light', 'medium', 'intense'], onChanged: (v) => setState(() => _workloadLevel = v!)),
                const SizedBox(height: 40),

                Center(
                  child: buildCustomButton(
                    context,
                        () async {
                      await _savePreferences();
                      await ScheduleService.saveSchedule({
                        'courseType': _courseType,
                        'selectedCourses': [_selectedCourses],
                        'preferredTime': _preferredTime,
                        'workloadLevel': _workloadLevel,
                        'breakStart': _breakStart != null ? _breakStart!.format(context) : '',
                        'breakEnd': _breakEnd != null ? _breakEnd!.format(context) : '',
                        'createdAt': DateTime.now().toIso8601String(),
                      });
                      Navigator.pushReplacementNamed(context, AppRoutes.scheduleResult);
                    },
                    const Icon(Icons.schedule),
                    Text(localizer.translate("generate_schedule"),
                        style: const TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }

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
          child: Text(label,
              style: TextStyle(
                  color: selected ? Colors.black : Colors.grey.shade700, fontWeight: FontWeight.w500)),
        ),
      ),
    );
  }

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

  Widget _buildCourseDropdown(int index) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: DropdownButton<String>(
        value: _selectedCourses[index],
        icon: const Icon(Icons.keyboard_arrow_down),
        isExpanded: true,
        underline: const SizedBox(),
        onChanged: (value) {
          if (value != null) {
            setState(() => _selectedCourses[index] = value);
          }
        },
        items: courses.map((course) {
          return DropdownMenuItem(value: course, child: Text(course));
        }).toList(),
      ),
    );
  }
}