import 'package:flutter/material.dart';
import 'package:syner_sched/localization/app_localizations.dart';
import 'package:syner_sched/routes/app_routes.dart';

import '../../shared/buildInputField.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool _hidePassword = true;
  bool _hideConfirmPassword = true;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    final localizer = AppLocalizations.of(context)!;

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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Logo
                  Image.asset('assets/images/app_icon_teal.png', height: 160),
                  const SizedBox(height: 10),

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

                  const SizedBox(height: 16),

                  // Confirm Password Field
                  buildInputField(
                    controller: _confirmPasswordController,
                    hint: localizer.translate("confirm_password"),
                    icon: Icons.lock_outline,
                    obscureText: _hideConfirmPassword,
                    toggle: () {
                      setState(
                        () => _hideConfirmPassword = !_hideConfirmPassword,
                      );
                    },
                  ),

                  const SizedBox(height: 30),

                  // Sign Up Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Handle sign-up logic
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
                        localizer.translate("signup"),
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Already have account? Login
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        localizer.translate("already_have_account"),
                        style: const TextStyle(color: Colors.black87),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(
                            context,
                            AppRoutes.login,
                          );
                        },
                        child: Text(
                          localizer.translate("login"),
                          style: const TextStyle(
                            color: Color(0xFF2D4F48),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
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
