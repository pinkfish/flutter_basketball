import 'package:basketballdata/basketballdata.dart';
import 'package:basketballdata/db/basketballdatabase.dart';
import 'package:basketballstats/services/authenticationbloc.dart';
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
import 'services/loginbloc.dart';

FirebaseAnalytics analytics = FirebaseAnalytics();

void main() {
  BlocSupervisor.delegate = _SimpleBlocDelegate();

  WidgetsFlutterBinding.ensureInitialized();

  analytics.logAppOpen();

  // Send error logs up to crashlytics.
  FlutterError.onError = Crashlytics.instance.recordFlutterError;

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // Log an error if the db fails to open.
    //_db.waitTillOpen();

    return RepositoryProvider<BasketballDatabase>(
      create: (BuildContext context) => MultiplexDatabase(),
      child: MultiBlocProvider(
        providers: <BlocProvider>[
          BlocProvider<TeamsBloc>(
            create: (BuildContext context) => TeamsBloc(
                db: RepositoryProvider.of<BasketballDatabase>(context)),
          ),
          BlocProvider<AuthenticationBloc>(
            create: (BuildContext context) =>
                AuthenticationBloc(analyticsSubsystem: analytics),
          ),
          BlocProvider<LoginBloc>(
            create: (BuildContext context) =>
                LoginBloc(analyticsSubsystem: analytics),
          )
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
            brightness: Brightness.dark,
            primarySwatch: Colors.green,
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.green,
          ),
          home: SplashScreen(),
          navigatorObservers: [
            FirebaseAnalyticsObserver(analytics: analytics),
          ],
          initialRoute: "Home",
          onGenerateRoute: _buildRoute,
        ),
      ),
    );
  }

  Route<dynamic> _buildRoute(RouteSettings routeSettings) {
    return AppRouter.instance.generator(routeSettings);
  }
}

class _SimpleBlocDelegate extends BlocDelegate {
  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print(transition);
  }
}
