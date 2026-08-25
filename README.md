<div align="center">

<img src="https://docs-aibuds.github.io/img/logo.svg" alt="AIBuds SDK" width="112" />

# AIBuds SDK for iOS

**A modular iOS SDK for building connected AI wearable experiences.**

Connect smart glasses, earbuds, speakers, watches, badges, and other AI devices with a unified device, media, voice, and AI stack.

[![SDK](https://img.shields.io/badge/SDK-AIBuds%20for%20iOS-7c3aed)](https://docs-aibuds.github.io/)
[![Pod Version](https://img.shields.io/badge/Pod-1.0.0-7c3aed?logo=cocoapods&logoColor=white)](https://github.com/topstepsmart/AIBuds-SDK-iOS/releases/tag/1.0.0)
[![Release](https://img.shields.io/badge/Release-v1.0.0-2563eb)](https://github.com/topstepsmart/AIBuds-SDK-iOS/releases/tag/1.0.0)
[![Nightly](https://img.shields.io/badge/Nightly-v1.0.0-22c55e)](https://github.com/topstepsmart/AIBuds-SDK-iOS)

[![Platform](https://img.shields.io/badge/Platform-iOS%2013%2B-111827?logo=apple)](https://docs-aibuds.github.io/docs/getting-started/installation)
[![Languages](https://img.shields.io/badge/Swift%20%7C%20Objective--C-supported-f97316?logo=swift&logoColor=white)](https://docs-aibuds.github.io/docs/getting-started/quickstart)
[![CocoaPods](https://img.shields.io/badge/CocoaPods-1.16%2B-ee3322?logo=cocoapods&logoColor=white)](https://cocoapods.org/)
[![Release Date](https://img.shields.io/badge/Released-2026.08.24-10b981)](./RELEASES/RELEASES.md)

[![Last Commit](https://img.shields.io/github/last-commit/topstepsmart/AIBuds-SDK-iOS)](https://github.com/topstepsmart/AIBuds-SDK-iOS/commits)
[![License](https://img.shields.io/github/license/topstepsmart/AIBuds-SDK-iOS?color=10b981)](LICENSE)
[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/topstepsmart/AIBuds-SDK-iOS)

[Get Started](#-quick-start) · [Explore Features](#-features) · [Choose Modules](#-modules) · [Documentation](https://docs-aibuds.github.io/) · [API Reference](https://docs-aibuds.github.io/api-reference)

English · [简体中文文档](https://docs-aibuds.github.io/zh-Hans/)

</div>

---

## ✨ Overview

AIBuds SDK is a modular framework for discovering, connecting, and interacting with supported AIBuds AI devices. Start quickly with the complete `AllInOne` package, or install only the CocoaPods subspecs your product needs.

- **Unified connectivity** — Device discovery, connection lifecycle, persistent device records, and Bluetooth communication.
- **Built for AI wearables** — Smart glasses, earbuds, earrings, speakers, watches, electronic badges, and more.
- **Rich device capabilities** — Device information, controls, audio, recording, camera, media transfer, live streaming, and firmware updates.
- **End-to-end AI experiences** — AI chat, streaming ASR, TTS, summaries, translation, simultaneous interpretation, image generation, and Q&A.
- **Flexible architecture** — Use the complete SDK or compose a smaller integration from independent modules.
- **Production tooling** — Structured logs, crash reports, a local AI dashboard, video stabilization, and a comprehensive demo app.

> Availability depends on the connected device, installed SDK modules, and service configuration. Refer to the [documentation](https://docs-aibuds.github.io/docs/intro) and your target device capabilities.

## 🧩 Features

| Area | Capabilities |
| --- | --- |
| Device connectivity | BLE discovery, device enrollment, connection management, auto-reconnect, and persistence |
| Device control | Device information, time sync, volume, EQ, ANC, wear detection, and input mapping |
| Audio and media | Audio recording, file import, photo/video management, RTSP playback, and RTMP publishing |
| AI services | AI chat, AI recording, streaming ASR, TTS, summaries, translation, interpretation, and AIGC |
| Voice assistant | Service authorization, wake and command handling, capability and mode management |
| Device maintenance | Firmware OTA, camera OTA, device apps, storage information, and factory reset |
| Diagnostics | Configurable logging, log export, crash reports, AI Dashboard, and video stabilization |

## 🚀 Quick Start

### Requirements

| Tool | Minimum version |
| --- | --- |
| iOS | 13.0 |
| Xcode | 26.0 |
| CocoaPods | 1.16.0 |

### 1. Install the SDK

Use the complete package when you are evaluating the SDK or need most capabilities:

```ruby
platform :ios, '13.0'

target 'YourTargetName' do
  pod 'AIBudsSDK/AllInOne',
      :git => 'https://github.com/topstepsmart/AIBuds-SDK-iOS.git',
      :tag => '1.0.0'
end
```

For a smaller integration, select only the modules you need:

```ruby
target 'YourTargetName' do
  # ABMate BLE device communication
  pod 'AIBudsSDK/ABMate',
      :git => 'https://github.com/topstepsmart/AIBuds-SDK-iOS.git',
      :tag => '1.0.0'

  # Add one AI provider when required
  # pod 'AIBudsSDK/AI/StarBurst', :git => '...', :tag => '1.0.0'
  # pod 'AIBudsSDK/AI/MltCloud',  :git => '...', :tag => '1.0.0'
end
```

Use a local checkout while developing the SDK and app together:

```ruby
pod 'AIBudsSDK/AllInOne', :path => '../AIBuds-SDK-iOS'
```

> AIBuds SDK requires additional Podfile hooks for dynamic frameworks, private-header compatibility, and binary distribution. Copy the complete hooks from the [installation guide](https://docs-aibuds.github.io/docs/getting-started/installation) to avoid dependency or archive failures.

Install the dependencies and open the generated workspace:

```bash
pod install
open YourProject.xcworkspace
```

### 2. Add Bluetooth permissions

Add both usage descriptions to the application target's `Info.plist`. SDK initialization returns `false` when either key is missing.

```xml
<key>NSBluetoothWhileInUseUsageDescription</key>
<string>This app uses Bluetooth to connect to AIBuds devices.</string>
<key>NSBluetoothAlwaysUsageDescription</key>
<string>This app uses Bluetooth to communicate with AIBuds devices.</string>
```

Microphone, local network, Bonjour, background modes, Wi-Fi information, and hotspot entitlements are required only for the features that use them. See [Permissions and Entitlements](https://docs-aibuds.github.io/docs/getting-started/installation) for complete configuration snippets.

### 3. Initialize

Initialize the complete SDK from `AppDelegate` or `SceneDelegate`:

```swift
import AIBudsAllInOne

final class AppDelegate: UIResponder, UIApplicationDelegate, SDKDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        guard AIBudsAllInOneSDK.initialize(self) else {
            assertionFailure("AIBuds SDK initialization failed")
            return true
        }

        return true
    }
}
```

### 4. Discover devices

```swift
AIBudsSDK.startScanning(
    deviceFoundHandler: { device, isExistingDevice in
        print("Found \(device.name), RSSI: \(device.rssi)")
        print(isExistingDevice ? "Stored device" : "New device")
    },
    completion: {
        print("Scanning stopped")
    }
)
```

Convert a discovery result with `makeStorableDeviceFromDiscovered(_:)`, persist it with `StoredDevicesMgr`, and connect using `ConnectParams`. The [Quick Start guide](https://docs-aibuds.github.io/docs/getting-started/quickstart) covers enrollment, connection, commands, delegate callbacks, and disconnection in both Swift and Objective-C.

## 📦 Modules

| CocoaPods subspec | Purpose | Use it for |
| --- | --- | --- |
| `AIBudsSDK/AllInOne` | Complete device, AI, voice, media, and diagnostic stack | Fast evaluation or full-featured products |
| `AIBudsSDK/Core` | Base types, Bluetooth orchestration, models, and protocols | The foundation of a custom integration |
| `AIBudsSDK/ABMate` | ABMate BLE protocol and device APIs | Devices using the ABMate protocol |
| `AIBudsSDK/Audio` | Audio session, processing, and VAD | Voice and AI audio workflows |
| `AIBudsSDK/AI/StarBurst` | StarBurst AI provider | Products using StarBurst services |
| `AIBudsSDK/AI/MltCloud` | MltCloud AI provider | Products using MltCloud services |
| `AIBudsSDK/AI/Dashboard` | Local AI session dashboard | AI diagnostics and report inspection |
| `AIBudsSDK/VoiceAssistant` | On-device assistant authorization bridge | Offline voice assistants |
| `AIBudsSDK/LiveStream` | RTSP playback and RTMP publishing | Real-time audio/video experiences |
| `AIBudsSDK/VideoStabilization` | Six-axis imported video processing | Stabilizing smart-glasses recordings |
| `AIBudsSDK/Log/XLFacility` | Persistent logs and local log browser | Development and field diagnostics |
| `AIBudsSDK/CrashReporter` | Crash capture and persisted reports | Stability diagnostics |

Installing only `pod 'AIBudsSDK'` selects `Core`; it does not include ABMate, an AI provider, or optional features. See the [module reference](https://docs-aibuds.github.io/docs/getting-started/installation) for the complete dependency graph.

## 🧪 Demo App

[`AIBudsSDK-Demo`](./AIBudsSDK-Demo) demonstrates device discovery and connection, controls, OTA, audio/video, AI services, voice assistant integration, logs, and crash reporting.

```bash
cd AIBudsSDK-Demo
pod install
open AIBuds.xcworkspace
```

Before running the app:

1. Add the service-provider values required by your integration to `AIBudsSDK-Demo/AIBudsSDK-Demo/configs.plist`.
2. Select your development team and set a valid Bundle Identifier in Xcode.
3. Use a physical device to verify Bluetooth, hotspot, camera, and real-time media features.

## 📚 Documentation

| Resource | Description |
| --- | --- |
| [Documentation](https://docs-aibuds.github.io/) | Installation, configuration, concepts, and feature guides |
| [Quick Start](https://docs-aibuds.github.io/docs/getting-started/quickstart) | Initialization, discovery, enrollment, connection, and commands |
| [API Reference](https://docs-aibuds.github.io/api-reference) | Framework, type, and method reference |
| [Core Features](https://docs-aibuds.github.io/docs/core/basic-features/overview) | Device control, media, live streaming, and OTA |
| [AI Services](https://docs-aibuds.github.io/docs/ai/overview) | Providers, sessions, and AI capabilities |
| [Troubleshooting](https://docs-aibuds.github.io/docs/troubleshooting/common-issues) | Installation, initialization, discovery, and connection issues |
| [中文文档](https://docs-aibuds.github.io/zh-Hans/) | Complete Simplified Chinese documentation |

## 🛠️ FAQ

<details>
<summary><strong>Why does SDK initialization return false?</strong></summary>

First verify that both `NSBluetoothWhileInUseUsageDescription` and `NSBluetoothAlwaysUsageDescription` are present in the application target's `Info.plist`. Then confirm that your initialization code matches the modules installed in the Podfile.

</details>

<details>
<summary><strong>Should I use AllInOne or a modular installation?</strong></summary>

Choose `AllInOne` for prototypes, evaluation, and products that need most capabilities. For a production app exposing a limited feature set, select individual subspecs to reduce dependencies and application size.

</details>

<details>
<summary><strong>Why should I open the .xcworkspace file?</strong></summary>

CocoaPods integrates the SDK and its third-party dependencies into the generated workspace. After `pod install`, open `.xcworkspace` instead of the original `.xcodeproj`.

</details>

## 📄 Release and License

- Current release: `1.0.0` — August 24, 2026
- Release notes: [CHANGELOG](./CHANGELOG/CHANGELOG.md) · [RELEASES](./RELEASES/RELEASES.md)
- License: [MIT](./LICENSE)

---

<div align="center">

If AIBuds SDK helps your project, consider giving the repository a ⭐️ and following future releases.

[Read the Docs](https://docs-aibuds.github.io/) · [Report an Issue](https://github.com/topstepsmart/AIBuds-SDK-iOS/issues)

</div>
