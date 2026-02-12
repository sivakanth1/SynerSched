import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:syner_sched/localization/app_localizations.dart';
import 'package:syner_sched/localization/inherited_locale.dart';
import 'package:syner_sched/routes/app_routes.dart';
import 'package:syner_sched/shared/build_input_field.dart';
import 'package:syner_sched/shared/email_validator.dart';

/// This screen provides the login interface for users.
/// It includes email and password input fields, password visibility toggle,
/// localization support, and a button to log in with Firebase Authentication.
/// On successful login, it navigates to the home screen.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controllers to capture user input for email and password fields.
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Controls whether the password is obscured in the input field.
  bool _hidePassword = true;

  // Tracks the loading state during login to show a spinner in the button.
  bool _isLoading = false;

  // Firebase Authentication instance for user login.
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Attempts to log the user in using the entered email and password.
  /// If successful, navigates to the home screen.
  /// If login fails, displays a localized error message using a snackbar.
  Future<void> _login() async {
    // Start loading spinner.
    setState(() => _isLoading = true);
    final localizer = AppLocalizations.of(context)!;

    final email = _emailController.text.trim();
    if (!EmailValidator.isEmailValid(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizer.translate("invalid_email"))),
      );
      setState(() => _isLoading = false);
      return;
    }

    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: _passwordController.text.trim(),
      );

      // Navigate to the home screen upon successful login.
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = localizer.translate("no_user_for_email");
          break;
        case 'wrong-password':
          message = localizer.translate("incorrect_password");
          break;
        case 'invalid-email':
          message = localizer.translate("invalid_email");
          break;
        default:
          message = localizer.translate("login_failed");
      }

      // Show a snackbar with a user-friendly error message based on Firebase error code.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Builds the complete login UI with input fields, buttons,
  /// and localized text with language toggle.
  @override
  Widget build(BuildContext context) {
    final localizer = AppLocalizations.of(context)!;
    // Get the current language setting and a controller to toggle languages.
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
                  // App logo and title
                  Image.asset('assets/images/app_icon_teal.png', height: 250),
                  const SizedBox(height: 20),
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

                  // Email input field
                  buildInputField(
                    keyboardType: TextInputType.emailAddress,
                    controller: _emailController,
                    hint: localizer.translate("email"),
                    icon: Icons.email_outlined,
                    obscureText: false,
                  ),
                  const SizedBox(height: 16),

                  // Password input field with toggle
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
                  const SizedBox(height: 10),

                  // Forgot password link
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // Optional: Forgot password
                      },
                      child: Text(
                        localizer.translate('forgot_password'),
                        style: const TextStyle(color: Color(0xFF2D4F48)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Login button with loading state
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2D4F48),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      )
                          : Text(
                        localizer.translate('login'),
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Sign-up link for new users
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        localizer.translate('dont_have_account'),
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

                  // Language toggle button
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