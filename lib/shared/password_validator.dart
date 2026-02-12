// password_validator.dart
// This utility class provides validation for user passwords based on best practices.

class PasswordValidator {
  /// Validates password complexity including length and character types.
  ///
  /// Best practices (NIST SP 800-63B) suggest allowing long passwords.
  /// This validator enforces a minimum of 8 and a maximum of 128 characters.
  /// It also checks for uppercase, lowercase, digits, and special characters.
  static bool isPasswordValid(String password) {
    final lengthValid = password.length >= 8 && password.length <= 128;
    final hasUpper = password.contains(RegExp(r'[A-Z]'));
    final hasLower = password.contains(RegExp(r'[a-z]'));
    final hasDigit = password.contains(RegExp(r'\d'));
    final hasSpecial = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    return lengthValid && hasUpper && hasLower && hasDigit && hasSpecial;
  }
}
