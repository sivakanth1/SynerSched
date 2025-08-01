import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syner_sched/shared/custom_button.dart';
import 'dart:convert';
import '../../../shared/custom_app_bar.dart';
import '../../../shared/custom_nav_bar.dart';
import '../../../localization/app_localizations.dart';

class CourseSelectionScreen extends StatefulWidget {
  const CourseSelectionScreen({super.key});

  @override
  State<CourseSelectionScreen> createState() => _CourseSelectionScreenState();
}

class _CourseSelectionScreenState extends State<CourseSelectionScreen> {
  final List<String> courses = [
    'COSC 5311 - Advanced Operating Systems',
    'COSC 5360 - Parallel Computing',
    'COSC 5321 - Database Systems',
    'COSC 5340 - Computer Networks',
    'COSC 5315 - Software Engineering',
  ];

  Map<String, bool> selectedCourses = {};
  String selectedType = 'Required';
  String preferredTime = 'Morning';
  String workloadLevel = 'Medium';

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final coursesJson = prefs.getString('selectedCourses');
    if (coursesJson != null) {
      selectedCourses = Map<String, bool>.from(jsonDecode(coursesJson));
    } else {
      for (var course in courses) {
        selectedCourses[course] = false;
      }
    }

    setState(() {
      selectedType = prefs.getString('courseType') ?? 'Required';
      preferredTime = prefs.getString('preferredTime') ?? 'Morning';
      workloadLevel = prefs.getString('workloadLevel') ?? 'Medium';
    });
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedCourses', jsonEncode(selectedCourses));
    await prefs.setString('courseType', selectedType);
    await prefs.setString('preferredTime', preferredTime);
    await prefs.setString('workloadLevel', workloadLevel);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.translate('preferences_saved'))),
    );
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
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: Text(localizer.translate('course_selection')),centerTitle: true,backgroundColor: Colors.transparent,),
        bottomNavigationBar: const CustomNavBar(currentIndex: 0),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(16.0,16,16,0),
          child: ListView(
            children: [
              Text(
                localizer.translate('select_courses'),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ...courses.map((course) {
                return CheckboxListTile(
                  title: Text(course),
                  value: selectedCourses[course] ?? false,
                  onChanged: (bool? value) {
                    setState(() {
                      selectedCourses[course] = value ?? false;
                    });
                  },
                );
              }).toList(),

              const SizedBox(height: 20),
              Text(
                localizer.translate('course_type'),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              DropdownButton<String>(
                value: selectedType,
                items: ['Required', 'Elective'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(localizer.translate(value.toLowerCase())),
                  );
                }).toList(),
                onChanged: (newVal) {
                  setState(() {
                    selectedType = newVal!;
                  });
                },
              ),

              const SizedBox(height: 20),
              Text(
                localizer.translate('preferred_study_time'),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              DropdownButton<String>(
                value: preferredTime,
                items: ['Morning', 'Afternoon', 'Evening'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(localizer.translate(value.toLowerCase())),
                  );
                }).toList(),
                onChanged: (newVal) {
                  setState(() {
                    preferredTime = newVal!;
                  });
                },
              ),

              const SizedBox(height: 20),
              Text(
                localizer.translate('workload_preference'),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              DropdownButton<String>(
                value: workloadLevel,
                items: ['Light', 'Medium', 'Intense'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(localizer.translate(value.toLowerCase())),
                  );
                }).toList(),
                onChanged: (newVal) {
                  setState(() {
                    workloadLevel = newVal!;
                  });
                },
              ),

              const SizedBox(height: 15),
              buildCustomButton(context, _savePreferences, Icon(Icons.schedule_rounded), Text(localizer.translate('save_continue')))
            ],
          ),
        ),
      ),
    );
  }
}