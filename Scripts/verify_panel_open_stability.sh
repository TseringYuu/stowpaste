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

reject_source() {
  local pattern="$1"
  local message="$2"
  if grep -Eq "$pattern" "$SOURCE"; then
    echo "Unexpected: $message" >&2
    exit 1
  fi
}

require_source 'panel\.acceptsMouseMovedEvents = true' 'paste panel opts into mouse-moved events without custom cursor rect registration'
require_source 'override func mouseMoved\(with event: NSEvent\)' 'paste panel updates resize cursors from mouse movement'
require_source 'updateResizeCursor\(at: event\.locationInWindow\)' 'paste panel cursor feedback is driven by the current pointer location'
require_source 'STOWPASTE_PANEL_SMOKE_TEST' 'app exposes a hidden panel-open smoke test mode'
reject_source 'override func resetCursorRects\(\)' 'paste panel should not register cursor rects from the window reset path'
reject_source 'addCursorRect' 'paste panel should not call AppKit cursor-rect registration while opening'

swift build --package-path "$APP_PACKAGE_DIR" ${SWIFT_BUILD_FLAGS:-} >/dev/null
if [[ -z "$BUILD_PATH" ]]; then
  BUILD_PATH="$(swift build --package-path "$APP_PACKAGE_DIR" ${SWIFT_BUILD_FLAGS:-} --show-bin-path)"
fi

LOG="$(mktemp)"
TEST_HOME="$(mktemp -d)"
trap 'rm -f "$LOG"; rm -rf "$TEST_HOME"' EXIT
mkdir -p "$TEST_HOME/Library/Application Support"

STOWPASTE_APPLICATION_SUPPORT_DIR="$TEST_HOME/Library/Application Support" STOWPASTE_PANEL_SMOKE_TEST=1 STOWPASTE_PANEL_FOCUS_SMOKE_TEST=1 "$BUILD_PATH/StowPaste" >"$LOG" 2>&1

if ! grep -q 'panel smoke test visible' "$LOG"; then
  cat "$LOG" >&2
  echo "Panel smoke test did not prove the panel stayed visible" >&2
  exit 1
fi

echo "panel open stability regression checks passed"
