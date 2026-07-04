# AIBuds Live Stream Flutter Developer Guide

This guide explains how to integrate the Flutter plugin in your app. It focuses on plugin features, parameters, events, and common usage patterns.

## Platform Support

- iOS: supported
- Android: not implemented yet

Use a physical iOS device for live RTSP playback and RTMP push streaming validation.

## Installation

Add the plugin:

```yaml
dependencies:
  aibuds_live_stream_flutter:
    path: path/to/aibuds-live-stream-flutter
```

Run:

```sh
flutter pub get
```

Import:

```dart
import 'package:aibuds_live_stream_flutter/aibuds_live_stream_flutter.dart';
```

## iOS Framework Setup

The plugin wraps native AIBuds `.xcframework` middleware. Keep the provided frameworks in:

```text
ios/Frameworks/
```

The primary middleware is:

```text
ios/Frameworks/AIBudsLiveStreamFlutterPlugin.xcframework
```

Keep any required AIBuds, FFmpeg, logging, or resource frameworks in the same iOS packaging flow. If Xcode cannot find a framework, confirm the framework exists and is linked or embedded by the iOS plugin target.

## Feature Overview

- Render native live video with `AIBudsLiveStreamPlayerView`.
- Control playback with `AIBudsLiveStreamPlayerController`.
- Listen to player callbacks with `controller.events`.
- Push an RTSP input stream to RTMP with `AIBudsLiveStreamStreamerController`.
- Configure streaming quality and reconnect behavior with `AIBudsLiveStreamStreamerConfig`.
- Query SDK metadata with `AIBudsLiveStreamFlutter`.

## RTSP Player Example

Render the native player view and control it with a controller.

```dart
import 'dart:async';

import 'package:aibuds_live_stream_flutter/aibuds_live_stream_flutter.dart';
import 'package:flutter/material.dart';

class RtspPlayerPage extends StatefulWidget {
  const RtspPlayerPage({super.key});

  @override
  State<RtspPlayerPage> createState() => _RtspPlayerPageState();
}

class _RtspPlayerPageState extends State<RtspPlayerPage> {
  final _controller = AIBudsLiveStreamPlayerController();
  final _urlController = TextEditingController(text: 'rtsp://');
  StreamSubscription<AIBudsLiveStreamPlayerEvent>? _events;
  String _state = 'idle';

  @override
  void initState() {
    super.initState();
    _events = _controller.events.listen((event) {
      setState(() {
        _state = event.stateDescription ?? event.event;
      });
      debugPrint('player event=${event.event}, state=${event.stateDescription}');
    });
  }

  Future<void> _play() {
    return _controller.play(
      _urlController.text.trim(),
      format: AIBudsLiveStreamFormat.rtsp,
      gravityMode: AIBudsLiveStreamGravityMode.resizeAspect,
    );
  }

  Future<void> _stop() {
    return _controller.stop();
  }

  @override
  void dispose() {
    _events?.cancel();
    _controller.disposePlayer();
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: AIBudsLiveStreamPlayerView(
            controller: _controller,
            options: const AIBudsLiveStreamPlayerOptions(
              format: AIBudsLiveStreamFormat.rtsp,
              gravityMode: AIBudsLiveStreamGravityMode.resizeAspect,
            ),
          ),
        ),
        Text('State: $_state'),
        TextField(controller: _urlController),
        FilledButton(onPressed: _play, child: const Text('Play')),
        OutlinedButton(onPressed: _stop, child: const Text('Stop')),
      ],
    );
  }
}
```

Important: call player methods after `AIBudsLiveStreamPlayerView` has been created. Otherwise the controller is not attached to a native view.

## Player View

`AIBudsLiveStreamPlayerView` is the native iOS preview widget.

| Parameter | Type | Description |
| --- | --- | --- |
| `controller` | `AIBudsLiveStreamPlayerController` | Required controller for commands and events. |
| `options` | `AIBudsLiveStreamPlayerOptions` | Initial player options. |
| `creationParams` | `Map<String, dynamic>?` | Extra parameters passed to native view creation. |
| `gestureRecognizers` | `Set<Factory<OneSequenceGestureRecognizer>>?` | Optional Flutter gesture recognizers for the platform view. |

