# AIBuds Live Stream Flutter Developer Guide

यह दस्तावेज़ Flutter app में plugin integrate करने के लिए है। इसमें demo UI की जगह plugin features, parameters, callbacks और usage examples पर ध्यान है।

## Platform Support

- iOS: supported
- Android: अभी implemented नहीं है

Live RTSP playback और RTMP push streaming verify करने के लिए physical iOS device इस्तेमाल करें।

## Installation

```yaml
dependencies:
  aibuds_live_stream_flutter:
    path: path/to/aibuds-live-stream-flutter
```

```sh
flutter pub get
```

```dart
import 'package:aibuds_live_stream_flutter/aibuds_live_stream_flutter.dart';
```

## iOS Framework Setup

Plugin native AIBuds `.xcframework` middleware wrap करता है। Frameworks यहां रखें:

```text
ios/Frameworks/
```

Primary middleware:

```text
ios/Frameworks/AIBudsLiveStreamFlutterPlugin.xcframework
```

अगर आपके middleware build को AIBuds, FFmpeg, logging या resource frameworks चाहिए, उन्हें भी iOS packaging flow में include करें।

## Feature Overview

- `AIBudsLiveStreamPlayerView` से native video view render करें।
- `AIBudsLiveStreamPlayerController` से playback control करें।
- `controller.events` से player callbacks सुनें।
- `AIBudsLiveStreamStreamerController` से RTSP input को RTMP output पर push करें।
- `AIBudsLiveStreamStreamerConfig` से quality, audio, adaptive bitrate और reconnect configure करें।
- `AIBudsLiveStreamFlutter` से SDK metadata लें।

## RTSP Player Example

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
      setState(() => _state = event.stateDescription ?? event.event);
    });
  }

  Future<void> _play() {
    return _controller.play(
      _urlController.text.trim(),
      format: AIBudsLiveStreamFormat.rtsp,
      gravityMode: AIBudsLiveStreamGravityMode.resizeAspect,
    );
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
          child: AIBudsLiveStreamPlayerView(controller: _controller),
        ),
        Text('State: $_state'),
        TextField(controller: _urlController),
        FilledButton(onPressed: _play, child: const Text('Play')),
        OutlinedButton(
          onPressed: _controller.stop,
          child: const Text('Stop'),
        ),
      ],
    );
  }
}
```

Player commands call करने से पहले `AIBudsLiveStreamPlayerView` render होना चाहिए, क्योंकि controller native view से attach होता है।

## Player View

| Parameter | Type | Description |
| --- | --- | --- |
| `controller` | `AIBudsLiveStreamPlayerController` | Required controller for commands and events. |
| `options` | `AIBudsLiveStreamPlayerOptions` | Initial player options. |
| `creationParams` | `Map<String, dynamic>?` | Native view creation के extra params. |
| `gestureRecognizers` | `Set<Factory<OneSequenceGestureRecognizer>>?` | Platform view gestures. |

## Player Options

| Parameter | Type | Description |
| --- | --- | --- |
| `url` | `String?` | Initial media URL. `play(url)` से भी दे सकते हैं। |
| `format` | `AIBudsLiveStreamFormat?` | Media format. |
| `videoType` | `AIBudsLiveStreamVideoType?` | Video type/projection. |
| `displayMode` | `AIBudsLiveStreamDisplayMode?` | Display mode. |
| `gravityMode` | `AIBudsLiveStreamGravityMode?` | Video fit mode. Default `resizeAspect`. |
| `headers` | `Map<String, String>?` | Request headers. |
| `volume` | `double?` | Volume, usually `0.0` to `1.0`. |
| `muted` | `bool?` | Mute state. |

Enums:

- `AIBudsLiveStreamFormat`: `normal`, `rtsp`, `rtmp`, `hls`, `vr`, `fisheye`
- `AIBudsLiveStreamVideoType`: `normal`, `vr`, `fisheye`, `pano`, `custom`
- `AIBudsLiveStreamDisplayMode`: `normal`, `vrBox`
- `AIBudsLiveStreamGravityMode`: `resize`, `resizeAspect`, `resizeAspectFill`

## Player Controller

| Method | Description |
| --- | --- |
| `play(url, format, videoType, displayMode, gravityMode, headers)` | Playback start करता है। |
| `pause()` | Playback pause करता है। |
| `resume()` | Playback resume करता है। |
| `stop()` | Playback stop करता है। |
| `seek(Duration position)` | Position पर seek करता है। |
| `setVolume(double volume)` | Volume set करता है। |
| `setMuted(bool muted)` | Mute/unmute करता है। |
| `setGravityMode(AIBudsLiveStreamGravityMode gravityMode)` | Video fit mode बदलता है। |
| `getState()` | Native player state map देता है। |
| `disposePlayer()` | Native player resources release करता है। |

## Player Events

```dart
final subscription = controller.events.listen((event) {
  debugPrint(event.event);
  debugPrint(event.stateDescription);
});
```

| Field | Type | Description |
| --- | --- | --- |
| `data` | `Map<String, dynamic>` | Raw native event payload. |
| `event` | `String` | Event name. |
| `message` | `String?` | Optional message. |
| `stateDescription` | `String?` | Current/new player state. |
| `currentTime` | `double?` | Current playback time. |
| `duration` | `double?` | Media duration. |
| `playableTime` | `double?` | Buffered/playable time. |

`dispose` में subscription cancel करें।

## RTSP to RTMP Streaming Example

```dart
final streamer = AIBudsLiveStreamStreamerController();

