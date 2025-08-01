import 'package:flutter/material.dart';

SizedBox buildCustomButton(BuildContext context,void Function()? onPressed, Icon icon, Text label) {
  return SizedBox(
    width: double.infinity,
    child: ElevatedButton.icon(
      onPressed: onPressed,
      icon: icon,
      label: label,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFF2D4F48),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32),
        ),
        textStyle: const TextStyle(fontSize: 18),
      ),
    ),
  );
}