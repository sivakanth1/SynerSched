import 'package:flutter/material.dart';
import 'package:syner_sched/localization/app_localizations.dart';
import 'package:syner_sched/routes/app_routes.dart';
import 'package:syner_sched/localization/inherited_locale.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizer = AppLocalizations.of(context)!;
    final localeController = InheritedLocale.of(context);
    final isEnglish = localizer.locale.languageCode == 'en';

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/app_background.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Logo
                  Image.asset('assets/images/app_icon_teal.png', height: 250),
                  const SizedBox(height: 24),

                  // Welcome Text
                  Text(
                    localizer.translate("welcome_to"),
                    style: const TextStyle(
                      fontSize: 20,
                      color: Color(0xFF4A4A4A),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "SynerSched",
                    style: const TextStyle(
                      fontSize: 36,
                      color: Color(0xFF2D4F48),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.login);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2D4F48),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        localizer.translate("login"),
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Sign Up Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.signup);
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Color(0xFF2D4F48),
                          width: 1.5,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        localizer.translate("signup"),
                        style: const TextStyle(
                          fontSize: 18,
                          color: Color(0xFF2D4F48),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Language Toggle
                  TextButton(
                    onPressed: () {
                      // Language toggle logic already implemented via InheritedLocale
                      final newLocale = isEnglish
                          ? const Locale('es')
                          : const Locale('en');
                      localeController?.setLocale(newLocale);
                    },
                    child: Text(
                      localizer.locale.languageCode == 'en'
                          ? "Español >"
                          : "English >",
                      style: const TextStyle(color: Color(0xFF2D4F48)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
