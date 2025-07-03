import 'package:flutter/material.dart';
import 'package:syner_sched/localization/app_localizations.dart';
import 'package:syner_sched/localization/inherited_locale.dart';
import 'package:syner_sched/routes/app_routes.dart';
import 'package:syner_sched/shared/custom_nav_bar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizer = AppLocalizations.of(context)!;
    final localeController = InheritedLocale.of(context);
    final isEnglish = localizer.locale.languageCode == 'en';

    return Scaffold(
      appBar: AppBar(
        title: Text(localizer.translate("profile")),
        backgroundColor: const Color(0xFF0277BD),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.editProfile);
            },
            icon: Icon(Icons.edit),
          ),
        ],
      ),
      bottomNavigationBar: CustomNavBar(currentIndex: 3),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundImage: AssetImage(
              'assets/images/avatar_placeholder.png',
            ), // Replace with user avatar
          ),
          const SizedBox(height: 16),

          Center(
            child: Text(
              "Siva Kondamadugula", // Static or from user data
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),

          const SizedBox(height: 10),
          Center(
            child: Text(
              "Computer Science • 2nd Year",
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ),

          const Divider(height: 30),

          Text(
            localizer.translate("skills"),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: const [
              Chip(label: Text("Flutter")),
              Chip(label: Text("Machine Learning")),
              Chip(label: Text("Firebase")),
            ],
          ),

          const SizedBox(height: 20),
          Text(
            localizer.translate("interests"),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          const Text(
            "Building smart campus apps, automation, and AI in education.",
          ),

          const Divider(height: 30),

          ListTile(
            leading: const Icon(Icons.language),
            title: Text(localizer.translate("change_language")),
            trailing: TextButton(
              onPressed: () {
                final newLocale = isEnglish
                    ? const Locale('es')
                    : const Locale('en');
                localeController?.setLocale(newLocale);
              },
              child: Text(isEnglish ? "Español >" : "English >"),
            ),
          ),

          const SizedBox(height: 40),

          Center(
            child: ElevatedButton.icon(
              onPressed: () {
                // TODO: Log out user
              },
              icon: const Icon(Icons.logout),
              label: Text(localizer.translate("logout")),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
