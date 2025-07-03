import 'package:flutter/material.dart';

class InheritedLocale extends InheritedWidget {
  final Locale locale;
  final void Function(Locale) setLocale;

  const InheritedLocale({
    super.key,
    required this.locale,
    required this.setLocale,
    required super.child,
  });

  static InheritedLocale? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<InheritedLocale>();
  }

  @override
  bool updateShouldNotify(InheritedLocale oldWidget) =>
      locale != oldWidget.locale;
}
