#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "$0")" && pwd)/lib/paths.sh"

BUILD_APP="$ROOT/Scripts/build_app.sh"
BUILD_DMG="$ROOT/Scripts/build_dmg.sh"
BUILD_INSTALLER="$ROOT/Scripts/build_installer.sh"
DMG_BACKGROUND_EN="$ROOT/Scripts/assets/dmg-background-en.svg"
DMG_BACKGROUND_ZH="$ROOT/Scripts/assets/dmg-background-zh-CN.svg"
DMG_GUIDE_SCREENSHOT="$ROOT/Scripts/assets/dmg-open-anyway-zh.png"

require_file_source() {
  local file="$1"
  local pattern="$2"
  local message="$3"
  if ! grep -Eq -- "$pattern" "$file"; then
    echo "Missing: $message" >&2
    exit 1
  fi
}

require_file_source "$BUILD_APP" 'BUILD_ARCHS=\$\{STOWPASTE_BUILD_ARCHS:-"arm64 x86_64"\}' 'normal app builds default to universal arm64 and x86_64'
require_file_source "$BUILD_APP" 'for arch in \$BUILD_ARCHS' 'normal app builds pass each requested architecture to SwiftPM'
require_file_source "$BUILD_APP" 'SWIFT_ARCH_FLAGS\+=\(--arch "\$arch"\)' 'normal app build uses SwiftPM architecture flags'
require_file_source "$BUILD_APP" 'BUILD_DIR="\$BUILD_PATH/apple/Products/Release"' 'normal app build copies the universal binary emitted by SwiftPM'
require_file_source "$BUILD_DMG" 'DMG_LOCALE="\$\{1:-en\}"' 'DMG build accepts an explicit locale and defaults to English'
require_file_source "$BUILD_DMG" '\$\{DISPLAY_NAME\}-v\$\{APP_VERSION\}\.dmg' 'English DMG uses the default versioned artifact name'
require_file_source "$BUILD_DMG" '\$\{DISPLAY_NAME\}-v\$\{APP_VERSION\}-zh-CN\.dmg' 'Chinese DMG uses a locale-qualified artifact name'
require_file_source "$BUILD_DMG" 'ditto --noextattr --noacl' 'DMG preserves the app bundle without extended metadata'
require_file_source "$BUILD_DMG" 'shasum -a 256' 'DMG build emits a SHA-256 checksum'
require_file_source "$BUILD_DMG" 'CODESIGN_IDENTITY="-"' 'public DMG forces identity-free ad-hoc signing'
require_file_source "$BUILD_DMG" 'set background picture' 'DMG configures a Finder background'
require_file_source "$BUILD_DMG" 'set position of item "\$DISPLAY_NAME\.app"' 'DMG positions the app for drag installation'
require_file_source "$BUILD_DMG" 'set position of item "Applications"' 'DMG positions the Applications shortcut'
require_file_source "$DMG_BACKGROUND_ZH" '拖动安装' 'Chinese DMG background includes Chinese drag guidance'
require_file_source "$DMG_BACKGROUND_ZH" '仍要打开' 'Chinese DMG background includes the real Chinese Gatekeeper action'
require_file_source "$DMG_BACKGROUND_ZH" 'dmg-open-anyway-zh\.png' 'Chinese DMG background embeds the real macOS screenshot'
require_file_source "$DMG_BACKGROUND_EN" 'DRAG TO INSTALL' 'English DMG background includes English drag guidance'
require_file_source "$DMG_BACKGROUND_EN" 'Open Anyway' 'English DMG background includes the English Gatekeeper action'
if [[ ! -f "$DMG_GUIDE_SCREENSHOT" ]]; then
  echo "Missing: real macOS Open Anyway guide screenshot" >&2
  exit 1
fi
require_file_source "$BUILD_INSTALLER" 'APP_VERSION="0\.1\.1"' 'installer artifact name identifies the universal 0.1.1 build'

echo "packaging architecture regression checks passed"
