import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'basketballstatsapp.dart';

FirebaseAnalytics analytics = FirebaseAnalytics();

void main() {
  print("main");
  WidgetsFlutterBinding.ensureInitialized();
  Trace trace;
  if (!kIsWeb) {
    trace = FirebasePerformance.instance.newTrace("startup");
    trace.start();
  }
  Bloc.observer = _SimpleBlocDelegate();

  WidgetsFlutterBinding.ensureInitialized();

  analytics.logAppOpen();

  // Send error logs up to crashlytics.
  FlutterError.onError = Crashlytics.instance.recordFlutterError;

  runApp(BasketballStatsApp(false, trace, analytics));
}

class _SimpleBlocDelegate extends BlocObserver {
  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print(transition);
  }
}
