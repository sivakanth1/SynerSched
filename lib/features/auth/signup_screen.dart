// signup_screen.dart
// This screen provides a user interface for new users to sign up for an account in the SynerSched app.
// It handles user input for email and password, validates the input, and interacts with AuthService to register the user.
// Upon successful signup, the user is navigated to the EditProfileScreen to complete their profile.

import 'package:flutter/material.dart';
import 'package:syner_sched/localization/app_localizations.dart';
import 'package:syner_sched/routes/app_routes.dart';
import 'package:syner_sched/firebase/auth_service.dart';
import '../../shared/build_input_field.dart';
import '../../shared/password_validator.dart';
import '../profile/edit_profile_screen.dart';

// SignupScreen is a stateful widget that displays the signup form to the user.
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

// State class for SignupScreen. Manages form input, validation, loading state, and error messages.
class _SignupScreenState extends State<SignupScreen> {
  bool _hidePassword = true;
  bool _hideConfirmPassword = true;
  bool _isLoading = false;
  String? _error;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // Handles the signup process: validates input, interacts with AuthService, and manages UI state.
  void _handleSignup() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();
    final localizer = AppLocalizations.of(context)!;

    // Check if any required fields are empty
    if (email.isEmpty || password.isEmpty || confirm.isEmpty) {
      setState(() {
        _error = localizer.translate("fill_all_fields");
      });
      return;
    }

    // Check if password and confirm password fields match
    if (password != confirm) {
      setState(() {
        _error = localizer.translate("passwords_do_not_match");
      });
      return;
    }

    // Check if password meets the complexity requirements
    if (!PasswordValidator.isPasswordValid(password)) {
      setState(() {
        _error = localizer.translate("password_policy_message");
      });
      return;
    }

    // Begin loading and clear previous errors
    setState(() {
      _isLoading = true;
      _error = null;
    });

    // Attempt to sign up the user using AuthService
    final user = await AuthService.signUp(email, password);

    if (!mounted) return;

    setState(() => _isLoading = false);

    // If signup is successful, navigate to EditProfileScreen
    if (user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const EditProfileScreen(fromSignup: true),
        ),
      );
    // If signup fails, display an error message
    } else {
      setState(() {
        _error = localizer.translate("signup_failed");
      });
    }
  }

  // Builds the signup screen UI, including input fields, error messages, and buttons.
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
                  // App icon
                  Image.asset('assets/images/app_icon_teal.png', height: 160),
                  const SizedBox(height: 10),
                  // App name/title
                  Text(
                    localizer.translate("app_name"),
                    style: const TextStyle(
                      fontSize: 32,
                      color: Color(0xFF2D4F48),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Email input field
                  buildInputField(
                    keyboardType: TextInputType.emailAddress,
                    controller: _emailController,
                    hint: localizer.translate("email"),
                    icon: Icons.email_outlined,
                    obscureText: false,
                  ),
                  const SizedBox(height: 16),

                  // Password input field with visibility toggle
                  buildInputField(
                    keyboardType: TextInputType.visiblePassword,
                    controller: _passwordController,
                    hint: localizer.translate("password"),
                    icon: Icons.lock_outline,
                    obscureText: _hidePassword,
                    toggle: () {
                      setState(() => _hidePassword = !_hidePassword);
                    },
                  ),
                  const SizedBox(height: 16),

                  // Confirm password input field with visibility toggle
                  buildInputField(
                    keyboardType: TextInputType.visiblePassword,
                    controller: _confirmPasswordController,
                    hint: localizer.translate("confirm_password"),
                    icon: Icons.lock_outline,
                    obscureText: _hideConfirmPassword,
                    toggle: () {
                      setState(() => _hideConfirmPassword = !_hideConfirmPassword);
                    },
                  ),
                  const SizedBox(height: 20),

                  // Error message display (if any)
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),

                  // Signup button or loading indicator
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleSignup,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2D4F48),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          // Show loading spinner when processing, otherwise show signup text
                          ? const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            )
                          : Text(
                              localizer.translate("signup"),
                              style: const TextStyle(fontSize: 18, color: Colors.white),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Link to login screen for existing users
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