On non-iOS platforms the widget shows a placeholder.

## Player Options

`AIBudsLiveStreamPlayerOptions` can be passed to the view at creation time.

| Parameter | Type | Description |
| --- | --- | --- |
| `url` | `String?` | Initial media URL. You can also call `controller.play(url)`. |
| `format` | `AIBudsLiveStreamFormat?` | Media format. |
| `videoType` | `AIBudsLiveStreamVideoType?` | Video projection/type metadata. |
| `displayMode` | `AIBudsLiveStreamDisplayMode?` | Display mode, such as normal or VR box. |
| `gravityMode` | `AIBudsLiveStreamGravityMode?` | How video fits the view. Defaults to `resizeAspect`. |
| `headers` | `Map<String, String>?` | Optional request headers. |
| `volume` | `double?` | Playback volume, normally `0.0` to `1.0`. |
| `muted` | `bool?` | Whether playback starts muted. |

### `AIBudsLiveStreamFormat`

- `normal`
- `rtsp`
- `rtmp`
- `hls`
- `vr`
- `fisheye`

### `AIBudsLiveStreamVideoType`

- `normal`
- `vr`
- `fisheye`
- `pano`
- `custom`

### `AIBudsLiveStreamDisplayMode`

- `normal`
- `vrBox`

### `AIBudsLiveStreamGravityMode`

- `resize`
- `resizeAspect`
- `resizeAspectFill`

## Player Controller

`AIBudsLiveStreamPlayerController` controls a single `AIBudsLiveStreamPlayerView`.

| Method | Description |
| --- | --- |
| `play(url, format, videoType, displayMode, gravityMode, headers)` | Start playback for a URL. |
| `pause()` | Pause playback. |
| `resume()` | Resume playback. |
| `stop()` | Stop playback. |
| `seek(Duration position)` | Seek to a playback position. |
| `setVolume(double volume)` | Set volume. |
| `setMuted(bool muted)` | Mute or unmute. |
| `setGravityMode(AIBudsLiveStreamGravityMode gravityMode)` | Change video fit mode. |
| `getState()` | Read native player state as a map. |
| `disposePlayer()` | Release native player resources. |

## Player Events

Listen with:

```dart
final subscription = controller.events.listen((event) {
  debugPrint(event.event);
  debugPrint(event.stateDescription);
});
```

`AIBudsLiveStreamPlayerEvent` fields:

| Field | Type | Description |
| --- | --- | --- |
| `data` | `Map<String, dynamic>` | Raw native event payload. |
| `event` | `String` | Native event name. |
| `message` | `String?` | Optional message. |
| `stateDescription` | `String?` | Current or new player state description. |
| `currentTime` | `double?` | Current playback time. |
| `duration` | `double?` | Media duration. |
| `playableTime` | `double?` | Playable/buffered time. |

Always cancel the event subscription in `dispose`.

## RTSP to RTMP Streaming Example

Use the streamer controller when you want to push an RTSP input stream to an RTMP server.

```dart
import 'dart:async';

import 'package:aibuds_live_stream_flutter/aibuds_live_stream_flutter.dart';

class StreamerService {
  final controller = AIBudsLiveStreamStreamerController();
  StreamSubscription<AIBudsLiveStreamStreamerEvent>? _events;

  void listen() {
    _events = controller.events.listen((event) {
      print('streamer event=${event.event}, streaming=${event.isStreaming}');
    });
  }

  Future<void> start({
    required String rtspUrl,
    required String rtmpUrl,
  }) {
    return controller.startStreaming(
      inputURL: rtspUrl,
      outputURL: rtmpUrl,
      config: const AIBudsLiveStreamStreamerConfig(
        preset: AIBudsLiveStreamPreset.defaultConfig,
        publishAudio: true,
        adaptiveBitrate: true,
        reconnectAttempts: 3,
        reconnectDelay: 2,
      ),
    );
  }

  Future<void> stop() {
    return controller.stopStreaming();
  }

  Future<void> dispose() async {
    await _events?.cancel();
    await controller.dispose();
  }
}
```

