# AIBuds Live Stream Flutter 開発者ガイド

このドキュメントは、Flutter アプリにプラグインを組み込むためのガイドです。デモ説明ではなく、機能、パラメータ、コールバック、利用例を中心に説明します。

## 対応プラットフォーム

- iOS: 対応
- Android: 未実装

RTSP 再生と RTMP 配信の検証には実機 iOS デバイスを使用してください。

## インストール

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

## iOS Framework 設定

このプラグインは AIBuds ネイティブ `.xcframework` ミドルウェアをラップします。Framework は以下に配置します。

```text
ios/Frameworks/
```

主なミドルウェア:

```text
ios/Frameworks/AIBudsLiveStreamFlutterPlugin.xcframework
```

追加の AIBuds、FFmpeg、ログ、リソース framework が必要な場合は、同じ iOS パッケージング手順に含めてください。

## 機能概要

- `AIBudsLiveStreamPlayerView` でネイティブ映像ビューを表示。
- `AIBudsLiveStreamPlayerController` で再生制御。
- `controller.events` でプレイヤーイベントを購読。
- `AIBudsLiveStreamStreamerController` で RTSP 入力を RTMP へ配信。
- `AIBudsLiveStreamStreamerConfig` で画質、音声、ビットレート、再接続を設定。
- `AIBudsLiveStreamFlutter` で SDK 情報を取得。

## RTSP プレイヤー例

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

プレイヤー操作は `AIBudsLiveStreamPlayerView` が作成された後に呼び出してください。

## プレイヤービュー

| パラメータ | 型 | 説明 |
| --- | --- | --- |
| `controller` | `AIBudsLiveStreamPlayerController` | 必須。操作とイベントに使用します。 |
| `options` | `AIBudsLiveStreamPlayerOptions` | 初期プレイヤー設定。 |
| `creationParams` | `Map<String, dynamic>?` | ネイティブビュー作成時の追加パラメータ。 |
| `gestureRecognizers` | `Set<Factory<OneSequenceGestureRecognizer>>?` | PlatformView 用ジェスチャー認識器。 |

## プレイヤーオプション

| パラメータ | 型 | 説明 |
| --- | --- | --- |
| `url` | `String?` | 初期 URL。`play(url)` でも指定できます。 |
| `format` | `AIBudsLiveStreamFormat?` | メディア形式。 |
| `videoType` | `AIBudsLiveStreamVideoType?` | 映像タイプ。 |
| `displayMode` | `AIBudsLiveStreamDisplayMode?` | 表示モード。 |
| `gravityMode` | `AIBudsLiveStreamGravityMode?` | 映像のフィット方法。既定は `resizeAspect`。 |
| `headers` | `Map<String, String>?` | リクエストヘッダー。 |
| `volume` | `double?` | 音量。通常 `0.0` から `1.0`。 |
| `muted` | `bool?` | ミュート状態。 |

列挙値:

- `AIBudsLiveStreamFormat`: `normal`, `rtsp`, `rtmp`, `hls`, `vr`, `fisheye`
- `AIBudsLiveStreamVideoType`: `normal`, `vr`, `fisheye`, `pano`, `custom`
- `AIBudsLiveStreamDisplayMode`: `normal`, `vrBox`
- `AIBudsLiveStreamGravityMode`: `resize`, `resizeAspect`, `resizeAspectFill`

## プレイヤーコントローラ

| メソッド | 説明 |
| --- | --- |
| `play(url, format, videoType, displayMode, gravityMode, headers)` | 再生開始。 |
| `pause()` | 一時停止。 |
| `resume()` | 再開。 |
| `stop()` | 停止。 |
| `seek(Duration position)` | 指定位置へシーク。 |
| `setVolume(double volume)` | 音量設定。 |
| `setMuted(bool muted)` | ミュート設定。 |
| `setGravityMode(AIBudsLiveStreamGravityMode gravityMode)` | 表示フィット方法を変更。 |
| `getState()` | ネイティブ状態を取得。 |
| `disposePlayer()` | プレイヤーリソースを解放。 |

## プレイヤーイベント

```dart
final subscription = controller.events.listen((event) {
  debugPrint(event.event);
  debugPrint(event.stateDescription);
});
```

| フィールド | 型 | 説明 |
| --- | --- | --- |
| `data` | `Map<String, dynamic>` | ネイティブイベントの生データ。 |
| `event` | `String` | イベント名。 |
| `message` | `String?` | メッセージ。 |
| `stateDescription` | `String?` | 現在または新しい状態。 |
| `currentTime` | `double?` | 現在の再生時間。 |
| `duration` | `double?` | メディア長。 |
| `playableTime` | `double?` | 再生可能時間。 |

`dispose` で購読を解除してください。

## RTSP から RTMP への配信例

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
```

## ストリーマーコントローラ

| メソッド | 説明 |
| --- | --- |
| `configure(inputURL, outputURL, config)` | 開始せず設定だけ行う。 |
| `startStreaming(inputURL, outputURL, config)` | 配信開始。設定済みなら引数は省略可能。 |
| `stopStreaming()` | 配信停止。 |
| `getState()` | ネイティブ状態を取得。 |
| `dispose()` | リソースを解放。 |

## ストリーマー設定

| パラメータ | 型 | 説明 |
| --- | --- | --- |
| `preset` | `AIBudsLiveStreamPreset?` | 品質プリセット。 |
| `videoBitrate` | `int?` | 映像ビットレート。 |
| `audioBitrate` | `int?` | 音声ビットレート。 |
| `videoWidth` | `int?` | 出力幅。 |
| `videoHeight` | `int?` | 出力高さ。 |
| `frameRate` | `int?` | フレームレート。 |
| `audioSampleRate` | `int?` | 音声サンプルレート。 |
| `audioChannels` | `int?` | 音声チャンネル数。 |
| `publishAudio` | `bool?` | 音声を配信するか。 |
| `connectionTimeout` | `double?` | 接続タイムアウト秒数。 |
| `adaptiveBitrate` | `bool?` | 自動ビットレートを有効化。 |
| `reconnectAttempts` | `int?` | 再接続回数。 |
| `reconnectDelay` | `double?` | 再接続間隔秒数。 |
| `useSharedRTSPIngest` | `bool?` | 対応時に RTSP 入力を共有するか。 |

`AIBudsLiveStreamPreset`: `defaultConfig`, `highQuality`, `lowQuality`

## ストリーマーイベント

| フィールド | 型 | 説明 |
| --- | --- | --- |
| `data` | `Map<String, dynamic>` | ネイティブイベントの生データ。 |
| `event` | `String` | イベント名。 |
| `message` | `String?` | メッセージ。 |
| `stateDescription` | `String?` | 現在または新しい状態。 |
| `isStreaming` | `bool?` | ネイティブ側の配信中フラグ。 |

## SDK 情報

```dart
final info = await AIBudsLiveStreamFlutter.getSDKInfo();
final sdkVersion = await AIBudsLiveStreamFlutter.getSDKVersion();
```

## トラブルシューティング

- コントローラ未接続: 先に `AIBudsLiveStreamPlayerView` を表示してください。
- RTSP が再生できない: iOS 端末から RTSP URL に到達できるか確認してください。
- RTMP 配信できない: RTMP URL が publish を許可しているか確認してください。
- framework が見つからない: `.xcframework` が配置され、iOS ターゲットにリンクされているか確認してください。
