#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "$0")" && pwd)/lib/paths.sh"

ENTITLEMENTS="$APP_RESOURCES_DIR/StowPaste.entitlements"
APP_BINARY="${STOWPASTE_APP_BINARY:-}"
BUILD_PATH="${SWIFT_BUILD_PATH:-}"

reject_text() {
  local file="$1"
  local pattern="$2"
  local message="$3"
  if grep -Eq "$pattern" "$file"; then
    echo "Unexpected: $message" >&2
    grep -En "$pattern" "$file" >&2 || true
    exit 1
  fi
}

reject_tree() {
  local path="$1"
  local pattern="$2"
  local message="$3"
  if grep -REq "$pattern" "$path"; then
    echo "Unexpected: $message" >&2
    grep -REn "$pattern" "$path" >&2 || true
    exit 1
  fi
}

require_text() {
  local file="$1"
  local pattern="$2"
  local message="$3"
  if ! grep -Eq "$pattern" "$file"; then
    echo "Missing: $message" >&2
    exit 1
  fi
}

FORBIDDEN_NETWORK_SOURCE_PATTERN='URLRequest|NWConnection|NWListener|NWTCPConnection|WebSocket|NSURLConnection|grpc|GRPC|chat/completions|x-stowpaste-upgrade-token|AIChatClient|StowPasteAIServiceClient'
REMOTE_URL_PATTERN='https://api\.openai\.com|https://stowpaste\.aiware\.store/api|chat/completions|x-stowpaste-upgrade-token'

reject_text "$APP_SOURCE" "$FORBIDDEN_NETWORK_SOURCE_PATTERN" 'StowPaste client source must not contain general networking or remote AI clients'
reject_text "$APP_SOURCE" 'TranslationModelManager|OfflineTranslationProvider|StowPasteTranslationModelsURL' 'translation implementation must be absent'
reject_text "$ENTITLEMENTS" 'com\.apple\.security\.network\.client' 'local-only desktop app must not enable outbound network access'
reject_tree "$APP_RESOURCES_DIR" "$REMOTE_URL_PATTERN" 'StowPaste app resources must not contain remote AI endpoints'

if [[ -n "$APP_BINARY" && -f "$APP_BINARY" ]]; then
  if strings "$APP_BINARY" | grep -Eq "$REMOTE_URL_PATTERN"; then
    echo "Unexpected: StowPaste binary contains remote AI network markers" >&2
    strings "$APP_BINARY" | grep -E "$REMOTE_URL_PATTERN" >&2 || true
    exit 1
  fi
fi

swift build --package-path "$APP_PACKAGE_DIR" ${SWIFT_BUILD_FLAGS:-} >/dev/null
if [[ -z "$BUILD_PATH" ]]; then
  BUILD_PATH="$(swift build --package-path "$APP_PACKAGE_DIR" ${SWIFT_BUILD_FLAGS:-} --show-bin-path)"
fi

LOG="$(mktemp)"
TEST_HOME="$(mktemp -d)"
trap 'rm -f "$LOG"; rm -rf "$TEST_HOME"' EXIT
mkdir -p "$TEST_HOME/Library/Application Support"

STOWPASTE_APPLICATION_SUPPORT_DIR="$TEST_HOME/Library/Application Support" STOWPASTE_PANEL_SMOKE_TEST=1 STOWPASTE_PANEL_FOCUS_SMOKE_TEST=1 "$BUILD_PATH/StowPaste" >"$LOG" 2>&1 &
APP_PID=$!
NETWORK_CAPTURE=""

for _ in {1..12}; do
  if ! kill -0 "$APP_PID" 2>/dev/null; then
    break
  fi
  SAMPLE="$(lsof -nP -a -p "$APP_PID" -i 2>/dev/null | sed '1d' || true)"
  if [[ -n "$SAMPLE" ]]; then
    NETWORK_CAPTURE+="$SAMPLE"$'\n'
  fi
  sleep 0.12
done

if ! wait "$APP_PID"; then
  cat "$LOG" >&2
  echo "Unexpected: no-network runtime smoke app exited unsuccessfully" >&2
  exit 1
fi

if [[ -n "$NETWORK_CAPTURE" ]]; then
  cat "$LOG" >&2
  echo "Unexpected: StowPaste opened network sockets during runtime capture" >&2
  printf "%s" "$NETWORK_CAPTURE" >&2
  exit 1
fi

if ! grep -q 'panel smoke test visible' "$LOG"; then
  cat "$LOG" >&2
  echo "Unexpected: no-network runtime capture did not exercise the app smoke path" >&2
  exit 1
fi

echo "desktop network boundary passed: no entitlement and 0 runtime sockets"
