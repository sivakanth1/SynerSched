/// This file defines the application's light and dark theme configurations.
/// These themes are applied globally throughout the app to ensure visual consistency.
import 'package:flutter/material.dart';

/// Light theme configuration using Material 3.
/// Sets the brightness to light and uses a blue color scheme.
final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primarySwatch: Colors.blue,
  useMaterial3: true,
);

/// Dark theme configuration using Material 3.
/// Sets the brightness to dark and uses a blue-grey color scheme.
final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primarySwatch: Colors.blueGrey,
  useMaterial3: true,
);
