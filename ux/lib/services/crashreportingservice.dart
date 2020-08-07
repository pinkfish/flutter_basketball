import 'dart:io';

import 'package:basketballdata/basketballdata.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info/package_info.dart';

class CrashReportingService implements CrashReporting {
  @override
  Future<void> recordError(exception, StackTrace stack, {context}) {
    if (!kIsWeb) {
      Crashlytics.instance.recordError(exception, stack, context: context);
    }
    return null;
  }

  Future<void> recordFlutterError(FlutterErrorDetails details) async {
    if (kIsWeb) {
      Crashlytics.instance.recordFlutterError(details);
    }
  }

  void setUser(FirebaseUser user) async {
    if (!kIsWeb) {
      if (user != null) {
        Crashlytics.instance.setUserIdentifier(user.uid);
      } else {
        Crashlytics.instance.setUserIdentifier("None");
      }
      Crashlytics.instance.setString("OS", Platform.operatingSystem);
      Crashlytics.instance
          .setString("OSVersion", Platform.operatingSystemVersion);
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      Crashlytics.instance.setString("version", packageInfo.version);
      Crashlytics.instance.setString("buildNumber", packageInfo.buildNumber);
    }
  }
}
