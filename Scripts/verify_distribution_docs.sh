#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "$0")" && pwd)/lib/paths.sh"

require_repo_text() {
  local file="$1"
  local pattern="$2"
  local message="$3"
  if ! grep -Eq "$pattern" "$ROOT/$file"; then
    echo "Missing: $message" >&2
    exit 1
  fi
}

reject_repo_text() {
  local file="$1"
  local pattern="$2"
  local message="$3"
  if grep -Eq "$pattern" "$ROOT/$file"; then
    echo "Unexpected: $message" >&2
    exit 1
  fi
}

require_website_text() {
  local file="$1"
  local pattern="$2"
  local message="$3"
  if ! grep -Eq "$pattern" "$WEBSITE_PACKAGE_DIR/$file"; then
    echo "Missing: $message" >&2
    exit 1
  fi
}

require_repo_text "README.zh-CN.md" 'docs/assets/readme-hero\.png' 'Chinese README includes the current product preview'
require_repo_text "README.zh-CN.md" 'StowPaste v0\.1\.0（PKG）' 'Chinese README has a prominent versioned download action'
require_repo_text "README.zh-CN.md" 'https://github\.com/TseringYuu/stowpaste/releases/download/v0\.1\.0/StowPaste-v0\.1\.0\.pkg' 'Chinese README links the published release PKG'
require_repo_text "README.zh-CN.md" 'macOS 14' 'Chinese README documents the minimum macOS version'
require_repo_text "README.zh-CN.md" 'Apple silicon.*Intel' 'Chinese README documents the universal architecture'
require_repo_text "README.zh-CN.md" '不需要账户' 'Chinese README states that no account is required'
require_repo_text "README.zh-CN.md" '保存在.*本机|保存在当前 Mac' 'Chinese README documents local storage'
require_repo_text "README.zh-CN.md" '不会把剪贴板内容上传到外部服务' 'Chinese README documents the clipboard network boundary'
require_repo_text "README.zh-CN.md" 'https://stowpaste\.aiware\.store/privacy' 'Chinese README links the privacy policy'
require_repo_text "README.zh-CN.md" 'Apache License 2\.0' 'Chinese README documents the open-source license'
require_repo_text "README.zh-CN.md" '仍要打开' 'Chinese README explains the per-app Gatekeeper exception'
require_repo_text "README.zh-CN.md" '未经.*公证|未.*公证' 'Chinese README discloses missing Apple notarization'
require_repo_text "README.zh-CN.md" 'https://github\.com/TseringYuu/stowpaste|CONTRIBUTING\.md' 'Chinese README points to the public project workflow'
reject_repo_text "README.zh-CN.md" 'Mac App Store|apps\.apple\.com|Lite|智能推荐|翻译|OpenAI|chat/completions|API Key|Endpoint' 'Chinese README must not expose unavailable distribution channels or absent features'

require_repo_text "README.md" 'docs/assets/readme-hero\.png' 'English README includes the current product preview'
require_repo_text "README.md" 'Download StowPaste v0\.1\.0 \(PKG\)' 'English README has a prominent versioned download action'
require_repo_text "README.md" 'https://github\.com/TseringYuu/stowpaste/releases/download/v0\.1\.0/StowPaste-v0\.1\.0\.pkg' 'English README links the published release PKG'
require_repo_text "README.md" 'macOS 14' 'English README documents the minimum macOS version'
require_repo_text "README.md" 'Apple silicon.*Intel' 'English README documents the universal architecture'
require_repo_text "README.md" 'requires no account' 'English README states that no account is required'
require_repo_text "README.md" 'stay in the current Mac' 'English README documents local storage'
require_repo_text "README.md" 'does not upload clipboard content to external services' 'English README documents the clipboard network boundary'
require_repo_text "README.md" 'https://stowpaste\.aiware\.store/privacy' 'English README links the privacy policy'
require_repo_text "README.md" 'Apache License 2\.0' 'English README documents the open-source license'
require_repo_text "README.md" 'Open Anyway' 'English README explains the per-app Gatekeeper exception'
require_repo_text "README.md" 'not notarized|notarized' 'English README discloses missing Apple notarization'
require_repo_text "README.md" 'https://github\.com/TseringYuu/stowpaste|CONTRIBUTING\.md' 'English README points to the public project workflow'
reject_repo_text "README.md" 'Mac App Store|apps\.apple\.com|Lite|recommendation|translation|OpenAI|chat/completions|API Key|Endpoint' 'English README must not expose unavailable distribution channels or absent features'

require_website_text "lib/site.ts" 'privacyUrl' 'website has a privacy policy URL'
require_website_text "components/site-header.tsx" 'privacyUrl' 'site header links privacy details'
require_website_text "components/install-guide.tsx" 'OPEN SOURCE / NOT NOTARIZED' 'website discloses missing Apple notarization before installation'
require_website_text "components/install-guide.tsx" 'Open Anyway' 'website explains the per-app Gatekeeper exception'
require_website_text "components/install-guide.tsx" 'checksumSha256' 'website publishes the installer checksum'
require_website_text "app/privacy/page.tsx" 'StowPaste privacy' 'website includes privacy page'
require_website_text "app/api/downloads/route.ts" 'versionTag' 'downloads API exposes a version tag'
require_website_text "app/api/downloads/route.ts" 'type: "pkg"' 'downloads API exposes the PKG artifact'
if grep -Eq 'appStoreUrl|artifacts: \["app-store"\]' "$WEBSITE_PACKAGE_DIR/app/api/downloads/route.ts"; then
  echo "Unexpected: downloads API still references the unavailable App Store" >&2
  exit 1
fi

echo "distribution documentation regression checks passed"
