import 'package:flutter/material.dart';

Widget buildInputField({
  required TextEditingController controller,
  required String hint,
  required IconData icon,
  bool obscureText = false,
  VoidCallback? toggle,
}) {
  return TextField(
    controller: controller,
    obscureText: obscureText,
    decoration: InputDecoration(
      prefixIcon: Icon(icon, color: const Color(0xFF2D4F48)),
      suffixIcon: toggle != null
          ? IconButton(
              icon: Icon(
                obscureText ? Icons.visibility_off : Icons.visibility,
                color: const Color(0xFF2D4F48),
              ),
              onPressed: toggle,
            )
          : null,
      hintText: hint,
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.95),
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
