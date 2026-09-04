#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DISPLAY_NAME="StowPaste"
APP_VERSION="0.1.0"
DIST_DIR="$ROOT_DIR/dist"
APP_DIR="$DIST_DIR/$DISPLAY_NAME.app"
DMG_DIR="$DIST_DIR/dmg-root"
DMG_PATH="$DIST_DIR/${DISPLAY_NAME}-v${APP_VERSION}.dmg"
CHECKSUM_PATH="$DMG_PATH.sha256"

export COPYFILE_DISABLE=1
CODESIGN_IDENTITY="-" STOWPASTE_ALLOW_AD_HOC_SIGNING=1 "$ROOT_DIR/Scripts/build_app.sh" >/dev/null

rm -rf "$DMG_DIR" "$DMG_PATH" "$CHECKSUM_PATH"
mkdir -p "$DMG_DIR"
ditto --noextattr --noacl "$APP_DIR" "$DMG_DIR/$DISPLAY_NAME.app"
ln -s /Applications "$DMG_DIR/Applications"
xattr -cr "$DMG_DIR" 2>/dev/null || true
find "$DMG_DIR" -name ".DS_Store" -delete
find "$DMG_DIR" -name "._*" -delete

hdiutil create \
  -volname "$DISPLAY_NAME" \
  -srcfolder "$DMG_DIR" \
  -ov \
  -format UDZO \
  "$DMG_PATH" >/dev/null

(
  cd "$DIST_DIR"
  shasum -a 256 "$(basename "$DMG_PATH")" > "$(basename "$CHECKSUM_PATH")"
)

rm -rf "$DMG_DIR"
echo "$DMG_PATH"
