#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_PACKAGE_DIR="$ROOT_DIR/packages/app"
APP_NAME="StowPaste"
DISPLAY_NAME="StowPaste"
BUNDLE_ID="store.aiware.stowpaste"
APP_VERSION="${STOWPASTE_APP_VERSION:-0.1.1}"
BUILD_PATH="${SWIFT_BUILD_PATH:-$ROOT_DIR/.build}"
BUILD_ARCHS=${STOWPASTE_BUILD_ARCHS:-"arm64 x86_64"}
BUILD_DIR="$BUILD_PATH/apple/Products/Release"
DIST_DIR="$ROOT_DIR/dist"
APP_DIR="$DIST_DIR/$DISPLAY_NAME.app"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"

select_codesign_identity() {
  if [[ -n "${CODESIGN_IDENTITY:-}" ]]; then
    echo "$CODESIGN_IDENTITY"
    return
  fi
  local identities
  identities="$(security find-identity -v -p codesigning 2>/dev/null || true)"
  local preferred
  preferred="$(printf "%s\n" "$identities" | sed -n 's/.*"\(Developer ID Application:[^"]*\)".*/\1/p' | head -n 1)"
  if [[ -n "$preferred" ]]; then
    echo "$preferred"
    return
  fi
  preferred="$(printf "%s\n" "$identities" | sed -n 's/.*"\(Apple Development:[^"]*\)".*/\1/p' | head -n 1)"
  if [[ -n "$preferred" ]]; then
    echo "$preferred"
    return
  fi
  echo ""
}

CODESIGN_IDENTITY="$(select_codesign_identity)"

cd "$APP_PACKAGE_DIR"
SWIFT_ARCH_FLAGS=()
for arch in $BUILD_ARCHS; do
  SWIFT_ARCH_FLAGS+=(--arch "$arch")
done
SWIFT_RELEASE_FLAGS=(
  -Xswiftc -gnone
  -Xswiftc -file-prefix-map
  -Xswiftc "$ROOT_DIR=."
  -Xswiftc -debug-prefix-map
  -Xswiftc "$ROOT_DIR=."
)
swift build -c release --build-path "$BUILD_PATH" "${SWIFT_ARCH_FLAGS[@]}" "${SWIFT_RELEASE_FLAGS[@]}" ${SWIFT_BUILD_FLAGS:-}

rm -rf "$APP_DIR"
mkdir -p "$MACOS_DIR" "$RESOURCES_DIR"
cp "$BUILD_DIR/$APP_NAME" "$MACOS_DIR/$APP_NAME"
strip -S -x "$MACOS_DIR/$APP_NAME"
if [[ -f "$APP_PACKAGE_DIR/Resources/AppIcon.icns" ]]; then
  cp "$APP_PACKAGE_DIR/Resources/AppIcon.icns" "$RESOURCES_DIR/AppIcon.icns"
fi
cp "$ROOT_DIR/LICENSE" "$RESOURCES_DIR/LICENSE.txt"
cp "$ROOT_DIR/THIRD_PARTY_NOTICES.md" "$RESOURCES_DIR/THIRD_PARTY_NOTICES.md"
find "$APP_PACKAGE_DIR/Resources" -maxdepth 1 -type f \
  ! -name "*.entitlements" \
  ! -name "PrivacyInfo.xcprivacy" \
  ! -name "AppIcon.icns" \
  -exec cp {} "$RESOURCES_DIR/" \;
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
  <string>$APP_VERSION</string>
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

if [[ -z "$CODESIGN_IDENTITY" ]]; then
  if [[ "${STOWPASTE_ALLOW_AD_HOC_SIGNING:-0}" == "1" ]]; then
    echo "warning: stable codesigning identity not found; using ad-hoc signing. Accessibility authorization may need to be granted again." >&2
    CODESIGN_IDENTITY="-"
  else
    echo "error: stable codesigning identity not found." >&2
    echo "Set CODESIGN_IDENTITY to Developer ID Application or Apple Development, or set STOWPASTE_ALLOW_AD_HOC_SIGNING=1 for local-only builds that may require reauthorization." >&2
    exit 1
  fi
fi

codesign --force --deep --sign "$CODESIGN_IDENTITY" "$APP_DIR" >/dev/null
codesign -d -r- "$APP_DIR" >/dev/null 2>"$DIST_DIR/$DISPLAY_NAME.designated-requirement.txt" || true

echo "$APP_DIR"
