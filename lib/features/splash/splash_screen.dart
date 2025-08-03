import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart' as stream;
import 'package:syner_sched/routes/app_routes.dart';
import 'package:syner_sched/shared/stream_helper.dart'; // ✅ use helper

/// The SplashScreen widget is the initial screen shown when the app launches.
/// It checks if a user is currently logged in and routes accordingly.
/// If a user is logged in, it attempts to establish a Stream chat connection.
/// Depending on success or failure, it navigates to the home or onboarding screen.
class SplashScreen extends StatefulWidget {
  final Function(Locale) setLocale;
  final stream.StreamChatClient streamClient;

  const SplashScreen({
    super.key,
    required this.setLocale,
    required this.streamClient,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // Flag to ensure that the setup logic runs only once.
  bool _hasSetupRun = false;

  @override
  void initState() {
    super.initState();
    // Initiate the setup process safely to avoid multiple calls.
    _safeSetupOnce();
  }

  /// Ensures that the setup process is only triggered once.
  /// Uses a post-frame callback to delay execution until after the first frame.
  Future<void> _safeSetupOnce() async {
    if (_hasSetupRun) return;
    _hasSetupRun = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setup();
    });
  }

  /// Main setup method that checks Firebase authentication status.
  /// - If no user is logged in, navigates to the onboarding screen.
  /// - If a user is logged in, attempts to connect to Stream chat.
  ///   On success, navigates to home screen.
  ///   On failure, navigates to onboarding screen.
  Future<void> _setup() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // No user logged in; redirect to onboarding.
      _navigateTo(AppRoutes.onboarding);
      return;
    }

    try {
      // Ensure Stream chat client is connected before proceeding.
      await StreamConnectionHelper.ensureConnected(widget.streamClient);
      _navigateTo(AppRoutes.home);
    } catch (e) {
      // On connection failure, fallback to onboarding.
      _navigateTo(AppRoutes.onboarding);
    }
  }

  /// Helper method to navigate to a given route, ensuring the widget is still mounted.
  /// Uses a microtask to avoid navigation issues during build.
  void _navigateTo(String route) {
    if (!mounted) return;
    Future.microtask(() {
      Navigator.pushReplacementNamed(context, route);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Builds the splash screen UI showing the app logo and name.
    // The background is a full-screen image with a transparent scaffold overlay.
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/app_background.jpg"),
          fit: BoxFit.fill,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/app_icon_teal.png', // update this path if your logo is elsewhere
                height: 300,
              ),
              const SizedBox(height: 16),
              const Text(
                'SynerSched',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}