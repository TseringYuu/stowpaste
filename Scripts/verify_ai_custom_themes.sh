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

require_source_count_at_least() {
  local pattern="$1"
  local minimum="$2"
  local message="$3"
  local count
  count="$(grep -Ec "$pattern" "$SOURCE" || true)"
  if (( count < minimum )); then
    echo "Missing: $message" >&2
    exit 1
  fi
}

require_source 'struct CustomThemeSettings: Codable, Equatable, Identifiable' 'custom themes are persisted as settings'
require_source 'var customThemes: \[CustomThemeSettings\] = \[\]' 'app settings stores custom themes'
require_source 'LocalThemeGenerator' 'custom themes are generated locally'
require_source 'static func generateThemeOptions\(prompt: String\) -> \[AIThemeOption\]' 'local theme generator exposes prompt-based options'
require_source 'basePalette\(for: text\)' 'local theme generator derives palettes from prompt keywords'
require_source 'promptSeed' 'local theme generator derives a deterministic seed from any prompt'
require_source 'promptHueRotation' 'local theme generator changes palettes even for prompts without known keywords'
require_source 'rotatedHex' 'local theme generator rotates colors locally from the prompt seed'
require_source 'seededVariantAmount' 'local theme generator varies each proposal from the prompt seed'
require_source 'mixHex' 'local theme generator blends colors locally'
require_source 'ThemeProposalSheet' 'theme prompt and proposal sheet exists'
require_source 'TextEditor\(text: \$text\)' 'theme prompt uses an editable text editor'
require_source 'ForEach\(model\.themeOptions\)' 'multiple local color proposals are shown for confirmation'
require_source 'applyCustomTheme\(' 'selected local theme can be applied immediately'
require_source 'saveCustomTheme\(' 'selected local theme can be saved into the theme picker'
require_source 'deleteCustomTheme\(' 'saved custom themes can be deleted'
require_source 'var savedTheme = theme' 'saving a custom theme treats the proposal as a new saved theme'
require_source 'savedTheme\.id = UUID\(\)\.uuidString' 'saving a custom theme assigns a fresh id'
require_source 'DeleteCustomThemeButton' 'settings panel exposes a custom theme delete control'
require_source 'ThemePromptEditor' 'custom theme prompt editor handles keyboard submission'
require_source 'event\.keyCode == 36' 'pressing Enter in the custom theme prompt can submit generation'
require_source 'PanelThemeColors' 'clipboard panel receives custom theme colors'
require_source '\.environment\(\\.panelThemeColors, panelThemeColors\)' 'clipboard panel injects custom theme colors into child controls'
require_source 'neutralPalette\(for: theme, colorScheme: colorScheme\)' 'custom theme neutral colors are derived from actual theme background brightness'
require_source 'backgroundIsLight\(hex: backgroundHex\)' 'custom theme brightness detection decides light or dark neutrals'
require_source '\.foregroundStyle\(theme\.itemTitle \?\? Color\.primary\)' 'history item title uses the neutral title color'
require_source_count_at_least '\.foregroundStyle\(theme\.itemTitle \?\? Color\.primary\)' 2 'editing and non-editing history item titles use the same neutral title color'
require_source '\.foregroundStyle\(theme\.itemSecondary \?\? Color\.secondary\)' 'history body text uses the second-level neutral color'
require_source 'L10n\.customTheme' 'theme picker includes a custom theme option'
reject_source 'AIThemeGenerator|Theme names must use the current system language|systemPrompt|chat/completions' 'custom theme generation must not use remote AI prompts'
reject_source 'generateThemeOptions\(prompt: String, settings' 'theme generation must not require AI provider settings'
reject_source 'TranslatorSettings|AIConfiguration|AIChatClient|StowPasteAIServiceClient' 'theme generation must not depend on remote AI configuration'
reject_source 'next\.customThemes\[index\] = theme' 'saving custom themes should not replace existing themes'

echo "local custom theme regression checks passed"