streamer.events.listen((event) {
  print('event=${event.event}, streaming=${event.isStreaming}');
});

await streamer.startStreaming(
  inputURL: 'rtsp://your-camera/live',
  outputURL: 'rtmp://your-server/app/stream-key',
  config: const AIBudsLiveStreamStreamerConfig(
    preset: AIBudsLiveStreamPreset.defaultConfig,
    publishAudio: true,
    adaptiveBitrate: true,
    reconnectAttempts: 3,
    reconnectDelay: 2,
  ),
);

await streamer.stopStreaming();
await streamer.dispose();
```

## Streamer Controller

| Method | Description |
| --- | --- |
| `configure(inputURL, outputURL, config)` | Start किए बिना configuration set करता है। |
| `startStreaming(inputURL, outputURL, config)` | Streaming start करता है; configured हो तो params optional हैं। |
| `stopStreaming()` | Streaming stop करता है। |
| `getState()` | Native streamer state map देता है। |
| `dispose()` | Streamer resources release करता है। |

## Streamer Config

| Parameter | Type | Description |
| --- | --- | --- |
| `preset` | `AIBudsLiveStreamPreset?` | Quality preset. |
| `videoBitrate` | `int?` | Video bitrate. |
| `audioBitrate` | `int?` | Audio bitrate. |
| `videoWidth` | `int?` | Output width. |
| `videoHeight` | `int?` | Output height. |
| `frameRate` | `int?` | Frame rate. |
| `audioSampleRate` | `int?` | Audio sample rate. |
| `audioChannels` | `int?` | Audio channel count. |
| `publishAudio` | `bool?` | Audio publish करना है या नहीं। |
| `connectionTimeout` | `double?` | Connection timeout seconds. |
| `adaptiveBitrate` | `bool?` | Adaptive bitrate enable करता है। |
| `reconnectAttempts` | `int?` | Reconnect attempts count. |
| `reconnectDelay` | `double?` | Reconnect delay seconds. |
| `useSharedRTSPIngest` | `bool?` | Supported हो तो shared RTSP ingest use करता है। |

`AIBudsLiveStreamPreset`: `defaultConfig`, `highQuality`, `lowQuality`

## Streamer Events

| Field | Type | Description |
| --- | --- | --- |
| `data` | `Map<String, dynamic>` | Raw native event payload. |
| `event` | `String` | Event name. |
| `message` | `String?` | Optional message. |
| `stateDescription` | `String?` | Current/new streamer state. |
| `isStreaming` | `bool?` | Native streaming flag. |

## SDK Metadata

```dart
final info = await AIBudsLiveStreamFlutter.getSDKInfo();
final sdkVersion = await AIBudsLiveStreamFlutter.getSDKVersion();
```

## Troubleshooting

- Controller not attached: पहले `AIBudsLiveStreamPlayerView` render करें।
- RTSP play नहीं होता: iOS device network से RTSP URL reachable है या नहीं check करें।
- RTMP push नहीं होता: RTMP URL publishing accept करता है या नहीं check करें।
- Framework missing: `.xcframework` मौजूद और iOS target से linked है या नहीं check करें।
