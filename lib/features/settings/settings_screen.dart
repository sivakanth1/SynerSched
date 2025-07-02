import 'package:flutter/material.dart';
import 'package:syner_sched/localization/app_localizations.dart';
import 'package:syner_sched/localization/inherited_locale.dart';
import 'package:syner_sched/shared/custom_nav_bar.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizer = AppLocalizations.of(context)!;
    final localeController = InheritedLocale.of(context);
    final isEnglish = localizer.locale.languageCode == 'en';

    return Scaffold(
      appBar: AppBar(
        title: Text(localizer.translate("settings")),
        backgroundColor: const Color(0xFF0277BD),
        foregroundColor: Colors.white,
      ),
      bottomNavigationBar: CustomNavBar(currentIndex: 3, onTap: (index) {}),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(localizer.translate("change_language")),
            subtitle: Text(isEnglish ? "English" : "Español"),
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
          const Divider(),

          ListTile(
            leading: const Icon(Icons.color_lens),
            title: Text(localizer.translate("theme")),
            subtitle: const Text("Coming soon..."),
            trailing: const Icon(Icons.lock_outline),
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.logout),
            title: Text(localizer.translate("logout")),
            onTap: () {
              // TODO: Implement logout functionality
            },
          ),
        ],
      ),
    );
  }
}
