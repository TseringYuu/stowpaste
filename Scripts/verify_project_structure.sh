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

require_source() {
  local pattern="$1"
  local message="$2"
  if ! grep -Eq "$pattern" "$SOURCE"; then
    echo "Missing: $message" >&2
    exit 1
  fi
}

reject_repo_text() {
  local pattern="$1"
  local message="$2"
  if grep -R -n -E "$pattern" "$ROOT/.github" "$ROOT/README.md" "$ROOT/README.en.md" "$ROOT/docs" "$ROOT/CONTRIBUTING.md" 2>/dev/null; then
    echo "Unexpected: $message" >&2
    exit 1
  fi
}

require_path "packages/app/Package.swift" "Swift app package manifest"
require_path "packages/app/Sources/StowPaste/StowPaste.swift" "StowPaste Swift source"
require_path "packages/app/Resources/AppIcon.icns" "StowPaste app icon resources"
reject_path "Package.swift" "root Swift package manifest"
reject_path "Sources/StowPaste/StowPaste.swift" "root Swift source"
reject_path "Resources/AppIcon.icns" "root app icon resources"
require_path "README.md" "README"
require_path "README.en.md" "English README"
require_path "docs/DEVELOPMENT.md" "developer documentation"
require_path "LICENSE" "license"
require_path "CONTRIBUTING.md" "open-source contributing guide"
require_path "THIRD_PARTY_NOTICES.md" "third-party notices"
reject_path "CODE_OF_CONDUCT.md" "open-source code of conduct"
reject_path ".github/ISSUE_TEMPLATE" "public issue templates"
reject_path ".github/PULL_REQUEST_TEMPLATE.md" "public pull request template"
reject_repo_text "Cilplet" "misspelled app name in repository text"
reject_repo_text "MIT License" "repository must not claim MIT licensing"
reject_path "native-swift" "legacy native-swift directory"
reject_path "src-tauri" "Tauri project"
reject_path "src" "React source directory"
require_path "package.json" "root npm workspace manifest"
require_path "packages/website/package.json" "website package manifest"
require_source 'currentDirectoryName = "StowPaste"' 'new app support directory'
for legacy_name in '"Stow" + "lark"' '"Clip" + "let"' '"Cilplet"' '"ClipboardDock"'; do
  if ! grep -Fq "$legacy_name" "$SOURCE"; then
    echo "Missing: previous product data migration ($legacy_name)" >&2
    exit 1
  fi
done

echo "project structure regression checks passed"
