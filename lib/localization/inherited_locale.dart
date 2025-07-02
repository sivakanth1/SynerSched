import 'package:flutter/material.dart';

class InheritedLocale extends InheritedWidget {
  final Locale locale;
  final void Function(Locale) setLocale;

  const InheritedLocale({
    super.key,
    required this.locale,
    required this.setLocale,
    required Widget child,
  }) : super(child: child);

  static InheritedLocale? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<InheritedLocale>();
  }

  @override
  bool updateShouldNotify(InheritedLocale oldWidget) =>
      locale != oldWidget.locale;
}
