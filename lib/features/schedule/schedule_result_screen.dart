import 'package:flutter/material.dart';
import 'package:syner_sched/localization/app_localizations.dart';
import 'package:syner_sched/shared/custom_nav_bar.dart';

class ScheduleResultScreen extends StatelessWidget {
  const ScheduleResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizer = AppLocalizations.of(context)!;

    final Map<String, List<String>> sampleSchedule = {
      "Monday": ["CSCI 6362 – 10:00 AM", "STAT 5300 – 1:30 PM"],
      "Wednesday": ["ENGL 3320 – 9:00 AM"],
      "Friday": ["MATH 2413 – 11:30 AM"],
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(localizer.translate("your_schedule")),
        backgroundColor: const Color(0xFF0277BD),
        foregroundColor: Colors.white,
      ),
      bottomNavigationBar: CustomNavBar(currentIndex: 1),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0277BD), Color(0xFF03A9F4)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: sampleSchedule.keys.length,
          itemBuilder: (context, index) {
            String day = sampleSchedule.keys.elementAt(index);
            List<String> sessions = sampleSchedule[day]!;

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: Colors.white.withValues(alpha: 0.95),
              child: ExpansionTile(
                title: Text(
                  day,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                children: sessions
                    .map(
                      (session) => ListTile(
                        leading: const Icon(Icons.class_),
                        title: Text(session),
                      ),
                    )
                    .toList(),
              ),
            );
          },
        ),
      ),
    );
  }
}
