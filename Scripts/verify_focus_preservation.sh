#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "$0")" && pwd)/lib/paths.sh"
SOURCE="$APP_SOURCE"
BUILD_PATH="${SWIFT_BUILD_PATH:-}"

require_source() {
  local pattern="$1"
  local message="$2"
  if ! grep -Eq "$pattern" "$SOURCE"; then
    echo "Missing: $message" >&2
    exit 1
  fi
}

reject_region_source() {
  local start_pattern="$1"
  local end_pattern="$2"
  local pattern="$3"
  local message="$4"
  if START_PATTERN="$start_pattern" END_PATTERN="$end_pattern" MATCH_PATTERN="$pattern" perl -0ne '
    if ($_ =~ /$ENV{START_PATTERN}(.*?)$ENV{END_PATTERN}/s && $1 =~ /$ENV{MATCH_PATTERN}/s) {
      exit 0;
    }
    exit 1;
  ' "$SOURCE"; then
    echo "Unexpected: $message" >&2
    exit 1
  fi
}

require_source 'styleMask: \[\.borderless\]' 'paste panel keeps the existing lightweight borderless window style'
reject_region_source 'func showPanel\(positioning: PanelPresentationPositioning = \.insertionPoint\)' 'func showPanelFromHotkey\(\)' 'NSApp\.activate' 'opening the paste panel should not activate StowPaste'
reject_region_source 'func showPanel\(positioning: PanelPresentationPositioning = \.insertionPoint\)' 'func showPanelFromHotkey\(\)' 'panel\.makeKey\(\)' 'opening the paste panel should not steal the focused text field'
reject_region_source 'func showPanelCentered\(\)' 'private func runPanelSmokeTestIfNeeded' 'NSApp\.activate' 'centered paste panel should not activate StowPaste'
reject_region_source 'func showPanelCentered\(\)' 'private func runPanelSmokeTestIfNeeded' 'panel\.makeKey\(\)' 'centered paste panel should not steal the focused text field'
reject_region_source 'private func postPasteWhenTargetIsReady' 'private func postPasteShortcut\(\)' 'makeKey\(\)' 'restoring a pinned paste panel should not steal focus after paste'

swift build --package-path "$APP_PACKAGE_DIR" ${SWIFT_BUILD_FLAGS:-} >/dev/null
if [[ -z "$BUILD_PATH" ]]; then
  BUILD_PATH="$(swift build --package-path "$APP_PACKAGE_DIR" ${SWIFT_BUILD_FLAGS:-} --show-bin-path)"
fi

LOG="$(mktemp)"
TEST_HOME="$(mktemp -d)"
trap 'rm -f "$LOG"; rm -rf "$TEST_HOME"' EXIT
mkdir -p "$TEST_HOME/Library/Application Support"

if ! STOWPASTE_APPLICATION_SUPPORT_DIR="$TEST_HOME/Library/Application Support" STOWPASTE_PANEL_SMOKE_TEST=1 STOWPASTE_PANEL_FOCUS_SMOKE_TEST=1 "$BUILD_PATH/StowPaste" >"$LOG" 2>&1; then
  cat "$LOG" >&2
  echo "Missing: paste panel focus smoke test exited unexpectedly" >&2
  exit 1
fi

if ! grep -q 'panel smoke test active=false key=false' "$LOG"; then
  cat "$LOG" >&2
  echo "Missing: paste panel must open without activating StowPaste or becoming key" >&2
  exit 1
fi

echo "focus preservation regression checks passed"
