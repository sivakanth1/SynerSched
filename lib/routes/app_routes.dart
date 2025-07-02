import 'package:flutter/material.dart';
import 'package:syner_sched/features/collab_match/collab_board_screen.dart';
import 'package:syner_sched/features/profile/profile_screen.dart';
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

class AppRoutes {
  static const String onboarding = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String scheduleBuilder = '/scheduleBuilderScreen';
  static const String scheduleResult = '/scheduleResultScreen';
  static const String collabBoard = '/collabBoardScreen';
  static const String newCollab = '/new-collab';
  static const String chatDetail = '/chat';
  static const String editProfile = '/edit-profile';
  static const String gpaEstimator = '/gpa-estimator';
  static const String notifications = '/notifications';
  static const String settings = '/settings';

  static Map<String, WidgetBuilder> routes = {
    onboarding: (_) => const OnboardingScreen(),
    login: (_) => const LoginScreen(),
    signup: (_) => const SignupScreen(),
    home: (_) => const HomeScreen(),
    profile: (_) => const ProfileScreen(),
    scheduleBuilder: (_) => const ScheduleBuilderScreen(),
    scheduleResult: (_) => const ScheduleResultScreen(),
    collabBoard: (_) => const CollabBoardScreen(),
    newCollab: (_) => const NewCollabScreen(),
    chatDetail: (_) => const ChatDetailScreen(),
    editProfile: (_) => const EditProfileScreen(),
    gpaEstimator: (_) => const GPAEstimatorScreen(),
    notifications: (_) => const NotificationsScreen(),
    settings: (_) => const SettingsScreen(),
  };
}
