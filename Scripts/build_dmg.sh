#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DISPLAY_NAME="StowPaste"
APP_VERSION="0.1.1"
DMG_LOCALE="${1:-en}"
DIST_DIR="$ROOT_DIR/dist"
APP_DIR="$DIST_DIR/$DISPLAY_NAME.app"

case "$DMG_LOCALE" in
  en)
    DMG_BASENAME="${DISPLAY_NAME}-v${APP_VERSION}.dmg"
    BACKGROUND_PATH="$ROOT_DIR/Scripts/assets/dmg-background-en.png"
    ;;
  zh|zh-CN)
    DMG_LOCALE="zh-CN"
    DMG_BASENAME="${DISPLAY_NAME}-v${APP_VERSION}-zh-CN.dmg"
    BACKGROUND_PATH="$ROOT_DIR/Scripts/assets/dmg-background-zh-CN.png"
    ;;
  *)
    echo "error: unsupported DMG locale '$DMG_LOCALE' (expected en or zh-CN)" >&2
    exit 1
    ;;
esac

DMG_DIR="$DIST_DIR/dmg-root-$DMG_LOCALE"
DMG_PATH="$DIST_DIR/$DMG_BASENAME"
CHECKSUM_PATH="$DMG_PATH.sha256"
DMG_RW_PATH="$DIST_DIR/${DISPLAY_NAME}-v${APP_VERSION}-${DMG_LOCALE}-readwrite.dmg"
MOUNT_DIR=""

cleanup() {
  if [[ -n "$MOUNT_DIR" ]]; then
    hdiutil detach "$MOUNT_DIR" >/dev/null 2>&1 || true
  fi
  rm -rf "$DMG_DIR"
  rm -f "$DMG_RW_PATH"
}
trap cleanup EXIT

if [[ ! -f "$BACKGROUND_PATH" ]]; then
  echo "error: missing DMG background: $BACKGROUND_PATH" >&2
  exit 1
fi

export COPYFILE_DISABLE=1
CODESIGN_IDENTITY="-" STOWPASTE_ALLOW_AD_HOC_SIGNING=1 "$ROOT_DIR/Scripts/build_app.sh" >/dev/null

cleanup
rm -f "$DMG_PATH" "$CHECKSUM_PATH"
mkdir -p "$DMG_DIR/.background"
ditto --noextattr --noacl "$APP_DIR" "$DMG_DIR/$DISPLAY_NAME.app"
ditto --noextattr --noacl "$BACKGROUND_PATH" "$DMG_DIR/.background/dmg-background.png"
ln -s /Applications "$DMG_DIR/Applications"
xattr -cr "$DMG_DIR" 2>/dev/null || true
find "$DMG_DIR" -name ".DS_Store" -delete
find "$DMG_DIR" -name "._*" -delete

hdiutil create \
  -volname "$DISPLAY_NAME" \
  -srcfolder "$DMG_DIR" \
  -ov \
  -format UDRW \
  "$DMG_RW_PATH" >/dev/null

ATTACH_OUTPUT="$(hdiutil attach \
  -readwrite \
  -noverify \
  -noautoopen \
  "$DMG_RW_PATH")"
MOUNT_DIR="$(printf '%s\n' "$ATTACH_OUTPUT" | awk 'index($0, "/Volumes/") { print substr($0, index($0, "/Volumes/")); exit }')"
if [[ -z "$MOUNT_DIR" || ! -d "$MOUNT_DIR" ]]; then
  echo "error: unable to determine mounted DMG path" >&2
  exit 1
fi
VOLUME_NAME="${MOUNT_DIR##*/}"

osascript <<OSA
tell application "Finder"
  tell disk "$VOLUME_NAME"
    open
    set dmgWindow to container window
    set current view of dmgWindow to icon view
    set toolbar visible of dmgWindow to false
    set statusbar visible of dmgWindow to false
    set pathbar visible of dmgWindow to false
    set bounds of dmgWindow to {100, 100, 900, 780}
    set viewOptions to icon view options of dmgWindow
    set arrangement of viewOptions to not arranged
    set icon size of viewOptions to 112
    set text size of viewOptions to 13
    set label position of viewOptions to bottom
    set shows item info of viewOptions to false
    set shows icon preview of viewOptions to true
    set background picture of viewOptions to file ".background:dmg-background.png"
    set position of item "$DISPLAY_NAME.app" to {208, 220}
    set position of item "Applications" to {590, 220}
    update without registering applications
    delay 2
    close dmgWindow
  end tell
end tell
OSA

sync
hdiutil detach "$MOUNT_DIR" >/dev/null
hdiutil convert \
  "$DMG_RW_PATH" \
  -format UDZO \
  -o "$DMG_PATH" >/dev/null

(
  cd "$DIST_DIR"
  shasum -a 256 "$(basename "$DMG_PATH")" > "$(basename "$CHECKSUM_PATH")"
)

cleanup
echo "$DMG_PATH"
