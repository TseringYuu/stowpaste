#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "$0")" && pwd)/lib/paths.sh"
SOURCE="$APP_SOURCE"

require_source() {
  local pattern="$1"
  local message="$2"
  if ! grep -Eq "$pattern" "$SOURCE"; then
    echo "Missing: $message" >&2
    exit 1
  fi
}

reject_source() {
  local pattern="$1"
  local message="$2"
  if grep -Eq "$pattern" "$SOURCE"; then
    echo "Unexpected: $message" >&2
    exit 1
  fi
}

require_source 'final class SystemAppearance: ObservableObject' 'system appearance is tracked independently of SwiftUI forced color schemes'
require_source 'application\.effectiveAppearance\.bestMatch\(from: \[\.darkAqua, \.aqua\]\)' 'system appearance reads the real macOS effective appearance'
require_source 'resolvedApplication\.observe\(\\\.effectiveAppearance' 'system appearance refreshes when macOS appearance changes'
require_source 'systemAppearance\.colorScheme' 'views use the tracked system appearance when app theme is System'
require_source '\.environmentObject\(model\.systemAppearance\)' 'panel injects system appearance into child views'
reject_source 'model\.settings\.colorScheme\)' 'clipboard panel should not pass nil preferredColorScheme for System'
reject_source 'draft\.colorScheme \?\? preferredSettingsColorScheme \?\? colorScheme' 'settings panel should not fall back to a stale forced SwiftUI color scheme for System'

echo "system theme regression checks passed"
