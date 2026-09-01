# Contributing to StowPaste

Thank you for helping improve StowPaste. Project-authored contributions are accepted under the Apache License 2.0 (`Apache-2.0`). By submitting a contribution, you confirm that you have the right to provide it under those terms.

## Development workflow

1. Create a focused branch from `main`.
2. Install website dependencies with `npm install` when website work is needed.
3. Build the macOS app with `swift build --package-path packages/app`.
4. Run `./Scripts/verify_all.sh`.
5. Run `git diff --check` and review the full diff before opening a pull request.

Use a short conventional prefix such as `feat:`, `fix:`, `docs:`, `test:`, `refactor:`, or `chore:`.

## Product boundaries

- Clipboard history and app settings must remain local unless a future proposal explicitly changes the product and privacy model.
- Network access, new permissions, new data collection, and new background processing require matching tests, documentation, privacy review, and release notes.
- Preserve compatibility with macOS 14 or later and both Apple silicon and Intel unless a documented release changes those requirements.
- User-facing documentation must describe only behavior present in the released code.

## Pull requests

Describe the problem, the chosen behavior, verification performed, and any impact on user data, permissions, packaging, signing, accessibility, or privacy. Add regression coverage for behavioral changes.

Do not commit build directories, local application state, clipboard contents, credentials, signing material, API keys, or personal data. The repository `.gitignore` covers common generated and secret-file patterns, but contributors are responsible for reviewing every staged file.

## Security issues

Do not open a public issue for an undisclosed vulnerability. Follow [SECURITY.md](SECURITY.md).

## Third-party material

Do not assume imported code, assets, fonts, models, or generated files can be relicensed under Apache-2.0. Record third-party material in [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md), preserve required notices, and verify compatibility before submission.
