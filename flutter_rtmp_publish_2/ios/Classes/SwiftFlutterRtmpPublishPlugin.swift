import Flutter
import UIKit

public class SwiftFlutterRtmpPublishPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_rtmp_publish", binaryMessenger: registrar.messenger())
    let instance = SwiftFlutterRtmpPublishPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result("iOS " + UIDevice.current.systemVersion)
  }
}
