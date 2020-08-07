import 'package:basketballstats/services/crashreportingservice.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'basketballstatsapp.dart';

FirebaseAnalytics analytics = FirebaseAnalytics();
CrashReportingService crashReportingService = CrashReportingService();

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Setup crash reporting.
  crashReportingService.setUser(null);

  // Start startup trace.
  Trace trace;
  if (!kIsWeb) {
    trace = FirebasePerformance.instance.newTrace("startup");
    trace.start();
  }
  Bloc.observer = _SimpleBlocDelegate();

  WidgetsFlutterBinding.ensureInitialized();

  analytics.logAppOpen();

  // Send error logs up to crashlytics.
  FlutterError.onError = crashReportingService.recordFlutterError;

  runApp(BasketballStatsApp(false, trace, analytics, crashReportingService));
}

class _SimpleBlocDelegate extends BlocObserver {
  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print(transition);
  }
}
