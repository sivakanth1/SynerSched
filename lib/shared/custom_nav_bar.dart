import 'package:flutter/material.dart';

/// A custom bottom navigation bar used throughout the app.
/// It displays four navigation items: Home, Schedule, Collaboration, and Profile.
class CustomNavBar extends StatelessWidget {
  final int currentIndex; // Currently selected tab index
  final Function(int)? onTap; // Callback function when a tab is tapped

  const CustomNavBar({super.key, required this.currentIndex, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      // Container for styling the navigation bar with rounded corners and shadow
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
      // Actual bottom navigation bar widget
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        currentIndex: currentIndex, // Controls the active tab
        selectedItemColor: const Color(0xFF2D4F48), // Color for selected tab icon
        unselectedItemColor: const Color(0xFF4A4A4A), // Color for unselected tab icons
        type: BottomNavigationBarType.fixed, // Ensures all items are always shown
        enableFeedback: true, // Enables haptic feedback on tap
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        onTap: onTap, // Callback triggered when a tab is tapped
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