## Streamer Controller

| Method | Description |
| --- | --- |
| `configure(inputURL, outputURL, config)` | Configure input, output, and stream settings without starting. |
| `startStreaming(inputURL, outputURL, config)` | Start pushing stream. Parameters are optional if already configured. |
| `stopStreaming()` | Stop pushing stream. |
| `getState()` | Read native streamer state as a map. |
| `dispose()` | Release native streamer resources. |

## Streamer Config

`AIBudsLiveStreamStreamerConfig` controls push streaming behavior.

| Parameter | Type | Description |
| --- | --- | --- |
| `preset` | `AIBudsLiveStreamPreset?` | Convenience quality preset. |
| `videoBitrate` | `int?` | Video bitrate. |
| `audioBitrate` | `int?` | Audio bitrate. |
| `videoWidth` | `int?` | Output width. |
| `videoHeight` | `int?` | Output height. |
| `frameRate` | `int?` | Output frame rate. |
| `audioSampleRate` | `int?` | Audio sample rate. |
| `audioChannels` | `int?` | Audio channel count. |
| `publishAudio` | `bool?` | Whether to publish audio. |
| `connectionTimeout` | `double?` | Connection timeout in seconds. |
| `adaptiveBitrate` | `bool?` | Enable adaptive bitrate. |
| `reconnectAttempts` | `int?` | Number of reconnect attempts. |
| `reconnectDelay` | `double?` | Delay between reconnect attempts in seconds. |
| `useSharedRTSPIngest` | `bool?` | Whether native middleware should use shared RTSP ingest when supported. |

### `AIBudsLiveStreamPreset`

- `defaultConfig`
- `highQuality`
- `lowQuality`

## Streamer Events

Listen with:

```dart
final subscription = streamer.events.listen((event) {
  debugPrint(event.event);
  debugPrint(event.stateDescription);
  debugPrint('${event.isStreaming}');
});
```

`AIBudsLiveStreamStreamerEvent` fields:

| Field | Type | Description |
| --- | --- | --- |
| `data` | `Map<String, dynamic>` | Raw native event payload. |
| `event` | `String` | Native event name. |
| `message` | `String?` | Optional message. |
| `stateDescription` | `String?` | Current or new streamer state description. |
| `isStreaming` | `bool?` | Whether native streamer reports active streaming. |

## SDK Metadata

```dart
final platformVersion = await AIBudsLiveStreamFlutter.getPlatformVersion();
final sdkVersion = await AIBudsLiveStreamFlutter.getSDKVersion();
final sdkBuild = await AIBudsLiveStreamFlutter.getSDKBuild();
final releaseDate = await AIBudsLiveStreamFlutter.getSDKReleaseDate();
final info = await AIBudsLiveStreamFlutter.getSDKInfo();
```

## Recommended State Handling

Native event strings may vary by middleware version. Normalize state strings in your UI before comparing them.

```dart
String normalizeState(String? state) {
  final value = (state ?? '').toLowerCase();
  if (value.contains('play')) return 'playing';
  if (value.contains('buffer')) return 'buffering';
  if (value.contains('error') || value.contains('fail')) return 'error';
  if (value.contains('stop')) return 'stopped';
  if (value.contains('open') || value.contains('connect')) return 'opening';
  return value.isEmpty ? 'idle' : value;
}
```

## Troubleshooting

### Controller is not attached

Render `AIBudsLiveStreamPlayerView` before calling player commands.

### RTSP playback does not start

Check that the iOS device can reach the RTSP URL on the current network.

### RTMP push does not start

Check that the RTMP URL accepts publishing and that the RTSP input is reachable.

### iOS cannot find a framework

Confirm the required `.xcframework` files are present and linked by the iOS plugin target.
