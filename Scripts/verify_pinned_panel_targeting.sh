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

require_region_source() {
  local start_pattern="$1"
  local end_pattern="$2"
  local pattern="$3"
  local message="$4"
  if ! START_PATTERN="$start_pattern" END_PATTERN="$end_pattern" MATCH_PATTERN="$pattern" perl -0ne '
    if ($_ =~ /$ENV{START_PATTERN}(.*?)$ENV{END_PATTERN}/s && $1 =~ /$ENV{MATCH_PATTERN}/s) {
      exit 0;
    }
    exit 1;
  ' "$SOURCE"; then
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

require_source 'refreshPasteTargetFromFrontmostApp\(\)' 'pinned panels can refresh the paste target from the current frontmost app'
require_region_source 'func sendPasteShortcutIgnoringNext\(\)' 'private func postPasteWhenTargetIsReady' 'refreshPasteTargetFromFrontmostApp\(\)' 'paste refreshes its target immediately before posting paste'
reject_region_source 'func sendPasteShortcutIgnoringNext\(\)' 'private func postPasteWhenTargetIsReady' 'hidePanelIfAllowed\(\)' 'paste panel should not hide before the target app is ready'
require_region_source 'private func postPasteWhenTargetIsReady' 'private func postPasteShortcut\(\)' 'hidePanelIfAllowed\(\)' 'paste panel hides only after the target app is ready to avoid flashing settings'
reject_region_source 'private func postPasteWhenTargetIsReady' 'private func postPasteShortcut\(\)' 'if model\.panelPinned \{[[:space:]]*panel\?\.orderOut\(nil\)' 'pinned paste should not hide the panel and flash before posting paste'
reject_region_source 'private func postPasteWhenTargetIsReady' 'private func postPasteShortcut\(\)' 'if self\.model\.panelPinned \{[[:space:]]*self\.panel\?\.orderFrontRegardless\(\)' 'pinned paste should not hide and re-show the panel after posting paste'
require_region_source 'private func postPasteWhenTargetIsReady' 'private func postPasteShortcut\(\)' 'if !model\.panelPinned \{[[:space:]]*hidePanelIfAllowed\(\)' 'unpinned paste still hides after the target app is ready'
require_source 'app\.processIdentifier != NSRunningApplication\.current\.processIdentifier' 'paste target ignores StowPaste itself'
require_source 'private func rememberPasteTarget\(_ app: NSRunningApplication\?\)' 'paste target updates are centralized'
require_source 'private func validPasteTarget\(_ app: NSRunningApplication\?\) -> NSRunningApplication\?' 'paste target can be safely filtered before activation'
require_region_source 'func showPanel\(positioning: PanelPresentationPositioning = \.insertionPoint\)' 'func showPanelFromHotkey\(\)' 'rememberPasteTarget\(NSWorkspace\.shared\.frontmostApplication\)' 'showing the paste panel must not store StowPaste settings as the paste target'
require_region_source 'func showPanelCentered\(\)' 'private func runPanelSmokeTestIfNeeded' 'rememberPasteTarget\(NSWorkspace\.shared\.frontmostApplication\)' 'centered panel presentation must not store StowPaste settings as the paste target'
require_region_source 'private func handlePanelHotkeyFromEventTap\(\)' 'private func matchesPastePanelHotkey' 'rememberPasteTarget\(NSWorkspace\.shared\.frontmostApplication\)' 'hotkey presentation must not store StowPaste settings as the paste target'
require_region_source 'func sendPasteShortcutIgnoringNext\(\)' 'private func postPasteWhenTargetIsReady' 'validPasteTarget\(previousFrontmostApp\)' 'paste should never reactivate StowPaste settings as the target app'
require_source 'previousFrontmostApp = app' 'paste target stores the current external input app'
require_source 'NSWorkspace\.didActivateApplicationNotification' 'app activation updates the remembered paste target while pinned'
require_region_source 'private func installWorkspaceObservers\(\)' 'private func removeOutsideClickMonitor\(\)' 'refreshPasteTargetFromFrontmostApp\(\)' 'workspace activation observer refreshes the paste target'
require_region_source 'private func installOutsideClickMonitor\(\)' 'private var visualPanelFrame' 'refreshPasteTargetFromFrontmostApp\(\)' 'outside clicks update the pinned paste target before paste actions'

echo "pinned panel targeting regression checks passed"
