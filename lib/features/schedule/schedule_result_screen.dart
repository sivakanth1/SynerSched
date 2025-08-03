import 'package:flutter/material.dart';
import '../../firebase/class_service.dart';
import '../../firebase/smart_scheduler.dart';
import '../../firebase/task_service.dart';
import '../../localization/app_localizations.dart';

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
    // context is not available in initState, so use a workaround in build
    // _selectedDay will be initialized in build if null
    // or, set a dummy value here, but will override in build.
    _selectedDay = '';
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
    final localizer = AppLocalizations.of(context)!;
    final today = DateTime.now();
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    final weekDates =
    List.generate(7, (i) => startOfWeek.add(Duration(days: i)));

    // Initialize _selectedDay if not set
    if (_selectedDay.isEmpty) {
      _selectedDay = _shortDayName(context, DateTime.now());
    }

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
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            localizer.translate("your_weekly_schedule"),
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D4F48)),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded,
                        size: 18, color: Color(0xFF2D4F48)),
                    const SizedBox(width: 6),
                    Text(
                      "${today.day} ${_monthName(context, today.month)}",
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
                      final shortDay = _shortDayName(context, date);
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
                      ? Center(
                    child: Text(localizer.translate("no_schedule_for_day")),
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