import 'package:flutter/material.dart';
import 'package:syner_sched/shared/custom_nav_bar.dart';
import '../../firebase/class_service.dart';
import '../../firebase/smart_scheduler.dart';
import '../../firebase/task_service.dart';

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
    _selectedDay = _shortDayName(DateTime.now());
    //weeklySlots = _generateMarkedSchedule();
    _loadAndGenerateSchedule();
  }


  Future<void> _loadAndGenerateSchedule() async {
    final tasks = await TaskService.getUserTasks(); // Add this line
    final classSlots = await ClassService.getUserClassSchedule();
    final generated = SmartScheduler.generateWeeklyGrid();
    final marked = SmartScheduler.markClassesAndBreaks(
      grid: generated,
      occupiedSlots: classSlots,
    );
    setState(() {
      weeklySlots = marked;
    });
    final withTasks = SmartScheduler.allocateTasks(
      weeklyGrid: marked,
      tasks: tasks,
    );

// NEW: Save to Firebase
    await TaskService.saveAllocatedTasks(withTasks);
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    final weekDates =
    List.generate(7, (i) => startOfWeek.add(Duration(days: i)));

    final daySlots = weeklySlots
        .where((slot) => slot['day'] == _selectedDay && slot['type'] != 'free')
        .toList();

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/app_background.jpg"),
          fit: BoxFit.fill,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        bottomNavigationBar: const CustomNavBar(currentIndex: 1),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back)),
                    const Text(
                      "Your Weekly Schedule",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D4F48)),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),

                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded,
                        size: 18, color: Color(0xFF2D4F48)),
                    const SizedBox(width: 6),
                    Text(
                      "${today.day} ${_monthName(today.month)}",
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF2D4F48)),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Day Chips
                SizedBox(
                  height: 75,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: weekDates.length,
                    itemBuilder: (context, index) {
                      final date = weekDates[index];
                      final shortDay = _shortDayName(date);
                      final isSelected = shortDay == _selectedDay;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedDay = shortDay),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color:
                            isSelected ? const Color(0xFF2D4F48) : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(shortDay,
                                  style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.black)),
                              Text('${date.day}',
                                  style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.black)),
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
                      ? const Center(
                    child: Text("No schedule for this day."),
                  )
                      : ListView.builder(
                      itemCount: daySlots.length,
                      itemBuilder: (context, index) {
                        final item = daySlots[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: item['type'] == 'break'
                                ? Colors.orange.shade100
                                : item['type'] == 'class'?Colors.teal.shade100: Colors.greenAccent,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                item['type'] == 'break'
                                    ? Icons.local_cafe
                                    : item['type'] == 'class' ? Icons.school_rounded : Icons.task_alt_rounded,
                                color: const Color(0xFF2D4F48),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(item['title'],
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF2D4F48))),
                                    Text(item['time'],
                                        style: const TextStyle(
                                            color: Colors.black87)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Helper: Format time
String _formatTime(int hour) {
  final h = hour % 12 == 0 ? 12 : hour % 12;
  final period = hour < 12 ? 'AM' : 'PM';
  return '$h:00 $period';
}

String _shortDayName(DateTime date) {
  return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][date.weekday - 1];
}

String _monthName(int month) {
  return [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ][month - 1];
}