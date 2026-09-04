# Changelog

All notable changes to StowPaste are documented here. This project follows semantic versioning.

## [Unreleased]

### Fixed

- Made the website GitHub button start with a verified nonzero star count and refresh through a cached public badge endpoint instead of the frequently rate-limited unauthenticated GitHub API.

## [0.1.1] - 2026-09-04

### Changed

- Made the website and installation guide explicitly disclose that `v0.1.0` is not Developer ID signed or Apple-notarized.
- Added the macOS `Open Anyway` path, published checksum, source-review link, and Apple guidance alongside the download.
- Changed the primary direct-distribution format from PKG to a drag-to-Applications DMG.
- Added separate English and Chinese Finder installation windows, selected from the browser's primary language on the website.
- Added a real Chinese macOS Privacy & Security screenshot and matching localized `Open Anyway` guidance.
- Added a cache-busting download URL so previously cached release artifacts are not reused.
- Updated the public app and website downloads to patch release `v0.1.1`.

### Fixed

- Refresh Accessibility authorization when StowPaste becomes active, opens a panel or Settings, and during event-tap health checks.
- Reliably activate the macOS Accessibility settings pane from every authorization button.
- Explain how to replace a stale Accessibility entry after updating an ad-hoc-signed build.
- Record modifier shortcuts such as `⌘V` without incorrectly turning them into `V V`.
- Merge modifier state across `flagsChanged` and `keyDown`, ignore key-repeat events, and require a release between double taps.

## [0.1.0] - 2026-09-01

Initial public release.

### Added

- Native SwiftUI and AppKit menu bar application for macOS 14 or later.
- Local clipboard history for text, images, and files.
- Double-tap left Command (⌘⌘) as the default global shortcut, with configurable shortcuts in Settings.
- Keyboard and mouse navigation, click-to-paste, quick paste, panel movement, resizing, and screen pinning.
- Favorites, pinned items, renaming, deletion, custom groups, group ordering, and image grouping.
- Configurable history retention and launch at login.
- System, light, dark, and locally generated custom themes.
- Local persistence for clipboard history, images, groups, favorites, and settings.
- Official website, guide, privacy page, versioned direct download, and SHA-256 checksum.
- Universal Apple silicon and Intel build tooling.
- Apache License 2.0 source release, contribution guide, security policy, and third-party notices.

### Distribution note

The current `v0.1.1` direct download is a DMG. The application uses an identity-free ad-hoc signature; the app and disk image are not Developer ID signed, and the release is not notarized. macOS may require confirmation in System Settings → Privacy & Security on first launch. Replacing an existing build may require removing the old Accessibility entry and adding `/Applications/StowPaste.app` again.

[Unreleased]: https://github.com/TseringYuu/stowpaste/compare/v0.1.1...HEAD
[0.1.1]: https://github.com/TseringYuu/stowpaste/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/TseringYuu/stowpaste/releases/tag/v0.1.0
