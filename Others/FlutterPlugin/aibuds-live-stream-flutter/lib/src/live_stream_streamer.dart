import 'dart:async';

import 'package:flutter/services.dart';

import 'aibuds_live_stream_flutter.dart';

enum AIBudsLiveStreamPreset { defaultConfig, highQuality, lowQuality }

extension on AIBudsLiveStreamPreset {
  String get channelValue {
    switch (this) {
      case AIBudsLiveStreamPreset.highQuality:
        return 'high_quality';
      case AIBudsLiveStreamPreset.lowQuality:
        return 'low_quality';
      case AIBudsLiveStreamPreset.defaultConfig:
        return 'default';
    }
  }
}

class AIBudsLiveStreamStreamerConfig {
  const AIBudsLiveStreamStreamerConfig({
    this.preset,
    this.videoBitrate,
    this.audioBitrate,
    this.videoWidth,
    this.videoHeight,
    this.frameRate,
    this.audioSampleRate,
    this.audioChannels,
    this.publishAudio,
    this.connectionTimeout,
    this.adaptiveBitrate,
    this.reconnectAttempts,
    this.reconnectDelay,
    this.useSharedRTSPIngest,
  });

  final AIBudsLiveStreamPreset? preset;
  final int? videoBitrate;
  final int? audioBitrate;
  final int? videoWidth;
  final int? videoHeight;
  final int? frameRate;
  final int? audioSampleRate;
  final int? audioChannels;
  final bool? publishAudio;
  final double? connectionTimeout;
  final bool? adaptiveBitrate;
  final int? reconnectAttempts;
  final double? reconnectDelay;
  final bool? useSharedRTSPIngest;

  Map<String, dynamic> toMap() {
    return cleanArguments(<String, dynamic>{
      'preset': preset?.channelValue,
      'videoBitrate': videoBitrate,
      'audioBitrate': audioBitrate,
      'videoWidth': videoWidth,
      'videoHeight': videoHeight,
      'frameRate': frameRate,
      'audioSampleRate': audioSampleRate,
      'audioChannels': audioChannels,
      'publishAudio': publishAudio,
      'connectionTimeout': connectionTimeout,
      'adaptiveBitrate': adaptiveBitrate,
      'reconnectAttempts': reconnectAttempts,
      'reconnectDelay': reconnectDelay,
      'useSharedRTSPIngest': useSharedRTSPIngest,
    });
  }
}

class AIBudsLiveStreamStreamerEvent {
  AIBudsLiveStreamStreamerEvent(this.data);

  final Map<String, dynamic> data;

  String get event => data['event']?.toString() ?? '';
  String? get message => data['message']?.toString();
  String? get stateDescription =>
      (data['stateDescription'] ?? data['newStateDescription'])?.toString();
  bool? get isStreaming => data['isStreaming'] as bool?;
}

class AIBudsLiveStreamStreamerController {
  AIBudsLiveStreamStreamerController({String? streamerId})
    : streamerId =
          streamerId ?? 'streamer_${DateTime.now().microsecondsSinceEpoch}';

  final String streamerId;
  Stream<AIBudsLiveStreamStreamerEvent>? _events;

  Stream<AIBudsLiveStreamStreamerEvent> get events {
    return _events ??=
        EventChannel(
          '$aibudsLiveStreamChannelName/streamer_$streamerId/events',
        ).receiveBroadcastStream().map(
          (dynamic event) => AIBudsLiveStreamStreamerEvent(
            Map<String, dynamic>.from(event as Map),
          ),
        );
  }

  Future<Map<String, dynamic>> configure({
    required String inputURL,
    required String outputURL,
    AIBudsLiveStreamStreamerConfig config =
        const AIBudsLiveStreamStreamerConfig(),
  }) {
    return _stateInvoke('configure', <String, dynamic>{
      'inputURL': inputURL,
      'outputURL': outputURL,
      'config': config.toMap(),
    });
  }

  Future<void> startStreaming({
    String? inputURL,
    String? outputURL,
    AIBudsLiveStreamStreamerConfig? config,
  }) {
    return _invoke<void>(
      'startStreaming',
      cleanArguments(<String, dynamic>{
        'inputURL': inputURL,
        'outputURL': outputURL,
        'config': config?.toMap(),
      }),
    );
  }

  Future<void> stopStreaming() => _invoke<void>('stopStreaming');

  Future<Map<String, dynamic>> getState() => _stateInvoke('getState');

  Future<void> dispose() => _invoke<void>('disposeStreamer');

  Future<Map<String, dynamic>> _stateInvoke(
    String method, [
    Map<String, dynamic>? arguments,
  ]) async {
    final result = await _invoke<Map<dynamic, dynamic>>(method, arguments);
    return Map<String, dynamic>.from(result ?? <dynamic, dynamic>{});
  }

  Future<T?> _invoke<T>(String method, [Map<String, dynamic>? arguments]) {
    return AIBudsLiveStreamFlutter.channel.invokeMethod<T>('streamer', {
      'streamerId': streamerId,
      'method': method,
      'arguments': arguments ?? <String, dynamic>{},
    });
  }
}
