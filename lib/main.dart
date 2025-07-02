import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:syner_sched/localization/app_localizations.dart';
import 'package:syner_sched/routes/app_routes.dart';
import 'package:syner_sched/shared/theme.dart';

import 'localization/inherited_locale.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // lock portraitawait
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('en');

  void _setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SynerSched',
      theme: lightTheme,
      darkTheme: darkTheme,
      locale: _locale,
      debugShowCheckedModeBanner: false,
      supportedLocales: const [Locale('en'), Locale('es')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routes: AppRoutes.routes,
      initialRoute: AppRoutes.onboarding,
      builder: (context, child) {
        return InheritedLocale(
          locale: _locale,
          setLocale: _setLocale,
          child: child!,
        );
      },
    );
  }
}
