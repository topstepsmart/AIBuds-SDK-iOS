# AIBuds Live Stream Flutter 开发者指南

本文档帮助开发者在 Flutter App 中集成插件，重点说明功能用法、参数、回调和常见集成方式。

## 平台支持

- iOS：已支持
- Android：暂未实现

建议使用真实 iOS 设备验证 RTSP 播放和 RTMP 推流。

## 安装

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

## iOS Framework 配置

插件封装了 AIBuds 原生 `.xcframework` 中间件。框架文件应放在：

```text
ios/Frameworks/
```

主要中间件：

```text
ios/Frameworks/AIBudsLiveStreamFlutterPlugin.xcframework
```

如果当前中间件版本依赖其他 AIBuds、FFmpeg、日志或资源框架，请保持同一套 iOS 打包和链接方式。

## 功能概览

- 使用 `AIBudsLiveStreamPlayerView` 渲染原生视频画面。
- 使用 `AIBudsLiveStreamPlayerController` 控制播放。
- 使用 `controller.events` 接收播放器回调。
- 使用 `AIBudsLiveStreamStreamerController` 将 RTSP 输入推送到 RTMP 地址。
- 使用 `AIBudsLiveStreamStreamerConfig` 配置清晰度、音频、自适应码率和重连。
- 使用 `AIBudsLiveStreamFlutter` 查询 SDK 信息。

## RTSP 播放示例

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

注意：调用播放器控制方法前，必须先创建 `AIBudsLiveStreamPlayerView`，否则控制器还没有绑定原生视图。

## 播放器视图

`AIBudsLiveStreamPlayerView` 是 iOS 原生播放器视图。

| 参数 | 类型 | 说明 |
| --- | --- | --- |
| `controller` | `AIBudsLiveStreamPlayerController` | 必填，用于控制和接收事件。 |
| `options` | `AIBudsLiveStreamPlayerOptions` | 初始播放参数。 |
| `creationParams` | `Map<String, dynamic>?` | 传给原生视图创建阶段的额外参数。 |
| `gestureRecognizers` | `Set<Factory<OneSequenceGestureRecognizer>>?` | 平台视图手势识别器。 |

## 播放器参数

| 参数 | 类型 | 说明 |
| --- | --- | --- |
| `url` | `String?` | 初始媒体地址，也可以通过 `play(url)` 设置。 |
| `format` | `AIBudsLiveStreamFormat?` | 媒体格式。 |
| `videoType` | `AIBudsLiveStreamVideoType?` | 视频类型或投影类型。 |
| `displayMode` | `AIBudsLiveStreamDisplayMode?` | 显示模式。 |
| `gravityMode` | `AIBudsLiveStreamGravityMode?` | 画面填充方式，默认 `resizeAspect`。 |
| `headers` | `Map<String, String>?` | 请求头。 |
| `volume` | `double?` | 音量，通常为 `0.0` 到 `1.0`。 |
| `muted` | `bool?` | 是否静音。 |

枚举：

- `AIBudsLiveStreamFormat`：`normal`、`rtsp`、`rtmp`、`hls`、`vr`、`fisheye`
- `AIBudsLiveStreamVideoType`：`normal`、`vr`、`fisheye`、`pano`、`custom`
- `AIBudsLiveStreamDisplayMode`：`normal`、`vrBox`
- `AIBudsLiveStreamGravityMode`：`resize`、`resizeAspect`、`resizeAspectFill`

## 播放器控制器

| 方法 | 说明 |
| --- | --- |
| `play(url, format, videoType, displayMode, gravityMode, headers)` | 开始播放。 |
| `pause()` | 暂停。 |
| `resume()` | 继续。 |
| `stop()` | 停止。 |
| `seek(Duration position)` | 跳转到指定位置。 |
| `setVolume(double volume)` | 设置音量。 |
| `setMuted(bool muted)` | 设置静音。 |
| `setGravityMode(AIBudsLiveStreamGravityMode gravityMode)` | 修改画面填充方式。 |
| `getState()` | 读取原生播放器状态。 |
| `disposePlayer()` | 释放播放器资源。 |

## 播放器回调

```dart
final subscription = controller.events.listen((event) {
  debugPrint(event.event);
  debugPrint(event.stateDescription);
});
```

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `data` | `Map<String, dynamic>` | 原始原生事件数据。 |
| `event` | `String` | 事件名称。 |
| `message` | `String?` | 可选消息。 |
| `stateDescription` | `String?` | 当前或新的播放器状态。 |
| `currentTime` | `double?` | 当前播放时间。 |
| `duration` | `double?` | 媒体总时长。 |
| `playableTime` | `double?` | 已缓冲或可播放时长。 |

请在 `dispose` 中取消订阅。

## RTSP 转 RTMP 推流示例

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

## 推流控制器

| 方法 | 说明 |
| --- | --- |
| `configure(inputURL, outputURL, config)` | 只配置，不立即开始。 |
| `startStreaming(inputURL, outputURL, config)` | 开始推流；如果已经配置过，参数可省略。 |
| `stopStreaming()` | 停止推流。 |
| `getState()` | 读取原生推流状态。 |
| `dispose()` | 释放推流资源。 |

## 推流参数

| 参数 | 类型 | 说明 |
| --- | --- | --- |
| `preset` | `AIBudsLiveStreamPreset?` | 预设质量。 |
| `videoBitrate` | `int?` | 视频码率。 |
| `audioBitrate` | `int?` | 音频码率。 |
| `videoWidth` | `int?` | 输出宽度。 |
| `videoHeight` | `int?` | 输出高度。 |
| `frameRate` | `int?` | 帧率。 |
| `audioSampleRate` | `int?` | 音频采样率。 |
| `audioChannels` | `int?` | 音频声道数。 |
| `publishAudio` | `bool?` | 是否推送音频。 |
| `connectionTimeout` | `double?` | 连接超时时间，单位秒。 |
| `adaptiveBitrate` | `bool?` | 是否启用自适应码率。 |
| `reconnectAttempts` | `int?` | 重连次数。 |
| `reconnectDelay` | `double?` | 重连间隔，单位秒。 |
| `useSharedRTSPIngest` | `bool?` | 原生中间件支持时，是否复用 RTSP 输入。 |

`AIBudsLiveStreamPreset`：`defaultConfig`、`highQuality`、`lowQuality`

## 推流回调

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `data` | `Map<String, dynamic>` | 原始原生事件数据。 |
| `event` | `String` | 事件名称。 |
| `message` | `String?` | 可选消息。 |
| `stateDescription` | `String?` | 当前或新的推流状态。 |
| `isStreaming` | `bool?` | 原生侧报告的推流状态。 |

## SDK 信息

```dart
final info = await AIBudsLiveStreamFlutter.getSDKInfo();
final sdkVersion = await AIBudsLiveStreamFlutter.getSDKVersion();
```

## 常见问题

- 控制器未绑定：先渲染 `AIBudsLiveStreamPlayerView`，再调用播放方法。
- RTSP 无法播放：确认 iOS 设备网络能访问 RTSP 地址。
- RTMP 无法推流：确认 RTMP 地址允许发布，并且 RTSP 输入可用。
- iOS 找不到 framework：确认 `.xcframework` 已放置并被 iOS 插件目标链接。
