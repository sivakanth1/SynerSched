import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:syner_sched/routes/app_routes.dart';
import 'package:syner_sched/shared/custom_button.dart';
import 'package:syner_sched/shared/custom_nav_bar.dart';

import '../../firebase/auth_service.dart';
import '../../shared/notification_service.dart';
import '../../shared/stream_helper.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<Map<String, dynamic>?> _getProfileData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('profile')
        .doc('info')
        .get();

    return doc.data();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/app_background.jpg"),
          fit: BoxFit.fill,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        //bottomNavigationBar: const CustomNavBar(currentIndex: 3),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.editProfile);
              },
              icon: const Icon(Icons.edit, color: Color(0xFF2D4F48)),
            ),
          ],
          centerTitle: true,
          title: const Text(
            "Profile",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D4F48),
            ),
          ),
        ),
        body: SafeArea(
          child: FutureBuilder<Map<String, dynamic>?>(
            future: _getProfileData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data == null) {
                return const Center(child: Text("No profile data found."));
              }

              final data = snapshot.data!;
              final name = data['name'] ?? "No name";
              final department = data['department'] ?? "Unknown Department";
              final year = data['year'] ?? "Unknown Year";
              final skills = List<String>.from(data['skills'] ?? []);
              final interests = data['interests'] ?? "No interests";

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 24),
                    const CircleAvatar(
                      radius: 50,
                      backgroundColor: Color(0xFFDDCFFC),
                      child: Icon(Icons.person, size: 50, color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D4F48),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "$department • $year",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 24),

                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Skills",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      children: skills.map((skill) => _SkillChip(skill)).toList(),
                    ),
                    const SizedBox(height: 24),

                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Interests",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "$interests",
                      style: TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                    const SizedBox(height: 40),

                    buildCustomButton(context, () async {
                      await AuthService.logout();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("You have been logged out")),
                      );

                      await NotificationService().cancelAllNotifications();

                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.onboarding,
                            (route) => false,
                      );
                    }, const Icon(Icons.logout), const Text("Logout")),
                    const SizedBox(height: 24),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SkillChip extends StatelessWidget {
  final String text;
  const _SkillChip(this.text);

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(text),
      labelStyle: const TextStyle(fontWeight: FontWeight.w500),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFBFD6E2)),
      ),
    );
  }
}