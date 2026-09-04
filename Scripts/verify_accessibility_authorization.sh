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

require_source 'openAccessibilityAuthorization\(\)' 'settings button opens the authorization destination'
require_source 'x-apple\.systempreferences:com\.apple\.preference\.security\?Privacy_Accessibility' 'authorization opens the Accessibility pane'
require_source 'NSWorkspace\.OpenConfiguration\(\)' 'authorization uses an activating workspace configuration'
require_source 'configuration\.activates = true' 'authorization brings System Settings to the foreground'
require_source 'applicationDidBecomeActive' 'authorization state refreshes after returning from System Settings'
require_source 'refreshAccessibilityTrust\(' 'authorization state uses one refresh path'
require_source 'accessibilityRepairHint' 'ad-hoc upgrades explain how to replace a stale authorization entry'
require_source 'model\.accessibilityTrusted = AXIsProcessTrusted\(\)' 'event-tap installation failure preserves the actual system authorization state'
require_source 'stopPermissionRetryTimer\(\)' 'authorization and event-tap retries stop only after monitoring is restored'
require_source 'window\.setFrameAutosaveName\("StowPasteSettings"\)' 'settings window position is preserved after moving'
require_source 'menuNeedsUpdate' 'status menu refreshes before opening'
require_source 'if !model\.accessibilityTrusted' 'status menu hides the accessibility entry after authorization'
require_source 'static var showMainPanel' 'status menu has localized show main panel copy'
require_source 'menu\.addItem\(NSMenuItem\(title: L10n\.showMainPanel, action: #selector\(showMainPanelFromMenu\)' 'status menu exposes a show main panel action'
require_source 'func showPanelCentered\(\)' 'controller can show the paste panel centered on screen'
require_source 'positionPanelAtScreenCenter\(\)' 'status menu panel presentation uses center positioning'
reject_source 'menu\.addItem\(NSMenuItem\(title: L10n\.openClipboard' 'status menu should not include open clipboard'
reject_source 'menu\.addItem\(NSMenuItem\(title: L10n\.translateLatest' 'status menu should not include translate latest'
reject_source 'if !model\.accessibilityTrusted \{[[:space:]]*startPermissionRetryTimer\(\)[[:space:]]*showSettings\(\)' 'permission request should not recenter settings'

echo "accessibility authorization regression checks passed"
