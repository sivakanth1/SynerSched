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
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );
  tz.initializeTimeZones();
  NotificationService().initialize();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('en');
  late final stream.StreamChatClient _streamClient;

  @override
  void initState() {
    super.initState();
    _streamClient = stream.StreamChatClient(
      'wrdqf8s3gjmh', // 👈 Use your real API key
      logLevel: stream.Level.INFO,
    );
  }

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
      locale: InheritedLocale.of(context)?.locale ?? _locale,
      debugShowCheckedModeBanner: false,
      supportedLocales: const [Locale('en'), Locale('es')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      restorationScopeId: 'root',
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
      home: SplashScreen(setLocale: _setLocale, streamClient: _streamClient),
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