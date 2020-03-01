import 'package:basketballdata/basketballdata.dart';
import 'package:basketballstats/services/multiplexdatabase.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'messages.dart';
import 'routes.dart';
import 'screens/splashscreen.dart';

FirebaseAnalytics analytics = FirebaseAnalytics();

void main() {
  BlocSupervisor.delegate = SimpleBlocDelegate();

  WidgetsFlutterBinding.ensureInitialized();

  analytics.logAppOpen();

  // Send error logs up to crashlytics.
  FlutterError.onError = Crashlytics.instance.recordFlutterError;

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final MultiplexDatabase _db = new MultiplexDatabase();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // Log an error if the db fails to open.
    _db.open().catchError((Object e, StackTrace stack) {
      Crashlytics.instance.recordError(e, stack);
    }, test: (_) => true);

    return MultiBlocProvider(
      providers: <BlocProvider>[
        BlocProvider<TeamsBloc>(
          create: (BuildContext context) => TeamsBloc(db: _db),
        ),
      ],
      child: MaterialApp(
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
        onGenerateTitle: (BuildContext context) => Messages.of(context).title,
        theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          primarySwatch: Colors.blue,
        ),
        home: SplashScreen(),
        navigatorObservers: [
          FirebaseAnalyticsObserver(analytics: analytics),
        ],
        initialRoute: "Home",
        onGenerateRoute: _buildRoute,
      ),
    );
  }

  Route<dynamic> _buildRoute(RouteSettings routeSettings) {
    return AppRouter.instance.generator(routeSettings);
  }
}

class SimpleBlocDelegate extends BlocDelegate {
  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print(transition);
  }
}
