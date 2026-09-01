#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "$0")" && pwd)/lib/paths.sh"
SOURCE="$APP_SOURCE"

require_path() {
  local path="$1"
  local message="$2"
  if [[ ! -e "$ROOT/$path" ]]; then
    echo "Missing: $message" >&2
    exit 1
  fi
}

reject_path() {
  local path="$1"
  local message="$2"
  if [[ -e "$ROOT/$path" ]]; then
    echo "Unexpected: $message" >&2
    exit 1
  fi
}

require_file_text() {
  local file="$1"
  local pattern="$2"
  local message="$3"
  if ! grep -Eq "$pattern" "$ROOT/$file"; then
    echo "Missing: $message" >&2
    exit 1
  fi
}

reject_file_text() {
  local file="$1"
  local pattern="$2"
  local message="$3"
  if grep -Eq "$pattern" "$ROOT/$file"; then
    echo "Unexpected: $message" >&2
    exit 1
  fi
}

require_path "packages/app/Sources/StowPaste/StowPaste.swift" "correctly named Swift source"
reject_path "packages/app/Sources/Cilplet" "misspelled source directory"
reject_path "Sources/StowPaste/StowPaste.swift" "Swift source should live in packages/app"
require_file_text "packages/app/Package.swift" 'name: "StowPaste"' 'package name is StowPaste'
require_file_text "packages/app/Package.swift" 'name: "StowPaste"' 'target name is StowPaste'
require_file_text "Scripts/build_app.sh" 'APP_NAME="StowPaste"' 'app executable name is StowPaste'
require_file_text "Scripts/build_app.sh" 'BUNDLE_ID="store\.aiware\.stowpaste"' 'bundle id uses the StowPaste-owned namespace'
require_file_text "Scripts/build_dmg.sh" 'DISPLAY_NAME="StowPaste"' 'DMG display name is StowPaste'
require_file_text "README.md" '<h1>StowPaste</h1>' 'README title appears with the centered logo'
require_file_text "LICENSE" 'Apache License' 'license is Apache-2.0'
require_file_text "package.json" '"license": "Apache-2\.0"' 'package metadata uses Apache-2.0 SPDX identifier'
require_file_text "Scripts/verify_project_structure.sh" 'packages/app/Sources/StowPaste/StowPaste\.swift' 'project structure check follows renamed source'
grep -Eq 'currentDirectoryName = "StowPaste"' "$SOURCE" || {
  echo "Missing: new app support directory uses StowPaste" >&2
  exit 1
}
for legacy_name in '"Stow" + "lark"' '"Clip" + "let"' '"Cilplet"' '"ClipboardDock"'; do
  grep -Fq "$legacy_name" "$SOURCE" || {
    echo "Missing: previous product data is migrated into StowPaste ($legacy_name)" >&2
    exit 1
  }
done
reject_file_text "Scripts/build_app.sh" 'Cilplet|cilplet' 'build app script should not use misspelled app name'
reject_file_text "Scripts/build_dmg.sh" 'Cilplet|cilplet' 'build dmg script should not use misspelled app name'

echo "app naming regression checks passed"
