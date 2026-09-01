#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "$0")" && pwd)/lib/paths.sh"

PKG="$WEBSITE_PACKAGE_DIR/public/downloads/StowPaste-v0.1.0.pkg"
CHECKSUM_FILE="$PKG.sha256"

if [[ ! -f "$PKG" || ! -f "$CHECKSUM_FILE" ]]; then
  echo "Missing: public PKG or checksum" >&2
  exit 1
fi

EXPECTED_SHA="$(awk 'NR == 1 { print $1 }' "$CHECKSUM_FILE")"
ACTUAL_SHA="$(shasum -a 256 "$PKG" | awk '{ print $1 }')"
if [[ "$EXPECTED_SHA" != "$ACTUAL_SHA" ]]; then
  echo "Unexpected: public PKG checksum does not match its checksum file" >&2
  exit 1
fi

AUDIT_DIR="$(mktemp -d)"
trap 'rm -rf "$AUDIT_DIR"' EXIT
pkgutil --expand-full "$PKG" "$AUDIT_DIR/unpacked" >/dev/null
APP_PATH="$(find "$AUDIT_DIR/unpacked" -type d -name 'StowPaste.app' -print -quit)"

if [[ -z "$APP_PATH" ]]; then
  echo "Missing: StowPaste.app in the public installer" >&2
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
