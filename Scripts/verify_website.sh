#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "$0")" && pwd)/lib/paths.sh"

require_file() {
  local path="$1"
  local message="$2"
  if [[ ! -f "$WEBSITE_PACKAGE_DIR/$path" ]]; then
    echo "Missing: $message" >&2
    exit 1
  fi
}

require_text() {
  local path="$1"
  local pattern="$2"
  local message="$3"
  if ! grep -Eq "$pattern" "$WEBSITE_PACKAGE_DIR/$path"; then
    echo "Missing: $message" >&2
    exit 1
  fi
}

require_file "package.json" "website package manifest"
require_file "app/layout.tsx" "Next.js root layout"
require_file "app/page.tsx" "website homepage"
require_file "app/docs/page.tsx" "documentation page"
require_file "app/api/health/route.ts" "health backend API"
require_file "app/api/downloads/route.ts" "downloads backend API"
require_file "app/api/feedback/route.ts" "feedback backend API"
require_file "app/privacy/page.tsx" "privacy policy page"
require_file "app/sitemap.ts" "SEO sitemap"
require_file "app/robots.ts" "SEO robots"
require_file "app/opengraph-image.tsx" "OpenGraph image route"
require_text "app/layout.tsx" 'metadataBase' "SEO metadata base"
require_text "app/layout.tsx" 'openGraph' "OpenGraph metadata"
require_text "app/layout.tsx" 'twitter' "Twitter card metadata"
require_text "components/seo-json-ld.tsx" 'SoftwareApplication' "software JSON-LD"
require_text "app/page.tsx" 'LocalizedDownloadLink' "homepage has a browser-localized DMG download action"
require_text "components/localized-download.tsx" 'navigator\.languages' "download locale follows the browser's preferred language"
require_text "components/localized-download.tsx" '\^zh' "Chinese browser locales select the Chinese DMG"
require_text "lib/site.ts" 'downloadUrlZhCN' "website publishes a Chinese DMG URL"
require_text "lib/site.ts" 'checksumSha256ZhCN' "website publishes the Chinese DMG checksum"
require_text "app/page.tsx" 'Download DMG' "homepage explicit download label"
require_text "app/page.tsx" 'data-paper-field' "homepage WebGL paper field"
require_text "components/site-header.tsx" 'GitHubLink' "header includes the GitHub repository entry"
require_text "components/github-link.tsx" 'stargazers_count' "GitHub entry displays the current star count"
require_text "lib/site.ts" 'githubUrl' "website has the public repository URL"
if grep -Eq 'hero-utility-links' "$WEBSITE_PACKAGE_DIR/app/page.tsx"; then
  echo "Unexpected: homepage still includes the retired lower-right utility buttons" >&2
  exit 1
fi
require_text "app/docs/page.tsx" 'Install and authorize' "docs installation section"
require_text "app/docs/page.tsx" 'Themes and retention' "docs theme and retention section"
require_text "tailwind.config.ts" 'fontFamily' "intentional typography configuration"

RETIRED_COPY_PATTERN='(^|[^[:alnum:]_])lite([^[:alnum:]_]|$)|app[[:space:]-]*store|recommend(ation|ations)?|translation(s)?'
if grep -RiqE "$RETIRED_COPY_PATTERN" "$WEBSITE_PACKAGE_DIR" --exclude-dir=node_modules --exclude-dir=.next --exclude='*.pkg' --exclude='*.dmg'; then
  echo "Unexpected: website contains retired product positioning" >&2
  grep -RinE "$RETIRED_COPY_PATTERN" "$WEBSITE_PACKAGE_DIR" --exclude-dir=node_modules --exclude-dir=.next --exclude='*.pkg' --exclude='*.dmg' >&2
  exit 1
fi

require_file "public/downloads/StowPaste-v0.1.1.dmg" "current DMG download artifact"
require_file "public/downloads/StowPaste-v0.1.1.dmg.sha256" "current DMG checksum"
require_file "public/downloads/StowPaste-v0.1.1-zh-CN.dmg" "current Chinese DMG download artifact"
require_file "public/downloads/StowPaste-v0.1.1-zh-CN.dmg.sha256" "current Chinese DMG checksum"
if [[ -e "$WEBSITE_PACKAGE_DIR/public/downloads/StowPaste-v0.1.1.pkg" ]]; then
  echo "Unexpected: retired PKG remains in the website download directory" >&2
  exit 1
fi

if [[ -d "$WEBSITE_PACKAGE_DIR/app/api/v1/ai" ]]; then
  echo "Unexpected: website AI upgrade-pack backend API directory must not be present" >&2
  find "$WEBSITE_PACKAGE_DIR/app/api/v1/ai" -type f >&2
  exit 1
fi

for removed_file in "$WEBSITE_PACKAGE_DIR/lib/platform-ai.ts" "$WEBSITE_PACKAGE_DIR/lib/upgrade-quota.ts"; do
  if [[ -e "$removed_file" ]]; then
    echo "Unexpected: website AI upgrade-pack support library must not be present: $removed_file" >&2
    exit 1
  fi
done

if [[ -d "$WEBSITE_PACKAGE_DIR/node_modules" || -d "$ROOT/node_modules" ]]; then
  npm --workspace @stowpaste/website run typecheck
else
  echo "website dependencies not installed; skipped npm typecheck"
fi

echo "website regression checks passed"
