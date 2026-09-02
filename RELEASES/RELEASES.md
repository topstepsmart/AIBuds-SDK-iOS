# RELEASES

## V1.0.1-beta.5 (Build 20260902001)

**Release date:** 2026-09-02

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
- Enhanced AI chat capabilities.
- Improved AI service compatibility.
- Bundled ZipZap with the SDK to address security vulnerabilities in the upstream ZipZap SDK.
- Improved SDK stability.

## V1.0.0 (Build 20260824001)

**Release date:** 2026-08-24

### Features

- Initial release of the AIBuds SDK.
