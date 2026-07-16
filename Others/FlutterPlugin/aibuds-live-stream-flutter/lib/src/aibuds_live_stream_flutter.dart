import 'package:flutter/services.dart';

const String aibudsLiveStreamChannelName =
    'com.topstep.sdks.aibuds.live-stream.flutter-plugin';

const String aibudsLiveStreamPlayerViewType =
    'com.topstep.sdks.aibuds.live-stream.flutter-plugin/player-view';

class AIBudsLiveStreamFlutter {
  AIBudsLiveStreamFlutter._();

  static const MethodChannel _channel = MethodChannel(
    aibudsLiveStreamChannelName,
  );

  static MethodChannel get channel => _channel;

  static Future<String?> getPlatformVersion() {
    return _channel.invokeMethod<String>('getPlatformVersion');
  }

  static Future<String?> getSDKVersion() {
    return _channel.invokeMethod<String>('getSDKVersion');
  }

  static Future<String?> getSDKBuild() {
    return _channel.invokeMethod<String>('getSDKBuild');
  }

  static Future<String?> getSDKReleaseDate() {
    return _channel.invokeMethod<String>('getSDKReleaseDate');
  }

  static Future<String?> getSDKVersionDescription() {
    return _channel.invokeMethod<String>('getSDKVersionDescription');
  }

  static Future<String?> getAIBudsLiveStreamSDKVersion() {
    return _channel.invokeMethod<String>('getAIBudsLiveStreamSDKVersion');
  }

  static Future<String?> getAIBudsLiveStreamSDKVersionDescription() {
    return _channel.invokeMethod<String>(
      'getAIBudsLiveStreamSDKVersionDescription',
    );
  }

  static Future<Map<String, dynamic>> getSDKInfo() async {
    final result = await _channel.invokeMapMethod<String, dynamic>(
      'getSDKInfo',
    );
    return result ?? <String, dynamic>{};
  }
}

Map<String, dynamic> cleanArguments(Map<String, dynamic> arguments) {
  return Map<String, dynamic>.from(arguments)
    ..removeWhere((_, Object? value) => value == null);
}
