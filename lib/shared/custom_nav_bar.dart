import 'package:flutter/material.dart';
import 'package:syner_sched/routes/app_routes.dart';

class CustomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Future<bool> checkScheduleExists() async {
      // In future: fetch from local storage or server
      // For now: mock value
      return Future.value(true); // or false to simulate no schedule
    }

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF6F8FA),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        currentIndex: currentIndex,
        selectedItemColor: const Color(0xFF2D4F48),
        unselectedItemColor: const Color(0xFF4A4A4A),
        type: BottomNavigationBarType.fixed,
        enableFeedback: true,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        onTap: (index) {
          onTap(index);
          // Optional: Handle navigation globally
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, AppRoutes.home);
              break;
            case 1:
              // Schedule tab
              checkScheduleExists().then((exists) {
                Navigator.pushNamed(
                  context,
                  exists ? AppRoutes.scheduleResult : AppRoutes.scheduleBuilder,
                );
              });
              break;
            case 2:
              // Collab tab
              Navigator.pushNamed(context, AppRoutes.collabBoard);
              break;
            case 3:
              // Profile tab
              Navigator.pushNamed(context, AppRoutes.profile);
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
            activeIcon: Icon(Icons.home_rounded),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Schedule',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Collab'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
