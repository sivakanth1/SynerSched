import 'package:flutter/material.dart';

/// A global tab index manager that holds and notifies the current tab index.
class TabControllerProvider {
  /// Holds the current tab index and notifies listeners when it changes.
  static final ValueNotifier<int> tabIndex = ValueNotifier<int>(0);
}