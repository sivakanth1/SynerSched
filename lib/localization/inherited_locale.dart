// This file defines the InheritedLocale class, an InheritedWidget that
// allows the current locale and a function to update it to be propagated
// throughout the widget tree, enabling widgets to access and react to
// changes in the app's locale.

import 'package:flutter/material.dart';

// Provides a way to manage and propagate the app's current locale throughout the widget tree.
class InheritedLocale extends InheritedWidget {
  /// Holds the current selected locale.
  final Locale locale;
  /// Function to update the locale dynamically.
  final void Function(Locale) setLocale;

  const InheritedLocale({
    super.key,
    required this.locale,
    required this.setLocale,
    required super.child,
  });

  /// Provides access to the nearest InheritedLocale up the widget tree.
  static InheritedLocale? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<InheritedLocale>();
  }

  /// Determines whether the widgets that depend on this should rebuild when the locale changes.
  @override
  bool updateShouldNotify(InheritedLocale oldWidget) =>
      locale != oldWidget.locale;
}
