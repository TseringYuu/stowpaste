#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "$0")" && pwd)/lib/paths.sh"

APP_STORE_BUILD="$ROOT/Scripts/build_app_store_archive.sh"
LOCAL_BUILD="$ROOT/Scripts/build_app.sh"
ENTITLEMENTS="$APP_PACKAGE_DIR/Resources/StowPaste.entitlements"
PRIVACY_MANIFEST="$APP_PACKAGE_DIR/Resources/PrivacyInfo.xcprivacy"
COMPLIANCE_DOC="$ROOT/docs/app-store-compliance.md"
DEVELOPMENT_DOC="$ROOT/docs/DEVELOPMENT.md"

require_path() {
  local path="$1"
  local message="$2"
  if [[ ! -e "$path" ]]; then
    echo "Missing: $message" >&2
    exit 1
  fi
}

require_file_source() {
  local file="$1"
  local pattern="$2"
  local message="$3"
  if ! grep -Eq -- "$pattern" "$file"; then
    echo "Missing: $message" >&2
    exit 1
  fi
}

require_path "$APP_STORE_BUILD" "Mac App Store archive/upload script"
require_path "$ENTITLEMENTS" "App Sandbox entitlements file"
require_path "$PRIVACY_MANIFEST" "privacy manifest file"
require_path "$COMPLIANCE_DOC" "App Store compliance documentation"

require_file_source "$LOCAL_BUILD" 'Developer ID Application' 'local direct-distribution build still supports Developer ID signing'
require_file_source "$LOCAL_BUILD" 'STOWPASTE_ALLOW_AD_HOC_SIGNING' 'local debug builds can still explicitly opt into ad-hoc signing'

require_file_source "$APP_STORE_BUILD" '3rd Party Mac Developer Application' 'App Store lane signs the app with Mac App Store application identity'
require_file_source "$APP_STORE_BUILD" '3rd Party Mac Developer Installer' 'App Store lane signs the upload package with Mac App Store installer identity'
require_file_source "$APP_STORE_BUILD" '--entitlements "\$ENTITLEMENTS"' 'App Store lane signs with sandbox entitlements'
require_file_source "$APP_STORE_BUILD" 'xcrun altool --upload-app' 'App Store lane can upload the package to App Store Connect'
require_file_source "$APP_STORE_BUILD" 'STOWPASTE_SKIP_APP_STORE_UPLOAD' 'App Store upload can be skipped for local archive verification'
require_file_source "$APP_STORE_BUILD" 'xcodebuild -version' 'App Store lane checks Xcode version'
require_file_source "$APP_STORE_BUILD" 'STOWPASTE_ALLOW_OLDER_XCODE' 'older Xcode override is explicit for local dry runs only'

require_file_source "$ENTITLEMENTS" 'com\.apple\.security\.app-sandbox' 'App Sandbox is enabled'
if grep -Eq 'com\.apple\.security\.network\.client' "$ENTITLEMENTS"; then
  echo "Unexpected: the current local-only app must not enable outbound network access" >&2
  exit 1
fi
require_file_source "$ENTITLEMENTS" 'com\.apple\.security\.files\.user-selected\.read-only' 'user-selected file read access is declared for clipboard file entries'
require_file_source "$ENTITLEMENTS" 'com\.apple\.security\.automation\.apple-events' 'Apple Events automation entitlement is declared for paste workflows'

require_file_source "$PRIVACY_MANIFEST" 'NSPrivacyCollectedDataTypes' 'privacy manifest declares collected data types'
require_file_source "$PRIVACY_MANIFEST" 'NSPrivacyTracking' 'privacy manifest declares tracking field'
require_file_source "$PRIVACY_MANIFEST" '<false/>' 'privacy manifest declares no tracking'

require_file_source "$COMPLIANCE_DOC" 'App Privacy Label Mapping' 'compliance doc includes App Privacy label mapping'
require_file_source "$COMPLIANCE_DOC" 'Privacy Policy URL' 'compliance doc includes privacy policy URL'
require_file_source "$COMPLIANCE_DOC" 'Third-party Recipients' 'compliance doc includes third-party recipients'
require_file_source "$COMPLIANCE_DOC" 'Current App Store status: not submitted and not listed' 'compliance doc records the real distribution status'
require_file_source "$COMPLIANCE_DOC" 'no network client entitlement' 'compliance doc records the desktop network boundary'
if grep -Eq 'macOS Translation|language-pack|language packs' "$COMPLIANCE_DOC"; then
  echo "Unexpected: compliance doc must not describe macOS Translation language packs as the production path" >&2
  exit 1
fi
require_file_source "$COMPLIANCE_DOC" 'Optional Mac App Store Build Lane' 'compliance doc includes the optional App Store build lane'
require_file_source "$DEVELOPMENT_DOC" 'build_app_store_archive\.sh' 'development guide documents the App Store archive/upload lane'

echo "App Store compliance regression checks passed"
