import 'package:flutter/material.dart';

class CustomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int)? onTap;

  const CustomNavBar({super.key, required this.currentIndex, this.onTap});

  @override
  Widget build(BuildContext context) {
    Future<bool> checkScheduleExists() async {
      // In future: fetch from local storage or server
      // For now: mock value
      return Future.value(false); // or false to simulate no schedule
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
      onTap: onTap, // use callback
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: 'Home',
          activeIcon: Icon(Icons.home_rounded),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_month_outlined),
          label: 'Schedule',
          activeIcon: Icon(Icons.calendar_month),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.group_outlined),
          label: 'Collab',
          activeIcon: Icon(Icons.group),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outlined),
          label: 'Profile',
          activeIcon: Icon(Icons.person),
        ),
      ],
      ),
    );
  }
}

// class CustomNavBar extends StatelessWidget {
//   final int currentIndex;
//   final Function(int)? onTap;
//
//   const CustomNavBar({super.key, required this.currentIndex, this.onTap});
//
//   @override
//   Widget build(BuildContext context) {
//     return BottomNavigationBar(
//       currentIndex: currentIndex,
//       onTap: onTap, // use callback
//       items: const [
//         BottomNavigationBarItem(
//           icon: Icon(Icons.home_outlined),
//           label: 'Home',
//           activeIcon: Icon(Icons.home_rounded),
//         ),
//         BottomNavigationBarItem(
//           icon: Icon(Icons.calendar_month_outlined),
//           label: 'Schedule',
//           activeIcon: Icon(Icons.calendar_month),
//         ),
//         BottomNavigationBarItem(
//           icon: Icon(Icons.group_outlined),
//           label: 'Collab',
//           activeIcon: Icon(Icons.group),
//         ),
//         BottomNavigationBarItem(
//           icon: Icon(Icons.person_outlined),
//           label: 'Profile',
//           activeIcon: Icon(Icons.person),
//         ),
//       ],
//     );
//   }
// }