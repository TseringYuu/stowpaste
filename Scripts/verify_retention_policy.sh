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

require_source 'enum HistoryRetentionPeriod: String, Codable, CaseIterable, Identifiable' 'history retention is represented as a persisted time period'
require_source 'var historyRetentionPeriod: HistoryRetentionPeriod = \.quarter' 'default retention is one quarter'
require_source 'case week' 'one week retention option exists'
require_source 'case month' 'one month retention option exists'
require_source 'case quarter' 'one quarter retention option exists'
require_source 'case halfYear' 'half year retention option exists'
require_source 'case year' 'one year retention option exists'
require_source 'case threeYears' 'three year retention option exists'
require_source 'case unlimited' 'unlimited retention option exists'
require_source 'Calendar\.current\.date\(byAdding: \.month, value: -3' 'quarter retention uses a three month cutoff'
require_source 'func isShorter\(than other: HistoryRetentionPeriod\) -> Bool' 'retention periods can detect when the user narrows the time range'
require_source 'Picker\("", selection: historyRetentionSelection\)' 'settings intercept retention changes before applying them'
require_source '@State private var pendingHistoryRetentionPeriod: HistoryRetentionPeriod\?' 'settings stores the pending narrower retention selection'
require_source '@State private var showingHistoryRetentionConfirmation = false' 'settings shows confirmation before narrowing retention'
require_source 'if next\.isShorter\(than: draft\.historyRetentionPeriod\)' 'narrower retention changes are intercepted'
require_source 'showingHistoryRetentionConfirmation = true' 'narrower retention changes request confirmation'
require_source 'confirmHistoryRetentionChange\(to period: HistoryRetentionPeriod\)' 'confirmed retention changes are applied explicitly'
require_source 'historyRetentionConfirmMessage' 'retention confirmation explains that old data can be removed'
require_source 'ForEach\(HistoryRetentionPeriod\.allCases\)' 'settings dropdown shows every retention period'
reject_source 'SettingsNumberField\(value: \$draft\.maxHistoryItems' 'history retention should no longer use a numeric item-count field'
reject_source 'max\(50, settings\.maxHistoryItems\)' 'history should no longer trim by item count'
require_region_source 'private func trimHistory\(\)' 'private func imageFileExists' 'protectedHistoryIDs\(\)' 'trim protects important history entries'
require_region_source 'private func trimHistory\(\)' 'private func imageFileExists' 'entry\.updatedAt < cutoff' 'trim removes ordinary entries older than the retention cutoff'
require_region_source 'private func trimHistory\(\)' 'private func imageFileExists' '-> Bool' 'trim reports whether it changed persisted history'
require_region_source 'private func protectedHistoryIDs\(\)' 'private func trimHistory\(\)' 'favoriteOrder' 'favorites are protected from retention cleanup'
require_region_source 'private func protectedHistoryIDs\(\)' 'private func trimHistory\(\)' 'pinnedTabs\.isEmpty' 'pinned entries are protected from retention cleanup'
require_region_source 'private func protectedHistoryIDs\(\)' 'private func trimHistory\(\)' 'customGroups\.flatMap.*itemIDs' 'custom group entries are protected from retention cleanup'
require_region_source 'private func load\(\)' 'private func migrateFavoritePins\(\)' 'let trimmedHistory = trimHistory\(\)' 'loaded history is immediately checked against the retention policy'
require_region_source 'private func load\(\)' 'private func migrateFavoritePins\(\)' 'if trimmedHistory \|\| migratedImages' 'startup retention cleanup is persisted when it changes history'

echo "history retention regression checks passed"
