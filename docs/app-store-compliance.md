# StowPaste Distribution and App Store Readiness

Last reviewed: 2026-09-04

This document records the current release channel and the checks required before any future Mac App Store submission. It is a maintainer reference, not a claim that StowPaste is listed in the App Store.

## Current distribution decision

- Current public version: `v0.1.1`.
- Supported platform: macOS 14 or later.
- Architectures: Apple silicon and Intel.
- Current public channel: versioned DMG download from `https://stowpaste.aiware.store`.
- Current App Store status: not submitted and not listed.
- Source license: Apache License 2.0.
- App data model: clipboard history, images, groups, favorites, and settings are stored locally in Application Support.
- App network boundary: the macOS target has no network client entitlement and does not upload clipboard content.

## Direct-distribution status

The published `v0.1.1` DMG has a verified SHA-256 checksum. The application bundle uses an identity-free ad-hoc signature, the disk image is not signed with a Developer ID identity, and the release has not been notarized. Replacing a previous ad-hoc build may require replacing the old Accessibility entry and reopening the app.

Before describing a future package as signed or notarized, verify all of the following against the exact public artifact:

```bash
hdiutil verify StowPaste-v0.1.1.dmg
spctl --assess --type open --context context:primary-signature --verbose StowPaste-v0.1.1.dmg
shasum -a 256 StowPaste-v0.1.1.dmg
```

Direct-distribution build scripts:

- `Scripts/build_app.sh`
- `Scripts/build_dmg.sh`
- `Scripts/build_installer.sh`

## Privacy Policy URL

Production URL: `https://stowpaste.aiware.store/privacy`

The policy must continue to match clipboard polling, local text and image persistence, file URL handling, retention, deletion, custom themes, support contact, and any website requests.

## Third-party Recipients

- The macOS application does not send clipboard history or theme prompts to a third-party service.
- The website reads the public repository star count from GitHub's repository API when the header is displayed. GitHub receives the normal network information associated with that browser request.
- Support receives only the email and message a user chooses to send.

## App Privacy Label Mapping

The following is the current product baseline. Re-evaluate it against Apple's latest definitions before any submission.

| Data type | Leaves the device | Linked to user | Tracking | Purpose |
| --- | --- | --- | --- | --- |
| Clipboard text | No | No | No | App functionality |
| Clipboard images | No | No | No | App functionality |
| Clipboard file URLs and names | No | No | No | App functionality |
| Groups, favorites, and settings | No | No | No | App functionality |
| Custom theme descriptions | No | No | No | App functionality |
| Support email and message | Only when sent by the user | Yes | No | Support |

## Optional Mac App Store Build Lane

`Scripts/build_app_store_archive.sh` is retained for future archive validation. It is not the current release path.

- Application identity: `3rd Party Mac Developer Application`.
- Installer identity: `3rd Party Mac Developer Installer`.
- Sandbox entitlements: `packages/app/Resources/StowPaste.entitlements`.
- Privacy manifest: `packages/app/Resources/PrivacyInfo.xcprivacy`.
- Local archive validation: `STOWPASTE_SKIP_APP_STORE_UPLOAD=1 ./Scripts/build_app_store_archive.sh`.

Before enabling upload or announcing App Store availability:

1. Test clipboard capture, file URLs, paste automation, Accessibility authorization, launch at login, and first launch using a correctly signed sandboxed build on a clean macOS account.
2. Confirm App Store Connect identifiers, signing identities, privacy answers, support URL, and the public privacy policy.
3. Recheck current Apple review, privacy manifest, sandbox, Accessibility, and notarization requirements.
4. Update the README, website, changelog, download API, and release notes only after the distribution channel is actually available.

## Release checklist

1. Update `CHANGELOG.md` and all version metadata.
2. Run `./Scripts/verify_all.sh` and `git diff --check`.
3. Build the exact public artifact from a clean checkout.
4. Verify architecture, payload paths, code signature, installer signature, notarization status, and checksum.
5. Confirm the website download and checksum match the release artifact byte for byte.
6. Review the staged repository for secrets, personal data, local state, and generated files.
