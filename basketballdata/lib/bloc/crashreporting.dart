abstract class CrashReporting {
  Future<void> recordError(dynamic exception, StackTrace stack,
      {dynamic context});
}
