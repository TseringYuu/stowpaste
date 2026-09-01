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

require_source 'pasteHitArea' 'history row has a full background paste hit area'
require_source '\.background\(pasteHitArea\)' 'history row attaches the paste hit area behind content'
require_source 'weak var controller: AppController\?' 'paste panel keeps a weak controller reference for native interactions'
require_source 'override func mouseDown\(with event: NSEvent\)' 'paste panel handles native mouse down events'
require_source 'private func panelInteraction\(at location: NSPoint\) -> PanelWindowInteraction\?' 'paste panel isolates non-functional drag and resize hit testing'
require_source 'private func panelVisualRect\(in bounds: NSRect\) -> NSRect' 'paste panel hit testing follows the visible rounded panel instead of transparent shadow margins'
require_source 'private static let dragHandleHeight' 'paste panel has a visible top non-functional drag area'
require_source 'private func isInDragHandle\(location: NSPoint, visualRect: NSRect\) -> Bool' 'paste panel keeps drag hit testing isolated from functional content'
require_source 'PanelMetrics\.headerDragHeight' 'paste panel drag hit testing covers the full header blank area'
require_source 'private func isFunctionalHeaderHit\(at location: NSPoint\) -> Bool' 'paste panel avoids intercepting tabs and toolbar buttons while expanding header dragging'
require_source 'headerInteractiveRects' 'paste panel uses explicit SwiftUI header control frames to keep buttons clickable'
require_source 'func updateHeaderInteractiveRect' 'SwiftUI header controls can register their interactive frames'
require_source 'func removeHeaderInteractiveRect' 'header controls unregister their frames when SwiftUI removes them'
require_source 'HeaderInteractiveRectModifier' 'header buttons report their frames without adding visible UI'
require_source 'headerInteractiveArea' 'toolbar tabs and action buttons mark their real controls as non-draggable'
require_source 'headerInteractiveRectByID' 'paste panel updates header control frames by stable id instead of appending stale rectangles'
require_source 'PanelMetrics\.sideMargin' 'header control frames are converted from SwiftUI panel coordinates into window coordinates'
require_source 'interactiveRects\.isEmpty' 'paste panel lets SwiftUI handle early header clicks before control frames are registered'
reject_source 'view is NSButton \|\| view is NSScrollView' 'paste panel should not treat the entire tabs scroll view as functional content'
reject_source 'hitTest\(location\)' 'paste panel should not infer SwiftUI header controls from AppKit hit testing'
reject_region_source 'func showPanel\(positioning: PanelPresentationPositioning = \.insertionPoint\).*?\{' 'func showPanelFromHotkey' 'clearHeaderInteractiveRects' 'paste panel should not clear header control frames when showing an already-mounted SwiftUI view'
reject_region_source 'func showPanelCentered\(\).*?\{' 'private func runPanelSmokeTestIfNeeded' 'clearHeaderInteractiveRects' 'centered paste panel should keep registered header control frames clickable'
require_source 'return \.drag' 'paste panel can route visible non-functional regions to native dragging'
require_source 'enum PanelWindowInteraction' 'paste panel models native drag and resize interactions'
require_source 'case resize\(PanelResizeEdge\)' 'paste panel can route edge interactions to native resize'
require_source 'controller\?\.resizePanel\(edge: edge, with: event\)' 'paste panel routes native edge drags through resize logic'
require_source 'controller\?\.dragPanel\(with: event\)' 'paste panel routes native non-functional drags through window dragging'
require_source 'func dragPanel\(with event: NSEvent\)' 'panel dragging is routed through the controller'
require_source 'panel\.performDrag\(with: event\)' 'paste panel uses native window dragging from explicit drag handles'
require_source 'static let resizeHandleThickness' 'paste panel has a native edge resize hit area'
require_source 'static let resizeCornerSize' 'paste panel has native corner resize hit areas'
require_source 'resizeHandleThickness: CGFloat = 14' 'paste panel resize hit area is wide enough to avoid slipping through to the desktop'
require_source 'resizeCornerSize: CGFloat = 28' 'paste panel corner resize hit area gives corners a forgiving target'
require_source 'updateResizeCursor\(at: event\.locationInWindow\)' 'paste panel updates resize cursors while the mouse moves'
require_source 'override func mouseMoved\(with event: NSEvent\)' 'paste panel responds to mouse movement for cursor feedback'
require_source 'override func mouseExited\(with event: NSEvent\)' 'paste panel restores the arrow cursor after leaving resize zones'
require_source 'override var acceptsMouseMovedEvents: Bool' 'paste panel receives mouse movement events for cursor changes'
require_source 'cursor\(for edge: PanelResizeEdge\) -> NSCursor' 'paste panel maps resize edges to cursors'
require_source 'private var activeResizeCursorEdge: PanelResizeEdge\?' 'paste panel tracks whether it is currently showing a resize cursor'
require_source 'guard activeResizeCursorEdge != nil else \{ return \}' 'paste panel does not reset normal content cursors on every mouse move'
reject_region_source 'private func updateResizeCursor\(at location: NSPoint\) \{' 'private func cursor\(for edge: PanelResizeEdge\) -> NSCursor' 'else \{[[:space:]]*NSCursor\.arrow\.set\(\)[[:space:]]*\}' 'paste panel should not force the arrow cursor over normal SwiftUI content'
require_source 'func resizePanel\(edge: PanelResizeEdge, with event: NSEvent\)' 'panel resizing is routed through the controller'
require_source 'private var isResizingPanel = false' 'panel tracks active resize gestures'
require_source 'isResizingPanel = true' 'panel marks resize as active while dragging an edge'
require_source 'defer \{ isResizingPanel = false \}' 'panel clears resize state after edge dragging ends'
require_source 'guard !self\.isResizingPanel else \{ return \}' 'outside clicks are ignored while resizing the panel'
require_source 'private func resizePanel\(from startFrame: NSRect, edge: PanelResizeEdge, delta: NSPoint\)' 'panel resize math is isolated'
require_source 'model\.panelContentSize = contentSize' 'panel resize persists the user-selected content size'
require_source 'panel\.setFrame\(nextFrame, display: true\)' 'panel resize applies a native window frame'
reject_source 'PanelDragHandle\(controller: controller\)' 'paste panel should not depend on SwiftUI overlay drag handles'
reject_source 'PanelResizeHandle\(controller: controller' 'paste panel should not depend on SwiftUI overlay resize handles'
reject_source 'panel\.isMovableByWindowBackground = true' 'paste panel should not make every SwiftUI background draggable'
require_source 'onTapGesture\(perform: onBeginEdit\)' 'title keeps its edit-only tap target'
require_source 'itemIcon' 'item icon remains visible in the history row'
require_source 'RelativeTimeFormatter\.relativeTime\(from: entry\.updatedAt, now: now\)' 'time label remains visible in the history row'
require_source '\.background\(hovered \? rowHoverBackground : Color\.clear\)' 'history rows show a hover background'
require_source '\.onHover \{ hovered = \$0 \}' 'history rows track hover state'
require_source 'return selectedBackground\.opacity\(0\.3\)' 'history row hover uses the active item background at 30 percent opacity'
require_source 'onTapGesture\(count: 2' 'history rows support double-click paste'
require_source '\.onTapGesture\(count: 2, perform: onPaste\)' 'display areas support double-click paste'
require_source '\.onDrag \{' 'history rows remain draggable'
require_source '\} preview: \{' 'history item drags provide an explicit preview'
require_source '\.opacity\(1\)' 'history item drag preview stays fully opaque'
require_source 'fixedSize\(horizontal: false, vertical: true\)' 'multi-line text previews wrap by line instead of clipping by word'
require_source 'entry\.kind == \.text && entry\.preview\.contains\("\\n"\)' 'text previews with line breaks get multiline treatment'
require_source 'currentClipboardSignature' 'model tracks the signature currently on the system clipboard'
require_source 'isCurrentClipboardItem: entry\.signature == model\.currentClipboardSignature' 'history rows know when they match the current system clipboard item'
require_source 'let isCurrentClipboardItem: Bool' 'history rows receive current clipboard state'
require_source 'deleteButtonPlaceholder' 'current clipboard row preserves delete button space without rendering the close action'
require_source 'Color\.clear\.frame\(width: 22, height: 22\)' 'delete placeholder keeps the time label aligned with other rows'
require_source 'let commandShortcutIndexes = commandShortcutIndexes\(for: visibleItems\)' 'visible list computes cmd-number shortcut hint indices once'
require_source 'commandShortcutIndex: model\.panelPinned \? nil : commandShortcutIndexes\[entry\.id\]' 'pinned panels hide cmd-number shortcut hints because keyboard actions are disabled'
require_source 'private func commandShortcutIndexes\(for visibleItems: \[ClipboardEntry\]\) -> \[UUID: Int\]' 'shortcut hint indices are derived from the current visible list'
require_source 'visibleItems\.prefix\(5\)' 'only the first five visible rows display cmd-number shortcuts'
require_source 'let commandShortcutIndex: Int\?' 'history rows can render an optional cmd-number shortcut hint'
require_source 'CommandShortcutBadge\(number: commandShortcutIndex\)' 'history row renders the cmd-number shortcut hint before the time'
require_source 'struct CommandShortcutBadge: View' 'cmd-number shortcut hint has a dedicated visual component'
require_source 'Image\(systemName: "command"\)' 'cmd-number shortcut hint displays the command icon'
require_source 'shortcutBorderColor' 'cmd-number shortcut hint is wrapped with a themed border'
require_source 'onTapGesture\(perform: onPaste\)' 'display areas trigger paste'
require_source 'IconButton\(symbol: "xmark"' 'delete button remains a separate action'
require_source 'struct IconButton: View' 'shared icon button component exists'
require_source '\.contentShape\(Rectangle\(\)\)' 'icon buttons use their full visual frame as the click target'

echo "history row hit-area regression checks passed"
