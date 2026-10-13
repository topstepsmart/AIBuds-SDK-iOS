# RELEASES

## V1.0.1-beta.13 (Build 20261013001)

**Release date:** 2026-10-13

### Features

- Improved speech input language selection for AI features by preferring an exact regional match, then another supported variant of the same language, and finally the service's default language. When no input language is specified, applicable services apply the same matching rules to the device's system language.
- Added support for over-ear headphones, allowing them to be recognized and their battery levels to be interpreted correctly.
- Refined device capability definitions and added information about the device’s hardware configuration.
- Improved media file importing and video stabilization to reduce excessive memory and CPU usage and prevent related app crashes.
- Enhanced the file import demo with a before-and-after view for comparing video stabilization results.
- Added a new API to format device media storage by deleting all media files.
- Apps can now check whether the connected device supports the find-device feature.
- Added the following device information:
    - Image-enhancement post-processing algorithm currently in use.
    - Recommended maximum recording duration options for video and audio.
    - Minimum battery level required for taking photos, recording video or audio, and transferring files.
- Enhanced AI Asking capabilities.
- Improved AI service compatibility.
- Bundled ZipZap with the SDK to address security vulnerabilities in the upstream ZipZap SDK.
- Added support for the FitCloud Pro and Jieli OTA protocols.
- Improved Swift 6 compatibility for the Live Stream Flutter plugin.
- Fixed an issue where voice data callbacks were not invoked during AI chat sessions.
- Fixed an issue that could cause apps to crash during Jieli OTA updates.
- Improved media file importing so hotspot disconnections during an import now terminate the operation and invoke the completion callback with an error.
- Bump MagicHelper SDK to 2.13.2 to fix a crash in the SDK.
- Raised the minimum supported iOS version to 15.0 for Xcode 27 compatibility; integrating apps must update their deployment target accordingly.
- Added support for Jieli glasses without onboard storage, including receiving captured photos directly over Bluetooth.
- Fixed device type recognition for audio glasses.
- Added audio support for JPEG live streaming on compatible devices; existing calls to the JPEG live streaming start API must supply the new `opusDataReceivedHandler` argument, using `nil` if audio is not needed.
- Added RTMP publishing from JPEG frames and PCM audio through the Live Stream SDK and the iOS Flutter plugin bridge.
- Fixed an issue where an AI response containing no playable voice data could leave the playback state active and prevent subsequent user speech from starting a new question.
- Added support for mapping StarBurst music pause intents to stop-playback intents.
- Added support for mapping StarBurst Spanish recording intents to start-audio-recording intents and video recording intents to start-video-recording intents.
- Improved SDK stability.

## V1.0.0 (Build 20260824001)

**Release date:** 2026-08-24

### Features

- Initial release of the AIBuds SDK.
