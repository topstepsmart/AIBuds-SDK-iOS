import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'aibuds_live_stream_flutter.dart';

enum AIBudsLiveStreamFormat { normal, rtsp, rtmp, hls, vr, fisheye }

enum AIBudsLiveStreamVideoType { normal, vr, fisheye, pano, custom }

enum AIBudsLiveStreamDisplayMode { normal, vrBox }

enum AIBudsLiveStreamGravityMode { resize, resizeAspect, resizeAspectFill }

extension on Enum {
  String get channelValue {
    switch (this) {
      case AIBudsLiveStreamDisplayMode.vrBox:
        return 'vr_box';
      case AIBudsLiveStreamGravityMode.resizeAspect:
        return 'resize_aspect';
      case AIBudsLiveStreamGravityMode.resizeAspectFill:
        return 'resize_aspect_fill';
      default:
        return name;
    }
  }
}

class AIBudsLiveStreamPlayerOptions {
  const AIBudsLiveStreamPlayerOptions({
    this.url,
    this.format,
    this.videoType,
    this.displayMode,
    this.gravityMode = AIBudsLiveStreamGravityMode.resizeAspect,
    this.headers,
    this.volume,
    this.muted,
  });

  final String? url;
  final AIBudsLiveStreamFormat? format;
  final AIBudsLiveStreamVideoType? videoType;
  final AIBudsLiveStreamDisplayMode? displayMode;
  final AIBudsLiveStreamGravityMode? gravityMode;
  final Map<String, String>? headers;
  final double? volume;
  final bool? muted;

  Map<String, dynamic> toMap() {
    return cleanArguments(<String, dynamic>{
      'url': url,
      'format': format?.channelValue,
      'videoType': videoType?.channelValue,
      'displayMode': displayMode?.channelValue,
      'gravityMode': gravityMode?.channelValue,
      'headers': headers,
      'volume': volume,
      'muted': muted,
    });
  }
}

class AIBudsLiveStreamPlayerEvent {
  AIBudsLiveStreamPlayerEvent(this.data);

  final Map<String, dynamic> data;

  String get event => data['event']?.toString() ?? '';
  String? get message => data['message']?.toString();
  String? get stateDescription =>
      (data['stateDescription'] ?? data['newStateDescription'])?.toString();
  double? get currentTime => _doubleValue(data['currentTime']);
  double? get duration => _doubleValue(data['duration']);
  double? get playableTime => _doubleValue(data['playableTime']);
}

class AIBudsLiveStreamPlayerController {
  AIBudsLiveStreamPlayerController();

  int? _viewId;
  Stream<AIBudsLiveStreamPlayerEvent>? _events;

  bool get isAttached => _viewId != null;

  Stream<AIBudsLiveStreamPlayerEvent> get events {
    final viewId = _requireViewId();
    return _events ??= EventChannel(
      '$aibudsLiveStreamChannelName/player_$viewId/events',
    ).receiveBroadcastStream().map(
          (dynamic event) => AIBudsLiveStreamPlayerEvent(
            Map<String, dynamic>.from(event as Map),
          ),
        );
  }

  void attach(int viewId) {
    if (_viewId == viewId) {
      return;
    }
    _viewId = viewId;
    _events = null;
  }

  Future<void> play(
    String url, {
    AIBudsLiveStreamFormat? format,
    AIBudsLiveStreamVideoType? videoType,
    AIBudsLiveStreamDisplayMode? displayMode,
    AIBudsLiveStreamGravityMode? gravityMode,
    Map<String, String>? headers,
  }) {
    return _invoke<void>(
      'play',
      cleanArguments(<String, dynamic>{
        'url': url,
        'format': format?.channelValue,
        'videoType': videoType?.channelValue,
        'displayMode': displayMode?.channelValue,
        'gravityMode': gravityMode?.channelValue,
        'headers': headers,
      }),
    );
  }

  Future<void> resume() => _invoke<void>('resume');

  Future<void> pause() => _invoke<void>('pause');

  Future<void> stop() => _invoke<void>('stop');

  Future<bool?> seek(Duration position) {
    return _invoke<bool>('seek', <String, dynamic>{
      'position': position.inMilliseconds / 1000,
    });
  }

  Future<void> setVolume(double volume) {
    return _invoke<void>('setVolume', <String, dynamic>{'volume': volume});
  }

  Future<void> setMuted(bool muted) {
    return _invoke<void>('setMuted', <String, dynamic>{'muted': muted});
  }

  Future<void> setGravityMode(AIBudsLiveStreamGravityMode gravityMode) {
    return _invoke<void>('setGravityMode', <String, dynamic>{
      'gravityMode': gravityMode.channelValue,
    });
  }

  Future<Map<String, dynamic>> getState() async {
    final result = await _invoke<Map<dynamic, dynamic>>('getState');
    return Map<String, dynamic>.from(result ?? <dynamic, dynamic>{});
  }

  Future<void> disposePlayer() {
    if (_viewId == null) {
      return Future<void>.value();
    }
    return _invoke<void>('disposePlayer');
  }

  Future<T?> _invoke<T>(String method, [Map<String, dynamic>? arguments]) {
    return AIBudsLiveStreamFlutter.channel.invokeMethod<T>('player', {
      'viewId': _requireViewId(),
      'method': method,
      'arguments': arguments ?? <String, dynamic>{},
    });
  }

  int _requireViewId() {
    final viewId = _viewId;
    if (viewId == null) {
      throw StateError('AIBudsLiveStreamPlayerController is not attached.');
    }
    return viewId;
  }
}

class AIBudsLiveStreamPlayerView extends StatelessWidget {
  const AIBudsLiveStreamPlayerView({
    super.key,
    required this.controller,
    this.options = const AIBudsLiveStreamPlayerOptions(),
    this.creationParams,
    this.gestureRecognizers,
  });

  final AIBudsLiveStreamPlayerController controller;
  final AIBudsLiveStreamPlayerOptions options;
  final Map<String, dynamic>? creationParams;
  final Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers;

  @override
  Widget build(BuildContext context) {
    if (!Platform.isIOS) {
      return const ColoredBox(
        color: Colors.black,
        child: Center(
          child: Text(
            'AIBuds Live Stream player is available on iOS.',
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final params = <String, dynamic>{...options.toMap(), ...?creationParams};

    return UiKitView(
      viewType: aibudsLiveStreamPlayerViewType,
      creationParams: params,
      creationParamsCodec: const StandardMessageCodec(),
      gestureRecognizers: gestureRecognizers,
      onPlatformViewCreated: controller.attach,
    );
  }
}

double? _doubleValue(Object? value) {
  if (value is num) {
    return value.toDouble();
  }
  if (value is String) {
    return double.tryParse(value);
  }
  return null;
}
