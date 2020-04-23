import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_rtmp_publish/flutter_rtmp_publish.dart';

void main() {
  const MethodChannel channel = MethodChannel('flutter_rtmp_publish');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await FlutterRtmpPublish.platformVersion, '42');
  });
}
