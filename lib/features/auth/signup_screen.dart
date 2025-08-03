import 'package:flutter/material.dart';
import 'package:syner_sched/localization/app_localizations.dart';
import 'package:syner_sched/routes/app_routes.dart';
import 'package:syner_sched/firebase/auth_service.dart';
import '../../shared/build_input_field.dart';
import '../profile/edit_profile_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool _hidePassword = true;
  bool _hideConfirmPassword = true;
  bool _isLoading = false;
  String? _error;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isPasswordValid(String password) {
    final lengthValid = password.length >= 8 && password.length <= 16;
    final hasUpper = password.contains(RegExp(r'[A-Z]'));
    final hasLower = password.contains(RegExp(r'[a-z]'));
    final hasDigit = password.contains(RegExp(r'\d'));
    final hasSpecial = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    return lengthValid && hasUpper && hasLower && hasDigit && hasSpecial;
  }

  void _handleSignup() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();
    final localizer = AppLocalizations.of(context)!;

    if (email.isEmpty || password.isEmpty || confirm.isEmpty) {
      setState(() {
        _error = localizer.translate("fill_all_fields");
      });
      return;
    }

    if (password != confirm) {
      setState(() {
        _error = localizer.translate("passwords_do_not_match");
      });
      return;
    }

    if (!_isPasswordValid(password)) {
      setState(() {
        _error = localizer.translate("password_policy_message");
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final user = await AuthService.signUp(email, password);

    setState(() => _isLoading = false);

    if (user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const EditProfileScreen(fromSignup: true),
        ),
      );
    } else {
      setState(() {
        _error = localizer.translate("signup_failed");
      });
    }
  }

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
                  Image.asset('assets/images/app_icon_teal.png', height: 160),
                  const SizedBox(height: 10),
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

                  buildInputField(
                    keyboardType: TextInputType.emailAddress,
                    controller: _emailController,
                    hint: localizer.translate("email"),
                    icon: Icons.email_outlined,
                    obscureText: false,
                  ),
                  const SizedBox(height: 16),

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

                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),

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