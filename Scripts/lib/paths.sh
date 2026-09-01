#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
APP_PACKAGE_DIR="$ROOT/packages/app"
APP_SOURCE="$APP_PACKAGE_DIR/Sources/StowPaste/StowPaste.swift"
APP_RESOURCES_DIR="$APP_PACKAGE_DIR/Resources"
WEBSITE_PACKAGE_DIR="$ROOT/packages/website"
