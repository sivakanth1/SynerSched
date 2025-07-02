import 'package:flutter/material.dart';
import 'package:syner_sched/localization/app_localizations.dart';
import 'package:syner_sched/localization/inherited_locale.dart';
import 'package:syner_sched/routes/app_routes.dart';
import 'package:syner_sched/shared/buildInputField.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _hidePassword = true;

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
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Logo
                  Image.asset('assets/images/app_icon_teal.png', height: 250),
                  const SizedBox(height: 20),

                  // App Title
                  const Text(
                    "SynerSched",
                    style: TextStyle(
                      fontSize: 32,
                      color: Color(0xFF2D4F48),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Email Field
                  buildInputField(
                    controller: _emailController,
                    hint: localizer.translate("email"),
                    icon: Icons.email_outlined,
                    obscureText: false,
                  ),
                  const SizedBox(height: 16),

                  // Password Field
                  buildInputField(
                    controller: _passwordController,
                    hint: localizer.translate("password"),
                    icon: Icons.lock_outline,
                    obscureText: _hidePassword,
                    toggle: () {
                      setState(() => _hidePassword = !_hidePassword);
                    },
                  ),
                  const SizedBox(height: 10),

                  // Forgot Password Link
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // TODO: Navigate to forgot password screen or show a dialog
                      },
                      child: Text(
                        localizer.translate('forgot_password'),
                        style: const TextStyle(color: Color(0xFF2D4F48)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Log In Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Add login logic
                        Navigator.pushReplacementNamed(context, AppRoutes.home);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2D4F48),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        localizer.translate('login'),
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Sign Up Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        localizer.translate('no_account'),
                        style: const TextStyle(color: Colors.black87),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.signup);
                        },
                        child: Text(
                          localizer.translate('signup'),
                          style: const TextStyle(
                            color: Color(0xFF2D4F48),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Language toggle
                  TextButton(
                    onPressed: () {
                      final newLocale = isEnglish
                          ? const Locale('es')
                          : const Locale('en');
                      localeController?.setLocale(newLocale);
                    },
                    child: Text(
                      isEnglish ? "Español >" : "English >",
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
