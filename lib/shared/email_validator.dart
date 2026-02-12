// email_validator.dart
// This utility class provides validation for user emails.

class EmailValidator {
  /// Validates email format using a regular expression.
  static bool isEmailValid(String email) {
    // Basic email regex to check for valid format and prevent common injection attempts
    // Allows subdomains and hyphens in domain.
    final RegExp emailRegex = RegExp(
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)+$",
    );
    return emailRegex.hasMatch(email);
  }
}
