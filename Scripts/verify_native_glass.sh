#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "$0")" && pwd)/lib/paths.sh"

GLASS_SOURCE="$APP_PACKAGE_DIR/Sources/StowPaste/GlassSurfaces.swift"

require_file_source() {
  local file="$1"
  local pattern="$2"
  local message="$3"
  if [[ ! -f "$file" ]] || ! grep -Eq "$pattern" "$file"; then
    echo "Missing: $message" >&2
    exit 1
  fi
}

require_file_source "$GLASS_SOURCE" 'struct NativeVisualEffectView: NSViewRepresentable' 'SwiftUI exposes a native AppKit visual effect bridge'
require_file_source "$GLASS_SOURCE" 'NSVisualEffectView\.Material = \.popover' 'the clipboard panel uses the semantic popover material'
require_file_source "$GLASS_SOURCE" 'NSVisualEffectView\.BlendingMode = \.behindWindow' 'the material samples the desktop and windows behind the panel'
require_file_source "$GLASS_SOURCE" '@Environment\(\\\.accessibilityReduceTransparency\)' 'glass surfaces honor Reduce Transparency'
require_file_source "$GLASS_SOURCE" '#available\(macOS 26\.0, \*\)' 'Liquid Glass is guarded for older supported systems'
require_file_source "$GLASS_SOURCE" 'content\.glassEffect\(' 'macOS 26 uses the native Liquid Glass effect'
require_file_source "$APP_SOURCE" 'AdaptivePanelBackground\(tint: panelTint\)' 'the floating clipboard panel uses the adaptive native material'
require_file_source "$APP_SOURCE" '\.adaptiveGlassSurface\(' 'the toolbar uses a dedicated glass functional layer'
require_file_source "$APP_SOURCE" '@Environment\(\\\.colorSchemeContrast\)' 'the panel border responds to Increase Contrast'
require_file_source "$APP_SOURCE" 'window\.backgroundColor = \.clear' 'secondary window content allows the native material to render'
require_file_source "$APP_SOURCE" 'Color\(nsColor: \.labelColor\)' 'settings use semantic macOS label colors'

echo "native glass regression checks passed"
