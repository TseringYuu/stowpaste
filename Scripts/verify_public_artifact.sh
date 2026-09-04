#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "$0")" && pwd)/lib/paths.sh"

DMG="$WEBSITE_PACKAGE_DIR/public/downloads/StowPaste-v0.1.0.dmg"
CHECKSUM_FILE="$DMG.sha256"

if [[ ! -f "$DMG" || ! -f "$CHECKSUM_FILE" ]]; then
  echo "Missing: public DMG or checksum" >&2
  exit 1
fi

EXPECTED_SHA="$(awk 'NR == 1 { print $1 }' "$CHECKSUM_FILE")"
ACTUAL_SHA="$(shasum -a 256 "$DMG" | awk '{ print $1 }')"
if [[ "$EXPECTED_SHA" != "$ACTUAL_SHA" ]]; then
  echo "Unexpected: public DMG checksum does not match its checksum file" >&2
  exit 1
fi

AUDIT_DIR="$(mktemp -d)"
MOUNT_POINT="$AUDIT_DIR/mount"
mkdir -p "$MOUNT_POINT"
cleanup() {
  hdiutil detach "$MOUNT_POINT" >/dev/null 2>&1 || true
  rm -rf "$AUDIT_DIR"
}
trap cleanup EXIT
hdiutil verify "$DMG" >/dev/null
hdiutil attach -readonly -nobrowse -mountpoint "$MOUNT_POINT" "$DMG" >/dev/null
APP_PATH="$MOUNT_POINT/StowPaste.app"

if [[ ! -d "$APP_PATH" ]]; then
  echo "Missing: StowPaste.app in the public DMG" >&2
  exit 1
fi
if [[ ! -L "$MOUNT_POINT/Applications" || "$(readlink "$MOUNT_POINT/Applications")" != "/Applications" ]]; then
  echo "Missing: Applications shortcut in the public DMG" >&2
  exit 1
fi

SIGNATURE="$(codesign -dv --verbose=4 "$APP_PATH" 2>&1 || true)"
if ! grep -Eq '^Signature=adhoc$' <<<"$SIGNATURE"; then
  echo "Unexpected: public app is not identity-free ad-hoc signed" >&2
  exit 1
fi
if grep -Eq '^Authority=' <<<"$SIGNATURE" || grep -E '^TeamIdentifier=' <<<"$SIGNATURE" | grep -Fqv 'TeamIdentifier=not set'; then
  echo "Unexpected: public app exposes a signing identity" >&2
  exit 1
fi

APP_BINARY="$APP_PATH/Contents/MacOS/StowPaste"
if rg -a -q '/Users/|/Volumes/|icloud\.com|-----BEGIN .*PRIVATE KEY-----' "$APP_BINARY"; then
  echo "Unexpected: public app binary contains a local path or private identity marker" >&2
  exit 1
fi

if ! file "$APP_BINARY" | grep -Eq 'x86_64.*arm64|arm64.*x86_64'; then
  echo "Unexpected: public app binary is not universal" >&2
  exit 1
fi

echo "public artifact checks passed"
