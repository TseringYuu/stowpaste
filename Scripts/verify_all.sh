#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "$0")" && pwd)/lib/paths.sh"

"$ROOT/Scripts/verify_accessibility_authorization.sh"
"$ROOT/Scripts/verify_app_store_compliance.sh"
"$ROOT/Scripts/verify_distribution_docs.sh"
"$ROOT/Scripts/verify_ai_custom_themes.sh"
"$ROOT/Scripts/verify_aiware_standards.sh"
"$ROOT/Scripts/verify_app_naming.sh"
"$ROOT/Scripts/verify_configurable_hotkey.sh"
"$ROOT/Scripts/verify_editing_shortcuts.sh"
"$ROOT/Scripts/verify_focus_preservation.sh"
"$ROOT/Scripts/verify_group_tab_navigation.sh"
"$ROOT/Scripts/verify_history_row_hit_area.sh"
"$ROOT/Scripts/verify_installer.sh"
"$ROOT/Scripts/verify_public_artifact.sh"
"$ROOT/Scripts/verify_media_rows.sh"
"$ROOT/Scripts/verify_memory_budget.sh"
"$ROOT/Scripts/verify_monorepo.sh"
"$ROOT/Scripts/verify_no_client_network.sh"
"$ROOT/Scripts/verify_panel_open_stability.sh"
"$ROOT/Scripts/verify_packaging_architecture.sh"
"$ROOT/Scripts/verify_pinned_panel_targeting.sh"
"$ROOT/Scripts/verify_project_structure.sh"
"$ROOT/Scripts/verify_relative_time.sh"
"$ROOT/Scripts/verify_retention_policy.sh"
"$ROOT/Scripts/verify_settings_panel.sh"
"$ROOT/Scripts/verify_system_theme.sh"
"$ROOT/Scripts/verify_website.sh"

swift build --package-path "$APP_PACKAGE_DIR" ${SWIFT_BUILD_FLAGS:-}
swift test --package-path "$APP_PACKAGE_DIR" ${SWIFT_BUILD_FLAGS:-}

echo "all checks passed"
