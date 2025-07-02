import 'package:flutter/material.dart';
import 'package:syner_sched/localization/app_localizations.dart';
import 'package:syner_sched/routes/app_routes.dart';
import 'package:syner_sched/shared/custom_nav_bar.dart';

class ScheduleBuilderScreen extends StatefulWidget {
  const ScheduleBuilderScreen({super.key});

  @override
  State<ScheduleBuilderScreen> createState() => _ScheduleBuilderScreenState();
}

class _ScheduleBuilderScreenState extends State<ScheduleBuilderScreen> {
  String selectedType = 'Required';
  String selectedCourse = 'CSCI 6362';
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  final List<String> courses = [
    'CSCI 6362',
    'STAT 5300',
    'ENGL 3320',
    'MATH 2413',
    'HIST 1301',
  ];

  @override
  Widget build(BuildContext context) {
    final localizer = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizer.translate("build_schedule")),
        backgroundColor: const Color(0xFF0277BD),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      bottomNavigationBar: CustomNavBar(currentIndex: 1, onTap: (index) {}),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0277BD), Color(0xFF03A9F4)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Course Type Toggle Card
            _buildSectionCard(
              title: localizer.translate("course_type"),
              child: ToggleButtons(
                isSelected: [
                  selectedType == 'Required',
                  selectedType == 'Elective',
                ],
                onPressed: (index) {
                  setState(() {
                    selectedType = index == 0 ? 'Required' : 'Elective';
                  });
                },
                borderRadius: BorderRadius.circular(12),
                selectedColor: Colors.white,
                color: Colors.black,
                fillColor: Colors.blue.shade700,
                constraints: const BoxConstraints(minHeight: 45, minWidth: 110),
                children: const [Text('Required'), Text('Elective')],
              ),
            ),

            const SizedBox(height: 20),

            // Course Dropdown
            _buildSectionCard(
              title: localizer.translate("select_course"),
              child: DropdownButtonFormField<String>(
                value: selectedCourse,
                dropdownColor: Colors.white,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: courses.map((course) {
                  return DropdownMenuItem(value: course, child: Text(course));
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => selectedCourse = val);
                  }
                },
              ),
            ),

            const SizedBox(height: 20),

            // Preferred Time Range
            _buildSectionCard(
              title: localizer.translate("preferred_time"),
              child: Column(
                children: [
                  _buildTimePicker("Start Time", startTime, (picked) {
                    setState(() => startTime = picked);
                  }),
                  const SizedBox(height: 10),
                  _buildTimePicker("End Time", endTime, (picked) {
                    setState(() => endTime = picked);
                  }),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Generate Button
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.scheduleResult);
                },
                icon: const Icon(Icons.auto_mode),
                label: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(localizer.translate("generate_schedule")),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  foregroundColor: Colors.white,
                  elevation: 6,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker(
    String label,
    TimeOfDay? value,
    Function(TimeOfDay) onPicked,
  ) {
    return GestureDetector(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );
        if (picked != null) {
          onPicked(picked);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade400),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 14)),
            Text(
              value != null ? value.format(context) : "--:--",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
