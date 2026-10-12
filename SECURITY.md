# Security Policy

## Supported Versions

Security fixes target the latest public release, currently `v0.1.3`. Update to that release before reporting a problem that has already been fixed.

## Reporting a Vulnerability

Please report security issues privately through [GitHub Security Advisories](https://github.com/TseringYuu/stowpaste/security/advisories/new). If GitHub advisories are unavailable, contact the project maintainer listed by the repository owner.

Do not disclose vulnerabilities publicly until a fix or mitigation is available.

## Sensitive Data

StowPaste stores clipboard history and local settings on device. Avoid sharing logs or state files that contain clipboard content.

The local app state is stored under the user's Application Support directory.

Image previews read clipboard image copies or referenced local image files on the same Mac. Deleting a history record removes its saved entry and unused stored image copy; it does not delete the original source file or clear the system clipboard. Explicit deletion is separate from the retention protection for favorites, pinned items, and grouped items.
