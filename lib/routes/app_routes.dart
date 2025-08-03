// This file defines all the named routes used across the SynerSched app
// and maps them to their corresponding screen widgets.
import 'package:flutter/material.dart';
import 'package:stream_chat/stream_chat.dart' as stream;
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:syner_sched/features/collab_match/collab_board_screen.dart';
import 'package:syner_sched/features/profile/profile_screen.dart';
import 'package:syner_sched/features/schedule/schedule_builder_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/signup_screen.dart';
import '../features/collab_match/chat_detail_screen.dart';
import '../features/collab_match/new_collab_screen.dart';
import '../features/notifications/notifications_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/profile/edit_profile_screen.dart';
import '../features/schedule/gpa_estimator.dart';
import '../features/schedule/schedule_result_screen.dart';
import '../features/settings/settings_screen.dart';
import '../shared/main_navigation_shell.dart';

// A centralized class that stores all route names and the function to generate routes
// with required StreamChatClient dependency for chat-enabled screens.
class AppRoutes {
  // Route for the onboarding screen
  static const String onboarding = '/onboarding';

  // Route for login screen
  static const String login = '/login';

  // Route for signup screen
  static const String signup = '/signup';

  // Route for home navigation shell
  static const String home = '/home';

  // Route for profile screen
  static const String profile = '/profile';

  // Route for schedule builder
  static const String scheduleBuilder = '/scheduleBuilderScreen';

  // Route for schedule results
  static const String scheduleResult = '/scheduleResultScreen';

  // Route for collaboration board
  static const String collabBoard = '/collabBoardScreen';

  // Route for creating a new collaboration
  static const String newCollab = '/new-collab';

  // Route for chat detail screen
  static const String chatScreen = '/chat';

  // Route for editing user profile
  static const String editProfile = '/edit-profile';

  // Route for GPA estimation tool
  static const String gpaEstimator = '/gpa-estimator';

  // Route for notifications screen
  static const String notifications = '/notifications';

  // Route for app settings screen
  static const String settings = '/settings';

  // Returns a map of route names to widget builders,
  // injecting the required StreamChatClient where needed for chat functionality.
  static Map<String, WidgetBuilder> routesWithStreamClient(
      stream.StreamChatClient client) {
    return {
      onboarding: (_) => const OnboardingScreen(), // Onboarding flow
      login: (_) => const LoginScreen(), // Login screen
      signup: (_) => const SignupScreen(), // Signup screen
      home: (_) => MainNavigationShell(streamClient: client,), // Main navigation with Stream client
      profile: (_) => const ProfileScreen(), // User profile screen
      scheduleBuilder: (_) => const ScheduleBuilderScreen(), // Schedule builder screen
      scheduleResult: (_) => const ScheduleResultScreen(), // Schedule results screen
      collabBoard: (_) => StreamChat(
        client: client,
        child: CollabBoardScreen(streamClient: client),
      ), // Collaboration board wrapped with StreamChat
      newCollab: (_) => NewCollabScreen(streamClient: client), // New collaboration creation screen
      chatScreen: (context) {
        // Retrieves arguments and builds the chat detail screen with necessary parameters
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
      ), // Edit profile screen wrapped with StreamChat
      gpaEstimator: (_) => const GPAEstimatorScreen(), // GPA estimation tool screen
      notifications: (_) => const NotificationsScreen(), // Notifications screen
      settings: (_) => const SettingsScreen(), // Settings screen
    };
  }
}
