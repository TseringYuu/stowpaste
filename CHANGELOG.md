# Changelog

All notable changes to StowPaste are documented here. This project follows semantic versioning.

## [Unreleased]

No unreleased changes yet.

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
- Official website, guide, privacy page, versioned PKG download, and SHA-256 checksum.
- Universal Apple silicon and Intel build tooling.
- Apache License 2.0 source release, contribution guide, security policy, and third-party notices.

### Distribution note

The `v0.1.0` PKG is an early direct-distribution build. The application uses an identity-free ad-hoc signature, its outer installer is not signed with a Developer ID Installer certificate, and the release is not notarized. macOS may require confirmation in System Settings → Privacy & Security on first launch.

[Unreleased]: https://github.com/TseringYuu/stowpaste/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/TseringYuu/stowpaste/releases/tag/v0.1.0
