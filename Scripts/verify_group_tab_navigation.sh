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

require_source 'selectTab\(_ tab: ClipTab\)' 'standard tabs use a dedicated selection helper'
require_source 'selectGroup\(_ group: CustomGroup\)' 'custom group tabs use a dedicated selection helper'
require_source 'addEntry\(_ entryID: UUID, to tab: ClipTab\)' 'standard tabs can receive dragged clipboard items'
require_source 'addEntry\(_ entryID: UUID, to group: CustomGroup\)' 'custom tabs can receive dragged clipboard items'
require_source 'private func dropEntry\(_ entryID: UUID\)' 'tab drop delegate routes the dragged item to its target'
require_source 'struct TabDropDelegate: DropDelegate' 'toolbar tabs use a dedicated drop delegate'
require_source 'struct GroupReorderDropDelegate: DropDelegate' 'group management rows use a dedicated reorder drop delegate'
require_source 'private func groupRowBottomBorder\(color: Color\) -> some View' 'group management rows share an inset bottom border'
require_source '\.padding\(\.horizontal, 10\)' 'group management row borders keep distance from panel edges'
require_source 'private var toolbarTabsScroller: some View' 'toolbar tabs have a dedicated scroll container'
require_region_source 'private var toolbarTabsScroller: some View' 'private var toolbarActionButtons' 'ScrollView\(\.horizontal, showsIndicators: false\)' 'group overflow scrolls horizontally without showing a scrollbar'
require_region_source 'private var toolbarTabsScroller: some View' 'private var toolbarActionButtons' '\.frame\(maxWidth: \.infinity, alignment: \.leading\)' 'scrollable tabs stay inside the toolbar tabs area'
require_region_source 'private var toolbarTabsScroller: some View' 'private var toolbarActionButtons' '\.mask\(toolbarTabsFadeMask\)' 'overflowing tabs fade naturally at the edges'
require_region_source 'private var toolbarTabsScroller: some View' 'private var toolbarActionButtons' 'HStack\(spacing: 2\)' 'toolbar tabs use a tighter 2px gap'
require_source 'private var toolbarTabsFadeMask: some View' 'toolbar tabs have a dedicated fade mask'
require_source 'private var tabsOverflowing: Bool' 'toolbar tabs only show the fade treatment when content overflows'
require_source '@State private var tabsScrollOffset: CGFloat = 0' 'toolbar tabs track horizontal scroll position'
require_source 'private var tabsCanFadeLeading: Bool' 'toolbar tabs compute when the leading fade should be visible'
require_source 'private var tabsCanFadeTrailing: Bool' 'toolbar tabs compute when the trailing fade should be visible'
require_source 'private var maxTabsScrollOffset: CGFloat' 'toolbar tabs compute their maximum scroll offset'
require_source 'TabsScrollOffsetReader\(offset: \$tabsScrollOffset\)' 'toolbar tabs observe the native scroll offset'
require_source 'if tabsCanFadeLeading' 'leading fade hides when scrolled fully to the leading edge'
require_source 'if tabsCanFadeTrailing' 'trailing fade hides when scrolled fully to the trailing edge'
require_source 'struct TabsScrollOffsetReader: NSViewRepresentable' 'toolbar tabs use a native scroll offset reader'
require_source 'final class TabsScrollOffsetCoordinator: NSObject' 'toolbar tabs observe scroll view bounds changes'
require_source 'LinearGradient\(colors: \[\.clear, \.black\]' 'toolbar tabs leading fade transitions from transparent to opaque'
require_source 'LinearGradient\(colors: \[\.black, \.clear\]' 'toolbar tabs trailing fade transitions from opaque to transparent'
reject_region_source 'private var toolbarTabsScroller: some View' 'private var toolbarActionButtons' 'showsIndicators: true' 'tabs scrollbar should be hidden without disabling horizontal scrolling'
require_region_source 'ForEach\(ClipTab\.allCases\)' 'ForEach\(model\.customGroups\)' 'conditionalDrop\(enabled: model\.canPin\(to: tab\)' 'only manually pinnable standard tabs expose drop targets'
require_region_source 'ForEach\(model\.customGroups\)' '\.padding\(\.bottom, 4\)' 'group: group' 'all custom group tabs are drop targets'
require_source '\.panelTooltip\("\\\(group\.name\) · \\\(group\.itemIDs\.count\)", tooltip: \$tooltip\)' 'custom group tab tooltips show their item count like built-in tabs'
require_source 'func canPin\(to tab: ClipTab\) -> Bool' 'only manually pinnable built-in tabs can receive added items'
require_source 'return tab != \.image && tab != \.file' 'image and file tabs reject manual item additions'
require_source 'let canPin = activeTab != \.favorites && activeTab != \.image && activeTab != \.file' 'history rows compute pin availability for image and file tabs'
require_source 'if canPin \{' 'history rows hide pin controls for image and file tabs'
require_region_source 'private func rowContextMenu\(_ entry: ClipboardEntry\)' 'struct HistoryRow' 'model\.canPin\(to: model\.activeTab\)' 'row context menus hide pin controls for image and file tabs'
require_source 'pinEntry\(entry, to: tab\)' 'dropping onto a standard tab adds instead of toggles the item'
require_source 'favoriteOrder\.contains\(entry\.id\)' 'favorite state is tracked separately from pinned tabs'
require_region_source 'func toggleFavorite\(_ entry: ClipboardEntry\)' 'func togglePin\(_ entry: ClipboardEntry, tab: ClipTab\)' 'favoriteOrder\.append\(item\.id\)' 'favoriting records order without pinning the item'
reject_region_source 'func toggleFavorite\(_ entry: ClipboardEntry\)' 'func togglePin\(_ entry: ClipboardEntry, tab: ClipTab\)' 'pinnedTabs\.(insert|remove)\(\.favorites\)' 'favoriting should not also pin or unpin the item'
reject_region_source 'case \.favorites: return' 'case \.text: return' 'pinnedTabs\.contains\(\.favorites\)' 'favorites tab should not depend on pinned tabs'
require_source 'merged\.id = history\[existingIndex\]\.id' 'refreshing duplicate clipboard content preserves the existing item identity'
require_source 'draggedEntryID = entry\.id' 'history rows publish the dragged clipboard item id'
require_source 'dragProvider\(for: entry\)' 'history rows expose real clipboard content for external drags'
require_source 'let onDrag: \(\) -> NSItemProvider' 'history rows receive a single drag provider'
require_source 'let sortDrag: \(\) -> NSItemProvider' 'history rows expose a separate drag provider for reorder handles'
require_source 'private var reorderDragHandle: some View' 'favorite sorting starts from a dedicated drag handle instead of the whole row'
require_source 'contentDragSource\(enabled: true, entry: entry, provider: onDrag\)' 'normal history rows remain draggable without stealing favorite sorting'
require_source 'struct ContentDragSourceModifier: ViewModifier' 'content dragging is isolated in a reusable modifier'
require_source '\.onDrag \{ sortDrag\(\) \} preview: \{' 'favorite reorder handle owns the original sorting drag gesture'
require_region_source 'private func prepareSortDrag\(_ entry: ClipboardEntry' 'private func rowContextMenu\(_ entry: ClipboardEntry\)' 'draggedEntryID = entry\.id' 'sort handle drags keep the clipboard item id so they can still be dropped onto other groups'
require_source 'draggedFavoriteID = entry\.id' 'favorite reorder handle publishes the dragged favorite id'
require_source '@State private var draggedGroupItemID: UUID\?' 'custom group item sorting tracks its own dragged item id'
require_source 'let canReorderItems = model\.activeTab == \.favorites \|\| model\.activeGroupID != nil' 'custom group item rows expose the same reorder handle as favorites'
require_source 'draggable: canReorderItems' 'history rows show reorder handles for favorite and custom group sorting'
require_source 'draggedGroupItemID = entry\.id' 'custom group reorder handle publishes the dragged item id'
require_source 'func moveGroupItem\(from source: UUID, to destination: UUID, in groupID: UUID\)' 'custom group item order can be persisted independently'
require_source 'model\.moveGroupItem\(from: draggedID, to: entry\.id, in: groupID\)' 'custom group row drops reorder items inside the active group'
require_region_source 'var visibleHistory: \[ClipboardEntry\]' 'var selectedEntry' 'groupItemRank\(left\.id, in: activeGroupID\)' 'custom group tabs render items in their saved order'
reject_source 'draggable: model\.activeTab == \.favorites,' 'custom group rows should not lose the reorder handle when the active standard tab is not favorites'
reject_region_source '\.id\(entry\.id\)' '\.onDrop' '\.onDrag \{' 'history list should not attach a row-level drag gesture that steals favorite sorting'
reject_region_source 'if draggable \{[[:space:]]*reorderDragHandle' 'Spacer\(minLength: 8\)' 'contentDragSource\(enabled: draggable' 'favorite rows should not expose content drags that compete with handle sorting'
reject_source 'onReorderDrag' 'favorite sorting should not use a second drag closure that can diverge from the original row drag behavior'
reject_source 'onContentDrag' 'favorite sorting should not keep the split content drag path on rows'
require_source 'static let internalEntryDragType = UTType\(exportedAs: "store\.aiware\.stowpaste\.entry-drag"\)' 'history rows expose an internal drag type for in-app sorting and grouping'
require_source 'provider\.registerDataRepresentation\(forTypeIdentifier: Self\.internalEntryDragType\.identifier' 'history drag provider keeps an internal id representation alongside real content'
require_source 'provider\.registerDataRepresentation\(forTypeIdentifier: UTType\.png\.identifier' 'image rows expose PNG data for dragging into external apps'
require_source 'static let entryDropTypes: \[UTType\] = \[internalEntryDragType, \.text, \.fileURL, \.image\]' 'history drop targets accept the internal type plus real external drag types so sorting still starts'
require_source 'static let internalGroupDragType = UTType\(exportedAs: "store\.aiware\.stowpaste\.group-drag"\)' 'group rows expose an internal drag type for sorting'
require_source 'static let groupDropTypes: \[UTType\] = \[internalGroupDragType, \.text\]' 'group reorder drop targets accept a stable public type as a fallback'
require_source 'NSItemProvider\(item: group\.id\.uuidString as NSString, typeIdentifier: Self\.internalGroupDragType\.identifier\)' 'inline group reordering uses an internal drag type'
require_source 'private func groupReorderDragHandle\(for group: CustomGroup\) -> some View' 'inline group sorting starts from a dedicated drag handle'
require_source 'private func windowGroupReorderDragHandle\(for group: CustomGroup\) -> some View' 'window group sorting starts from a dedicated drag handle'
require_region_source 'private func groupReorderDragHandle\(for group: CustomGroup\)' 'private func resetAddGroup' '\.onDrag \{' 'inline group drag handle owns the sorting drag gesture'
require_region_source 'private func windowGroupReorderDragHandle\(for group: CustomGroup\)' 'struct SettingsView' '\.onDrag \{' 'window group drag handle owns the sorting drag gesture'
require_region_source 'private var groupListPage: some View' 'private func groupListRow\(_ group: CustomGroup\)' '\.onDrop' 'inline group rows remain drop targets'
require_region_source 'struct GroupManagerView: View' 'private func groupRow\(_ group: CustomGroup\)' '\.onDrop' 'window group rows remain drop targets'
reject_region_source 'private var groupListPage: some View' 'private func groupListRow\(_ group: CustomGroup\)' '\.onDrag \{' 'inline group rows should not attach whole-row drag gestures'
reject_region_source 'struct GroupManagerView: View' 'private func groupRow\(_ group: CustomGroup\)' '\.onDrag \{' 'window group rows should not attach whole-row drag gestures'
require_source 'NSItemProvider\(object: text as NSString\)' 'text rows drag their text instead of an internal UUID'
require_source 'NSItemProvider\(contentsOf: url\)' 'file rows drag file URLs instead of an internal UUID'
require_source 'NSItemProvider\(object: image as NSImage\)' 'image rows drag image data instead of an internal UUID'
reject_region_source '\.onDrag \{' '\.onDrop' 'NSItemProvider\(object: entry\.id\.uuidString as NSString\)' 'history item drags should not expose UUID strings as public text to external targets'
require_region_source 'struct TabDropDelegate: DropDelegate' 'struct TooltipState' 'if let draggedEntryID' 'tab drops keep using the in-memory dragged id for internal grouping'
require_source 'private var toolbarActionButtons: some View' 'toolbar actions remain outside the scrollable tabs area'
require_region_source 'private var toolbarActionButtons: some View' 'private var panelPinButton' 'HStack\(spacing: 2\)' 'toolbar action buttons use a tighter 2px gap'
require_source 'private var panelPinButton: some View' 'toolbar exposes a discoverable panel pin button'
require_source 'model\.panelPinned\.toggle\(\)' 'panel pin button toggles panel pinned state'
require_source 'static var pinToScreen: String' 'panel pin has copy distinct from item pinning'
require_source 'model\.panelPinned \? L10n\.unpinFromScreen : L10n\.pinToScreen' 'panel pin tooltip uses screen pin copy'
require_region_source 'struct IconHitTarget: View' 'struct HoverBackground' '\.foregroundStyle\(iconColor\)' 'toolbar tab icons use state-aware theme colors'
require_region_source 'struct IconHitTarget: View' 'struct HoverBackground' 'return theme\.primary \?\? Color\.accentColor' 'active toolbar tab icons use the primary color'
require_region_source 'struct IconHitTarget: View' 'struct HoverBackground' 'Color\(hex: "#333333"\)' 'inactive toolbar tab icons use dark neutral text in the default light theme'
require_region_source 'private func buildStatusItem\(\)' 'private func makeStatusMenu\(\) -> NSMenu' 'Bundle\.main\.url\(forResource: "AppIcon", withExtension: "icns"\)' 'menu bar toolbar icon keeps the original app icon artwork'
require_region_source 'private func buildStatusItem\(\)' 'private func makeStatusMenu\(\) -> NSMenu' 'NSImage\(contentsOf: iconURL\)' 'menu bar toolbar icon loads the original icon resource'
require_region_source 'private func buildStatusItem\(\)' 'private func makeStatusMenu\(\) -> NSMenu' 'icon\.isTemplate = true' 'menu bar toolbar icon uses macOS template tinting'
reject_source 'whiteStatusBarIcon' 'status bar icon should not be manually rasterized as white'
reject_source 'fill\(using: \.sourceIn\)' 'status bar icon should not hard-code white pixels'
reject_region_source 'private func buildStatusItem\(\)' 'private func makeStatusMenu\(\) -> NSMenu' 'contentTintColor = \.white' 'menu bar toolbar icon should not rely on system tinting'
reject_region_source 'private func buildStatusItem\(\)' 'private func makeStatusMenu\(\) -> NSMenu' 'NSImage\(systemSymbolName:' 'menu bar toolbar icon should not switch to a different symbol'
require_source 'case image' 'image has a dedicated built-in tab'
require_region_source 'enum ClipTab: String, Codable, CaseIterable, Identifiable' 'struct CustomGroup' 'case image' 'image tab is part of the standard toolbar tabs'
require_region_source 'var visibleHistory: \[ClipboardEntry\]' 'var selectedEntry' 'case \.image: return entry\.kind == \.image \|\| isImageFileEntry\(entry\)' 'image tab includes image entries and copied image files'
require_region_source 'var visibleHistory: \[ClipboardEntry\]' 'var selectedEntry' 'case \.file: return entry\.kind == \.file && !isImageFileEntry\(entry\)' 'file tab excludes image file entries'
require_region_source 'func count\(for tab: ClipTab\)' 'func showOverlay' 'case \.image: return history\.filter \{ \$0\.kind == \.image \|\| isImageFileEntry\(\$0\) \}\.count' 'image tab count includes image entries and copied image files'
require_region_source 'func count\(for tab: ClipTab\)' 'func showOverlay' 'case \.file: return history\.filter \{ \$0\.kind == \.file && !isImageFileEntry\(\$0\) \}\.count' 'file tab count excludes image file entries'
require_source 'private func isImageFileEntry\(_ entry: ClipboardEntry\) -> Bool' 'image file entries are detected separately from generic file entries'
require_region_source 'var symbol: String' 'struct CustomGroup' 'case \.image: return "photo"' 'image tab uses the photo icon'
reject_source 'defaultImageGroupID' 'images should not be modeled as an auto-created custom group'
reject_source 'defaultImageGroup' 'images should not be duplicated in custom groups'
reject_source 'syncDefaultImageGroup' 'image membership should come from the built-in image tab filter'
reject_source 'seedDefaultGroupsIfNeeded' 'built-in image tab should not depend on seeded custom groups'
reject_source 'shouldSeedDefaultGroups' 'built-in image tab should not depend on persisted custom group state'
require_source 'if let persistedCustomGroups = state\.customGroups' 'persisted empty custom groups are respected'
require_source 'entry\.kind == \.image' 'image tab logic only gathers image entries'
require_source 'showingGroupList = false' 'tab selection closes the group management page'
require_source 'showingAddGroup = false' 'tab selection closes the add group dialog'
require_source 'editingGroupID = nil' 'tab selection exits group editing state'
require_source 'onTapGesture \{ showingAddGroup = false \}' 'add group dialog can dismiss from the overlay'
require_source 'contentShape\(Rectangle\(\)\)' 'add group overlay uses hit testing without a visible square backdrop'
require_source '\.background\(\.regularMaterial\)' 'add group dialog uses a glass material base'
require_source '\.background\(groupSecondaryBackground\)' 'add group dialog uses the high-opacity derived secondary background'
require_source 'secondarySurfaceBackground\(theme: model\.settings\.selectedCustomTheme, colorScheme: colorScheme\)' 'group surfaces derive from the active theme and color scheme'
require_source 'mixAmount: colorScheme == \.dark \? 0\.10 : 0\.03' 'dark group surfaces are slightly lifted while light surfaces stay subtle'
require_source 'RoundedRectangle\(cornerRadius: 14, style: \.continuous\)' 'add group dialog uses rounded glass card corners'
require_source '\.padding\(20\)' 'add group dialog keeps outer padding without a border overlay'
require_source '@Environment\(\\.panelThemeColors\) private var theme' 'add group dialog and icon grid consume panel theme colors'
require_source 'private var groupThemeColors: PanelThemeColors' 'group manager window computes theme colors'
require_source '\.environment\(\\.panelThemeColors, groupThemeColors\)' 'group manager injects theme colors into children'
require_source '\.background\(groupBackground\)' 'group manager uses themed background'
require_source 'private var groupSecondaryBackground: Color' 'group dialog and edit mode share a secondary background'
require_source 'theme\.tertiaryFill' 'group UI backgrounds use third-level theme fill'
require_source 'theme\.itemSecondary' 'group UI secondary text uses themed secondary color'
require_source 'theme\.itemTitle' 'group UI titles use themed title color'
require_source 'theme\.primary' 'group UI active buttons use themed primary color'
require_source 'theme\.secondaryText' 'add group icon colors follow tab default colors'
require_source 'symbol == item \? \(theme\.primary \?\? Color\.accentColor\)\.opacity\(0\.18\) : Color\.clear' 'add group icon cells have no default background'
require_source 'groupSecondaryBackground' 'group manager edit mode uses the same secondary background as add group'
require_source 'groupThemeColors\.itemSecondary' 'group manager secondary text uses themed secondary color'
require_source 'groupThemeColors\.itemTitle' 'group manager titles use themed title color'
require_source 'groupThemeColors\.primary' 'group manager active buttons use themed primary color'
require_region_source 'private func groupListRow\(_ group: CustomGroup\)' 'private func resetAddGroup' 'groupRowBottomBorder\(color: groupBorderColor\)' 'inline group manager rows draw an inset bottom border'
require_region_source 'private func groupListRow\(_ group: CustomGroup\)' 'private func resetAddGroup' 'Image\(systemName: "arrow\.up\.arrow\.down"\)' 'inline group manager rows expose a drag handle'
require_region_source 'private var groupListPage: some View' 'private func groupListRow\(_ group: CustomGroup\)' 'GroupReorderDropDelegate' 'inline group manager rows reorder with the shared drop delegate'
require_region_source 'private func groupRow\(_ group: CustomGroup\)' 'struct SettingsView' 'groupRowBottomBorder\(color: groupBorderColor\)' 'window group manager rows draw an inset bottom border'
require_source 'private var groupBorderColor: Color' 'inline group manager computes border color from item title'
require_source 'return \(panelThemeColors\.itemTitle \?\? Color\.primary\)\.opacity\(0\.1\)' 'inline group borders use item title at 10 percent opacity'
require_source 'return \(groupThemeColors\.itemTitle \?\? Color\.primary\)\.opacity\(0\.1\)' 'window group borders use item title at 10 percent opacity'
require_region_source 'struct GroupManagerView: View' 'private func groupRow\(_ group: CustomGroup\)' 'GroupReorderDropDelegate' 'window group manager rows reorder with the shared drop delegate'
require_region_source 'struct GroupReorderDropDelegate: DropDelegate' 'struct TooltipState' 'dropEntered\(info: DropInfo\)' 'group reordering updates during drag hover like favorites'
require_region_source 'struct GroupReorderDropDelegate: DropDelegate' 'struct TooltipState' 'withAnimation\(\.spring\(response: 0\.24, dampingFraction: 0\.86\)\)' 'group reordering uses the same spring animation as favorite rows'
require_source 'draftSymbol == item \? \(groupThemeColors\.primary \?\? Color\.accentColor\)\.opacity\(0\.18\) : Color\.clear' 'group manager edit icon cells only show background for the active icon'
require_region_source 'if editingGroupID == group\.id \{' '\} else \{' '\.background\(groupSecondaryBackground\)' 'group manager edit rows show the same secondary background as add group'
require_region_source 'TextField\(L10n\.groupName, text: \$editingGroupName\)' 'GroupIconGrid' '\.textFieldStyle\(\.plain\)' 'inline group manager edit text field avoids its own filled input background'
require_region_source 'TextField\(L10n\.groupName, text: \$editingGroupName\)' 'GroupIconGrid' '\.foregroundStyle\(panelThemeColors\.itemTitle \?\? Color\.primary\)' 'inline group manager edit text field uses item title text color'
require_region_source 'TextField\(L10n\.groupName, text: \$draftName\)' 'Button\(L10n\.done\)' '\.textFieldStyle\(\.plain\)' 'group manager edit text field avoids its own filled input background'
require_region_source 'TextField\(L10n\.groupName, text: \$draftName\)' 'Button\(L10n\.done\)' '\.foregroundStyle\(groupThemeColors\.itemTitle \?\? Color\.primary\)' 'group manager edit text field uses item title text color'
require_source 'IconButton\(symbol: "pencil", help: L10n\.edit, compact: true, quiet: true' 'inline group manager edit action has no icon background'
require_source 'IconButton\(symbol: "trash", help: L10n\.delete, compact: true, quiet: true' 'inline group manager delete action has no icon background'
reject_region_source 'private func groupListRow\(_ group: CustomGroup\)' 'private func resetAddGroup' '\.background\(rowHoverBackground' 'inline group manager normal rows should not draw row hover backgrounds'
reject_region_source 'private func groupListRow\(_ group: CustomGroup\)' 'private func resetAddGroup' '\.background\(panelThemeColors\.tertiaryFill' 'inline group manager normal row icons should not draw filled backgrounds'
reject_region_source 'Image\(systemName: "arrow\.up\.arrow\.down"\)' '\.padding\(\.vertical, 9\)' '\.buttonStyle\(\.borderless\)' 'window group manager row actions should not use button styles that can draw item-like backgrounds'
reject_source 'Color\.black\.opacity\(colorScheme == \.dark \? 0\.24 : 0\.10\)' 'add group overlay should not draw square translucent corners'
reject_source 'groupSecondaryBackground\.opacity\(0\.95\)' 'add group dialog should not multiply an already translucent secondary color'
reject_source '\.background\(groupRowBackground\)' 'normal group manager rows should not have a filled background'
reject_source '\.background\(groupIconBackground\)' 'normal group manager row icons should not create an item-like fill'

echo "group tab navigation regression checks passed"
