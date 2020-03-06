import 'package:basketballstats/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_driver/driver_extension.dart';

void main() {
  enableFlutterDriverExtension();
  WidgetsApp.debugAllowBannerOverride = false; // remove debug banner
  runApp(MyApp());
}
