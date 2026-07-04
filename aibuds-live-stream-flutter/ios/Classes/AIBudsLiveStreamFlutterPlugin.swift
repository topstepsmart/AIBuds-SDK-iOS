import Flutter
import UIKit
import AIBudsLiveStreamFlutterPlugin

public class AIBudsLiveStreamFlutterPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    AIBudsLiveStreamFlutterPluginSDK.register(with: registrar)
  }
}
