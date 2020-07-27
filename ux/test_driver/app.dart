import 'package:basketballstats/main.dart';
import 'package:basketballstats/routes.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/material.dart';
import 'package:flutter_driver/driver_extension.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  // Set things up to work with flutter driver for integration testing.
  enableFlutterDriverExtension();

  getDatabasesPath()
      .then((String s) => deleteDatabase(join(s, 'basketball.db')));

  WidgetsApp.debugAllowBannerOverride = false; // remove debug banner
  var trace = FirebasePerformance.instance.newTrace("inttest");
  runApp(MyApp(true, trace, BasketballAppRouter.createRouter(trace)));
}
