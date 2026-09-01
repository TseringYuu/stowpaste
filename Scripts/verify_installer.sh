#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "$0")" && pwd)/lib/paths.sh"
BUILD_APP="$ROOT/Scripts/build_app.sh"
BUILD_INSTALLER="$ROOT/Scripts/build_installer.sh"
POSTINSTALL="$ROOT/Scripts/installer/postinstall"

require_path() {
  local path="$1"
  local message="$2"
  if [[ ! -e "$ROOT/$path" ]]; then
    echo "Missing: $message" >&2
    exit 1
  fi
}

require_file_source() {
  local file="$1"
  local pattern="$2"
  local message="$3"
  if ! grep -Eq -- "$pattern" "$file"; then
    echo "Missing: $message" >&2
    exit 1
  fi
}

require_path "Scripts/build_installer.sh" "installer build script"
require_path "Scripts/installer/postinstall" "installer postinstall authorization helper"

require_file_source "$BUILD_APP" 'BUNDLE_ID="store\.aiware\.stowpaste"' 'app bundle id stays stable across installs'
require_file_source "$BUILD_APP" 'codesign --force --deep --sign "\$CODESIGN_IDENTITY"' 'app signing identity can be made stable outside local ad-hoc builds'
require_file_source "$BUILD_APP" 'select_codesign_identity\(\)' 'build selects a stable signing identity before falling back to ad-hoc signing'
require_file_source "$BUILD_APP" 'Developer ID Application' 'release builds prefer a stable Developer ID signing identity'
require_file_source "$BUILD_APP" 'Apple Development' 'local builds can still use a stable Apple Development identity'
require_file_source "$BUILD_APP" 'STOWPASTE_ALLOW_AD_HOC_SIGNING' 'local ad-hoc signing must be explicitly opted in'
require_file_source "$BUILD_APP" 'codesign -d -r-' 'build records the designated requirement used by macOS authorization'
require_file_source "$BUILD_APP" 'LICENSE\.txt' 'binary distribution includes the Apache-2.0 license'
require_file_source "$BUILD_APP" -- '-Xswiftc -gnone' 'release binary strips local compiler paths'
require_file_source "$BUILD_APP" 'file-prefix-map' 'release binary remaps source paths'
require_file_source "$BUILD_APP" 'debug-prefix-map' 'release binary remaps debug paths'
require_file_source "$BUILD_APP" 'strip -S -x' 'release binary strips compiler and linker metadata'
require_file_source "$BUILD_APP" 'THIRD_PARTY_NOTICES\.md' 'binary distribution includes third-party notices'
if [[ -e "$APP_RESOURCES_DIR/OfflineTranslation" ]]; then
  echo "Unexpected: app resources must not contain retired translation runtime or models" >&2
  exit 1
fi
if [[ -e "$APP_RESOURCES_DIR/StowPasteRecommendationRanker.json" ]]; then
  echo "Unexpected: app resources must not contain a retired recommendation ranker" >&2
  exit 1
fi
require_file_source "$BUILD_INSTALLER" 'pkgbuild' 'installer script builds a component package'
require_file_source "$BUILD_INSTALLER" 'productbuild' 'installer script builds a product installer package'
require_file_source "$BUILD_INSTALLER" '--install-location /Applications' 'installer places StowPaste.app into Applications'
require_file_source "$BUILD_INSTALLER" '"\$PKG_ROOT/\$DISPLAY_NAME\.app"' 'installer package root contains the app bundle directly'
require_file_source "$BUILD_INSTALLER" 'ditto --noextattr --noacl "\$APP_DIR" "\$PKG_ROOT/\$DISPLAY_NAME\.app"' 'installer copies app directly into the package root'
if grep -Eq 'PKG_ROOT/Applications' "$BUILD_INSTALLER"; then
  echo "Unexpected: installer package root should not include an Applications directory when install-location is /Applications" >&2
  exit 1
fi
require_file_source "$BUILD_INSTALLER" 'APP_VERSION="0\.1\.0"' 'installer artifact has a predictable 0.1.0 pkg name'
require_file_source "$BUILD_INSTALLER" 'PKG_VERSION="0\.1\.0"' 'installer package version matches the 0.1.0 release'
require_file_source "$BUILD_INSTALLER" '--scripts "\$SCRIPTS_DIR"' 'installer runs installation helper scripts'
require_file_source "$BUILD_INSTALLER" 'COPYFILE_DISABLE=1' 'installer avoids AppleDouble metadata files'
require_file_source "$BUILD_INSTALLER" 'ditto --noextattr --noacl' 'installer copies app bundle without extended metadata'
require_file_source "$BUILD_INSTALLER" 'xattr -cr "\$PKG_ROOT"' 'installer clears extended attributes before packaging'
require_file_source "$BUILD_INSTALLER" 'find "\$PKG_ROOT" -name "\._\*"' 'installer strips AppleDouble metadata before packaging'
require_file_source "$POSTINSTALL" 'x-apple\.systempreferences:com\.apple\.preference\.security\?Privacy_Accessibility' 'postinstall opens Accessibility authorization settings'
require_file_source "$POSTINSTALL" 'display dialog' 'postinstall asks whether to configure authorization'
require_file_source "$POSTINSTALL" 'STOWPASTE_CHECK_ACCESSIBILITY_ONLY=1' 'postinstall checks whether Accessibility is already authorized'
require_file_source "$POSTINSTALL" 'accessibilityStatus=0' 'postinstall skips authorization prompt when Accessibility is already trusted'
require_file_source "$POSTINSTALL" 'open -a "/Applications/StowPaste\.app"' 'postinstall launches the installed app'

echo "installer regression checks passed"
