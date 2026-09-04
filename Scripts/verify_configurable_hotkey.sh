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

require_source 'struct HotkeySettings: Codable, Equatable' 'hotkey settings are persisted'
require_source 'var doubleTap = true' 'new installations default to a double-tap hotkey'
require_source 'keyCode: Int64 = 0x37' 'new installations default to the left Command key'
require_source 'doubleTap: Bool = true' 'hotkey initializer defaults to a double-tap shortcut'
require_source 'if doubleTap \{' 'hotkey display marks double-tap shortcuts'
require_source 'var pastePanelHotkey = HotkeySettings' 'app settings include the paste panel hotkey'
require_source 'HotkeyRecorderView' 'settings panel has a hotkey recorder'
require_source 'NSEvent\.addLocalMonitorForEvents\(matching: \[\.keyDown, \.keyUp, \.flagsChanged\]\)' 'hotkey recorder captures complete press and release cycles'
require_source '@FocusState private var focused: Bool' 'hotkey recorder tracks focus'
require_source 'previousHotkey = hotkey' 'hotkey recorder remembers the previous shortcut'
require_source 'hotkey = previousHotkey' 'hotkey recorder restores the previous shortcut when recording is abandoned'
require_source '@State private var timeoutTask: Task<Void, Never>\?' 'hotkey recorder keeps a cancellable timeout task'
require_source 'struct HotkeyRecordingState' 'hotkey recorder uses a dedicated state machine'
require_source 'heldModifierFlags' 'hotkey recorder preserves modifier state across flags-changed and key-down events'
require_source 'pressedKeyCodes' 'hotkey recorder requires keys to be released before a second tap'
require_source '!isRepeat' 'hotkey recorder ignores key-repeat events'
require_source '\.union\(heldModifierFlags\)' 'hotkey recorder merges tracked modifiers into key chords'
require_source 'doubleTap: true' 'hotkey recorder stores same-key double taps'
require_source 'Task\.sleep\(for: \.seconds\(5\)\)' 'hotkey recorder has a 5 second recording timeout fallback'
require_source 'stopRecording\(restoreIfEmpty: true\)' 'hotkey recorder stops and restores when abandoned'
require_source 'timeoutTask\?\.cancel\(\)' 'hotkey recorder cancels timeout work when recording stops'
require_source 'matchesPastePanelHotkey\(' 'event tap matches the configured hotkey'
require_source 'matchesDoubleTapHotkey\(' 'event tap can match double-tap hotkeys'
require_source 'tapDisabledByTimeout' 'event tap recovers when macOS disables it after a timeout'
require_source 'tapDisabledByUserInput' 'event tap recovers when macOS disables it after user input'
require_source 'CGEvent\.tapEnable\(tap: tap, enable: true\)' 'disabled event taps are re-enabled so the global hotkey keeps working'
require_source 'private var eventTapRunLoopSource: CFRunLoopSource\?' 'event tap keeps its run loop source so stale taps can be removed'
require_source 'private var eventTapHealthTimer: Timer\?' 'event tap has a watchdog for long-running idle and wake recovery'
require_source 'ensureEventTapHealthy\(\)' 'event tap health is actively checked after idle or sleep'
require_source 'CFMachPortIsValid\(tap\)' 'event tap health detects invalidated mach ports'
require_source 'CGEvent\.tapIsEnabled\(tap: tap\)' 'event tap health detects disabled taps even without a callback'
require_source 'rebuildEventTap\(\)' 'event tap can be rebuilt when the mach port becomes stale'
require_source 'NSWorkspace\.didWakeNotification' 'event tap health is checked when macOS wakes from sleep'
require_source 'NSWorkspace\.sessionDidBecomeActiveNotification' 'event tap health is checked when the user session becomes active'
require_source 'private struct HotkeySnapshot: Equatable' 'event tap uses a lightweight hotkey snapshot'
require_source 'private var hotkeySnapshot = HotkeySnapshot\(settings: HotkeySettings\(\)\)' 'event tap keeps a cached hotkey snapshot'
require_source 'updateHotkeySnapshot\(\)' 'hotkey snapshot updates when settings change'
require_source 'DispatchQueue\.main\.async \{ self\.controller\.updateHotkeySnapshot\(\) \}' 'settings changes refresh shortcut state on the main thread'
require_source 'handlePanelHotkeyFromEventTap\(\)' 'event tap schedules panel display through a main-thread helper'
require_source 'DispatchQueue\.main\.async \{ self\.handlePanelHotkeyFromEventTap\(\) \}' 'event tap opens the panel asynchronously on the main thread'
require_source 'showPanelFromHotkey\(\)' 'global hotkey uses a crash-resistant panel presentation path'
require_source 'positionPanelNearMouse\(\)' 'global hotkey presentation avoids AX insertion point probing'
require_source 'func showPanel\(positioning: PanelPresentationPositioning = \.insertionPoint\)' 'panel presentation can choose between insertion point and mouse positioning'
require_source 'focusedTextAnchor\(fallback: mouse\)' 'regular panel presentation prefers a focused text insertion anchor when available'
require_source 'mousePriorityPanelFrame\(anchor: anchor, visible: visible, size: size, gap: gap, margin: margin\)' 'panel positioning falls back to the mouse-priority placement sequence'
require_source 'NSPoint\(x: anchor\.x \+ gap, y: anchor\.y - size\.height / 2\)' 'mouse fallback first tries the right side centered on the pointer'
require_source 'NSPoint\(x: anchor\.x \+ gap, y: anchor\.y - size\.height - gap\)' 'mouse fallback next tries the lower right of the pointer'
require_source 'NSPoint\(x: anchor\.x \+ gap, y: anchor\.y \+ gap\)' 'mouse fallback then tries the upper right of the pointer'
require_source 'NSPoint\(x: anchor\.x - size\.width - gap, y: anchor\.y - size\.height / 2\)' 'mouse fallback then tries the left side centered on the pointer'
require_source 'NSPoint\(x: anchor\.x - size\.width - gap, y: anchor\.y - size\.height - gap\)' 'mouse fallback then tries the lower left of the pointer'
require_source 'NSPoint\(x: anchor\.x - size\.width - gap, y: anchor\.y \+ gap\)' 'mouse fallback finally tries the upper left of the pointer'
require_source 'if panel\?\.isVisible == true, panelPinnedSnapshot' 'pinned panels pass keyboard events through'
reject_source 'private func insertionPoint\(\) -> NSPoint\?' 'global panel presentation should not rely on fragile AX insertion-point probing'
reject_source 'unsafeBitCast' 'clipboard panel should not use unsafe AX casts during hotkey presentation'
require_source 'lastHotkeyTriggerAt' 'event tap tracks double-tap timing for configured shortcuts'
require_source 'model\.settings\.pastePanelHotkey' 'event tap reads the configured hotkey'
require_source 'pasteCurrentClipboardIgnoringNext\(\)' 'pressing the hotkey again still pastes directly'
require_source 'doublePasteTip\(model\.settings\.pastePanelHotkey\.displayText\)' 'double-press hint uses the configured hotkey'
require_source '\.offset\(y: -46\)' 'double-press hint is rendered above the paste panel, outside the panel content'
require_source 'pasteVisibleItem\(at index: Int\)' 'cmd-number shortcuts can paste visible items by index'
require_source 'matchesCommandNumberShortcut\(_ event: CGEvent\) -> Int\?' 'event tap recognizes cmd-number shortcuts'
require_source 'case 0x12: return 0' 'cmd+1 selects the first visible item'
require_source 'case 0x13: return 1' 'cmd+2 selects the second visible item'
require_source 'case 0x14: return 2' 'cmd+3 selects the third visible item'
require_source 'case 0x15: return 3' 'cmd+4 selects the fourth visible item'
require_source 'case 0x17: return 4' 'cmd+5 selects the fifth visible item'
require_source 'DispatchQueue\.main\.async \{ self\.pasteVisibleItem\(at: index\) \}' 'cmd-number paste is executed on the main thread'
require_source 'model\.visibleHistory' 'cmd-number shortcuts use the current tab or group visible list'
reject_source 'keyCode == 0x09 && command' 'event tap should not hard-code cmd+v as the panel shortcut'
reject_source 'cmd\+v' 'visible double-press copy should not mention a fixed shortcut'

