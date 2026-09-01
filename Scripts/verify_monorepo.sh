#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "$0")" && pwd)/lib/paths.sh"

require_path() {
  local path="$1"
  local message="$2"
  if [[ ! -e "$ROOT/$path" ]]; then
    echo "Missing: $message" >&2
    exit 1
  fi
}

reject_path() {
  local path="$1"
  local message="$2"
  if [[ -e "$ROOT/$path" ]]; then
    echo "Unexpected: $message" >&2
    exit 1
  fi
}

require_path "package.json" "root npm workspace manifest"
require_path "packages/app/Package.swift" "Swift app package"
require_path "packages/website/package.json" "website package"
require_path "Scripts/lib/paths.sh" "shared script path helper"
reject_path "Package.swift" "root Swift manifest after monorepo migration"
reject_path "Sources" "root Swift sources after monorepo migration"
reject_path "Resources" "root app resources after monorepo migration"

echo "monorepo regression checks passed"
