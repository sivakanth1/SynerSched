// email_validator.dart
// This utility class provides validation for user email addresses.

class EmailValidator {
  /// Validates if the given email string is in a correct format.
  static bool isEmailValid(String email) {
    // Regular expression for validating an email
    final RegExp emailRegex = RegExp(
      r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
    );
    return emailRegex.hasMatch(email);
  }
}
