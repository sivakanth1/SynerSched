import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:syner_sched/routes/app_routes.dart';
import 'package:syner_sched/shared/custom_button.dart';
import '../../firebase/auth_service.dart';
import '../../localization/app_localizations.dart';
import '../../shared/notification_service.dart';

// This screen displays the user's profile information such as name, department, year,
// skills, and interests. It also allows the user to log out and navigate to edit their profile.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Fetches the current user's profile information from Firestore.
  // Returns a map of profile fields or null if not found.
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
    final localizer = AppLocalizations.of(context)!;

    // UI is wrapped inside a FutureBuilder to load the profile data asynchronously.
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
          title: Text(
            localizer.translate("my_profile"),
            style: const TextStyle(
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

              // Display a message if no profile data is found.
              if (!snapshot.hasData || snapshot.data == null) {
                return Center(child: Text(localizer.translate("no_profile_data")));
              }

              final data = snapshot.data!;
              final name = data['name'] ?? localizer.translate("no_name");
              final department = data['department'] ?? localizer.translate("unknown_department");
              final year = data['year'] ?? localizer.translate("unknown_year");
              final skills = List<String>.from(data['skills'] ?? []);
              final interests = data['interests'] ?? localizer.translate("no_interests");

              // Build the visual layout for the user's profile data including avatar, name, department, year, skills, and interests.
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

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        localizer.translate("skills"),
                        style: const TextStyle(
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

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        localizer.translate("interests"),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "$interests",
                      style: const TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                    const SizedBox(height: 40),

                    // Logout button: clears session, cancels notifications, and navigates back to onboarding.
                    buildCustomButton(context, () async {
                      await AuthService.logout();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(localizer.translate("logged_out"))),
                      );

                      await NotificationService().cancelAllNotifications();

                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.onboarding,
                            (route) => false,
                      );
                    }, const Icon(Icons.logout), Text(localizer.translate("logout"))),
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

// A simple reusable widget for displaying each skill as a chip.
class _SkillChip extends StatelessWidget {
  final String text;
  const _SkillChip(this.text);

  @override
  Widget build(BuildContext context) {
    // Build the visual appearance of a single skill chip with styling.
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