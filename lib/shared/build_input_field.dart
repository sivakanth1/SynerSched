import 'package:flutter/material.dart';

/// Builds a styled input field widget used across the app.
/// It supports both plain and password-style input,
/// and includes an optional toggle for showing/hiding the input text.
Widget buildInputField({
  required TextEditingController controller, // Controller for handling input text
  required String hint, // Placeholder text for the input field
  required IconData icon, // Icon to display at the start of the input field
  required TextInputType keyboardType, // Determines the type of keyboard shown
  bool obscureText = false, // Whether the input should be hidden (e.g. for passwords)
  VoidCallback? toggle, // Optional toggle function to switch obscureText on/off
}) {
  return TextField(
    keyboardType: keyboardType,
    controller: controller,
    obscureText: obscureText,
    decoration: InputDecoration(
      // Leading icon inside the input field
      prefixIcon: Icon(icon, color: const Color(0xFF2D4F48)),

      // Show a toggle icon for password visibility if toggle is provided
      suffixIcon: toggle != null
          ? IconButton(
              icon: Icon(
                obscureText ? Icons.visibility_off : Icons.visibility,
                color: const Color(0xFF2D4F48),
              ),
              onPressed: toggle,
            )
          : null,

      hintText: hint, // Text shown when the field is empty
      filled: true,
      fillColor: Colors.white.withOpacity(0.95), // Light background color
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF2D4F48)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF2D4F48), width: 1.5),
      ),
    ),
  );
}
