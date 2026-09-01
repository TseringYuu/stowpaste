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

require_source 'RelativeTimeFormatter\.relativeTime\(from: entry\.updatedAt, now: now\)' 'history rows render relative updated time'
require_source 'relativeTime\(from date: Date, now: Date' 'localized relative time formatter exists'
require_source 'static var justNow' 'just-now copy is localized'
require_source 'static var yesterday' 'yesterday copy is localized'
require_source 'static var dayBeforeYesterday' 'day-before-yesterday copy is localized'
require_source 'static var lastMonth' 'last-month copy is localized'
reject_source 'Text\(entry\.updatedAt, style: \.time\)' 'history rows should not use absolute clock time'

echo "relative time regression checks passed"
