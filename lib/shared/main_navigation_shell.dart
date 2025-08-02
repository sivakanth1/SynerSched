import 'package:flutter/material.dart';
import 'package:syner_sched/features/home/home_screen.dart';
import 'package:syner_sched/features/schedule/schedule_result_screen.dart';
import 'package:syner_sched/features/profile/profile_screen.dart';
import 'package:syner_sched/features/collab_match/collab_board_screen.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:syner_sched/shared/tab_controller_provider.dart';
import '../shared/custom_nav_bar.dart';

class MainNavigationShell extends StatefulWidget {
  final StreamChatClient streamClient;
  const MainNavigationShell({super.key, required this.streamClient});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  final ValueNotifier<int> tabIndex = TabControllerProvider.tabIndex;
  final PageStorageBucket _bucket = PageStorageBucket();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: tabIndex,
      builder: (context, index, _) {
        return PopScope(
          canPop: index == 0,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop && index != 0) {
              tabIndex.value = 0;
            }
          },
          child: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/app_background.jpg"),
                fit: BoxFit.fill,
              ),
            ),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: PageStorage(
                bucket: _bucket,
                child: IndexedStack(
                  index: index,
                  children: [
                    HomeScreen(streamClient: widget.streamClient),
                    const ScheduleResultScreen(),
                    CollabBoardScreen(streamClient: widget.streamClient),
                    const ProfileScreen(),
                  ],
                ),
              ),
              bottomNavigationBar: CustomNavBar(
                currentIndex: index,
                onTap: (newIndex) {
                  if (newIndex != index) {
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