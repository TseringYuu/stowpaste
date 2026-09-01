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

reject_source 'startSmartContextRefreshTimer|smartContextRefreshTimer' 'current build must not poll retired recommendation context'
reject_source 'settingsValueRow\(L10n\.(smartRecommendations|keepImportantInformation)' 'current build must not expose retired recommendation settings'
reject_source 'TranslationPanelContent|SmartPasteModeView|SmartAISection|onTranslate' 'history rows must not contain retired feature UI'
require_source 'window\.collectionBehavior = \[\.managed, \.fullScreenNone\]' 'settings window stays in regular desktop spaces'
require_source 'imageThumbnail' 'image rows render a thumbnail'
require_source 'imageFileName' 'image entries store original images outside the in-memory history payload'
require_source 'imageThumbnailPNG' 'image entries keep only a small thumbnail in the row model'
require_source 'imageStoreDirectory' 'image originals are written to a disk-backed image store'
require_source 'persistImageData\(' 'clipboard image capture persists original image data to disk'
require_source 'migrateImagePayloadsToDisk\(\)' 'legacy inline image payloads migrate out of state.json'
require_source 'history: history\.map\(entryForSaving\)' 'state saving strips large image payloads from persisted history'
require_source 'loadImageData\(for: entry\)' 'image paste reads original image data only on demand'
require_source 'summaryContent' 'image thumbnail lives in the row body'
require_source 'NSWorkspace\.shared\.icon\(forFile:' 'file rows use the system file icon'
require_source 'struct ClipboardSource: Codable, Equatable' 'clipboard entries persist their source app'
require_source 'var source: ClipboardSource\?' 'clipboard entries can carry source app metadata'
require_source 'ClipboardSource\.currentCopySource\(\)' 'captured clipboard items record the current source app'
require_source 'func displayTitle\(for entry: ClipboardEntry\) -> String' 'history rows compute a source-aware title'
require_source 'sourceAppIcon' 'history rows show the copied-from app icon'
require_source 'sourceAppName' 'history rows show the copied-from app name'
require_source 'stackedFileIcon' 'multi-file rows render stacked icons'
require_source 'names\.prefix\(3\)' 'multi-file rows show at most three file names'

echo "media row regression checks passed"
