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

require_source 'buildMainMenu\(\)' 'application installs a main menu'
require_source '#selector\(NSText\.cut\(_:\)\)' 'standard Cut command'
require_source '#selector\(NSText\.copy\(_:\)\)' 'standard Copy command'
require_source '#selector\(NSText\.paste\(_:\)\)' 'standard Paste command'
require_source '#selector\(NSText\.selectAll\(_:\)\)' 'standard Select All command'
require_source 'if NSApp\.isActive,' 'event tap recognizes own app focus'
require_source 'panel\?\.isKeyWindow == false' 'own-app shortcuts pass through unless paste panel is focused'

echo "editing shortcut regression checks passed"
