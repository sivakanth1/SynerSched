import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart' as stream;
import 'package:syner_sched/routes/app_routes.dart';
import 'package:syner_sched/shared/stream_helper.dart'; // ✅ use helper

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
  bool _hasSetupRun = false;

  @override
  void initState() {
    super.initState();
    _safeSetupOnce();
  }

  Future<void> _safeSetupOnce() async {
    if (_hasSetupRun) return;
    _hasSetupRun = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setup();
    });
  }

  Future<void> _setup() async {
    debugPrint("🚀 Splash _setup() started");

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      debugPrint("👤 Firebase currentUser: null");
      debugPrint("🔁 No user logged in → go to onboarding");
      _navigateTo(AppRoutes.onboarding);
      return;
    }

    try {
      await StreamConnectionHelper.ensureConnected(widget.streamClient);
      debugPrint("✅ Stream connected → go to home");
      _navigateTo(AppRoutes.home);
    } catch (e) {
      debugPrint("❌ Stream connection error: $e");
      _navigateTo(AppRoutes.onboarding);
    }
  }

  void _navigateTo(String route) {
    if (!mounted) return;
    Future.microtask(() {
      Navigator.pushReplacementNamed(context, route);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}