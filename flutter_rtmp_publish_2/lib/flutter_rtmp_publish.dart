import 'dart:async';

import 'package:flutter/services.dart';

class FlutterRtmpPublish {
  static const MethodChannel _channel =
      const MethodChannel('flutter_rtmp_publish');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
