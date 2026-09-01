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

require_source 'private let imageStoreDirectory: URL' 'image originals live in a disk-backed store'
require_source 'imageThumbnailPNG' 'history rows use small image thumbnails'
require_source 'imagePNG = nil' 'large inline image data is stripped from history entries'
require_source 'history: history\.map\(entryForSaving\)' 'persisted state strips inline image payloads before encoding'
require_source 'migrateImagePayloadsToDisk\(\)' 'legacy inline image payloads migrate to disk'
require_source 'loadImageData\(for: entry\)' 'image paste loads original image bytes only on demand'
require_source 'pruneImageStore\(\)' 'unused image files are cleaned up'
require_source 'imageFileExists\(' 'migration verifies image files exist before stripping inline payloads'
require_source 'persistImageData\(imagePNG, preferredName: history\[index\]\.imageFileName\)' 'migration backfills missing disk image files from legacy inline payloads'
require_source 'STOWPASTE_STATE_MIGRATION_CHECK' 'state migration can be verified without launching the app UI'
require_source 'private var settingsWindow: NSWindow\?' 'settings window is lazy to reduce idle memory'
require_source 'private var groupWindow: NSPanel\?' 'group manager window is lazy to reduce idle memory'
require_source 'private var panel: ClipboardPanel\?' 'paste panel is lazy to reduce idle memory before first use'
require_source 'private func ensurePanel\(\) -> ClipboardPanel' 'paste panel is created only when it is shown or manipulated'
require_source 'private func releasePanelIfIdle\(\)' 'hidden non-pinned paste panel releases its SwiftUI view tree'
require_source 'panel\?\.contentView = nil' 'releasing the paste panel drops retained SwiftUI row state'
require_region_source 'func hidePanel\(\)' 'func hidePanelIfAllowed\(\)' 'releasePanelIfIdle\(\)' 'hidden paste panels trigger idle release when dismissed'
require_source 'malloc_zone_pressure_relief\(nil, 0\)' 'released panel memory is returned to the allocator promptly'
require_source 'private let relativeTimeTimer' 'history rows share one relative-time refresh timer'
require_source 'let now: Date' 'history rows receive shared relative-time state'
require_source 'now: now' 'history rows receive shared relative-time state from the panel'
reject_region_source 'func applicationDidFinishLaunching' 'func applicationWillTerminate' 'buildSettingsWindow\(\)' 'settings window should not be built during app launch'
reject_region_source 'func applicationDidFinishLaunching' 'func applicationWillTerminate' 'buildGroupWindow\(\)' 'group manager should not be built during app launch'
reject_region_source 'func applicationDidFinishLaunching' 'func applicationWillTerminate' 'buildPanel\(\)' 'paste panel should not be built during app launch'
reject_region_source 'private var imageThumbnail: some View' 'private var systemFileIcon' 'entry\.imagePNG' 'image thumbnails should not decode original image payloads'
reject_region_source 'struct RelativeTimeText' 'struct FavoriteDropDelegate' 'Timer\.publish' 'relative time should not create one timer per history row'

echo "memory budget regression checks passed"
