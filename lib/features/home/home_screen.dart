import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syner_sched/localization/app_localizations.dart';
import 'package:syner_sched/routes/app_routes.dart';
import 'package:syner_sched/shared/custom_app_bar.dart';
import 'package:syner_sched/shared/custom_nav_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Map<String, dynamic>> _tasks = [
    {'title': 'Test', 'datetime': DateTime(2025, 6, 18)},
    {'title': 'Assignment 1', 'datetime': DateTime(2025, 6, 20)},
    {'title': 'Project Proposal', 'datetime': DateTime(2025, 6, 24)},
  ];
  final List<String> _scheduleItems = [
    "CSCI 6362 – 10:00 AM",
    "STAT 5300 – 1:30 PM",
  ];
  final List<String> _collabData = [
    "Machine Learning Capstone – 3 new messages",
    "UX Research Group – Meeting on Friday",
  ];

  @override
  Widget build(BuildContext context) {
    final localizer = AppLocalizations.of(context)!;

    _tasks.sort((a, b) => a['datetime'].compareTo(b['datetime']));

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/app_background.jpg"),
          fit: BoxFit.fill,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: CustomAppBar(
          actions: [
            Column(
              children: [
                SizedBox(height: 10),
                Text(
                  localizer.translate("welcome"),
                  style: TextStyle(color: Color(0xFF2D4F48)),
                ),
                Text('Siva 👋', style: TextStyle(color: Color(0xFF2D4F48))),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.notifications);
              },
              color: Color(0xFF2D4F48),
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.settings);
              },
              color: Color(0xFF2D4F48),
            ),
          ],
        ),
        bottomNavigationBar: CustomNavBar(currentIndex: 0, onTap: (index) {}),

        //Add Task Button
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showAddTaskDialog(context),
          icon: const Icon(Icons.add),
          label: const Text("Add Task"),
          backgroundColor: Color(0xFF5579f1),
          foregroundColor: Colors.white,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

        //Home Screen Contents
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    // Todo Navigate screen to Deadlines page
                  },
                  child: _buildUpcomingDeadlines(localizer),
                ),
                const SizedBox(height: 30),

                // My Schedule with Build Button
                GestureDetector(
                  onTap: () {
                    // Todo Navigate screen to MySchedules page
                  },
                  child: _buildMyScheduleCard(localizer),
                ),
                const SizedBox(height: 30),

                // Collaboration Highlights Card
                GestureDetector(
                  onTap: () {
                    // Todo Navigate screen to Collab page
                  },
                  child: _buildCollaborationCard(localizer),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMyScheduleCard(AppLocalizations localizer) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 24,
                backgroundColor: Color(0xFFFF6E5B),
                child: Icon(Icons.schedule_rounded, color: Colors.white),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizer.translate("my_schedule"),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF2D4F48),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "Build My Schedule",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._scheduleItems.map((item) {
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.check_circle_outline,
                color: Color(0xFF2D4F48),
              ),
              title: Text(
                item,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildUpcomingDeadlines(AppLocalizations localizer) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 24,
                backgroundColor: Color(0xFFFF6E5A),
                child: Icon(Icons.calendar_month, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizer.translate("upcoming_deadlines"),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Text("Welcome"),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF2D4F48),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "Open",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._tasks.map((task) {
            final formatted = DateFormat(
              'MMM dd, hh:mm a',
            ).format(task['datetime']);
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.calendar_today_outlined,
                color: Color(0xFF2D4F48),
              ),
              title: Text(
                task['title'],
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(formatted),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildCollaborationCard(AppLocalizations localizer) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 24,
                backgroundColor: Color(0xFFFF6E5B),
                child: Icon(Icons.diversity_3_rounded, color: Colors.white),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizer.translate("collab_highlights"),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._collabData.map((item) {
            return ListTile(
              contentPadding: EdgeInsets.zero,
              // leading: const Icon(
              //   Icons.check_circle_outline,
              //   color: Color(0xFF2D4F48),
              // ),
              title: Text(
                item,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    final _titleController = TextEditingController();
    DateTime? selectedDate;
    TimeOfDay? selectedTime;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: const Text("Add New Task"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: "Task Title",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    leading: const Icon(Icons.date_range),
                    title: Text(
                      selectedDate != null
                          ? DateFormat('EEE, MMM d').format(selectedDate!)
                          : "Pick a date",
                    ),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setModalState(() => selectedDate = picked);
                      }
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.access_time),
                    title: Text(
                      selectedTime != null
                          ? selectedTime!.format(context)
                          : "Pick a time",
                    ),
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (picked != null) {
                        setModalState(() => selectedTime = picked);
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_titleController.text.isNotEmpty &&
                        selectedDate != null &&
                        selectedTime != null) {
                      final dateTime = DateTime(
                        selectedDate!.year,
                        selectedDate!.month,
                        selectedDate!.day,
                        selectedTime!.hour,
                        selectedTime!.minute,
                      );
                      setState(() {
                        _tasks.add({
                          'title': _titleController.text,
                          'datetime': dateTime,
                        });
                      });
                      Navigator.pop(context);
                    }
                  },
                  child: const Text("Add"),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
