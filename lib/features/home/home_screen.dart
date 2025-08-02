import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stream_chat/stream_chat.dart';
import 'package:syner_sched/firebase/firestore_service.dart';
import 'package:syner_sched/localization/app_localizations.dart';
import 'package:syner_sched/routes/app_routes.dart';
import 'package:syner_sched/shared/custom_app_bar.dart';
import '../../firebase/task_service.dart';
import '../../shared/encryption_helper.dart';
import '../../shared/notification_service.dart';
import '../../shared/tab_controller_provider.dart';

class HomeScreen extends StatefulWidget {
  final StreamChatClient streamClient;
  const HomeScreen({super.key, required this.streamClient});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String uid = '';
  final List<String> _scheduleItems = [
    "CSCI 6362 – 10:00 AM",
    "STAT 5300 – 1:30 PM",
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getTasks();
    uid = FirebaseAuth.instance.currentUser!.uid;
  }

  void getTasks() async {
    await TaskService.getUserTasks();
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
        appBar: CustomAppBar(
          actions: [
            Column(
              children: [
                const SizedBox(height: 10),
                Text(
                  localizer.translate("welcome"),
                  style: const TextStyle(color: Color(0xFF2D4F48)),
                ),
                const Text(
                  'Siva 👋',
                  style: TextStyle(color: Color(0xFF2D4F48)),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.notifications);
              },
              color: const Color(0xFF2D4F48),
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.settings);
              },
              color: const Color(0xFF2D4F48),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showAddTaskDialog(context),
          icon: const Icon(Icons.add),
          label: const Text("Add Task"),
          backgroundColor: const Color(0xFF5579f1),
          foregroundColor: Colors.white,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ElevatedButton(onPressed: (){
                //   NotificationService().showNotification(id: 1, title: "Notification Title", body: "Notification Body");
                // }, child: Text("Text Notification")),
                const SizedBox(height: 30),
                GestureDetector(
                  onTap: () {
                    TabControllerProvider.tabIndex.value = 1;
                  },
                  child: _buildUpcomingDeadlines(localizer),
                ),
                const SizedBox(height: 30),
                GestureDetector(
                  onTap: () {
                    TabControllerProvider.tabIndex.value = 1;
                  },
                  child: _buildMyScheduleCard(localizer),
                ),
                const SizedBox(height: 30),
                GestureDetector(
                  onTap: () {
                    TabControllerProvider.tabIndex.value = 2;
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

  Widget _buildUpcomingDeadlines(AppLocalizations localizer) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: FirestoreService().getTasksStream(),
      builder: (context, snapshot) {
        final tasks = snapshot.data ?? [];

        final now = DateTime.now();

        // Filter out past deadlines
        final upcomingTasks = tasks.where((task) {
          final deadlineField = task['deadline'];
          DateTime? deadline;

          if (deadlineField is Timestamp) {
            deadline = deadlineField.toDate();
          } else if (deadlineField is String) {
            deadline = DateTime.tryParse(deadlineField);
          }

          // Keep only future deadlines
          return deadline != null && deadline.isAfter(now);
        }).toList();

        // Sort ascending
        upcomingTasks.sort((a, b) {
          final aDeadline = a['deadline'] is Timestamp
              ? (a['deadline'] as Timestamp).toDate()
              : DateTime.tryParse(a['deadline'].toString()) ?? DateTime.now();

          final bDeadline = b['deadline'] is Timestamp
              ? (b['deadline'] as Timestamp).toDate()
              : DateTime.tryParse(b['deadline'].toString()) ?? DateTime.now();

          return aDeadline.compareTo(bDeadline);
        });

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
              ...upcomingTasks.map((task) {
                final deadlineField = task['deadline'];
                late DateTime deadline;

                if (deadlineField is Timestamp) {
                  deadline = deadlineField.toDate();
                } else if (deadlineField is String) {
                  deadline = DateTime.tryParse(deadlineField) ?? DateTime.now();
                } else {
                  deadline = DateTime.now(); // fallback
                }

                final formatted = DateFormat(
                  'MMM dd, hh:mm a',
                ).format(deadline);
                final decryptedTitle = EncryptionHelper.decryptText(
                  task['title'],
                  FirebaseAuth.instance.currentUser?.uid ?? '',
                );

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.calendar_today_outlined,
                    color: Color(0xFF2D4F48),
                  ),
                  title: Text(
                    decryptedTitle,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(formatted),
                );
              }),
            ],
          ),
        );
      },
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
                child: Text(
                  localizer.translate("my_schedule"),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
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
          }),
        ],
      ),
    );
  }

  Widget _buildCollaborationCard(AppLocalizations localizer) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: FirestoreService().getUserJoinedCollaborations(uid),
      builder: (context, snapshot) {
        final collabs = snapshot.data ?? [];

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
                    child: Text(
                      localizer.translate("collab_highlights"),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (collabs.isEmpty)
                const Text("You're not part of any collaborations yet.")
              else
                ...collabs.map(
                      (collab) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      collab['title'] ?? 'Untitled',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      collab['description'] ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                        onTap: () {
                          // final channelId = collab['streamChannelId'];
                          // if (channelId != null && channelId.isNotEmpty) {
                          //   Navigator.pushNamed(
                          //     context,
                          //     AppRoutes.chatScreen,
                          //     arguments: {
                          //       'streamClient': widget.streamClient,
                          //       'collabId': collab['collabId'] ?? '',
                          //       'collabName': collab['title'] ?? 'Chat',
                          //     },
                          //   );
                          // } else {
                          //   // fallback to open collab board
                            TabControllerProvider.tabIndex.value = 2;
                          // }
                        },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    final titleController = TextEditingController();
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
                    controller: titleController,
                    keyboardType: TextInputType.name,
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
                  onPressed: () async {
                    if (titleController.text.isNotEmpty &&
                        selectedDate != null &&
                        selectedTime != null) {
                      final deadline = DateTime(
                        selectedDate!.year,
                        selectedDate!.month,
                        selectedDate!.day,
                        selectedTime!.hour,
                        selectedTime!.minute,
                      );

                      // Save task to Firebase...
                      await FirestoreService().addTask(
                        titleController.text,
                        deadline,
                      );

                      // Schedule reminders
                      final notifService = NotificationService();
                      await notifService.scheduleNotification(
                        id:
                            deadline.millisecondsSinceEpoch ~/
                            1000, // unique id
                        title: "Upcoming Task",
                        body: "${titleController.text} is due in 1 hour",
                        scheduledTime: deadline.subtract(
                          const Duration(hours: 1),
                        ),
                      );

                      await notifService.scheduleNotification(
                        id: deadline.millisecondsSinceEpoch ~/ 1000 + 1,
                        title: "Upcoming Task",
                        body: "${titleController.text} is due in 30 minutes",
                        scheduledTime: deadline.subtract(
                          const Duration(minutes: 30),
                        ),
                      );

                      await notifService.scheduleNotification(
                        id: deadline.millisecondsSinceEpoch ~/ 1000 + 2,
                        title: "Upcoming Task",
                        body: "${titleController.text} is due in 15 minutes",
                        scheduledTime: deadline.subtract(
                          const Duration(minutes: 15),
                        ),
                      );

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
