import 'package:flutter/material.dart';
import 'package:syner_sched/features/home/home_screen.dart';
import 'package:syner_sched/features/schedule/schedule_result_screen.dart';
import 'package:syner_sched/features/profile/profile_screen.dart';
import 'package:syner_sched/features/collab_match/collab_board_screen.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:syner_sched/shared/tab_controller_provider.dart';
import 'package:syner_sched/shared/utils.dart';
import '../shared/custom_nav_bar.dart';

/// MainNavigationShell manages the primary navigation structure of the app.
/// It holds the main screens and controls the bottom navigation bar and page switching.
class MainNavigationShell extends StatefulWidget {
  final StreamChatClient streamClient;

  /// Constructor requires a StreamChatClient instance for chat features.
  const MainNavigationShell({super.key, required this.streamClient});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  /// Holds the current selected tab index, shared across the app via TabControllerProvider.
  final ValueNotifier<int> tabIndex = TabControllerProvider.tabIndex;

  /// PageStorageBucket preserves the state of child pages when switching tabs.
  final PageStorageBucket _bucket = PageStorageBucket();

  @override
  Widget build(BuildContext context) {
    // Listens to changes in the tab index and rebuilds accordingly.
    return ValueListenableBuilder<int>(
      valueListenable: tabIndex,
      builder: (context, index, _) {
        return PopScope(
          // Determines if the current page can be popped; only allows pop on first tab.
          canPop: index == 0,
          // Handles back button behavior: if not on first tab and pop fails, switch to first tab.
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop && index != 0) {
              tabIndex.value = 0;
            }
          },
          child: Container(
            // Sets a background image for the entire navigation shell.
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/app_background.jpg"),
                fit: BoxFit.fill,
              ),
            ),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              // Uses PageStorage to maintain state of each tab's content.
              body: PageStorage(
                bucket: _bucket,
                child: IndexedStack(
                  index: index,
                  children: [
                    // Home screen with chat client passed.
                    HomeScreen(streamClient: widget.streamClient),
                    // Schedule results screen.
                    const ScheduleResultScreen(),
                    // Collaboration board screen with chat client.
                    CollabBoardScreen(streamClient: widget.streamClient),
                    // Profile screen.
                    const ProfileScreen(),
                  ],
                ),
              ),
              // Custom bottom navigation bar controlling tab changes.
              bottomNavigationBar: CustomNavBar(
                currentIndex: index,
                onTap: (newIndex) async {
                  // When switching to the schedule tab, ensure a schedule exists before switching.
                  if (newIndex == 1) {
                    await Utility.ensureScheduleExists(context);
                  } else {
                    // For other tabs, update the tab index directly.
                    tabIndex.value = newIndex;
                  }
                },
              ),
            ),
          ),
        );
      },
    );
  }
}