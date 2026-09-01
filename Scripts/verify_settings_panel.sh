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

require_before() {
  local first_pattern="$1"
  local second_pattern="$2"
  local message="$3"
  local first_line
  local second_line
  first_line="$(grep -En "$first_pattern" "$SOURCE" | head -n 1 | cut -d: -f1 || true)"
  second_line="$(grep -En "$second_pattern" "$SOURCE" | head -n 1 | cut -d: -f1 || true)"
  if [[ -z "$first_line" || -z "$second_line" || "$first_line" -ge "$second_line" ]]; then
    echo "Missing: $message" >&2
    exit 1
  fi
}

require_source 'static var hotkey: String' 'hotkey label is shortened'
require_source 'Picker\("", selection: historyRetentionSelection\)' 'history retention uses an intercepted dropdown picker'
require_source '\.alert\(L10n\.historyRetentionConfirmTitle, isPresented: \$showingHistoryRetentionConfirmation\)' 'narrowing history retention asks for confirmation'
require_source 'Button\(L10n\.continueAction, role: \.destructive\)' 'history retention confirmation uses a destructive continue action'
require_source 'ForEach\(HistoryRetentionPeriod\.allCases\)' 'history retention picker shows every retention period'
require_source 'private let settingsLabelWidth: CGFloat' 'settings rows use a shared label column width'
require_source 'private let settingsControlWidth: CGFloat' 'right-side settings controls use a shared width'
require_source 'private let settingsRowMinHeight: CGFloat' 'settings rows use a shared minimum height'
require_source '\.frame\(width: settingsLabelWidth, alignment: \.leading\)' 'settings labels align to a fixed column'
require_source '\.frame\(maxWidth: \.infinity, minHeight: settingsRowMinHeight, alignment: \.center\)' 'settings rows expand so controls stay right aligned'
require_source 'settingsValueRow\(L10n\.historyLimit\)' 'history retention uses the shared settings row'
require_source 'settingsValueRow\(L10n\.theme\)' 'theme uses the shared settings row'
require_source 'settingsValueRow\(L10n\.hotkey\)' 'hotkey uses the shared settings row'
reject_source 'settingsValueRow\(L10n\.(smartRecommendations|keepImportantInformation)' 'lite settings must not expose removed intelligent features'
require_source 'settingsValueRow\(L10n\.launchAtLogin\)' 'launch at login setting is shown'
require_before 'DeleteCustomThemeButton\(themeID: selectedCustomThemeID, action: deleteSelectedCustomTheme\)' 'Picker\("", selection: themeSelection\)' 'theme delete button is placed to the left of the theme picker'
require_source 'SmallSwitchToggle\(isOn: Binding' 'launch at login uses the compact custom switch'
require_source 'struct SmallSwitchToggle: View' 'compact custom switch exists'
require_source '\.frame\(width: 30, height: 18\)' 'compact switch has a smaller fixed track size'
require_source '\.frame\(width: 14, height: 14\)' 'compact switch has a smaller knob'
require_source '\.padding\(2\)' 'compact switch uses even internal padding'
require_source '\.animation\(\.easeInOut\(duration: 0\.14\), value: isOn\)' 'compact switch animates state changes cleanly'
require_source '\.contentShape\(Capsule\(\)\)' 'compact switch hit area matches the capsule'
reject_source '\.toggleStyle\(\.switch\)' 'launch at login should not use the large system switch'
require_source 'SMAppService\.mainApp' 'launch at login uses macOS ServiceManagement'
require_source 'toggleLaunchAtLogin' 'launch at login can be toggled'
require_source 'SettingsInitialFocusGuard' 'settings panel clears the default text-field focus on first open'
require_source 'window\.makeFirstResponder\(nil\)' 'settings panel does not auto-focus the history limit input'
reject_source 'Button \{[[:space:]]*loadTranslatorConfig\(\)' 'settings should not show a load local config button'
reject_source 'Label\(L10n\.loadLocalConfig' 'settings should not show load local config copy'
reject_source 'NSOpenPanel' 'load local config should not open a file picker'
reject_source 'Text\(L10n\.ai\)|SettingsInlineHelpText\(help: L10n\.localAIHelp\)|Label\(L10n\.localAIHelp' 'settings panel must not show a standalone AI module'
require_source 'struct InlineHelpText' 'inline help view exists'
require_source 'private var settingsThemeColors: PanelThemeColors' 'settings panel reuses clipboard panel theme tokens'
require_source 'private var effectiveColorScheme: ColorScheme' 'settings panel derives colors from the selected app theme instead of the system theme'
require_source 'private var preferredSettingsColorScheme: ColorScheme\?' 'settings panel can force native controls to the custom theme brightness'
require_source 'backgroundIsLight\(hex: theme\.lightBackground\)' 'custom light themes force native settings controls into light mode'
require_source 'draft\.colorScheme \?\? preferredSettingsColorScheme \?\? systemAppearance\.colorScheme' 'settings panel falls back to real system appearance only after app and custom theme schemes'
require_source 'if let theme = draft\.selectedCustomTheme' 'settings panel previews draft custom theme colors immediately'
require_source 'neutralPalette\(for: theme, colorScheme: effectiveColorScheme\)' 'settings neutral colors follow the effective app color scheme'
require_source 'theme\.darkBackground : theme\.lightBackground' 'settings background follows the effective app color scheme'
require_source '\.environment\(\\.panelThemeColors, settingsThemeColors\)' 'settings panel injects theme tokens into child controls'
require_source '\.tint\(settingsThemeColors\.primary \?\? Color\.accentColor\)' 'settings controls use the themed primary tint'
require_source '\.foregroundStyle\(settingsThemeColors\.itemTitle \?\? Color\.primary\)' 'settings panel primary text follows themed title color'
require_source 'settingsThemeColors\.tertiaryFill' 'settings cards use the themed tertiary fill'
require_source '\.preferredColorScheme\(preferredSettingsColorScheme\)' 'settings panel applies custom theme brightness to native controls'
require_source 'SettingsInlineHelpText' 'settings help text uses themed secondary color'
reject_source 'TextField\(L10n\.providerName' 'provider name field is removed from settings'
reject_source 'customProviderSettings|aiModeTabs|UpgradePackStatusView|draft\.aiMode|draft\.translator|draft\.upgradePack' 'removed remote AI settings must not be shown'

echo "settings panel regression checks passed"
