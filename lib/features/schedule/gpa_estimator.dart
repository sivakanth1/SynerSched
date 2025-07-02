import 'package:flutter/material.dart';
import 'package:syner_sched/localization/app_localizations.dart';
import 'package:syner_sched/shared/custom_nav_bar.dart';

class GPAEstimatorScreen extends StatefulWidget {
  const GPAEstimatorScreen({super.key});

  @override
  State<GPAEstimatorScreen> createState() => _GPAEstimatorScreenState();
}

class _GPAEstimatorScreenState extends State<GPAEstimatorScreen> {
  final _cgpaController = TextEditingController();
  final _creditsController = TextEditingController();

  final List<Map<String, dynamic>> courses = [
    {'name': 'Course 1', 'grade': 'A'},
    {'name': 'Course 2', 'grade': 'B+'},
  ];

  final List<String> grades = ['A', 'A-', 'B+', 'B', 'B-', 'C+', 'C'];

  double? newCGPA;

  @override
  Widget build(BuildContext context) {
    final localizer = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizer.translate('gpa_estimator')),
        backgroundColor: const Color(0xFF0277BD),
        foregroundColor: Colors.white,
      ),
      bottomNavigationBar: CustomNavBar(currentIndex: 1, onTap: (index) {}),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _cgpaController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: localizer.translate('current_cgpa'),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _creditsController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: localizer.translate('completed_credits'),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // Upcoming course grades
            Text(localizer.translate("expected_grades")),
            ...courses.asMap().entries.map((entry) {
              int index = entry.key;
              var course = entry.value;
              return Row(
                children: [
                  Expanded(child: Text(course['name'])),
                  const SizedBox(width: 8),
                  DropdownButton<String>(
                    value: course['grade'],
                    items: grades
                        .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          course['grade'] = val;
                        });
                      }
                    },
                  ),
                ],
              );
            }),

            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _calculateCGPA,
              icon: const Icon(Icons.calculate),
              label: Text(localizer.translate("calculate")),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
              ),
            ),
            const SizedBox(height: 20),
            if (newCGPA != null)
              Text(
                "${localizer.translate("estimated_cgpa")}: ${newCGPA!.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _calculateCGPA() {
    try {
      double currentCGPA = double.parse(_cgpaController.text);
      int completedCredits = int.parse(_creditsController.text);
      int upcomingCredits = courses.length * 3;

      double currentPoints = currentCGPA * completedCredits;
      double upcomingPoints = courses.fold(0.0, (sum, course) {
        return sum + _gradeToPoint(course['grade']) * 3;
      });

      double newCGPA =
          (currentPoints + upcomingPoints) /
          (completedCredits + upcomingCredits);

      setState(() {
        this.newCGPA = newCGPA;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill valid inputs")));
    }
  }

  double _gradeToPoint(String grade) {
    switch (grade) {
      case 'A':
        return 4.0;
      case 'A-':
        return 3.7;
      case 'B+':
        return 3.3;
      case 'B':
        return 3.0;
      case 'B-':
        return 2.7;
      case 'C+':
        return 2.3;
      case 'C':
        return 2.0;
      default:
        return 0.0;
    }
  }
}
