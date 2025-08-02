import 'package:flutter/material.dart';
import 'package:stream_chat/stream_chat.dart' as stream;
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:syner_sched/features/collab_match/collab_board_screen.dart';
import 'package:syner_sched/features/profile/profile_screen.dart';
import 'package:syner_sched/features/schedule/course_selection_screen.dart';
import 'package:syner_sched/features/schedule/schedule_builder_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/signup_screen.dart';
import '../features/collab_match/chat_detail_screen.dart';
import '../features/collab_match/new_collab_screen.dart';
import '../features/home/home_screen.dart';
import '../features/notifications/notifications_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/profile/edit_profile_screen.dart';
import '../features/schedule/gpa_estimator.dart';
import '../features/schedule/schedule_result_screen.dart';
import '../features/settings/settings_screen.dart';
import '../shared/main_navigation_shell.dart';

class AppRoutes {
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String scheduleBuilder = '/scheduleBuilderScreen';
  static const String scheduleResult = '/scheduleResultScreen';
  static const String collabBoard = '/collabBoardScreen';
  static const String newCollab = '/new-collab';
  static const String chatScreen = '/chat';
  static const String editProfile = '/edit-profile';
  static const String gpaEstimator = '/gpa-estimator';
  static const String notifications = '/notifications';
  static const String settings = '/settings';
  static const String courseSelection = '/course-selection';

  static Map<String, WidgetBuilder> routesWithStreamClient(
      stream.StreamChatClient client) {
    return {
      onboarding: (_) => const OnboardingScreen(),
      login: (_) => const LoginScreen(),
      signup: (_) => const SignupScreen(),
      home: (_) => MainNavigationShell(streamClient: client,),
      profile: (_) => const ProfileScreen(),
      scheduleBuilder: (_) => const ScheduleBuilderScreen(),
      scheduleResult: (_) => const ScheduleResultScreen(),
      collabBoard: (_) => StreamChat(
        client: client,
        child: CollabBoardScreen(streamClient: client), // 👈 pass it in
      ),
      newCollab: (_) => NewCollabScreen(streamClient: client),
      chatScreen: (context) {
        final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
        return ChatDetailScreen(
          streamClient: args['streamClient'],
          collabId: args['collabId'],
          collabName: args['collabName'],
        );
      },
      editProfile: (_) => StreamChat(
        client: client,
        child: const EditProfileScreen(),
      ),
      gpaEstimator: (_) => const GPAEstimatorScreen(),
      notifications: (_) => const NotificationsScreen(),
      settings: (_) => const SettingsScreen(),
      courseSelection: (_) => const CourseSelectionScreen(),
    };
  }
}
