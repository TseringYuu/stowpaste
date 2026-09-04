#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "$0")" && pwd)/lib/paths.sh"

BUILD_APP="$ROOT/Scripts/build_app.sh"
BUILD_DMG="$ROOT/Scripts/build_dmg.sh"
BUILD_INSTALLER="$ROOT/Scripts/build_installer.sh"

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
require_file_source "$BUILD_DMG" '\$\{DISPLAY_NAME\}-v\$\{APP_VERSION\}\.dmg' 'DMG artifact name identifies the versioned public build'
require_file_source "$BUILD_DMG" 'ditto --noextattr --noacl' 'DMG preserves the app bundle without extended metadata'
require_file_source "$BUILD_DMG" 'shasum -a 256' 'DMG build emits a SHA-256 checksum'
require_file_source "$BUILD_INSTALLER" 'APP_VERSION="0\.1\.0"' 'installer artifact name identifies the universal 0.1.0 build'

echo "packaging architecture regression checks passed"
