import 'package:flutter/material.dart';
import 'package:syner_sched/localization/app_localizations.dart';
import 'package:syner_sched/routes/app_routes.dart';
import 'package:syner_sched/localization/inherited_locale.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtain the localization object to translate strings based on the current locale
    final localizer = AppLocalizations.of(context)!;
    // Access the locale controller to allow changing the app's language
    final localeController = InheritedLocale.of(context);
    // Determine if the current language is English for toggle logic
    final isEnglish = localizer.locale.languageCode == 'en';

    return Scaffold(
      // Main container with a background image covering the entire screen
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/app_background.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        // SafeArea ensures content is not obscured by system UI elements
        child: SafeArea(
          // Center widget centers its child vertically and horizontally
          child: Center(
            child: Padding(
              // Horizontal padding to prevent content from touching screen edges
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                // Center children vertically and horizontally within the column
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Display the app logo with a fixed height
                  Image.asset('assets/images/app_icon_teal.png', height: 250),
                  const SizedBox(height: 24),

                  // Display a welcome text, localized to the current language
                  Text(
                    localizer.translate("welcome_to"),
                    style: const TextStyle(
                      fontSize: 20,
                      color: Color(0xFF4A4A4A),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Display the app name prominently with styling
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

                  // Button to navigate to the login screen
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate to the login route when pressed
                        Navigator.pushNamed(context, AppRoutes.login);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2D4F48),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      // Localized text for the button label
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

                  // Button to navigate to the sign-up screen
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        // Navigate to the sign-up route when pressed
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
                      // Localized text for the button label
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

                  // Text button to toggle the app's language between English and Spanish
                  TextButton(
                    onPressed: () {
                      // Determine the new locale based on the current language
                      final newLocale = isEnglish
                          ? const Locale('es')
                          : const Locale('en');
                      // Update the locale via the inherited locale controller
                      localeController?.setLocale(newLocale);
                    },
                    // Display the language toggle label dynamically
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
