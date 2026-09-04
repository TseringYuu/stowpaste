#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "$0")" && pwd)/lib/paths.sh"

verify_dmg() (
  set -euo pipefail

  local dmg_name="$1"
  local dmg="$WEBSITE_PACKAGE_DIR/public/downloads/$dmg_name"
  local checksum_file="$dmg.sha256"

  if [[ ! -f "$dmg" || ! -f "$checksum_file" ]]; then
    echo "Missing: public $dmg_name or checksum" >&2
    exit 1
  fi

  local expected_sha actual_sha
  expected_sha="$(awk 'NR == 1 { print $1 }' "$checksum_file")"
  actual_sha="$(shasum -a 256 "$dmg" | awk '{ print $1 }')"
  if [[ "$expected_sha" != "$actual_sha" ]]; then
    echo "Unexpected: $dmg_name checksum does not match its checksum file" >&2
    exit 1
  fi

  local audit_dir mount_point
  audit_dir="$(mktemp -d)"
  mount_point="$audit_dir/mount"
  mkdir -p "$mount_point"
  cleanup() {
    hdiutil detach "$mount_point" >/dev/null 2>&1 || true
    rm -rf "$audit_dir"
  }
  trap cleanup EXIT

  hdiutil verify "$dmg" >/dev/null
  hdiutil attach -readonly -nobrowse -mountpoint "$mount_point" "$dmg" >/dev/null
  local app_path="$mount_point/StowPaste.app"

  if [[ ! -d "$app_path" ]]; then
    echo "Missing: StowPaste.app in $dmg_name" >&2
    exit 1
  fi
  if [[ ! -L "$mount_point/Applications" || "$(readlink "$mount_point/Applications")" != "/Applications" ]]; then
    echo "Missing: Applications shortcut in $dmg_name" >&2
    exit 1
  fi
  if [[ ! -f "$mount_point/.background/dmg-background.png" ]]; then
    echo "Missing: localized installation background in $dmg_name" >&2
    exit 1
  fi
  if [[ ! -f "$mount_point/.DS_Store" ]]; then
    echo "Missing: Finder window layout in $dmg_name" >&2
    exit 1
  fi

  local signature
  signature="$(codesign -dv --verbose=4 "$app_path" 2>&1 || true)"
  if ! grep -Eq '^Signature=adhoc$' <<<"$signature"; then
    echo "Unexpected: public app in $dmg_name is not identity-free ad-hoc signed" >&2
    exit 1
  fi
  if grep -Eq '^Authority=' <<<"$signature" || grep -E '^TeamIdentifier=' <<<"$signature" | grep -Fqv 'TeamIdentifier=not set'; then
    echo "Unexpected: public app in $dmg_name exposes a signing identity" >&2
    exit 1
  fi

  local app_binary="$app_path/Contents/MacOS/StowPaste"
  if rg -a -q '/Users/|/Volumes/|icloud\.com|-----BEGIN .*PRIVATE KEY-----' "$app_binary"; then
    echo "Unexpected: public app binary in $dmg_name contains a local path or private identity marker" >&2
    exit 1
  fi
  if ! file "$app_binary" | grep -Eq 'x86_64.*arm64|arm64.*x86_64'; then
    echo "Unexpected: public app in $dmg_name is not universal" >&2
    exit 1
  fi
)

verify_dmg "StowPaste-v0.1.0.dmg"
verify_dmg "StowPaste-v0.1.0-zh-CN.dmg"

echo "public artifact checks passed"
