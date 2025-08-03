// This file defines a custom app bar widget used throughout the application.

import 'package:flutter/material.dart';

import '../localization/app_localizations.dart';

/// A custom app bar widget that displays the app title with configurable actions.
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Optional action widgets to display on the app bar.
  final List<Widget>? actions;

  /// Initializes the custom app bar with optional action buttons.
  const CustomAppBar({super.key, this.actions});

  @override
  Widget build(BuildContext context) {
    final localizer = AppLocalizations.of(context)!;
    // Configure the app bar with transparent background, custom title color, and optional actions.
    return AppBar(
      title: Text("SynerSched", style: TextStyle(color: Color(0xFF2D4F48))),
      actions: actions,
      backgroundColor: Colors.transparent,
      foregroundColor: Color(0xFF2D4F48),
      elevation: 0,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
