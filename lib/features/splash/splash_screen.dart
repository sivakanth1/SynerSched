import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart' as stream;
import 'package:syner_sched/routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  final Function(Locale) setLocale;
  const SplashScreen({super.key, required this.setLocale});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final stream.StreamChatClient _streamClient = stream.StreamChatClient(
    '7wm225mwe4kg',
    logLevel: stream.Level.INFO,
  );

  @override
  void initState() {
    super.initState();
    _setup();
  }

  Future<void> _setup() async {
    try {
      final user = await FirebaseAuth.instance.authStateChanges().firstWhere((u) => u != null);
      final userId = user?.uid;
      final name = user?.displayName ?? "User";

      print('✅ Firebase user: $userId');

      // 🔄 Refresh token before calling the function
      await user?.getIdToken(true);

      final callable = FirebaseFunctions.instanceFor(region: 'us-central1')
          .httpsCallable('getStreamToken');
      final result = await callable();
      final token = result.data['token'];

      await _streamClient.connectUser(stream.User(id: userId.toString(), name: name), token);
      print('✅ Stream user connected.');

      // ✅ Navigate to Home
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.home,
        arguments: _streamClient,
      );
    } catch (e) {
      print('❌ Error during setup: $e');

      // Navigate to onboarding if unauthenticated
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.onboarding,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}