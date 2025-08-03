// Entry point for the SynerSched app. Performs initial setup such as
// Flutter binding initialization, orientation lock, Firebase, Firestore,
// timezone data, and notification service.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:syner_sched/localization/app_localizations.dart';
import 'package:syner_sched/routes/app_routes.dart';
import 'package:syner_sched/shared/notification_service.dart';
import 'package:syner_sched/shared/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'features/splash/splash_screen.dart';
import 'firebase_options.dart';
import 'localization/inherited_locale.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:stream_chat_flutter/stream_chat_flutter.dart' as stream;

void main() async {
  // Ensures Flutter bindings are initialized before using any plugins.
  WidgetsFlutterBinding.ensureInitialized();
  // Forces the app to remain in portrait orientation.
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  // Initializes Firebase with platform-specific configuration.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Configures Firestore to enable offline persistence with unlimited cache.
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );
  // Loads timezone data for scheduling notifications across timezones.
  tz.initializeTimeZones();
  // Initializes the notification service for handling local notifications.
  NotificationService().initialize();

  runApp(const MyApp());
}

// The root widget of the application.
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Default locale for the app, initially set to English.
  Locale _locale = const Locale('en');
  // Stream Chat client used for enabling real-time chat functionality.
  late final stream.StreamChatClient _streamClient;

  @override
  // Initializes the StreamChat client when the app starts.
  void initState() {
    super.initState();
    _streamClient = stream.StreamChatClient(
      'wrdqf8s3gjmh',
      logLevel: stream.Level.INFO,
    );
  }

  // Updates the app's locale dynamically.
  void _setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  // Builds the root widget tree including localization, themes, and routing.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SynerSched',
      // Sets light and dark themes for the app.
      theme: lightTheme,
      darkTheme: darkTheme,
      // Applies the current locale from inherited widget or default.
      locale: InheritedLocale.of(context)?.locale ?? _locale,
      debugShowCheckedModeBanner: false,
      // Declares supported app locales: English and Spanish.
      supportedLocales: const [Locale('en'), Locale('es')],
      // Provides localization delegates for Material, Widgets, and Cupertino.
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      restorationScopeId: 'root',
      // Wraps the entire app in StreamChat and localization context.
      builder: (context, child) {
        return Builder(
          builder: (innerContext) {
            return InheritedLocale(
              locale: _locale,
              setLocale: _setLocale,
              child: stream.StreamChat(
                client: _streamClient,
                child: stream.StreamChatTheme(
                  data: stream.StreamChatThemeData(),
                  child: child!,
                ),
              ),
            );
          },
        );
      },
      // Sets the initial screen to the splash screen.
      home: SplashScreen(setLocale: _setLocale, streamClient: _streamClient),
      // Handles dynamic route generation, injecting the StreamChat client.
      onGenerateRoute: (settings) {
        final routes = AppRoutes.routesWithStreamClient(_streamClient);
        final builder = routes[settings.name];
        if (builder != null) {
          return MaterialPageRoute(
            builder: (context) => builder(context),
            settings: settings,
          );
        }
        return null;
      },
    );
  }
}