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
import 'package:localstorage/localstorage.dart';

import 'messages.dart';
import 'routes.dart';
import 'screens/splashscreen.dart';
import 'services/authenticationbloc.dart';
import 'services/crashreportingservice.dart';
import 'services/localstoragedata.dart';
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

  BasketballStatsApp(this.forceSql, this.startupTrace, this.analytics);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    print("MyApp");
    // Log an error if the db fails to open.
    var db = SQLDBRaw();
    var localStorage = LocalStorage("basketballstats");

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<CrashReporting>(
          create: (BuildContext context) => CrashReportingService(),
          lazy: false,
        ),
        RepositoryProvider<BasketballDatabase>(
          create: (BuildContext context) => MultiplexDatabase(forceSql,
              analytics, db, RepositoryProvider.of<CrashReporting>(context)),
          lazy: false,
        ),
        RepositoryProvider<MediaStreaming>(
          create: (BuildContext context) => MediaStreaming(),
          lazy: true,
        ),
        RepositoryProvider<UploadFilesBackground>(
          create: (BuildContext context) => UploadFilesBackground(db),
          lazy: false,
        ),
        RepositoryProvider<LocalStorage>(
          create: (BuildContext contxt) => localStorage,
          lazy: false,
        ),
        RepositoryProvider<Router>(
          create: (BuildContext context) =>
              BasketballAppRouter.createRouter(startupTrace),
        )
      ],
      child: MultiBlocProvider(
        providers: <BlocProvider>[
          BlocProvider<AuthenticationBloc>(
            create: (BuildContext context) => AuthenticationBloc(
                analyticsSubsystem: analytics,
                crashes: RepositoryProvider.of<CrashReporting>(context)),
          ),
          BlocProvider<LoginBloc>(
            create: (BuildContext context) => LoginBloc(
                analyticsSubsystem: analytics,
                db: RepositoryProvider.of<BasketballDatabase>(context),
                crashes: RepositoryProvider.of<CrashReporting>(context)),
          ),
        ],
        child: StreamBuilder(
          stream: localStorage.stream,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            var str = localStorage.getItem(LocalStorageData.themeMode);
            var mode = ThemeMode.values.firstWhere(
                (element) => element.toString() == str,
                orElse: () => ThemeMode.light);

            return BlocBuilder(
              cubit: BlocProvider.of<AuthenticationBloc>(context),
              builder: (BuildContext contex, AuthenticationState state) {
                if (!kIsWeb || state is AuthenticationLoggedIn) {
                  print("Making a team!");
                  return BlocProvider<TeamsBloc>(
                    create: (BuildContext context) => TeamsBloc(
                        db: RepositoryProvider.of<BasketballDatabase>(context),
                        crashes:
                            RepositoryProvider.of<CrashReporting>(context)),
                    child: _materialApp(context, mode),
                  );
                } else {
                  return _materialApp(context, mode);
                }
              },
            );
          },
        ),
      ),
    );
  }

  Widget _materialApp(BuildContext context, ThemeMode mode) {
    return MaterialApp(
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
      initialRoute: "Home",
      onGenerateRoute: (RouteSettings s) => _buildRoute(context, s),
    );
  }

  Route<dynamic> _buildRoute(
      BuildContext context, RouteSettings routeSettings) {
    print("${routeSettings.name}");
    var router = RepositoryProvider.of<Router>(context);
    return router.generator(routeSettings);
  }
}
