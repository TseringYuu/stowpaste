#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DISPLAY_NAME="StowPaste"
APP_VERSION="0.1.0"
PKG_VERSION="0.1.0"
DIST_DIR="$ROOT_DIR/dist"
APP_DIR="$DIST_DIR/$DISPLAY_NAME.app"
PKG_ROOT="$DIST_DIR/pkg-root"
COMPONENT_PKG="${TMPDIR:-/tmp}/${DISPLAY_NAME}_component.pkg"
INSTALLER_PKG="$DIST_DIR/${DISPLAY_NAME}_${APP_VERSION}_universal.pkg"
TMP_INSTALLER_PKG="${TMPDIR:-/tmp}/${DISPLAY_NAME}_${APP_VERSION}_universal.pkg"
SCRIPTS_DIR="$ROOT_DIR/Scripts/installer"

export COPYFILE_DISABLE=1
"$ROOT_DIR/Scripts/build_app.sh" >/dev/null

rm -rf "$PKG_ROOT" "$COMPONENT_PKG" "$INSTALLER_PKG" "$TMP_INSTALLER_PKG"
mkdir -p "$PKG_ROOT"
ditto --noextattr --noacl "$APP_DIR" "$PKG_ROOT/$DISPLAY_NAME.app"
xattr -cr "$PKG_ROOT" 2>/dev/null || true
find "$PKG_ROOT" -name ".DS_Store" -delete
find "$PKG_ROOT" -name "._*" -delete

pkgbuild \
  --root "$PKG_ROOT" \
  --identifier "store.aiware.stowpaste.pkg" \
  --version "$PKG_VERSION" \
  --install-location /Applications \
  --scripts "$SCRIPTS_DIR" \
  "$COMPONENT_PKG" >/dev/null

productbuild \
  --package "$COMPONENT_PKG" \
  "$TMP_INSTALLER_PKG" >/dev/null

mv "$TMP_INSTALLER_PKG" "$INSTALLER_PKG"

rm -rf "$PKG_ROOT" "$COMPONENT_PKG" "$TMP_INSTALLER_PKG"
echo "$INSTALLER_PKG"
