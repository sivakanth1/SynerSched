import 'package:flutter/material.dart';
import 'package:syner_sched/routes/app_routes.dart';
import 'package:syner_sched/shared/custom_button.dart';
import 'package:syner_sched/shared/custom_nav_bar.dart';

import '../../firebase/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
        bottomNavigationBar: CustomNavBar(currentIndex: 3,),
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
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 24),
                    // Profile Photo Placeholder
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: const Color(0xFFDDCFFC),
                      child: const Icon(Icons.person, size: 50, color: Colors.white),
                    ),
                    const SizedBox(height: 16),

                    // Name
                    const Text(
                      "Siva Kondamadugula",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D4F48),
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Department + Year
                    const Text(
                      "Computer Science • 2nd Year",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Skills
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
                      children: const [
                        _SkillChip("Flutter"),
                        _SkillChip("Machine Learning"),
                        _SkillChip("Firebase"),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Interests
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
                    const Text(
                      "Building smart campus apps, automation, and AI in education.",
                      style: TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                    const SizedBox(height: 40),

                    // Logout Button
                    buildCustomButton(context,() async{
                      await AuthService.logout();

                      // Show snack for visual confirmation (optional)
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("You have been logged out")),
                      );

                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.onboarding,
                            (route) => false,
                      );
                    },const Icon(Icons.logout),const Text("Logout")),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
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