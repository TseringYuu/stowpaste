#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "$0")" && pwd)/lib/paths.sh"

APP_SOURCE="$APP_SOURCE"

reject_text() {
  local file="$1"
  local pattern="$2"
  local message="$3"
  if grep -Eq "$pattern" "$file"; then
    echo "Forbidden: $message" >&2
    exit 1
  fi
}

reject_tree() {
  local path="$1"
  local pattern="$2"
  local message="$3"
  if grep -REq "$pattern" "$path"; then
    echo "Forbidden: $message" >&2
    grep -REn "$pattern" "$path" >&2
    exit 1
  fi
}

if [[ -d "$WEBSITE_PACKAGE_DIR/app/api/v1/ai" ]]; then
  echo "Forbidden: removed AI upgrade-pack website API directory must not exist" >&2
  find "$WEBSITE_PACKAGE_DIR/app/api/v1/ai" -type f >&2
  exit 1
fi

for removed_file in "$WEBSITE_PACKAGE_DIR/lib/platform-ai.ts" "$WEBSITE_PACKAGE_DIR/lib/upgrade-quota.ts"; do
  if [[ -e "$removed_file" ]]; then
    echo "Forbidden: removed AI upgrade-pack website library exists: $removed_file" >&2
    exit 1
  fi
done

reject_tree "$WEBSITE_PACKAGE_DIR/app" 'x-stowpaste-upgrade-token|upgrade_quota|ai_upgrade_pack|chat/completions|STOWPASTE_AI_API_KEY|STOWPASTE_AI_BASE_URL|STOWPASTE_AI_MODEL|STOWPASTE_PLATFORM_AI_GRPC_TARGET' 'website app must not expose removed AI upgrade-pack APIs or remote AI provider configuration'
reject_tree "$WEBSITE_PACKAGE_DIR/lib" 'x-stowpaste-upgrade-token|upgrade_quota|ai_upgrade_pack|chat/completions|STOWPASTE_AI_API_KEY|STOWPASTE_AI_BASE_URL|STOWPASTE_AI_MODEL|STOWPASTE_PLATFORM_AI_GRPC_TARGET' 'website shared libraries must not expose removed AI upgrade-pack APIs or remote AI provider configuration'

reject_text "$APP_SOURCE" 'chat/completions|x-stowpaste-upgrade-token|AIChatClient|StowPasteAIServiceClient|STOWPASTE_AI_API_KEY|STOWPASTE_AI_BASE_URL' 'StowPaste client must not contain remote AI client code'
for removed_path in \
  "$APP_RESOURCES_DIR/OfflineTranslation" \
  "$APP_RESOURCES_DIR/StowPasteRecommendationRanker.json" \
  "$ROOT/tools/recommendation"; do
  if [[ -e "$removed_path" ]]; then
    echo "Forbidden: retired feature path exists: $removed_path" >&2
    exit 1
  fi
done
if grep -Eq 'startSmartContextRefreshTimer|smartContextRefreshTimer' "$APP_SOURCE"; then
  echo "Forbidden: current build must not poll retired recommendation context" >&2
  exit 1
fi
if grep -Eq 'TranslationModelManager|OfflineTranslationProvider|TranslationPanelContent|SmartPasteExtractor|LocalClipboardRecommender|SmartPasteModeView' "$APP_SOURCE"; then
  echo "Forbidden: current source contains retired recommendation or translation implementation" >&2
  exit 1
fi
if grep -Eq 'settingsValueRow\(L10n\.(smartRecommendations|keepImportantInformation)' "$APP_SOURCE"; then
  echo "Forbidden: current build must not expose retired recommendation settings" >&2
  exit 1
fi

echo "retired feature checks passed"