if START_PATTERN='private func handle\(proxy: CGEventTapProxy' END_PATTERN='private func matchesPastePanelHotkey' MATCH_PATTERN='self\.showPanel\(\)' perl -0ne '
  if ($_ =~ /$ENV{START_PATTERN}(.*?)$ENV{END_PATTERN}/s && $1 =~ /$ENV{MATCH_PATTERN}/s) {
    exit 0;
  }
  exit 1;
' "$SOURCE"; then
  echo "Unexpected: event tap should not call showPanel directly from its callback body" >&2
  exit 1
fi

if ! START_PATTERN='private func handle\(proxy: CGEventTapProxy' END_PATTERN='if matchesPastePanelHotkey\(event\)' MATCH_PATTERN='if panel\?\.isVisible == true, panelPinnedSnapshot \{[[:space:]]*return Unmanaged\.passUnretained\(event\)' perl -0ne '
  if ($_ =~ /$ENV{START_PATTERN}(.*?)$ENV{END_PATTERN}/s && $1 =~ /$ENV{MATCH_PATTERN}/s) {
    exit 0;
  }
  exit 1;
' "$SOURCE"; then
  echo "Missing: pinned panels must pass keyboard events through before matching hotkeys" >&2
  exit 1
fi

if START_PATTERN='private func handle\(proxy: CGEventTapProxy' END_PATTERN='return Unmanaged\.passUnretained\(event\)[[:space:]]*\}' MATCH_PATTERN='model\.panelPinned' perl -0ne '
  if ($_ =~ /$ENV{START_PATTERN}(.*?)$ENV{END_PATTERN}/s && $1 =~ /$ENV{MATCH_PATTERN}/s) {
    exit 0;
  }
  exit 1;
' "$SOURCE"; then
  echo "Unexpected: event tap should use a cached pinned snapshot instead of reading model.panelPinned directly" >&2
  exit 1
fi

echo "configurable hotkey regression checks passed"
