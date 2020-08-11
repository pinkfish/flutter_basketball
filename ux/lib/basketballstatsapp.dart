import 'package:basketballdata/basketballdata.dart';
import 'package:basketballdata/db/basketballdatabase.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'messages.dart';
import 'routes.dart';
import 'screens/splashscreen.dart';
import 'services/authenticationbloc.dart';
import 'services/crashreportingservice.dart';
import 'services/localutilities.dart';
import 'services/loginbloc.dart';
import 'services/mediastreaming.dart';
import 'services/multiplexdatabase.dart';
import 'services/sqldbraw.dart';
import 'services/uploadfilesbackground.dart';

///
/// The main app class for the system.
///
class BasketballStatsApp extends StatelessWidget {
  final bool forceSql;
  final Trace startupTrace;
  final FirebaseAnalytics analytics;
  final CrashReportingService service;
  final GlobalKey<NavigatorState> finalKey = GlobalKey<NavigatorState>();

  BasketballStatsApp(
      this.forceSql, this.startupTrace, this.analytics, this.service);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    print("MyApp");
    // Log an error if the db fails to open.
    var db = SQLDBRaw();

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<CrashReporting>(
          create: (BuildContext context) => service,
          lazy: false,
        ),
        RepositoryProvider<BasketballDatabase>(
          create: (BuildContext context) =>
              MultiplexDatabase(forceSql, analytics, db, service),
          lazy: false,
        ),
        RepositoryProvider<MediaStreaming>(
          create: (BuildContext context) => MediaStreaming(),
          lazy: true,
        ),
        RepositoryProvider<UploadFilesBackground>(
          create: (BuildContext context) => UploadFilesBackground(),
          lazy: false,
        ),
        RepositoryProvider<Router>(
          create: (BuildContext context) =>
              BasketballAppRouter.createRouter(startupTrace, analytics),
        )
      ],
      child: MultiBlocProvider(
        providers: <BlocProvider>[
          BlocProvider<AuthenticationBloc>(
            create: (BuildContext context) => AuthenticationBloc(
                analyticsSubsystem: analytics, crashes: service),
          ),
          BlocProvider<LoginBloc>(
            create: (BuildContext context) => LoginBloc(
                analyticsSubsystem: analytics,
                db: RepositoryProvider.of<BasketballDatabase>(context),
                crashes: service),
          ),
          BlocProvider<TeamsBloc>(
            create: (BuildContext context) => TeamsBloc(
                db: RepositoryProvider.of<BasketballDatabase>(context),
                crashes: RepositoryProvider.of<CrashReporting>(context)),
          ),
        ],
        child: ValueListenableBuilder(
          valueListenable: Hive.box(LocalUtilities.settingsBox).listenable(),
          builder: (BuildContext context, Box<dynamic> box, Widget widget) {
            var str = box.get(LocalUtilities.themeMode);
            var mode = ThemeMode.values.firstWhere(
                (element) => element.toString() == str,
                orElse: () => ThemeMode.light);

            return BlocBuilder(
              cubit: BlocProvider.of<AuthenticationBloc>(context),
              builder: (BuildContext context, AuthenticationState state) {
                if (state is AuthenticationLoggedIn) {
                  BlocProvider.of<TeamsBloc>(context).add(TeamsReloadData());
                }
                return _materialApp(context, mode, finalKey);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _materialApp(BuildContext context, ThemeMode mode, Key navigatorKey) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        MessagesDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
      supportedLocales: const <Locale>[
        const Locale('en', 'US'),
        const Locale('en', 'UK'),
        const Locale('en', 'AU'),
      ],
      onGenerateTitle: (BuildContext context) =>
          Messages.of(context).titleOfApp,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.green,
      ),
      themeMode: mode,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.green,
      ),
      home: SplashScreen(),
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: analytics),
      ],
      initialRoute: "/Home/Splash",
      onGenerateRoute: (RouteSettings s) => _buildRoute(context, s),
    );
  }

  Route<dynamic> _buildRoute(
      BuildContext context, RouteSettings routeSettings) {
    print("${routeSettings.name}");
    // States on routes.
    var router = RepositoryProvider.of<Router>(context);
    return router.generator(routeSettings);
  }
}
