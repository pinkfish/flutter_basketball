import 'package:basketballdata/basketballdata.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

class CrashReportingService implements CrashReporting {
  @override
  Future<void> recordError(exception, StackTrace stack, {context}) {
    if (!kIsWeb) {
      Crashlytics.instance.recordError(exception, stack, context: context);
    }
    return null;
  }
}
