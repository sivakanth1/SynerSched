import 'package:flutter/material.dart';
import 'package:syner_sched/localization/app_localizations.dart';
import 'package:syner_sched/shared/custom_nav_bar.dart';

import '../../firebase/auth_service.dart';
import '../../localization/inherited_locale.dart';
import '../../routes/app_routes.dart';
import '../../shared/notification_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizer = AppLocalizations.of(context)!;

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/app_background.jpg"),
          fit: BoxFit.fill,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Color(0xFF2D4F48),
          centerTitle: true,
          title: Text(
            localizer.translate('settings'),
            style: const TextStyle(
              color: Color(0xFF2D4F48),
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        bottomNavigationBar: CustomNavBar(currentIndex: 3),
        body: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
          child: Column(
            children: [
              // Change Language Card
              _buildSettingCard(
                context,
                icon: Icons.language,
                title: localizer.translate('change_language'),
                subtitle: localizer.locale.languageCode == 'en'
                    ? "English"
                    : "Español",
                onTap: () {
                  String currentLang = localizer.locale.languageCode;
                  String selectedLang = currentLang;

                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text(localizer.translate('change_language')),
                        content: StatefulBuilder(
                          builder: (context, setState) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                RadioListTile<String>(
                                  title: const Text("English"),
                                  value: 'en',
                                  groupValue: selectedLang,
                                  onChanged: (value) {
                                    setState(() => selectedLang = value!);
                                  },
                                ),
                                RadioListTile<String>(
                                  title: const Text("Español"),
                                  value: 'es',
                                  groupValue: selectedLang,
                                  onChanged: (value) {
                                    setState(() => selectedLang = value!);
                                  },
                                ),
                              ],
                            );
                          },
                        ),
                        actions: [
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(context), // Close dialog
                            child: const Text("Cancel"),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              InheritedLocale.of(
                                context,
                              )?.setLocale(Locale(selectedLang));
                              Navigator.pop(context);
                            },
                            child: const Text("Apply"),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),

              const SizedBox(height: 12),

              // App Theme Card
              _buildSettingCard(
                context,
                icon: Icons.palette,
                title: localizer.translate('app_theme'),
                subtitle: localizer.translate('coming_soon'),
                trailing: const Icon(Icons.lock, color: Color(0xFF2D4F48)),
                onTap: () {},
              ),

              const SizedBox(height: 12),

              // Logout Card
              _buildSettingCard(
                context,
                icon: Icons.logout,
                title: localizer.translate('logout'),
                subtitle: "",
                onTap: () async {
                  await AuthService.logout();

                  // Show snack for visual confirmation (optional)
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("You have been logged out")),
                  );

                  await NotificationService().cancelAllNotifications();

                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.onboarding,
                        (route) => false,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
        leading: Icon(icon, color: const Color(0xFF2D4F48), size: 28),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Color(0xFF2D4F48),
          ),
        ),
        subtitle: subtitle.isNotEmpty
            ? Text(subtitle, style: const TextStyle(color: Color(0xFF4A4A4A)))
            : null,
        trailing:
            trailing ??
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Color(0xFF4A4A4A),
            ),
        onTap: onTap,
      ),
    );
  }
}
