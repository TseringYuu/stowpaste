#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_PACKAGE_DIR="$ROOT_DIR/packages/app"
APP_NAME="StowPaste"
DISPLAY_NAME="StowPaste"
BUNDLE_ID="store.aiware.stowpaste"
BUILD_PATH="${SWIFT_BUILD_PATH:-$ROOT_DIR/.build-app-store}"
BUILD_DIR="$BUILD_PATH/release"
DIST_DIR="$ROOT_DIR/dist/app-store"
APP_DIR="$DIST_DIR/$DISPLAY_NAME.app"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"
ENTITLEMENTS="$APP_PACKAGE_DIR/Resources/StowPaste.entitlements"
UNSIGNED_PKG="$DIST_DIR/${DISPLAY_NAME}_0.1.0_app_store_unsigned.pkg"
SIGNED_PKG="$DIST_DIR/${DISPLAY_NAME}_0.1.0_app_store.pkg"

require_supported_xcode() {
  local version
  version="$(xcodebuild -version 2>/dev/null | awk '/Xcode/{print $2; exit}')"
  local major="${version%%.*}"
  if [[ -z "$major" ]]; then
    echo "error: Xcode is required for the Mac App Store archive lane." >&2
    exit 1
  fi
  if [[ "$major" -lt 26 && "${STOWPASTE_ALLOW_OLDER_XCODE:-0}" != "1" ]]; then
    echo "error: App Store uploads require Xcode 26 or newer. Found Xcode $version." >&2
    echo "Set STOWPASTE_ALLOW_OLDER_XCODE=1 only for local dry-run validation that will not be uploaded." >&2
    exit 1
  fi
}

select_identity() {
  local requested="${1:-}"
  local pattern="$2"
  if [[ -n "$requested" ]]; then
    echo "$requested"
    return
  fi
  security find-identity -v -p codesigning 2>/dev/null \
    | sed -n "s/.*\"\($pattern[^\"]*\)\".*/\1/p" \
    | head -n 1
}

APP_STORE_APP_IDENTITY="$(select_identity "${APP_STORE_APP_IDENTITY:-}" "3rd Party Mac Developer Application:")"
APP_STORE_INSTALLER_IDENTITY="$(select_identity "${APP_STORE_INSTALLER_IDENTITY:-}" "3rd Party Mac Developer Installer:")"

require_supported_xcode

if [[ -z "$APP_STORE_APP_IDENTITY" ]]; then
  echo "error: missing 3rd Party Mac Developer Application signing identity." >&2
  echo "Set APP_STORE_APP_IDENTITY to the exact certificate name for CI or release machines." >&2
  exit 1
fi

if [[ -z "$APP_STORE_INSTALLER_IDENTITY" ]]; then
  echo "error: missing 3rd Party Mac Developer Installer signing identity." >&2
  echo "Set APP_STORE_INSTALLER_IDENTITY to the exact certificate name for CI or release machines." >&2
  exit 1
fi

cd "$APP_PACKAGE_DIR"
swift build -c release --build-path "$BUILD_PATH" ${SWIFT_BUILD_FLAGS:-}

rm -rf "$DIST_DIR"
mkdir -p "$MACOS_DIR" "$RESOURCES_DIR"
cp "$BUILD_DIR/$APP_NAME" "$MACOS_DIR/$APP_NAME"
cp "$APP_PACKAGE_DIR/Resources/AppIcon.icns" "$RESOURCES_DIR/AppIcon.icns"
cp "$APP_PACKAGE_DIR/Resources/PrivacyInfo.xcprivacy" "$RESOURCES_DIR/PrivacyInfo.xcprivacy"
cp "$ROOT_DIR/LICENSE" "$RESOURCES_DIR/LICENSE.txt"
cp "$ROOT_DIR/THIRD_PARTY_NOTICES.md" "$RESOURCES_DIR/THIRD_PARTY_NOTICES.md"
for resource_dir in "$APP_PACKAGE_DIR/Resources"/*; do
  if [[ -d "$resource_dir" && "$(basename "$resource_dir")" != "AppIcon.iconset" ]]; then
    ditto --noextattr --noacl "$resource_dir" "$RESOURCES_DIR/$(basename "$resource_dir")"
  fi
done

cat > "$CONTENTS_DIR/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleDevelopmentRegion</key>
  <string>zh_CN</string>
  <key>CFBundleExecutable</key>
  <string>$APP_NAME</string>
  <key>CFBundleIdentifier</key>
  <string>$BUNDLE_ID</string>
  <key>CFBundleInfoDictionaryVersion</key>
  <string>6.0</string>
  <key>CFBundleName</key>
  <string>$DISPLAY_NAME</string>
  <key>CFBundleDisplayName</key>
  <string>$DISPLAY_NAME</string>
  <key>CFBundleIconFile</key>
  <string>AppIcon</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>CFBundleShortVersionString</key>
  <string>0.1.0</string>
  <key>CFBundleVersion</key>
  <string>1</string>
  <key>LSMinimumSystemVersion</key>
  <string>14.0</string>
  <key>LSUIElement</key>
  <true/>
  <key>NSAppleEventsUsageDescription</key>
  <string>StowPaste uses Apple Events to restore the target app and paste selected clipboard history.</string>
  <key>NSAccessibilityUsageDescription</key>
  <string>StowPaste uses Accessibility permission to listen for the panel hotkey and paste selected content.</string>
  <key>NSHumanReadableCopyright</key>
  <string>Copyright © 2026 StowPaste contributors. Apache-2.0.</string>
</dict>
</plist>
PLIST

codesign --force --options runtime --entitlements "$ENTITLEMENTS" --sign "$APP_STORE_APP_IDENTITY" "$APP_DIR" >/dev/null
codesign --verify --deep --strict "$APP_DIR"

productbuild \
  --component "$APP_DIR" /Applications \
  "$UNSIGNED_PKG" >/dev/null

productsign \
  --sign "$APP_STORE_INSTALLER_IDENTITY" \
  "$UNSIGNED_PKG" \
  "$SIGNED_PKG" >/dev/null

if [[ "${STOWPASTE_SKIP_APP_STORE_UPLOAD:-0}" == "1" ]]; then
  echo "$SIGNED_PKG"
  exit 0
fi

if [[ -z "${APP_STORE_CONNECT_USERNAME:-}" || -z "${APP_STORE_CONNECT_PASSWORD:-}" ]]; then
  echo "error: set APP_STORE_CONNECT_USERNAME and APP_STORE_CONNECT_PASSWORD, or set STOWPASTE_SKIP_APP_STORE_UPLOAD=1." >&2
  exit 1
fi

xcrun altool --upload-app \
  --type macos \
  --file "$SIGNED_PKG" \
  --username "$APP_STORE_CONNECT_USERNAME" \
  --password "$APP_STORE_CONNECT_PASSWORD"

echo "$SIGNED_PKG"
