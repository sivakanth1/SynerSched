import 'package:flutter/material.dart';

/// Builds a reusable elevated button with an icon and label,
/// commonly used across the app for consistent styling.
///
/// Parameters:
/// - [context]: The build context for theme reference.
/// - [onPressed]: The callback to be executed when the button is tapped.
/// - [icon]: The icon displayed on the left side of the button.
/// - [label]: The text label displayed on the button.
SizedBox buildCustomButton(BuildContext context,void Function()? onPressed, Icon icon, Text label) {
  return SizedBox(
    width: double.infinity, // Makes the button take full horizontal width
    child: ElevatedButton.icon(
      onPressed: onPressed, // Button tap callback
      icon: icon,           // Icon widget to display on the button
      label: label,         // Text label for the button
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,              // Text/icon color
        backgroundColor: const Color(0xFF2D4F48),   // Button background color
        padding: const EdgeInsets.symmetric(vertical: 16), // Vertical padding for touch target
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32),  // Rounded corners
        ),
        textStyle: const TextStyle(fontSize: 18),   // Font styling
      ),
    ),
  );
}