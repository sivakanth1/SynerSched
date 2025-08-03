import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// This class is responsible for loading and providing localized strings
/// based on the current locale. It handles fetching translations from JSON
/// files and provides methods to retrieve translated text.
class AppLocalizations {
  final Locale locale;
  static late Map<String, String> _localizedStrings;

  AppLocalizations(this.locale);

  /// A delegate that helps Flutter load the localized resources for a given locale.
  /// It is used by the Flutter localization system to instantiate this class.
  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// Retrieves the current instance of AppLocalizations from the widget tree.
  /// This allows widgets to access localized strings easily.
  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  /// Loads the localized strings for the given locale by reading the appropriate
  /// JSON file from the assets. Parses the JSON and stores the key-value pairs
  /// for translation lookup.
  static Future<AppLocalizations> load(Locale locale) async {
    final localizations = AppLocalizations(locale);
    String jsonString = await rootBundle.loadString(
      'assets/lang/${locale.languageCode}.json',
    );
    Map<String, dynamic> jsonMap = json.decode(jsonString);
    _localizedStrings = jsonMap.map(
      (key, value) => MapEntry(key, value.toString()),
    );
    return localizations;
  }

  /// Returns the translated string for the given key.
  /// If the key does not exist, returns a placeholder indicating the missing translation.
  String translate(String key) => _localizedStrings[key] ?? '** $key **';

  /// Returns the translated string for the given key and replaces placeholders
  /// in the string with the provided arguments.
  /// Placeholders should be in the format {0}, {1}, etc.
  String translateWithArgs(String key, List<String> args) {
    String template = _localizedStrings[key] ?? '** $key **';
    for (int i = 0; i < args.length; i++) {
      template = template.replaceAll('{$i}', args[i]);
    }
    return template;
  }
}

/// A delegate class that helps Flutter determine which locales are supported,
/// how to load localized resources, and whether to reload them.
/// It is required by the Flutter localization system.
class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  /// Returns true if the given locale is supported by this delegate.
  /// Currently supports English ('en') and Spanish ('es').
  @override
  bool isSupported(Locale locale) => ['en', 'es'].contains(locale.languageCode);

  /// Loads the localized resources for the given locale by delegating
  /// to the AppLocalizations.load method.
  @override
  Future<AppLocalizations> load(Locale locale) => AppLocalizations.load(locale);

  /// Indicates whether the resources should be reloaded when the delegate changes.
  /// Returning false means the resources are cached and do not need to reload.
  @override
  bool shouldReload(LocalizationsDelegate<AppLocalizations> old) => false;
}
