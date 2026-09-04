# StowPaste Development Guide

This guide is for maintainers building, testing, packaging, and releasing StowPaste. User-facing installation and usage live in [README.md](../README.md).

## Requirements

- macOS 14 or later.
- Xcode or a Swift 6.3+ toolchain.
- Node.js and npm for website development.
- A stable signing identity when producing an installable app:
  - `Developer ID Application` for direct release builds.
  - `Apple Development` for local development.

Set `STOWPASTE_ALLOW_AD_HOC_SIGNING=1` only for local builds when no signing identity is available. Reinstalling builds with a different identity may require users to grant Accessibility permission again.

## Repository structure

```text
packages/app/         Native SwiftUI and AppKit application
packages/website/     Official website, guide, privacy page, and download API
Scripts/              Build, packaging, installer, and verification scripts
docs/                 Maintainer documentation and README assets
```

## Build

Build the macOS package:

```bash
swift build --package-path packages/app
```

Install website dependencies and run its checks:

```bash
npm install
npm run website:build
npm --workspace @stowpaste/website run typecheck
```

Create the app bundle:

```bash
./Scripts/build_app.sh
```

The app bundle is written to `dist/StowPaste.app`.

## Direct-distribution packaging

The current release channel is the versioned DMG published on `stowpaste.aiware.store`.

```bash
./Scripts/build_dmg.sh en
./Scripts/build_dmg.sh zh-CN
```

Generated artifacts are written to `dist/` and must not be committed from that directory. The website's public download must be copied from the final verified artifact and accompanied by its SHA-256 file.

The published `v0.1.1` disk images are independent open-source builds: the app uses identity-free ad-hoc signing, and the app and DMGs are not Developer ID signed or notarized. Do not describe a future package as signed or notarized without checking the exact artifact.

## Verification

Run the complete repository suite:

```bash
./Scripts/verify_all.sh
git diff --check
```

The suite covers Swift build and tests, global shortcuts, focus restoration, panel behavior, history rows, custom groups, retention, themes, local data boundaries, installer payload layout, architecture, repository structure, and website type checking.

Before a release, also inspect the package directly:

```bash
hdiutil verify packages/website/public/downloads/StowPaste-v0.1.1.dmg
hdiutil verify packages/website/public/downloads/StowPaste-v0.1.1-zh-CN.dmg
shasum -a 256 packages/website/public/downloads/StowPaste-v0.1.1*.dmg
```

## Product and network rules

- Clipboard history, images, groups, favorites, and settings remain local to the Mac.
- The desktop target must not add network requests or a network client entitlement without an explicit product decision, privacy review, tests, and release documentation.
- New permissions, data flows, background work, or persistence formats require migration and regression coverage.
- The website reads the public GitHub star count for the repository header; this is separate from the desktop application's data path.

## Signing

`Scripts/build_app.sh` chooses a signing identity in this order:

1. `CODESIGN_IDENTITY`, when explicitly provided.
2. The first available `Developer ID Application` identity.
3. The first available `Apple Development` identity.
4. Ad-hoc signing only when `STOWPASTE_ALLOW_AD_HOC_SIGNING=1`.

Accessibility authorization is tied to the app identity. Keep the bundle identifier and signing identity stable across public updates.

## Optional App Store archive lane

StowPaste is not currently listed in the Mac App Store. The repository retains `Scripts/build_app_store_archive.sh` for future sandboxed archive validation.

```bash
STOWPASTE_SKIP_APP_STORE_UPLOAD=1 ./Scripts/build_app_store_archive.sh
```

Do not enable upload or publish App Store instructions until the signed build has passed clean-account QA and the distribution channel is actually available. See [Distribution and App Store Readiness](app-store-compliance.md).

## Open-source license

Project-authored source is licensed under Apache License 2.0. Contributions are provided under the same terms. Preserve [LICENSE](../LICENSE), [THIRD_PARTY_NOTICES.md](../THIRD_PARTY_NOTICES.md), and all dependency notices in source and binary redistributions.

## Release checklist

1. Update `CHANGELOG.md` and version metadata.
2. Run `./Scripts/verify_all.sh` and `git diff --check`.
3. Audit staged files for credentials, signing material, clipboard contents, local state, and generated build directories.
4. Build the app and installer from a clean checkout.
5. Verify the universal architectures, package payload, signatures, notarization status, and SHA-256 checksum.
6. Copy the exact PKG and checksum into the website download directory.
7. Verify the public download matches the local release artifact.
8. Create the release tag and publish release notes that match the shipped code.

## Local state

StowPaste stores application state under the user's Application Support directory. Logs and state files may contain clipboard-related information; never attach them to an issue without reviewing and redacting them first.
